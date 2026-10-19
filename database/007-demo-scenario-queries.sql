USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON;

-- Actual row counts for all 35 tables.
SELECT t.name AS TableName,SUM(p.rows) AS TotalRows
FROM sys.tables t JOIN sys.partitions p ON p.object_id=t.object_id AND p.index_id IN (0,1)
WHERE t.schema_id=SCHEMA_ID('dbo') GROUP BY t.name ORDER BY t.name;

-- Demo users and global roles. Staff authorization also requires the assignment query below.
SELECT u.Username,u.FullName,u.Status,STRING_AGG(r.RoleCode,', ') AS GlobalRoles
FROM dbo.Users u LEFT JOIN dbo.UserRoles ur ON ur.UserId=u.UserId LEFT JOIN dbo.Roles r ON r.RoleId=ur.RoleId
WHERE u.Email LIKE 'demo.%' GROUP BY u.Username,u.FullName,u.Status ORDER BY u.Username;
SELECT u.Username,s.StoreCode,a.StoreRole,a.Status,a.StartAt,a.EndAt
FROM dbo.StaffStoreAssignments a JOIN dbo.Users u ON u.UserId=a.UserId JOIN dbo.Stores s ON s.StoreId=a.StoreId
WHERE u.Email LIKE 'demo.%' ORDER BY u.Username,s.StoreCode;

SELECT o.OrderCode,o.Channel,o.Status,u.Username AS Customer,o.Subtotal,o.DiscountAmount,o.ShippingFee,o.TotalAmount
FROM dbo.Orders o LEFT JOIN dbo.Users u ON u.UserId=o.CustomerId WHERE o.OrderCode LIKE 'DEMO-%' ORDER BY o.OrderId;

SELECT s.StoreCode,c.Status,COUNT(*) AS Copies
FROM dbo.BookCopies c JOIN dbo.Stores s ON s.StoreId=c.StoreId
WHERE c.CopyCode LIKE 'DEMO-%' GROUP BY s.StoreCode,c.Status ORDER BY s.StoreCode,c.Status;

-- The overdue ACTIVE row is intentional: the application expiry job must release it.
SELECT o.OrderCode,c.CopyCode,r.Status,r.ReservedAt,r.ExpiresAt,r.ReleasedAt,
 CASE WHEN r.Status='ACTIVE' AND r.ExpiresAt<=SYSUTCDATETIME() THEN 'DUE_FOR_RELEASE' ELSE 'NOT_DUE_OR_CLOSED' END AS CurrentExpiryState
FROM dbo.StockReservations r JOIN dbo.Orders o ON o.OrderId=r.OrderId JOIN dbo.BookCopies c ON c.CopyId=r.CopyId
WHERE o.OrderCode LIKE 'DEMO-%' ORDER BY r.ReservationId;

SELECT o.OrderCode,p.Method,p.Status AS PaymentStatus,p.Amount AS PaymentAmount,
 r.Status AS RefundStatus,r.Amount AS RefundAmount,r.ReturnId,p.IdempotencyKey,r.IdempotencyKey AS RefundKey
FROM dbo.Payments p JOIN dbo.Orders o ON o.OrderId=p.OrderId LEFT JOIN dbo.Refunds r ON r.PaymentId=p.PaymentId
WHERE o.OrderCode LIKE 'DEMO-%' ORDER BY o.OrderId,p.PaymentId,r.RefundId;

-- Timeline for a returned and resold physical copy.
SELECT c.CopyCode,m.MovementType,m.OccurredAt,o.OrderCode,m.Reason
FROM dbo.InventoryMovements m JOIN dbo.BookCopies c ON c.CopyId=m.CopyId
LEFT JOIN dbo.OrderItems i ON i.OrderItemId=m.OrderItemId LEFT JOIN dbo.Orders o ON o.OrderId=i.OrderId
WHERE c.CopyCode='DEMO-C1-003' ORDER BY m.OccurredAt,m.MovementId;

SELECT CreatedAt AS SeededAtUtc,Summary FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1';
