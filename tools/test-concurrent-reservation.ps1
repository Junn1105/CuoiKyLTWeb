# SQL-level concurrency test only; it does not implement an application checkout.
# Both successful inserts are rolled back. Never changes an existing reservation.
$ErrorActionPreference = 'Stop'
$connectionString = 'Server=localhost;Database=WebsiteQuanLyCuaHangSachCu;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=8'
$connectionA = [System.Data.SqlClient.SqlConnection]::new($connectionString)
$connectionB = [System.Data.SqlClient.SqlConnection]::new($connectionString)
$transactionA = $null
$transactionB = $null
$settings = 'SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF; SET XACT_ABORT OFF;'
$insert = @'
DECLARE @copy int, @order int;
SELECT @copy=i.CopyId,@order=i.OrderId
FROM dbo.OrderItems i JOIN dbo.Orders o ON o.OrderId=i.OrderId
WHERE o.OrderCode='DEMO-EXPIRED';
IF @copy IS NULL THROW 51400,'Missing expired-order fixture.',1;
INSERT dbo.StockReservations(CopyId,OrderId,Status,ReservedAt,ExpiresAt)
VALUES(@copy,@order,'ACTIVE',SYSUTCDATETIME(),DATEADD(minute,15,SYSUTCDATETIME()));
'@
try {
    $connectionA.Open()
    $connectionB.Open()
    foreach ($connection in @($connectionA,$connectionB)) {
        $command=$connection.CreateCommand()
        $command.CommandText=$settings
        $null=$command.ExecuteNonQuery()
        $command.Dispose()
    }
    $transactionA=$connectionA.BeginTransaction()
    $commandA=$connectionA.CreateCommand()
    $commandA.Transaction=$transactionA
    $commandA.CommandText=$insert
    $null=$commandA.ExecuteNonQuery()
    $commandB=$connectionB.CreateCommand()
    $commandB.CommandTimeout=10
    $commandB.CommandText='SET LOCK_TIMEOUT 1000;'+$insert
    $blocked=$false
    try { $null=$commandB.ExecuteNonQuery() }
    catch {
        $exception=$_.Exception
        while ($exception -and !($exception -is [System.Data.SqlClient.SqlException])) { $exception=$exception.InnerException }
        if ($exception -and @($exception.Errors | Where-Object Number -eq 1222).Count -gt 0) { $blocked=$true }
        else { throw }
    }
    if (!$blocked) { throw 'Second connection was not blocked by the uncommitted active reservation.' }
    'PASS: second connection cannot reserve the same copy while the first transaction holds it.'
    $transactionA.Rollback()
    $transactionA.Dispose()
    $transactionA=$null
    $transactionB=$connectionB.BeginTransaction()
    $commandB.Transaction=$transactionB
    $commandB.CommandText='SET LOCK_TIMEOUT 5000;'+$insert
    $null=$commandB.ExecuteNonQuery()
    $transactionB.Rollback()
    $transactionB.Dispose()
    $transactionB=$null
    'PASS: after first transaction rolls back, the second connection can reserve; its insert is also rolled back.'
    $commandA.Dispose()
    $commandB.Dispose()
} finally {
    if ($transactionA) { try { $transactionA.Rollback() } catch { } }
    if ($transactionB) { try { $transactionB.Rollback() } catch { } }
    $connectionA.Dispose()
    $connectionB.Dispose()
}
