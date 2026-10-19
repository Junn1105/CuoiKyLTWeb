const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const quote=s=>"N'"+s.replaceAll("'","''")+"'";
const cases=[];
function test(name,sql,kind='CONSTRAINT'){cases.push([name,sql,kind]);}
function change(name,table,sets,where){test(name,`UPDATE dbo.${table} SET ${sets} WHERE ${where};`);}
const first=(t,id)=>`${id}=(SELECT MIN(${id}) FROM dbo.${t})`;
change('Username must not be blank','Users',"Username=N' '","Username='nam'");
change('User status enum','Users',"Status='UNKNOWN'","Username='nam'");
change('User timestamps ordered','Users','UpdatedAt=DATEADD(day,-1,CreatedAt)',"Username='nam'");
test('Full name NOT NULL',"UPDATE dbo.Users SET FullName=NULL WHERE Username='nam';",'NULL');
test('Username maximum length',"UPDATE dbo.Users SET Username=REPLICATE(N'x',51) WHERE Username='nam';",'LENGTH');
test('Email uniqueness case insensitive',"UPDATE dbo.Users SET Email='DEMO.ADMIN@EXAMPLE.INVALID' WHERE Username='nam';",'UNIQUE');
test('Role code uniqueness',"INSERT dbo.Roles(RoleCode,RoleName) VALUES('ADMIN',N'Duplicate');",'UNIQUE');
test('User role pair uniqueness',"INSERT dbo.UserRoles(UserId,RoleId) SELECT TOP(1) UserId,RoleId FROM dbo.UserRoles;",'UNIQUE');
change('Store status enum','Stores',"Status='UNKNOWN'","StoreCode='DEMO-S4'");
change('Staff role enum','StaffStoreAssignments',"StoreRole='OWNER'",first('StaffStoreAssignments','AssignmentId'));
change('Staff end must follow start','StaffStoreAssignments',"Status='ENDED',EndAt=DATEADD(day,-1,StartAt)",first('StaffStoreAssignments','AssignmentId'));
test('One active staff assignment per store',"INSERT dbo.StaffStoreAssignments(UserId,StoreId,StoreRole) SELECT TOP(1) UserId,StoreId,StoreRole FROM dbo.StaffStoreAssignments WHERE Status='ACTIVE';",'UNIQUE');
change('Condition sort cannot be negative','BookConditions','SortOrder=-1',"ConditionCode='GOOD'");
change('Supplier type enum','Suppliers',"SupplierType='UNKNOWN'",first('Suppliers','SupplierId'));
change('Supplier status enum','Suppliers',"Status='UNKNOWN'",first('Suppliers','SupplierId'));
change('Receipt cannot have negative total','PurchaseReceipts','TotalAmount=-1',"ReceiptCode='DEMO-IN-1'");
change('Received receipt requires receipt time','PurchaseReceipts','ReceivedAt=NULL',"ReceiptCode='DEMO-IN-1'");
change('Receipt line quantity positive','PurchaseReceiptItems','Quantity=0',first('PurchaseReceiptItems','ReceiptItemId'));
change('Receipt line cost nonnegative','PurchaseReceiptItems','UnitCost=-1',first('PurchaseReceiptItems','ReceiptItemId'));
change('Copy version nonnegative','BookCopies','Version=-1',"CopyCode='DEMO-C1-042'");
change('Copy status enum','BookCopies',"Status='UNKNOWN'","CopyCode='DEMO-C1-042'");
change('Media dimensions positive','MediaAssets','Width=0',first('MediaAssets','MediaId'));
change('Media URL must match provider','MediaAssets',"Url='file:///D:/private.jpg'",first('MediaAssets','MediaId'));
change('Cloudinary requires public ID','MediaAssets','PublicId=NULL',"Provider='CLOUDINARY'");
change('Transfer timestamps ordered','StockTransfers','ReceivedAt=DATEADD(day,-1,ShippedAt)',"TransferCode='DEMO-TRANSFER-RECEIVED'");
change('Shipped transfer requires approver','StockTransfers','ApprovedBy=NULL',"TransferCode='DEMO-TRANSFER-TRANSIT'");
change('Received transfer item requires condition','StockTransferItems','ReceivedConditionId=NULL',"ReceiptStatus='RECEIVED'");
change('Finalized stocktake requires approver','Stocktakes','ApprovedBy=NULL',"StocktakeId=(SELECT MIN(StocktakeId) FROM dbo.Stocktakes WHERE Status='FINALIZED')");
change('Present counted copy requires condition','StocktakeItems','ActualConditionId=NULL',"StocktakeItemId=(SELECT MIN(StocktakeItemId) FROM dbo.StocktakeItems WHERE ActualPresent=1)");
change('Cart status enum','Carts',"Status='UNKNOWN'",first('Carts','CartId'));
change('Online order requires customer','Orders','CustomerId=NULL',"OrderCode='DEMO-HOLD-ACTIVE'");
change('POS order requires operator','Orders','CreatedBy=NULL',"OrderCode='DEMO-GUEST'");
change('Discount cannot exceed subtotal','Orders','DiscountAmount=Subtotal+1,TotalAmount=ShippingFee-1',"OrderCode='DEMO-SHIPPING'");
change('Order item discount bounded','OrderItems','DiscountAmount=UnitPrice+1,LineTotal=-1',first('OrderItems','OrderItemId'));
change('Active hold cannot already be released','StockReservations','ReleasedAt=SYSUTCDATETIME()',"ReservationId=(SELECT MIN(ReservationId) FROM dbo.StockReservations WHERE Status='ACTIVE')");
change('Payment amount positive','Payments','Amount=0',first('Payments','PaymentId'));
change('Payment currency VND','Payments',"Currency='USD'",first('Payments','PaymentId'));
change('Successful payment requires paid timestamp','Payments','PaidAt=NULL',"PaymentId=(SELECT MIN(PaymentId) FROM dbo.Payments WHERE Status='SUCCEEDED')");
change('History must change status','OrderStatusHistory','FromStatus=ToStatus',first('OrderStatusHistory','HistoryId'));
change('Approved return requires approval timestamp','SalesReturns','ApprovedAt=NULL',"ReturnId=(SELECT MIN(ReturnId) FROM dbo.SalesReturns WHERE Status='APPROVED')");
change('Accepted return item requires condition','SalesReturnItems','ReceivedConditionId=NULL',"ReturnItemId=(SELECT MIN(ReturnItemId) FROM dbo.SalesReturnItems WHERE Status='ACCEPTED')");
change('Refund amount positive','Refunds','Amount=0',first('Refunds','RefundId'));
change('Successful refund requires timestamp','Refunds','RefundedAt=NULL',"RefundId=(SELECT MIN(RefundId) FROM dbo.Refunds WHERE Status='SUCCEEDED')");
change('Refresh token replacement cannot reference itself','RefreshTokens','ReplacedByTokenId=RefreshTokenId,RevokedAt=SYSUTCDATETIME()',first('RefreshTokens','RefreshTokenId'));
change('Replacement token must stay in same family','RefreshTokens','FamilyId=NEWID()',"ReplacedByTokenId IS NOT NULL");
change('Notification read cannot precede creation','Notifications','ReadAt=DATEADD(day,-1,CreatedAt)',first('Notifications','NotificationId'));
change('Notification user must exist','Notifications','UserId=-1',first('Notifications','NotificationId'));
change('Receipt movement requires its receipt line','InventoryMovements','ReceiptItemId=NULL',"MovementId=(SELECT MIN(MovementId) FROM dbo.InventoryMovements WHERE MovementType='RECEIPT')");
test('Inventory operation idempotency',"UPDATE dbo.InventoryMovements SET OperationKey=(SELECT OperationKey FROM dbo.InventoryMovements WHERE MovementId=(SELECT MIN(MovementId) FROM dbo.InventoryMovements)) WHERE MovementId=(SELECT MAX(MovementId) FROM dbo.InventoryMovements);",'UNIQUE');
const script=`USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON; SET XACT_ABORT OFF; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
IF NOT EXISTS(SELECT 1 FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1') THROW 51300,'Install demo v1 first.',1;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @tests TABLE(Id int IDENTITY,Name nvarchar(200),SqlText nvarchar(max),Kind varchar(20));
INSERT @tests(Name,SqlText,Kind) VALUES
${cases.map(c=>'('+c.map(quote).join(',')+')').join(',\n')};
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
PRINT 'All ${cases.length} extended negative tests passed; database data rolled back.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
`;
fs.writeFileSync(path.join(root,'database/006-test-demo-negative-cases.sql'),script);
fs.writeFileSync(path.join(root,'docs/demo-negative-test-cases.json'),JSON.stringify(cases.map(([name,sql,kind],i)=>({id:i+1,name,sql,kind})),null,2));
console.log(`Generated ${cases.length} negative test cases.`);
