-- Integrity smoke tests. All fixture rows are rolled back, including on failure.
USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT OFF;

BEGIN TRY
BEGIN TRANSACTION;
DECLARE @u int, @s int, @s2 int, @b int, @b2 int, @c int, @supplier int,
 @receipt int, @receiptItem int, @copy int, @copy2 int, @o int, @o2 int,
 @oi int, @oi2 int, @ret int, @ret2 int, @retSame int, @pay int, @cart int;
SELECT @b=MIN(BookId), @b2=MAX(BookId) FROM dbo.Books;
SELECT @c=MIN(ConditionId) FROM dbo.BookConditions;
IF @b IS NULL OR @b=@b2 OR @c IS NULL THROW 51100, 'Catalog fixtures unavailable.', 1;

INSERT dbo.Users(Username,Email,PasswordHash,FullName)
 VALUES(N'__schema_test',N'__schema_test@example.invalid','test-only-never-committed',N'Kiểm thử');
SET @u=SCOPE_IDENTITY();
INSERT dbo.Stores(StoreCode,StoreName,Address) VALUES('__TEST_A',N'A',N'Test');
SET @s=SCOPE_IDENTITY();
INSERT dbo.Stores(StoreCode,StoreName,Address) VALUES('__TEST_B',N'B',N'Test');
SET @s2=SCOPE_IDENTITY();
INSERT dbo.Suppliers(SupplierType,SupplierName) VALUES('INDIVIDUAL',N'Test');
SET @supplier=SCOPE_IDENTITY();
INSERT dbo.PurchaseReceipts(ReceiptCode,SupplierId,StoreId,CreatedBy)
 VALUES('__TEST_RECEIPT',@supplier,@s,@u);
SET @receipt=SCOPE_IDENTITY();
INSERT dbo.PurchaseReceiptItems(ReceiptId,BookId,ConditionId,Quantity,UnitCost)
 VALUES(@receipt,@b,@c,2,10000);
SET @receiptItem=SCOPE_IDENTITY();
INSERT dbo.BookCopies(CopyCode,BookId,StoreId,ConditionId,PurchaseReceiptItemId,CostPrice,SalePrice)
 VALUES('__TEST_COPY_A',@b,@s,@c,@receiptItem,10000,20000);
SET @copy=SCOPE_IDENTITY();
INSERT dbo.BookCopies(CopyCode,BookId,StoreId,ConditionId,PurchaseReceiptItemId,CostPrice,SalePrice)
 VALUES('__TEST_COPY_B',@b,@s,@c,@receiptItem,10000,20000);
SET @copy2=SCOPE_IDENTITY();
INSERT dbo.Orders(OrderCode,StoreId,CreatedBy,Channel,Subtotal,TotalAmount)
 VALUES('__TEST_ORDER_A',@s,@u,'POS',20000,20000);
SET @o=SCOPE_IDENTITY();
INSERT dbo.Orders(OrderCode,StoreId,CreatedBy,Channel,Subtotal,TotalAmount)
 VALUES('__TEST_ORDER_B',@s,@u,'POS',20000,20000);
SET @o2=SCOPE_IDENTITY();
INSERT dbo.OrderItems(OrderId,CopyId,BookTitleSnapshot,ConditionSnapshot,UnitPrice,UnitCostSnapshot,LineTotal)
 VALUES(@o,@copy,N'Test',N'Tốt',20000,10000,20000);
SET @oi=SCOPE_IDENTITY();
INSERT dbo.OrderItems(OrderId,CopyId,BookTitleSnapshot,ConditionSnapshot,UnitPrice,UnitCostSnapshot,LineTotal)
 VALUES(@o2,@copy2,N'Test',N'Tốt',20000,10000,20000);
SET @oi2=SCOPE_IDENTITY();
INSERT dbo.StockReservations(CopyId,OrderId,ExpiresAt) VALUES(@copy,@o,DATEADD(minute,15,SYSUTCDATETIME()));
INSERT dbo.Payments(OrderId,Method,Provider,Amount,IdempotencyKey)
 VALUES(@o,'CASH','MANUAL',20000,'__TEST_PAY');
