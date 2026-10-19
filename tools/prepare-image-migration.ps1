$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = 'F:/CNPM/QuanLyThuVien/src/QuanLyThuVien.App'
$static = Join-Path $root 'src/main/resources/static'
$snapshot = Get-Content (Join-Path $root 'database/before-image-migration.json') -Raw | ConvertFrom-Json
$manifest = foreach ($folder in @('books', 'authors')) {
    foreach ($file in Get-ChildItem (Join-Path $source $folder) -File) {
        $relative = "images/$folder/$($file.Name)"
        $destination = Join-Path $static $relative
        $hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
        if (!(Test-Path -LiteralPath $destination) -or (Get-FileHash $destination -Algorithm SHA256).Hash -ne $hash) {
            throw "Missing or different copy: $relative"
        }
        [pscustomobject]@{ Path = "/$relative"; Bytes = $file.Length; SHA256 = $hash }
    }
}
$manifest | Export-Csv (Join-Path $root 'docs/image-manifest.csv') -NoTypeInformation -Encoding utf8
$mappings = foreach ($spec in @(
    @{Table='Books'; Id='BookId'; Column='CoverImage'; Folder='books'},
    @{Table='Authors'; Id='AuthorId'; Column='AuthorPhoto'; Folder='authors'}
)) {
    foreach ($row in $snapshot.($spec.Table)) {
        $old = $row.($spec.Column)
        if ([string]::IsNullOrWhiteSpace($old)) { continue }
        $normal = $old.Replace('\','/').TrimStart('/')
        if (!$normal.StartsWith($spec.Folder + '/')) { throw "Unrecognized source path: $old" }
        $new = '/images/' + $normal
        [pscustomobject]@{
            Table=$spec.Table; IdColumn=$spec.Id; Id=$row.($spec.Id); Column=$spec.Column
            OldPath=$old; NewPath=$new; FileExists=(Test-Path -LiteralPath (Join-Path $static $new.TrimStart('/')))
        }
    }
}
$mappings | Export-Csv (Join-Path $root 'docs/image-path-mapping.csv') -NoTypeInformation -Encoding utf8
$mappings | Where-Object { !$_.FileExists } | Export-Csv (Join-Path $root 'docs/missing-images.csv') -NoTypeInformation -Encoding utf8
foreach ($direction in @('forward','rollback')) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("USE [WebsiteQuanLyCuaHangSachCu];`nSET NOCOUNT ON;`nSET XACT_ABORT ON;`nSET QUOTED_IDENTIFIER ON;`nSET ANSI_NULLS ON;`nSET ANSI_PADDING ON;`nSET ANSI_WARNINGS ON;`nSET ARITHABORT ON;`nSET CONCAT_NULL_YIELDS_NULL ON;`nSET NUMERIC_ROUNDABORT OFF;`nBEGIN TRANSACTION;`nBEGIN TRY")
    foreach ($map in $mappings) {
        $from = $map.OldPath.Replace("'", "''")
        $to = $map.NewPath.Replace("'", "''")
        if ($direction -eq 'rollback') { $temp=$from; $from=$to; $to=$temp }
        $table=$map.Table; $column=$map.Column; $idColumn=$map.IdColumn; $id=$map.Id
        $lines.Add("IF NOT EXISTS (SELECT 1 FROM dbo.[$table] WITH (UPDLOCK,HOLDLOCK) WHERE [$idColumn]=$id AND [$column] IN (N'$from',N'$to')) THROW 50001, 'Image path changed; review snapshot before retrying.', 1;")
        $lines.Add("UPDATE dbo.[$table] SET [$column]=N'$to' WHERE [$idColumn]=$id AND [$column]=N'$from';")
    }
    $lines.Add("COMMIT TRANSACTION;`nEND TRY`nBEGIN CATCH`nIF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;`nTHROW;`nEND CATCH;")
    $name = if ($direction -eq 'forward') { '001-update-image-paths.sql' } else { '001-rollback-image-paths.sql' }
    $lines | Set-Content (Join-Path $root "database/$name") -Encoding utf8
}
[pscustomobject]@{VerifiedFiles=@($manifest).Count; PathUpdates=@($mappings).Count; MissingFiles=@($mappings | Where-Object {!$_.FileExists}).Count}
