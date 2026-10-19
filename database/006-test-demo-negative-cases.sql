USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON; SET XACT_ABORT OFF; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
IF NOT EXISTS(SELECT 1 FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1') THROW 51300,'Install demo v1 first.',1;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @tests TABLE(Id int IDENTITY,Name nvarchar(200),SqlText nvarchar(max),Kind varchar(20));
INSERT @tests(Name,SqlText,Kind) VALUES
(N'Username must not be blank',N'UPDATE dbo.Users SET Username=N'' '' WHERE Username=''nam'';',N'CONSTRAINT'),
(N'User status enum',N'UPDATE dbo.Users SET Status=''UNKNOWN'' WHERE Username=''nam'';',N'CONSTRAINT'),
(N'User timestamps ordered',N'UPDATE dbo.Users SET UpdatedAt=DATEADD(day,-1,CreatedAt) WHERE Username=''nam'';',N'CONSTRAINT'),
(N'Full name NOT NULL',N'UPDATE dbo.Users SET FullName=NULL WHERE Username=''nam'';',N'NULL'),
(N'Username maximum length',N'UPDATE dbo.Users SET Username=REPLICATE(N''x'',51) WHERE Username=''nam'';',N'LENGTH'),
(N'Email uniqueness case insensitive',N'UPDATE dbo.Users SET Email=''DEMO.ADMIN@EXAMPLE.INVALID'' WHERE Username=''nam'';',N'UNIQUE'),
(N'Role code uniqueness',N'INSERT dbo.Roles(RoleCode,RoleName) VALUES(''ADMIN'',N''Duplicate'');',N'UNIQUE'),
(N'User role pair uniqueness',N'INSERT dbo.UserRoles(UserId,RoleId) SELECT TOP(1) UserId,RoleId FROM dbo.UserRoles;',N'UNIQUE'),
(N'Store status enum',N'UPDATE dbo.Stores SET Status=''UNKNOWN'' WHERE StoreCode=''DEMO-S4'';',N'CONSTRAINT'),
(N'Staff role enum',N'UPDATE dbo.StaffStoreAssignments SET StoreRole=''OWNER'' WHERE AssignmentId=(SELECT MIN(AssignmentId) FROM dbo.StaffStoreAssignments);',N'CONSTRAINT'),
(N'Staff end must follow start',N'UPDATE dbo.StaffStoreAssignments SET Status=''ENDED'',EndAt=DATEADD(day,-1,StartAt) WHERE AssignmentId=(SELECT MIN(AssignmentId) FROM dbo.StaffStoreAssignments);',N'CONSTRAINT'),
(N'One active staff assignment per store',N'INSERT dbo.StaffStoreAssignments(UserId,StoreId,StoreRole) SELECT TOP(1) UserId,StoreId,StoreRole FROM dbo.StaffStoreAssignments WHERE Status=''ACTIVE'';',N'UNIQUE'),
(N'Condition sort cannot be negative',N'UPDATE dbo.BookConditions SET SortOrder=-1 WHERE ConditionCode=''GOOD'';',N'CONSTRAINT'),
(N'Supplier type enum',N'UPDATE dbo.Suppliers SET SupplierType=''UNKNOWN'' WHERE SupplierId=(SELECT MIN(SupplierId) FROM dbo.Suppliers);',N'CONSTRAINT'),
(N'Supplier status enum',N'UPDATE dbo.Suppliers SET Status=''UNKNOWN'' WHERE SupplierId=(SELECT MIN(SupplierId) FROM dbo.Suppliers);',N'CONSTRAINT'),
(N'Receipt cannot have negative total',N'UPDATE dbo.PurchaseReceipts SET TotalAmount=-1 WHERE ReceiptCode=''DEMO-IN-1'';',N'CONSTRAINT'),
(N'Received receipt requires receipt time',N'UPDATE dbo.PurchaseReceipts SET ReceivedAt=NULL WHERE ReceiptCode=''DEMO-IN-1'';',N'CONSTRAINT'),
(N'Receipt line quantity positive',N'UPDATE dbo.PurchaseReceiptItems SET Quantity=0 WHERE ReceiptItemId=(SELECT MIN(ReceiptItemId) FROM dbo.PurchaseReceiptItems);',N'CONSTRAINT'),
(N'Receipt line cost nonnegative',N'UPDATE dbo.PurchaseReceiptItems SET UnitCost=-1 WHERE ReceiptItemId=(SELECT MIN(ReceiptItemId) FROM dbo.PurchaseReceiptItems);',N'CONSTRAINT'),
(N'Copy version nonnegative',N'UPDATE dbo.BookCopies SET Version=-1 WHERE CopyCode=''DEMO-C1-042'';',N'CONSTRAINT'),
(N'Copy status enum',N'UPDATE dbo.BookCopies SET Status=''UNKNOWN'' WHERE CopyCode=''DEMO-C1-042'';',N'CONSTRAINT'),
(N'Media dimensions positive',N'UPDATE dbo.MediaAssets SET Width=0 WHERE MediaId=(SELECT MIN(MediaId) FROM dbo.MediaAssets);',N'CONSTRAINT'),
(N'Media URL must match provider',N'UPDATE dbo.MediaAssets SET Url=''file:///D:/private.jpg'' WHERE MediaId=(SELECT MIN(MediaId) FROM dbo.MediaAssets);',N'CONSTRAINT'),
(N'Cloudinary requires public ID',N'UPDATE dbo.MediaAssets SET PublicId=NULL WHERE Provider=''CLOUDINARY'';',N'CONSTRAINT'),
(N'Transfer timestamps ordered',N'UPDATE dbo.StockTransfers SET ReceivedAt=DATEADD(day,-1,ShippedAt) WHERE TransferCode=''DEMO-TRANSFER-RECEIVED'';',N'CONSTRAINT'),
(N'Shipped transfer requires approver',N'UPDATE dbo.StockTransfers SET ApprovedBy=NULL WHERE TransferCode=''DEMO-TRANSFER-TRANSIT'';',N'CONSTRAINT'),
(N'Received transfer item requires condition',N'UPDATE dbo.StockTransferItems SET ReceivedConditionId=NULL WHERE ReceiptStatus=''RECEIVED'';',N'CONSTRAINT'),
(N'Finalized stocktake requires approver',N'UPDATE dbo.Stocktakes SET ApprovedBy=NULL WHERE StocktakeId=(SELECT MIN(StocktakeId) FROM dbo.Stocktakes WHERE Status=''FINALIZED'');',N'CONSTRAINT'),
(N'Present counted copy requires condition',N'UPDATE dbo.StocktakeItems SET ActualConditionId=NULL WHERE StocktakeItemId=(SELECT MIN(StocktakeItemId) FROM dbo.StocktakeItems WHERE ActualPresent=1);',N'CONSTRAINT'),
(N'Cart status enum',N'UPDATE dbo.Carts SET Status=''UNKNOWN'' WHERE CartId=(SELECT MIN(CartId) FROM dbo.Carts);',N'CONSTRAINT'),
(N'Online order requires customer',N'UPDATE dbo.Orders SET CustomerId=NULL WHERE OrderCode=''DEMO-HOLD-ACTIVE'';',N'CONSTRAINT'),
(N'POS order requires operator',N'UPDATE dbo.Orders SET CreatedBy=NULL WHERE OrderCode=''DEMO-GUEST'';',N'CONSTRAINT'),
(N'Discount cannot exceed subtotal',N'UPDATE dbo.Orders SET DiscountAmount=Subtotal+1,TotalAmount=ShippingFee-1 WHERE OrderCode=''DEMO-SHIPPING'';',N'CONSTRAINT'),
(N'Order item discount bounded',N'UPDATE dbo.OrderItems SET DiscountAmount=UnitPrice+1,LineTotal=-1 WHERE OrderItemId=(SELECT MIN(OrderItemId) FROM dbo.OrderItems);',N'CONSTRAINT'),
(N'Active hold cannot already be released',N'UPDATE dbo.StockReservations SET ReleasedAt=SYSUTCDATETIME() WHERE ReservationId=(SELECT MIN(ReservationId) FROM dbo.StockReservations WHERE Status=''ACTIVE'');',N'CONSTRAINT'),
(N'Payment amount positive',N'UPDATE dbo.Payments SET Amount=0 WHERE PaymentId=(SELECT MIN(PaymentId) FROM dbo.Payments);',N'CONSTRAINT'),
(N'Payment currency VND',N'UPDATE dbo.Payments SET Currency=''USD'' WHERE PaymentId=(SELECT MIN(PaymentId) FROM dbo.Payments);',N'CONSTRAINT'),
(N'Successful payment requires paid timestamp',N'UPDATE dbo.Payments SET PaidAt=NULL WHERE PaymentId=(SELECT MIN(PaymentId) FROM dbo.Payments WHERE Status=''SUCCEEDED'');',N'CONSTRAINT'),
(N'History must change status',N'UPDATE dbo.OrderStatusHistory SET FromStatus=ToStatus WHERE HistoryId=(SELECT MIN(HistoryId) FROM dbo.OrderStatusHistory);',N'CONSTRAINT'),
(N'Approved return requires approval timestamp',N'UPDATE dbo.SalesReturns SET ApprovedAt=NULL WHERE ReturnId=(SELECT MIN(ReturnId) FROM dbo.SalesReturns WHERE Status=''APPROVED'');',N'CONSTRAINT'),
(N'Accepted return item requires condition',N'UPDATE dbo.SalesReturnItems SET ReceivedConditionId=NULL WHERE ReturnItemId=(SELECT MIN(ReturnItemId) FROM dbo.SalesReturnItems WHERE Status=''ACCEPTED'');',N'CONSTRAINT'),
(N'Refund amount positive',N'UPDATE dbo.Refunds SET Amount=0 WHERE RefundId=(SELECT MIN(RefundId) FROM dbo.Refunds);',N'CONSTRAINT'),
(N'Successful refund requires timestamp',N'UPDATE dbo.Refunds SET RefundedAt=NULL WHERE RefundId=(SELECT MIN(RefundId) FROM dbo.Refunds WHERE Status=''SUCCEEDED'');',N'CONSTRAINT'),
(N'Refresh token replacement cannot reference itself',N'UPDATE dbo.RefreshTokens SET ReplacedByTokenId=RefreshTokenId,RevokedAt=SYSUTCDATETIME() WHERE RefreshTokenId=(SELECT MIN(RefreshTokenId) FROM dbo.RefreshTokens);',N'CONSTRAINT'),
(N'Replacement token must stay in same family',N'UPDATE dbo.RefreshTokens SET FamilyId=NEWID() WHERE ReplacedByTokenId IS NOT NULL;',N'CONSTRAINT'),
(N'Notification read cannot precede creation',N'UPDATE dbo.Notifications SET ReadAt=DATEADD(day,-1,CreatedAt) WHERE NotificationId=(SELECT MIN(NotificationId) FROM dbo.Notifications);',N'CONSTRAINT'),
(N'Notification user must exist',N'UPDATE dbo.Notifications SET UserId=-1 WHERE NotificationId=(SELECT MIN(NotificationId) FROM dbo.Notifications);',N'CONSTRAINT'),
(N'Receipt movement requires its receipt line',N'UPDATE dbo.InventoryMovements SET ReceiptItemId=NULL WHERE MovementId=(SELECT MIN(MovementId) FROM dbo.InventoryMovements WHERE MovementType=''RECEIPT'');',N'CONSTRAINT'),
(N'Inventory operation idempotency',N'UPDATE dbo.InventoryMovements SET OperationKey=(SELECT OperationKey FROM dbo.InventoryMovements WHERE MovementId=(SELECT MIN(MovementId) FROM dbo.InventoryMovements)) WHERE MovementId=(SELECT MAX(MovementId) FROM dbo.InventoryMovements);',N'UNIQUE');
DECLARE @i int=1,@n int=(SELECT COUNT(*) FROM @tests),@name nvarchar(200),@sql nvarchar(max),@kind varchar(20),@caught bit;
WHILE @i<=@n
BEGIN
 SELECT @name=Name,@sql=SqlText,@kind=Kind FROM @tests WHERE Id=@i;
 SET @caught=0;
 SAVE TRANSACTION DemoNegativeCase;
 BEGIN TRY
  EXEC sys.sp_executesql @sql;
 END TRY
 BEGIN CATCH
  IF (@kind='CONSTRAINT' AND ERROR_NUMBER()=547)
   OR (@kind='UNIQUE' AND ERROR_NUMBER() IN (2601,2627))
   OR (@kind='NULL' AND ERROR_NUMBER()=515)
   OR (@kind='LENGTH' AND ERROR_NUMBER() IN (8152,2628)) SET @caught=1;
  ELSE THROW;
 END CATCH;
 IF @caught=0 BEGIN
  DECLARE @msg nvarchar(2048)=N'Invalid data was not rejected: '+@name;
  THROW 51301,@msg,1;
 END;
 ROLLBACK TRANSACTION DemoNegativeCase;
 PRINT N'PASS: '+@name;
 SET @i+=1;
END;
ROLLBACK TRANSACTION;
PRINT 'All 49 extended negative tests passed; database data rolled back.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
