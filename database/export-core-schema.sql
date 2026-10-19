SET NOCOUNT ON;
SELECT
 (SELECT t.name AS TableName, SUM(p.rows) AS TotalRows
  FROM sys.tables t JOIN sys.partitions p ON p.object_id=t.object_id AND p.index_id IN (0,1)
  WHERE t.schema_id=SCHEMA_ID('dbo') GROUP BY t.name ORDER BY t.name FOR JSON PATH) AS Tables,
 (SELECT t.name AS TableName,c.name AS ColumnName,TYPE_NAME(c.user_type_id) AS DataType,
  c.max_length,c.precision,c.scale,c.is_nullable,c.is_identity,d.definition AS DefaultDefinition
  FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id
  LEFT JOIN sys.default_constraints d ON d.object_id=c.default_object_id
  ORDER BY t.name,c.column_id FOR JSON PATH,INCLUDE_NULL_VALUES) AS Columns,
 (SELECT fk.name AS ConstraintName,OBJECT_NAME(fk.parent_object_id) AS FromTable,
  COL_NAME(fc.parent_object_id,fc.parent_column_id) AS FromColumn,
  OBJECT_NAME(fk.referenced_object_id) AS ToTable,
  COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ToColumn,
  fk.is_disabled,fk.is_not_trusted,fk.delete_referential_action_desc
  FROM sys.foreign_keys fk JOIN sys.foreign_key_columns fc ON fc.constraint_object_id=fk.object_id
  ORDER BY fk.name,fc.constraint_column_id FOR JSON PATH) AS ForeignKeys,
 (SELECT OBJECT_NAME(parent_object_id) AS TableName,name,definition,is_disabled,is_not_trusted
  FROM sys.check_constraints ORDER BY name FOR JSON PATH) AS Checks,
 (SELECT OBJECT_NAME(i.object_id) AS TableName,i.name,i.is_unique,i.is_primary_key,i.filter_definition,
  c.name AS ColumnName,ic.key_ordinal,ic.is_included_column
  FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
  JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
  WHERE i.object_id IN (SELECT object_id FROM sys.tables)
  ORDER BY TableName,i.name,ic.index_column_id FOR JSON PATH,INCLUDE_NULL_VALUES) AS Indexes
FOR JSON PATH,WITHOUT_ARRAY_WRAPPER;
