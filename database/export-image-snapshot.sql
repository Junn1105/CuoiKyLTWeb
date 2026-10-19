SET NOCOUNT ON;
SELECT
 (SELECT BookId,CoverImage FROM dbo.Books ORDER BY BookId FOR JSON PATH,INCLUDE_NULL_VALUES) AS Books,
 (SELECT AuthorId,AuthorPhoto FROM dbo.Authors ORDER BY AuthorId FOR JSON PATH,INCLUDE_NULL_VALUES) AS Authors,
 (SELECT t.name AS TableName,c.name AS ColumnName,ty.name AS DataType,c.max_length,c.is_nullable
  FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id
  JOIN sys.types ty ON ty.user_type_id=c.user_type_id
  ORDER BY t.name,c.column_id FOR JSON PATH) AS Columns,
 (SELECT * FROM (SELECT 'Books' AS TableName,COUNT(*) AS TotalRows FROM dbo.Books
  UNION ALL SELECT 'Authors',COUNT(*) FROM dbo.Authors
  UNION ALL SELECT 'Categories',COUNT(*) FROM dbo.Categories
  UNION ALL SELECT 'Publishers',COUNT(*) FROM dbo.Publishers
  UNION ALL SELECT 'BookAuthors',COUNT(*) FROM dbo.BookAuthors) AS totals FOR JSON PATH) AS Counts
FOR JSON PATH,WITHOUT_ARRAY_WRAPPER;