SET @pay=SCOPE_IDENTITY();
INSERT dbo.SalesReturns(OrderId,ReceivingStoreId,Reason) VALUES(@o,@s,N'Test');
SET @ret=SCOPE_IDENTITY();
INSERT dbo.SalesReturns(OrderId,ReceivingStoreId,Reason) VALUES(@o2,@s,N'Test');
SET @ret2=SCOPE_IDENTITY();
INSERT dbo.SalesReturns(OrderId,ReceivingStoreId,Reason) VALUES(@o,@s,N'Second request for same order');
SET @retSame=SCOPE_IDENTITY();
INSERT dbo.SalesReturnItems(ReturnId,OrderId,OrderItemId,ReceivedConditionId,Resolution,RefundAmount,Status)
 VALUES(@ret,@o,@oi,@c,'RESTOCK',20000,'ACCEPTED');
INSERT dbo.MediaAssets(Provider,Url,UserId,IsPrimary) VALUES('LOCAL','/images/books/test.jpg',@u,1);
INSERT dbo.CustomerAddresses(UserId,RecipientName,Phone,AddressLine,AdministrativeArea,IsDefault)
 VALUES(@u,N'Test','000','Test','Test',1);
INSERT dbo.Carts(UserId,StoreId) VALUES(@u,@s);
SET @cart=SCOPE_IDENTITY();
INSERT dbo.CartItems(CartId,CopyId) VALUES(@cart,@copy);

DECLARE @cases TABLE(TestId int IDENTITY, TestName nvarchar(150), SqlText nvarchar(max), ErrorKind varchar(10));
INSERT @cases(TestName,SqlText,ErrorKind) VALUES
 (N'Negative book price', N'UPDATE dbo.BookCopies SET SalePrice=-1 WHERE CopyId=@copy;', 'CHECK'),
 (N'Wrong book for receipt item', N'UPDATE dbo.BookCopies SET BookId=@b2 WHERE CopyId=@copy;', 'CHECK'),
 (N'Duplicate active reservation', N'INSERT dbo.StockReservations(CopyId,OrderId,ExpiresAt) VALUES(@copy,@o,DATEADD(minute,15,SYSUTCDATETIME()));', 'UNIQUE'),
 (N'Reservation not in order', N'INSERT dbo.StockReservations(CopyId,OrderId,ExpiresAt) VALUES(@copy2,@o,DATEADD(minute,15,SYSUTCDATETIME()));', 'CHECK'),
 (N'Expired reservation range', N'UPDATE dbo.StockReservations SET ExpiresAt=DATEADD(day,-1,ReservedAt) WHERE CopyId=@copy;', 'CHECK'),
 (N'Invalid order total', N'UPDATE dbo.Orders SET TotalAmount=1 WHERE OrderId=@o;', 'CHECK'),
 (N'Invalid line total', N'UPDATE dbo.OrderItems SET LineTotal=1 WHERE OrderItemId=@oi;', 'CHECK'),
 (N'Return to wrong store', N'INSERT dbo.SalesReturns(OrderId,ReceivingStoreId,Reason) VALUES(@o,@s2,N''Test'');', 'CHECK'),
 (N'Return item from another order', N'INSERT dbo.SalesReturnItems(ReturnId,OrderId,OrderItemId,RefundAmount) VALUES(@ret,@o,@oi2,20000);', 'CHECK'),
 (N'Duplicate accepted return across requests', N'INSERT dbo.SalesReturnItems(ReturnId,OrderId,OrderItemId,ReceivedConditionId,Resolution,RefundAmount,Status) VALUES(@retSame,@o,@oi,@c,''RESTOCK'',20000,''ACCEPTED'');', 'UNIQUE'),
 (N'Refund linked to wrong order', N'INSERT dbo.Refunds(ReturnId,OrderId,PaymentId,Amount,Reason,Provider,IdempotencyKey) VALUES(@ret2,@o2,@pay,100,N''Test'',''MANUAL'',''__TEST_BAD_REFUND'');', 'CHECK'),
 (N'Duplicate payment request', N'INSERT dbo.Payments(OrderId,Method,Provider,Amount,IdempotencyKey) VALUES(@o,''CASH'',''MANUAL'',100,''__TEST_PAY'');', 'UNIQUE'),
 (N'Media with no owner', N'INSERT dbo.MediaAssets(Provider,Url) VALUES(''LOCAL'',''/images/test.jpg'');', 'CHECK'),
 (N'Media with two owners', N'INSERT dbo.MediaAssets(Provider,Url,BookId,CopyId) VALUES(''LOCAL'',''/images/test.jpg'',@b,@copy);', 'CHECK'),
 (N'Duplicate primary image', N'INSERT dbo.MediaAssets(Provider,Url,UserId,IsPrimary) VALUES(''LOCAL'',''/images/test2.jpg'',@u,1);', 'UNIQUE'),
 (N'Duplicate default address', N'INSERT dbo.CustomerAddresses(UserId,RecipientName,Phone,AddressLine,AdministrativeArea,IsDefault) VALUES(@u,N''Test'',''000'',''Test'',''Test'',1);', 'UNIQUE'),
 (N'Duplicate active cart', N'INSERT dbo.Carts(UserId,StoreId) VALUES(@u,@s);', 'UNIQUE'),
 (N'Transfer to same store', N'INSERT dbo.StockTransfers(TransferCode,FromStoreId,ToStoreId,RequestedBy) VALUES(''__TEST_TRANSFER'',@s,@s,@u);', 'CHECK'),
 (N'Movement references wrong copy', N'INSERT dbo.InventoryMovements(CopyId,FromStoreId,MovementType,ActorId,OrderItemId,OperationKey) VALUES(@copy2,@s,''SALE'',@u,@oi,''__TEST_MOVEMENT'');', 'CHECK'),
 (N'Case-insensitive unique username', N'INSERT dbo.Users(Username,Email,PasswordHash,FullName) VALUES(N''__SCHEMA_TEST'',N''another@example.invalid'',''test'',N''Test'');', 'UNIQUE'),
 (N'Protect referenced catalog record', N'DELETE dbo.Books WHERE BookId=@b;', 'CHECK'),
 (N'Invalid refresh expiration', N'INSERT dbo.RefreshTokens(UserId,TokenHash,ExpiresAt) VALUES(@u,HASHBYTES(''SHA2_256'',''test''),DATEADD(day,-1,SYSUTCDATETIME()));', 'CHECK');

