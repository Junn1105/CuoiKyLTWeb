SET NOCOUNT ON;
SELECT
 (SELECT TOP(1) CreatedAt FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1' ORDER BY AuditId DESC) AS SeededAtUtc,
 (SELECT Username,FullName,Status FROM dbo.Users WHERE Email LIKE 'demo.%' ORDER BY Username FOR JSON PATH) AS Accounts,
 (SELECT s.StoreCode,c.Status,COUNT(*) AS TotalCopies FROM dbo.BookCopies c JOIN dbo.Stores s ON s.StoreId=c.StoreId
  WHERE c.CopyCode LIKE 'DEMO-%' GROUP BY s.StoreCode,c.Status ORDER BY s.StoreCode,c.Status FOR JSON PATH) AS Stock,
 (SELECT Status,COUNT(*) AS TotalOrders FROM dbo.Orders WHERE OrderCode LIKE 'DEMO-%' GROUP BY Status ORDER BY Status FOR JSON PATH) AS OrderStates,
 (SELECT o.OrderId,o.OrderCode,o.Status,o.Channel,o.Subtotal,o.DiscountAmount,o.ShippingFee,o.TotalAmount,
  u.Username AS Customer FROM dbo.Orders o LEFT JOIN dbo.Users u ON u.UserId=o.CustomerId
  WHERE o.OrderCode LIKE 'DEMO-%' ORDER BY o.OrderId FOR JSON PATH,INCLUDE_NULL_VALUES) AS Orders,
 (SELECT Provider,Url,IsPrimary,BookId,CopyId,AuthorId,UserId FROM dbo.MediaAssets ORDER BY MediaId FOR JSON PATH,INCLUDE_NULL_VALUES) AS Media,
 (SELECT MIN(ExpiresAt) AS FirstExpiry,MAX(ExpiresAt) AS LastExpiry FROM dbo.StockReservations WHERE Status='ACTIVE' FOR JSON PATH) AS ActiveHoldExpiry
FOR JSON PATH,WITHOUT_ARRAY_WRAPPER;