DECLARE @i int=1, @n int=(SELECT COUNT(*) FROM @cases), @name nvarchar(150), @sql nvarchar(max), @kind varchar(10), @rejected bit;
WHILE @i<=@n
BEGIN
 SELECT @name=TestName,@sql=SqlText,@kind=ErrorKind FROM @cases WHERE TestId=@i;
 SET @rejected=0;
 BEGIN TRY
  EXEC sys.sp_executesql @sql,
   N'@u int,@s int,@s2 int,@b int,@b2 int,@c int,@copy int,@copy2 int,@o int,@o2 int,@oi int,@oi2 int,@ret int,@ret2 int,@retSame int,@pay int',
   @u,@s,@s2,@b,@b2,@c,@copy,@copy2,@o,@o2,@oi,@oi2,@ret,@ret2,@retSame,@pay;
 END TRY
 BEGIN CATCH
  IF (@kind='CHECK' AND ERROR_NUMBER()=547) OR (@kind='UNIQUE' AND ERROR_NUMBER() IN (2601,2627))
   SET @rejected=1;
  ELSE THROW;
 END CATCH;
 IF @rejected=0
 BEGIN
  DECLARE @failure nvarchar(2048)=N'Constraint failed to reject: '+@name;
  THROW 51101,@failure,1;
 END;
 PRINT N'PASS: '+@name;
 SET @i+=1;
END;

-- A released reservation must permit a new active reservation for the same copy.
UPDATE dbo.StockReservations SET Status='EXPIRED',ReleasedAt=SYSUTCDATETIME() WHERE CopyId=@copy;
INSERT dbo.StockReservations(CopyId,OrderId,ExpiresAt) VALUES(@copy,@o,DATEADD(minute,15,SYSUTCDATETIME()));
PRINT 'PASS: release and reserve the same copy again';

-- A physical copy may be sold in a later order after return: no global UNIQUE(CopyId).
INSERT dbo.OrderItems(OrderId,CopyId,BookTitleSnapshot,ConditionSnapshot,UnitPrice,UnitCostSnapshot,LineTotal)
 VALUES(@o2,@copy,N'Resale',N'Tốt',20000,10000,20000);
PRINT 'PASS: resale history permits the same copy in another order';
ROLLBACK TRANSACTION;
PRINT 'All 24 integrity tests passed; every fixture row rolled back.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
