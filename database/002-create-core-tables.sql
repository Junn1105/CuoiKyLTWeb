-- SQL Server. Run once using sqlcmd -b -f 65001 against the named database.
-- No existing catalog data is changed. Any failure rolls back all 30 tables.
USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
BEGIN TRANSACTION;
DECLARE @lockResult int;
EXEC @lockResult = sys.sp_getapplock @Resource=N'WebsiteQuanLyCuaHangSachCu:002',
    @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=10000;
IF @lockResult < 0 THROW 51000, 'Cannot acquire migration lock.', 1;

IF OBJECT_ID(N'dbo.Books', N'U') IS NULL OR OBJECT_ID(N'dbo.Authors', N'U') IS NULL
 OR OBJECT_ID(N'dbo.Categories', N'U') IS NULL OR OBJECT_ID(N'dbo.Publishers', N'U') IS NULL
 OR OBJECT_ID(N'dbo.BookAuthors', N'U') IS NULL
 THROW 51001, 'The five catalog tables must exist before this migration.', 1;

DECLARE @expected TABLE (TableName sysname PRIMARY KEY);
INSERT @expected VALUES
 ('Users'),('Roles'),('UserRoles'),('StaffStoreAssignments'),('CustomerAddresses'),
 ('Stores'),('BookConditions'),('BookCopies'),('MediaAssets'),('Suppliers'),
 ('PurchaseReceipts'),('PurchaseReceiptItems'),('InventoryMovements'),('StockTransfers'),
 ('StockTransferItems'),('Stocktakes'),('StocktakeItems'),('Carts'),('CartItems'),
 ('Orders'),('OrderItems'),('StockReservations'),('Payments'),('OrderStatusHistory'),
 ('SalesReturns'),('SalesReturnItems'),('Refunds'),('RefreshTokens'),('Notifications'),('AuditLogs');
IF EXISTS (SELECT 1 FROM @expected WHERE OBJECT_ID(N'dbo.' + QUOTENAME(TableName)) IS NOT NULL)
 THROW 51002, 'A target object already exists. Migration is one-shot; inspect schema instead of rerunning.', 1;

CREATE TABLE dbo.Users (
 UserId int IDENTITY(1,1) CONSTRAINT PK_Users PRIMARY KEY,
 Username nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
 Email nvarchar(254) COLLATE Latin1_General_100_CI_AS NOT NULL,
 PasswordHash varchar(255) NOT NULL,
 FullName nvarchar(150) NOT NULL,
 Phone varchar(20) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Users_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Users_Username UNIQUE(Username),
 CONSTRAINT UQ_Users_Email UNIQUE(Email),
 CONSTRAINT CK_Users_Status CHECK(Status IN ('ACTIVE','LOCKED','PENDING')),
 CONSTRAINT CK_Users_Required CHECK(LEN(LTRIM(RTRIM(Username))) > 0 AND LEN(LTRIM(RTRIM(Email))) > 0
  AND LEN(LTRIM(RTRIM(FullName))) > 0 AND LEN(PasswordHash) > 0),
 CONSTRAINT CK_Users_Timestamps CHECK(UpdatedAt >= CreatedAt)
);
CREATE TABLE dbo.Roles (
 RoleId int IDENTITY(1,1) CONSTRAINT PK_Roles PRIMARY KEY,
 RoleCode varchar(30) NOT NULL CONSTRAINT UQ_Roles_Code UNIQUE,
 RoleName nvarchar(100) NOT NULL,
 CONSTRAINT CK_Roles_Code CHECK(LEN(LTRIM(RTRIM(RoleCode))) > 0)
);
CREATE TABLE dbo.UserRoles (
 UserId int NOT NULL CONSTRAINT FK_UserRoles_Users REFERENCES dbo.Users(UserId),
 RoleId int NOT NULL CONSTRAINT FK_UserRoles_Roles REFERENCES dbo.Roles(RoleId),
 AssignedAt datetime2(3) NOT NULL CONSTRAINT DF_UserRoles_AssignedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT PK_UserRoles PRIMARY KEY(UserId,RoleId)
);
CREATE TABLE dbo.Stores (
 StoreId int IDENTITY(1,1) CONSTRAINT PK_Stores PRIMARY KEY,
 StoreCode varchar(30) NOT NULL CONSTRAINT UQ_Stores_Code UNIQUE,
 StoreName nvarchar(150) NOT NULL,
 Address nvarchar(500) NOT NULL,
 Phone varchar(20) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Stores_Status DEFAULT ('ACTIVE'),
 OpenedAt date NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stores_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stores_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Stores_Status CHECK(Status IN ('ACTIVE','TEMPORARILY_CLOSED','CLOSED')),
 CONSTRAINT CK_Stores_Code CHECK(LEN(LTRIM(RTRIM(StoreCode))) > 0)
);
CREATE TABLE dbo.StaffStoreAssignments (
 AssignmentId int IDENTITY(1,1) CONSTRAINT PK_StaffStoreAssignments PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_StaffAssignments_Users REFERENCES dbo.Users(UserId),
 StoreId int NOT NULL CONSTRAINT FK_StaffAssignments_Stores REFERENCES dbo.Stores(StoreId),
 StoreRole varchar(20) NOT NULL,
 StartAt datetime2(3) NOT NULL CONSTRAINT DF_StaffAssignments_StartAt DEFAULT SYSUTCDATETIME(),
 EndAt datetime2(3) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_StaffAssignments_Status DEFAULT ('ACTIVE'),
 CONSTRAINT CK_StaffAssignments_Role CHECK(StoreRole IN ('MANAGER','STAFF')),
 CONSTRAINT CK_StaffAssignments_Status CHECK(Status IN ('ACTIVE','ENDED')),
 CONSTRAINT CK_StaffAssignments_Dates CHECK((Status='ACTIVE' AND EndAt IS NULL)
  OR (Status='ENDED' AND EndAt IS NOT NULL AND EndAt >= StartAt))
);
CREATE UNIQUE INDEX UX_StaffAssignments_Active ON dbo.StaffStoreAssignments(UserId,StoreId) WHERE Status='ACTIVE';
CREATE TABLE dbo.CustomerAddresses (
 AddressId int IDENTITY(1,1) CONSTRAINT PK_CustomerAddresses PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_CustomerAddresses_Users REFERENCES dbo.Users(UserId),
 RecipientName nvarchar(150) NOT NULL,
 Phone varchar(20) NOT NULL,
 AddressLine nvarchar(500) NOT NULL,
 AdministrativeArea nvarchar(255) NOT NULL,
 PostalCode varchar(20) NULL,
 CountryCode char(2) NOT NULL CONSTRAINT DF_CustomerAddresses_Country DEFAULT ('VN'),
 IsDefault bit NOT NULL CONSTRAINT DF_CustomerAddresses_IsDefault DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_CustomerAddresses_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_CustomerAddresses_UpdatedAt DEFAULT SYSUTCDATETIME()
);
CREATE UNIQUE INDEX UX_CustomerAddresses_Default ON dbo.CustomerAddresses(UserId) WHERE IsDefault=1;
CREATE TABLE dbo.BookConditions (
 ConditionId int IDENTITY(1,1) CONSTRAINT PK_BookConditions PRIMARY KEY,
 ConditionCode varchar(30) NOT NULL CONSTRAINT UQ_BookConditions_Code UNIQUE,
 ConditionName nvarchar(100) NOT NULL,
 Description nvarchar(500) NULL,
 SortOrder int NOT NULL CONSTRAINT DF_BookConditions_SortOrder DEFAULT (0),
 CONSTRAINT CK_BookConditions_Sort CHECK(SortOrder >= 0)
);
CREATE TABLE dbo.Suppliers (
 SupplierId int IDENTITY(1,1) CONSTRAINT PK_Suppliers PRIMARY KEY,
 SupplierType varchar(20) NOT NULL,
 SupplierName nvarchar(200) NOT NULL,
 Phone varchar(20) NULL,
 Email nvarchar(254) NULL,
 Address nvarchar(500) NULL,
 LinkedUserId int NULL CONSTRAINT FK_Suppliers_Users REFERENCES dbo.Users(UserId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Suppliers_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Suppliers_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Suppliers_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Suppliers_Type CHECK(SupplierType IN ('INDIVIDUAL','ORGANIZATION')),
 CONSTRAINT CK_Suppliers_Status CHECK(Status IN ('ACTIVE','INACTIVE'))
);
CREATE TABLE dbo.PurchaseReceipts (
 ReceiptId int IDENTITY(1,1) CONSTRAINT PK_PurchaseReceipts PRIMARY KEY,
 ReceiptCode varchar(40) NOT NULL CONSTRAINT UQ_PurchaseReceipts_Code UNIQUE,
 SupplierId int NOT NULL CONSTRAINT FK_PurchaseReceipts_Suppliers REFERENCES dbo.Suppliers(SupplierId),
 StoreId int NOT NULL CONSTRAINT FK_PurchaseReceipts_Stores REFERENCES dbo.Stores(StoreId),
 CreatedBy int NOT NULL CONSTRAINT FK_PurchaseReceipts_Creator REFERENCES dbo.Users(UserId),
 Status varchar(20) NOT NULL CONSTRAINT DF_PurchaseReceipts_Status DEFAULT ('DRAFT'),
 TotalAmount decimal(19,2) NOT NULL CONSTRAINT DF_PurchaseReceipts_Total DEFAULT (0),
 ReceivedAt datetime2(3) NULL,
 Note nvarchar(1000) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_PurchaseReceipts_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_PurchaseReceipts_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_PurchaseReceipts_Status CHECK(Status IN ('DRAFT','RECEIVED','CANCELLED')),
 CONSTRAINT CK_PurchaseReceipts_Total CHECK(TotalAmount >= 0),
 CONSTRAINT CK_PurchaseReceipts_Received CHECK((Status='RECEIVED' AND ReceivedAt IS NOT NULL AND ReceivedAt >= CreatedAt)
  OR (Status IN ('DRAFT','CANCELLED') AND ReceivedAt IS NULL))
);
CREATE TABLE dbo.PurchaseReceiptItems (
 ReceiptItemId int IDENTITY(1,1) CONSTRAINT PK_PurchaseReceiptItems PRIMARY KEY,
 ReceiptId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Receipts REFERENCES dbo.PurchaseReceipts(ReceiptId),
 BookId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Books REFERENCES dbo.Books(BookId),
 ConditionId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 Quantity int NOT NULL,
 UnitCost decimal(19,2) NOT NULL,
 Note nvarchar(1000) NULL,
 CONSTRAINT UQ_PurchaseReceiptItems_ItemBook UNIQUE(ReceiptItemId,BookId),
 CONSTRAINT CK_PurchaseReceiptItems_Quantity CHECK(Quantity > 0),
 CONSTRAINT CK_PurchaseReceiptItems_Cost CHECK(UnitCost >= 0)
);
CREATE TABLE dbo.BookCopies (
 CopyId int IDENTITY(1,1) CONSTRAINT PK_BookCopies PRIMARY KEY,
 CopyCode varchar(50) NOT NULL CONSTRAINT UQ_BookCopies_Code UNIQUE,
 BookId int NOT NULL CONSTRAINT FK_BookCopies_Books REFERENCES dbo.Books(BookId),
 StoreId int NOT NULL CONSTRAINT FK_BookCopies_Stores REFERENCES dbo.Stores(StoreId),
 ConditionId int NOT NULL CONSTRAINT FK_BookCopies_Conditions REFERENCES dbo.BookConditions(ConditionId),
 PurchaseReceiptItemId int NULL,
 CostPrice decimal(19,2) NOT NULL,
 SalePrice decimal(19,2) NOT NULL,
 ConditionNotes nvarchar(1000) NULL,
 ShelfLocation nvarchar(100) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_BookCopies_Status DEFAULT ('AVAILABLE'),
 Version bigint NOT NULL CONSTRAINT DF_BookCopies_Version DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_BookCopies_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_BookCopies_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT FK_BookCopies_ReceiptItemBook FOREIGN KEY(PurchaseReceiptItemId,BookId)
  REFERENCES dbo.PurchaseReceiptItems(ReceiptItemId,BookId),
 CONSTRAINT CK_BookCopies_Prices CHECK(CostPrice >= 0 AND SalePrice >= 0),
 CONSTRAINT CK_BookCopies_Version CHECK(Version >= 0),
 CONSTRAINT CK_BookCopies_Status CHECK(Status IN ('AVAILABLE','RESERVED','SOLD','IN_TRANSIT','DAMAGED','LOST'))
);
CREATE TABLE dbo.MediaAssets (
 MediaId int IDENTITY(1,1) CONSTRAINT PK_MediaAssets PRIMARY KEY,
 Provider varchar(20) NOT NULL,
 Url nvarchar(2048) NOT NULL,
 PublicId varchar(255) COLLATE Latin1_General_100_BIN2 NULL,
 ResourceType varchar(20) NOT NULL CONSTRAINT DF_MediaAssets_ResourceType DEFAULT ('image'),
 Format varchar(20) NULL,
 Width int NULL,
 Height int NULL,
 AltText nvarchar(255) NULL,
 SortOrder int NOT NULL CONSTRAINT DF_MediaAssets_SortOrder DEFAULT (0),
 IsPrimary bit NOT NULL CONSTRAINT DF_MediaAssets_IsPrimary DEFAULT (0),
 BookId int NULL CONSTRAINT FK_MediaAssets_Books REFERENCES dbo.Books(BookId),
 CopyId int NULL CONSTRAINT FK_MediaAssets_Copies REFERENCES dbo.BookCopies(CopyId),
 AuthorId int NULL CONSTRAINT FK_MediaAssets_Authors REFERENCES dbo.Authors(AuthorId),
 UserId int NULL CONSTRAINT FK_MediaAssets_Users REFERENCES dbo.Users(UserId),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_MediaAssets_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_MediaAssets_Provider CHECK(Provider IN ('LOCAL','CLOUDINARY')),
 CONSTRAINT CK_MediaAssets_Resource CHECK(ResourceType='image'),
 CONSTRAINT CK_MediaAssets_Url CHECK((Provider='LOCAL' AND Url LIKE '/images/%') OR
  (Provider='CLOUDINARY' AND Url LIKE 'https://%' AND PublicId IS NOT NULL AND LEN(PublicId)>0)),
 CONSTRAINT CK_MediaAssets_Size CHECK((Width IS NULL OR Width>0) AND (Height IS NULL OR Height>0) AND SortOrder>=0),
 CONSTRAINT CK_MediaAssets_Owner CHECK(
  (CASE WHEN BookId IS NULL THEN 0 ELSE 1 END)+(CASE WHEN CopyId IS NULL THEN 0 ELSE 1 END)+
  (CASE WHEN AuthorId IS NULL THEN 0 ELSE 1 END)+(CASE WHEN UserId IS NULL THEN 0 ELSE 1 END)=1)
);
CREATE UNIQUE INDEX UX_MediaAssets_PublicId ON dbo.MediaAssets(Provider,PublicId) WHERE PublicId IS NOT NULL;
CREATE UNIQUE INDEX UX_MediaAssets_BookPrimary ON dbo.MediaAssets(BookId) WHERE BookId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_CopyPrimary ON dbo.MediaAssets(CopyId) WHERE CopyId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_AuthorPrimary ON dbo.MediaAssets(AuthorId) WHERE AuthorId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_UserPrimary ON dbo.MediaAssets(UserId) WHERE UserId IS NOT NULL AND IsPrimary=1;
CREATE TABLE dbo.StockTransfers (
 TransferId int IDENTITY(1,1) CONSTRAINT PK_StockTransfers PRIMARY KEY,
 TransferCode varchar(40) NOT NULL CONSTRAINT UQ_StockTransfers_Code UNIQUE,
 FromStoreId int NOT NULL CONSTRAINT FK_StockTransfers_FromStore REFERENCES dbo.Stores(StoreId),
 ToStoreId int NOT NULL CONSTRAINT FK_StockTransfers_ToStore REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_StockTransfers_Status DEFAULT ('DRAFT'),
 RequestedBy int NOT NULL CONSTRAINT FK_StockTransfers_Requester REFERENCES dbo.Users(UserId),
 ApprovedBy int NULL CONSTRAINT FK_StockTransfers_Approver REFERENCES dbo.Users(UserId),
 ShippedAt datetime2(3) NULL,
 ReceivedAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_StockTransfers_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_StockTransfers_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_StockTransfers_Stores CHECK(FromStoreId<>ToStoreId),
 CONSTRAINT CK_StockTransfers_Status CHECK(Status IN ('DRAFT','APPROVED','IN_TRANSIT','RECEIVED','CANCELLED')),
 CONSTRAINT CK_StockTransfers_Dates CHECK((ShippedAt IS NULL OR ShippedAt>=CreatedAt)
  AND (ReceivedAt IS NULL OR (ShippedAt IS NOT NULL AND ReceivedAt>=ShippedAt))),
 CONSTRAINT CK_StockTransfers_Approval CHECK(Status NOT IN ('APPROVED','IN_TRANSIT','RECEIVED') OR ApprovedBy IS NOT NULL),
 CONSTRAINT CK_StockTransfers_Shipped CHECK(Status NOT IN ('IN_TRANSIT','RECEIVED') OR ShippedAt IS NOT NULL),
 CONSTRAINT CK_StockTransfers_Received CHECK(Status<>'RECEIVED' OR ReceivedAt IS NOT NULL)
);
CREATE TABLE dbo.StockTransferItems (
 TransferItemId int IDENTITY(1,1) CONSTRAINT PK_StockTransferItems PRIMARY KEY,
 TransferId int NOT NULL CONSTRAINT FK_StockTransferItems_Transfers REFERENCES dbo.StockTransfers(TransferId),
 CopyId int NOT NULL CONSTRAINT FK_StockTransferItems_Copies REFERENCES dbo.BookCopies(CopyId),
 SentConditionId int NOT NULL CONSTRAINT FK_StockTransferItems_SentCondition REFERENCES dbo.BookConditions(ConditionId),
 ReceivedConditionId int NULL CONSTRAINT FK_StockTransferItems_ReceivedCondition REFERENCES dbo.BookConditions(ConditionId),
 ReceiptStatus varchar(20) NOT NULL CONSTRAINT DF_StockTransferItems_Status DEFAULT ('PENDING'),
 Note nvarchar(1000) NULL,
 CONSTRAINT UQ_StockTransferItems_TransferCopy UNIQUE(TransferId,CopyId),
 CONSTRAINT UQ_StockTransferItems_ItemCopy UNIQUE(TransferItemId,CopyId),
 CONSTRAINT CK_StockTransferItems_Status CHECK(ReceiptStatus IN ('PENDING','RECEIVED','MISSING','DAMAGED')),
 CONSTRAINT CK_StockTransferItems_Condition CHECK(ReceiptStatus NOT IN ('RECEIVED','DAMAGED') OR ReceivedConditionId IS NOT NULL)
);
CREATE TABLE dbo.Stocktakes (
 StocktakeId int IDENTITY(1,1) CONSTRAINT PK_Stocktakes PRIMARY KEY,
 StoreId int NOT NULL CONSTRAINT FK_Stocktakes_Stores REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Stocktakes_Status DEFAULT ('DRAFT'),
 StartedAt datetime2(3) NULL,
 FinalizedAt datetime2(3) NULL,
 CreatedBy int NOT NULL CONSTRAINT FK_Stocktakes_Creator REFERENCES dbo.Users(UserId),
 ApprovedBy int NULL CONSTRAINT FK_Stocktakes_Approver REFERENCES dbo.Users(UserId),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stocktakes_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Stocktakes_Status CHECK(Status IN ('DRAFT','COUNTING','FINALIZED','CANCELLED')),
 CONSTRAINT CK_Stocktakes_Dates CHECK((StartedAt IS NULL OR StartedAt>=CreatedAt)
  AND (FinalizedAt IS NULL OR (StartedAt IS NOT NULL AND FinalizedAt>=StartedAt))),
 CONSTRAINT CK_Stocktakes_Started CHECK(Status NOT IN ('COUNTING','FINALIZED') OR StartedAt IS NOT NULL),
 CONSTRAINT CK_Stocktakes_Finalized CHECK(Status<>'FINALIZED' OR (FinalizedAt IS NOT NULL AND ApprovedBy IS NOT NULL))
);
CREATE UNIQUE INDEX UX_Stocktakes_Counting ON dbo.Stocktakes(StoreId) WHERE Status='COUNTING';
CREATE TABLE dbo.StocktakeItems (
 StocktakeItemId int IDENTITY(1,1) CONSTRAINT PK_StocktakeItems PRIMARY KEY,
 StocktakeId int NOT NULL CONSTRAINT FK_StocktakeItems_Stocktakes REFERENCES dbo.Stocktakes(StocktakeId),
 CopyId int NOT NULL CONSTRAINT FK_StocktakeItems_Copies REFERENCES dbo.BookCopies(CopyId),
 ExpectedPresent bit NOT NULL,
 ActualPresent bit NULL,
 ActualConditionId int NULL CONSTRAINT FK_StocktakeItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 DifferenceReason nvarchar(1000) NULL,
 CONSTRAINT UQ_StocktakeItems_StocktakeCopy UNIQUE(StocktakeId,CopyId),
 CONSTRAINT UQ_StocktakeItems_ItemCopy UNIQUE(StocktakeItemId,CopyId),
 CONSTRAINT CK_StocktakeItems_Condition CHECK(ActualPresent IS NULL OR ActualPresent=0 OR ActualConditionId IS NOT NULL)
);
CREATE TABLE dbo.Carts (
 CartId int IDENTITY(1,1) CONSTRAINT PK_Carts PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_Carts_Users REFERENCES dbo.Users(UserId),
 StoreId int NOT NULL CONSTRAINT FK_Carts_Stores REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Carts_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Carts_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Carts_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Carts_Status CHECK(Status IN ('ACTIVE','CHECKED_OUT','ABANDONED'))
);
CREATE UNIQUE INDEX UX_Carts_Active ON dbo.Carts(UserId,StoreId) WHERE Status='ACTIVE';
CREATE TABLE dbo.CartItems (
 CartItemId int IDENTITY(1,1) CONSTRAINT PK_CartItems PRIMARY KEY,
 CartId int NOT NULL CONSTRAINT FK_CartItems_Carts REFERENCES dbo.Carts(CartId),
 CopyId int NOT NULL CONSTRAINT FK_CartItems_Copies REFERENCES dbo.BookCopies(CopyId),
 AddedAt datetime2(3) NOT NULL CONSTRAINT DF_CartItems_AddedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_CartItems_CartCopy UNIQUE(CartId,CopyId)
);
CREATE TABLE dbo.Orders (
 OrderId int IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
 OrderCode varchar(40) NOT NULL CONSTRAINT UQ_Orders_Code UNIQUE,
 StoreId int NOT NULL CONSTRAINT FK_Orders_Stores REFERENCES dbo.Stores(StoreId),
 CustomerId int NULL CONSTRAINT FK_Orders_Customer REFERENCES dbo.Users(UserId),
 CreatedBy int NULL CONSTRAINT FK_Orders_Creator REFERENCES dbo.Users(UserId),
 Channel varchar(10) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('PENDING'),
 RecipientName nvarchar(150) NULL,
 RecipientPhone varchar(20) NULL,
 ShippingAddressSnapshot nvarchar(1000) NULL,
 Subtotal decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT (0),
 DiscountAmount decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Discount DEFAULT (0),
 ShippingFee decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Shipping DEFAULT (0),
 TotalAmount decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Total DEFAULT (0),
 Version bigint NOT NULL CONSTRAINT DF_Orders_Version DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Orders_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Orders_OrderStore UNIQUE(OrderId,StoreId),
 CONSTRAINT CK_Orders_Channel CHECK(Channel IN ('ONLINE','POS')),
 CONSTRAINT CK_Orders_Actor CHECK((Channel='ONLINE' AND CustomerId IS NOT NULL) OR (Channel='POS' AND CreatedBy IS NOT NULL)),
 CONSTRAINT CK_Orders_Status CHECK(Status IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_Orders_Money CHECK(Subtotal>=0 AND DiscountAmount>=0 AND DiscountAmount<=Subtotal AND ShippingFee>=0
  AND TotalAmount=Subtotal-DiscountAmount+ShippingFee),
 CONSTRAINT CK_Orders_Version CHECK(Version>=0)
);
CREATE TABLE dbo.OrderItems (
 OrderItemId int IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_OrderItems_Orders REFERENCES dbo.Orders(OrderId),
 CopyId int NOT NULL CONSTRAINT FK_OrderItems_Copies REFERENCES dbo.BookCopies(CopyId),
 BookTitleSnapshot nvarchar(255) NOT NULL,
 ConditionSnapshot nvarchar(255) NOT NULL,
 UnitPrice decimal(19,2) NOT NULL,
 UnitCostSnapshot decimal(19,2) NOT NULL,
 DiscountAmount decimal(19,2) NOT NULL CONSTRAINT DF_OrderItems_Discount DEFAULT (0),
 LineTotal decimal(19,2) NOT NULL,
 CONSTRAINT UQ_OrderItems_OrderCopy UNIQUE(OrderId,CopyId),
 CONSTRAINT UQ_OrderItems_ItemOrder UNIQUE(OrderItemId,OrderId),
 CONSTRAINT UQ_OrderItems_ItemCopy UNIQUE(OrderItemId,CopyId),
 CONSTRAINT CK_OrderItems_Money CHECK(UnitPrice>=0 AND UnitCostSnapshot>=0 AND DiscountAmount>=0
  AND DiscountAmount<=UnitPrice AND LineTotal=UnitPrice-DiscountAmount)
);
CREATE TABLE dbo.StockReservations (
 ReservationId int IDENTITY(1,1) CONSTRAINT PK_StockReservations PRIMARY KEY,
 CopyId int NOT NULL,
 OrderId int NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_StockReservations_Status DEFAULT ('ACTIVE'),
 ReservedAt datetime2(3) NOT NULL CONSTRAINT DF_StockReservations_ReservedAt DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NOT NULL,
 ReleasedAt datetime2(3) NULL,
 CONSTRAINT FK_StockReservations_OrderCopy FOREIGN KEY(OrderId,CopyId) REFERENCES dbo.OrderItems(OrderId,CopyId),
 CONSTRAINT CK_StockReservations_Status CHECK(Status IN ('ACTIVE','CONSUMED','EXPIRED','CANCELLED')),
 CONSTRAINT CK_StockReservations_Dates CHECK(ExpiresAt>ReservedAt AND
  ((Status='ACTIVE' AND ReleasedAt IS NULL) OR (Status<>'ACTIVE' AND ReleasedAt IS NOT NULL AND ReleasedAt>=ReservedAt)))
);
CREATE UNIQUE INDEX UX_StockReservations_ActiveCopy ON dbo.StockReservations(CopyId) WHERE Status='ACTIVE';
CREATE TABLE dbo.Payments (
 PaymentId int IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_Payments_Orders REFERENCES dbo.Orders(OrderId),
 Method varchar(20) NOT NULL,
 Provider varchar(50) NOT NULL,
 Amount decimal(19,2) NOT NULL,
 Currency char(3) NOT NULL CONSTRAINT DF_Payments_Currency DEFAULT ('VND'),
 Status varchar(20) NOT NULL CONSTRAINT DF_Payments_Status DEFAULT ('PENDING'),
 ProviderTransactionId varchar(150) COLLATE Latin1_General_100_BIN2 NULL,
 IdempotencyKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_Payments_Idempotency UNIQUE,
 PaidAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Payments_PaymentOrder UNIQUE(PaymentId,OrderId),
 CONSTRAINT CK_Payments_Method CHECK(Method IN ('CASH','BANK_TRANSFER','CARD','E_WALLET','COD')),
 CONSTRAINT CK_Payments_Status CHECK(Status IN ('PENDING','SUCCEEDED','FAILED','CANCELLED')),
 CONSTRAINT CK_Payments_Amount CHECK(Amount>0),
 CONSTRAINT CK_Payments_Currency CHECK(Currency='VND'),
 CONSTRAINT CK_Payments_Paid CHECK((Status='SUCCEEDED' AND PaidAt IS NOT NULL AND PaidAt>=CreatedAt)
  OR (Status<>'SUCCEEDED' AND PaidAt IS NULL))
);
CREATE UNIQUE INDEX UX_Payments_ProviderTransaction ON dbo.Payments(Provider,ProviderTransactionId) WHERE ProviderTransactionId IS NOT NULL;
CREATE TABLE dbo.OrderStatusHistory (
 HistoryId bigint IDENTITY(1,1) CONSTRAINT PK_OrderStatusHistory PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_OrderStatusHistory_Orders REFERENCES dbo.Orders(OrderId),
 FromStatus varchar(20) NULL,
 ToStatus varchar(20) NOT NULL,
 ChangedBy int NULL CONSTRAINT FK_OrderStatusHistory_Users REFERENCES dbo.Users(UserId),
 ChangedAt datetime2(3) NOT NULL CONSTRAINT DF_OrderStatusHistory_ChangedAt DEFAULT SYSUTCDATETIME(),
 Reason nvarchar(1000) NULL,
 CONSTRAINT CK_OrderStatusHistory_From CHECK(FromStatus IS NULL OR FromStatus IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_OrderStatusHistory_To CHECK(ToStatus IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_OrderStatusHistory_Change CHECK(FromStatus IS NULL OR FromStatus<>ToStatus)
);
CREATE TABLE dbo.SalesReturns (
 ReturnId int IDENTITY(1,1) CONSTRAINT PK_SalesReturns PRIMARY KEY,
 OrderId int NOT NULL,
 ReceivingStoreId int NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_SalesReturns_Status DEFAULT ('REQUESTED'),
 RequestedBy int NULL CONSTRAINT FK_SalesReturns_Requester REFERENCES dbo.Users(UserId),
 ProcessedBy int NULL CONSTRAINT FK_SalesReturns_Processor REFERENCES dbo.Users(UserId),
 Reason nvarchar(1000) NOT NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_SalesReturns_CreatedAt DEFAULT SYSUTCDATETIME(),
 ApprovedAt datetime2(3) NULL,
 CONSTRAINT UQ_SalesReturns_ReturnOrder UNIQUE(ReturnId,OrderId),
 CONSTRAINT FK_SalesReturns_OrderStore FOREIGN KEY(OrderId,ReceivingStoreId) REFERENCES dbo.Orders(OrderId,StoreId),
 CONSTRAINT CK_SalesReturns_Status CHECK(Status IN ('REQUESTED','APPROVED','COMPLETED','REJECTED','CANCELLED')),
 CONSTRAINT CK_SalesReturns_Approval CHECK(Status NOT IN ('APPROVED','COMPLETED') OR
  (ProcessedBy IS NOT NULL AND ApprovedAt IS NOT NULL AND ApprovedAt>=CreatedAt))
);
CREATE TABLE dbo.SalesReturnItems (
 ReturnItemId int IDENTITY(1,1) CONSTRAINT PK_SalesReturnItems PRIMARY KEY,
 ReturnId int NOT NULL,
 OrderId int NOT NULL,
 OrderItemId int NOT NULL,
 ReceivedConditionId int NULL CONSTRAINT FK_SalesReturnItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 Resolution varchar(20) NULL,
 RefundAmount decimal(19,2) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_SalesReturnItems_Status DEFAULT ('PENDING'),
 CONSTRAINT FK_SalesReturnItems_ReturnOrder FOREIGN KEY(ReturnId,OrderId) REFERENCES dbo.SalesReturns(ReturnId,OrderId),
 CONSTRAINT FK_SalesReturnItems_ItemOrder FOREIGN KEY(OrderItemId,OrderId) REFERENCES dbo.OrderItems(OrderItemId,OrderId),
 CONSTRAINT UQ_SalesReturnItems_ReturnItem UNIQUE(ReturnId,OrderItemId),
 CONSTRAINT UQ_SalesReturnItems_ItemOrderItem UNIQUE(ReturnItemId,OrderItemId),
 CONSTRAINT CK_SalesReturnItems_Resolution CHECK(Resolution IS NULL OR Resolution IN ('RESTOCK','DAMAGED')),
 CONSTRAINT CK_SalesReturnItems_Status CHECK(Status IN ('PENDING','ACCEPTED','REJECTED')),
 CONSTRAINT CK_SalesReturnItems_Refund CHECK(RefundAmount>=0),
 CONSTRAINT CK_SalesReturnItems_Accepted CHECK(Status<>'ACCEPTED' OR (ReceivedConditionId IS NOT NULL AND Resolution IS NOT NULL))
);
CREATE UNIQUE INDEX UX_SalesReturnItems_Accepted ON dbo.SalesReturnItems(OrderItemId) WHERE Status='ACCEPTED';
CREATE TABLE dbo.Refunds (
 RefundId int IDENTITY(1,1) CONSTRAINT PK_Refunds PRIMARY KEY,
 ReturnId int NULL,
 PaymentId int NOT NULL,
 OrderId int NOT NULL,
 Amount decimal(19,2) NOT NULL,
 Reason nvarchar(1000) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Refunds_Status DEFAULT ('PENDING'),
 Provider varchar(50) NOT NULL,
 ProviderRefundId varchar(150) COLLATE Latin1_General_100_BIN2 NULL,
 IdempotencyKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_Refunds_Idempotency UNIQUE,
 RefundedAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Refunds_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT FK_Refunds_ReturnOrder FOREIGN KEY(ReturnId,OrderId) REFERENCES dbo.SalesReturns(ReturnId,OrderId),
 CONSTRAINT FK_Refunds_PaymentOrder FOREIGN KEY(PaymentId,OrderId) REFERENCES dbo.Payments(PaymentId,OrderId),
 CONSTRAINT CK_Refunds_Amount CHECK(Amount>0),
 CONSTRAINT CK_Refunds_Status CHECK(Status IN ('PENDING','SUCCEEDED','FAILED','CANCELLED')),
 CONSTRAINT CK_Refunds_Date CHECK((Status='SUCCEEDED' AND RefundedAt IS NOT NULL AND RefundedAt>=CreatedAt)
  OR (Status<>'SUCCEEDED' AND RefundedAt IS NULL))
);
CREATE UNIQUE INDEX UX_Refunds_ProviderRefund ON dbo.Refunds(Provider,ProviderRefundId) WHERE ProviderRefundId IS NOT NULL;
CREATE TABLE dbo.RefreshTokens (
 RefreshTokenId bigint IDENTITY(1,1) CONSTRAINT PK_RefreshTokens PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_RefreshTokens_Users REFERENCES dbo.Users(UserId),
 TokenHash binary(32) NOT NULL CONSTRAINT UQ_RefreshTokens_Hash UNIQUE,
 FamilyId uniqueidentifier NOT NULL CONSTRAINT DF_RefreshTokens_Family DEFAULT NEWID(),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_RefreshTokens_CreatedAt DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NOT NULL,
 RevokedAt datetime2(3) NULL,
 ReplacedByTokenId bigint NULL,
 CONSTRAINT UQ_RefreshTokens_TokenUserFamily UNIQUE(RefreshTokenId,UserId,FamilyId),
 CONSTRAINT FK_RefreshTokens_Replacement FOREIGN KEY(ReplacedByTokenId,UserId,FamilyId)
  REFERENCES dbo.RefreshTokens(RefreshTokenId,UserId,FamilyId),
 CONSTRAINT CK_RefreshTokens_Dates CHECK(ExpiresAt>CreatedAt AND (RevokedAt IS NULL OR RevokedAt>=CreatedAt)),
 CONSTRAINT CK_RefreshTokens_Replacement CHECK(ReplacedByTokenId IS NULL OR
  (ReplacedByTokenId<>RefreshTokenId AND RevokedAt IS NOT NULL))
);
CREATE UNIQUE INDEX UX_RefreshTokens_Replacement ON dbo.RefreshTokens(ReplacedByTokenId) WHERE ReplacedByTokenId IS NOT NULL;
CREATE TABLE dbo.Notifications (
 NotificationId bigint IDENTITY(1,1) CONSTRAINT PK_Notifications PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_Notifications_Users REFERENCES dbo.Users(UserId),
 StoreId int NULL CONSTRAINT FK_Notifications_Stores REFERENCES dbo.Stores(StoreId),
 Type varchar(50) NOT NULL,
 Title nvarchar(200) NOT NULL,
 Content nvarchar(2000) NOT NULL,
 TargetUrl nvarchar(2048) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT SYSUTCDATETIME(),
 ReadAt datetime2(3) NULL,
 CONSTRAINT CK_Notifications_Read CHECK(ReadAt IS NULL OR ReadAt>=CreatedAt)
);
CREATE TABLE dbo.AuditLogs (
 AuditId bigint IDENTITY(1,1) CONSTRAINT PK_AuditLogs PRIMARY KEY,
 ActorId int NULL CONSTRAINT FK_AuditLogs_Users REFERENCES dbo.Users(UserId),
 StoreId int NULL CONSTRAINT FK_AuditLogs_Stores REFERENCES dbo.Stores(StoreId),
 Action varchar(100) NOT NULL,
 EntityType varchar(100) NOT NULL,
 EntityId varchar(100) NULL,
 Summary nvarchar(2000) NOT NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt DEFAULT SYSUTCDATETIME(),
 CorrelationId uniqueidentifier NULL
);
CREATE TABLE dbo.InventoryMovements (
 MovementId bigint IDENTITY(1,1) CONSTRAINT PK_InventoryMovements PRIMARY KEY,
 CopyId int NOT NULL CONSTRAINT FK_InventoryMovements_Copies REFERENCES dbo.BookCopies(CopyId),
 FromStoreId int NULL CONSTRAINT FK_InventoryMovements_FromStore REFERENCES dbo.Stores(StoreId),
 ToStoreId int NULL CONSTRAINT FK_InventoryMovements_ToStore REFERENCES dbo.Stores(StoreId),
 MovementType varchar(30) NOT NULL,
 OccurredAt datetime2(3) NOT NULL CONSTRAINT DF_InventoryMovements_OccurredAt DEFAULT SYSUTCDATETIME(),
 ActorId int NOT NULL CONSTRAINT FK_InventoryMovements_Actor REFERENCES dbo.Users(UserId),
 ReceiptItemId int NULL CONSTRAINT FK_InventoryMovements_ReceiptItem REFERENCES dbo.PurchaseReceiptItems(ReceiptItemId),
 OrderItemId int NULL,
 TransferItemId int NULL,
 ReturnItemId int NULL,
 StocktakeItemId int NULL,
 Reason nvarchar(1000) NULL,
 OperationKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_InventoryMovements_Operation UNIQUE,
 CONSTRAINT FK_InventoryMovements_OrderCopy FOREIGN KEY(OrderItemId,CopyId) REFERENCES dbo.OrderItems(OrderItemId,CopyId),
 CONSTRAINT FK_InventoryMovements_TransferCopy FOREIGN KEY(TransferItemId,CopyId) REFERENCES dbo.StockTransferItems(TransferItemId,CopyId),
 CONSTRAINT FK_InventoryMovements_ReturnItem FOREIGN KEY(ReturnItemId,OrderItemId) REFERENCES dbo.SalesReturnItems(ReturnItemId,OrderItemId),
 CONSTRAINT FK_InventoryMovements_StocktakeCopy FOREIGN KEY(StocktakeItemId,CopyId) REFERENCES dbo.StocktakeItems(StocktakeItemId,CopyId),
 CONSTRAINT CK_InventoryMovements_Type CHECK(MovementType IN ('RECEIPT','SALE','TRANSFER_OUT','TRANSFER_IN','RETURN','ADJUSTMENT')),
 CONSTRAINT CK_InventoryMovements_Reference CHECK(
  (MovementType='RECEIPT' AND ReceiptItemId IS NOT NULL AND OrderItemId IS NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType='SALE' AND ReceiptItemId IS NULL AND OrderItemId IS NOT NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType IN ('TRANSFER_OUT','TRANSFER_IN') AND ReceiptItemId IS NULL AND OrderItemId IS NULL AND TransferItemId IS NOT NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType='RETURN' AND ReceiptItemId IS NULL AND OrderItemId IS NOT NULL AND TransferItemId IS NULL AND ReturnItemId IS NOT NULL AND StocktakeItemId IS NULL)
  OR (MovementType='ADJUSTMENT' AND ReceiptItemId IS NULL AND OrderItemId IS NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NOT NULL AND Reason IS NOT NULL)),
 CONSTRAINT CK_InventoryMovements_Stores CHECK(
  (MovementType IN ('RECEIPT','RETURN') AND FromStoreId IS NULL AND ToStoreId IS NOT NULL)
  OR (MovementType='SALE' AND FromStoreId IS NOT NULL AND ToStoreId IS NULL)
  OR (MovementType IN ('TRANSFER_OUT','TRANSFER_IN') AND FromStoreId IS NOT NULL AND ToStoreId IS NOT NULL AND FromStoreId<>ToStoreId)
  OR (MovementType='ADJUSTMENT' AND (FromStoreId IS NOT NULL OR ToStoreId IS NOT NULL)))
);

-- Query and FK support indexes. Foreign keys use NO ACTION; history is never cascade-deleted.
CREATE INDEX IX_UserRoles_Role ON dbo.UserRoles(RoleId);
CREATE INDEX IX_StaffAssignments_Store ON dbo.StaffStoreAssignments(StoreId,Status);
CREATE INDEX IX_CustomerAddresses_User ON dbo.CustomerAddresses(UserId);
CREATE INDEX IX_Suppliers_User ON dbo.Suppliers(LinkedUserId);
CREATE INDEX IX_PurchaseReceipts_StoreDate ON dbo.PurchaseReceipts(StoreId,CreatedAt,Status);
CREATE INDEX IX_PurchaseReceipts_Supplier ON dbo.PurchaseReceipts(SupplierId);
CREATE INDEX IX_PurchaseReceiptItems_Receipt ON dbo.PurchaseReceiptItems(ReceiptId);
CREATE INDEX IX_PurchaseReceiptItems_Book ON dbo.PurchaseReceiptItems(BookId);
CREATE INDEX IX_BookCopies_StoreBookStatus ON dbo.BookCopies(StoreId,BookId,Status) INCLUDE(ConditionId,SalePrice);
CREATE INDEX IX_BookCopies_Book ON dbo.BookCopies(BookId);
CREATE INDEX IX_BookCopies_ReceiptItem ON dbo.BookCopies(PurchaseReceiptItemId,BookId);
CREATE INDEX IX_MediaAssets_Book ON dbo.MediaAssets(BookId,SortOrder);
CREATE INDEX IX_MediaAssets_Copy ON dbo.MediaAssets(CopyId,SortOrder);
CREATE INDEX IX_MediaAssets_Author ON dbo.MediaAssets(AuthorId);
CREATE INDEX IX_MediaAssets_User ON dbo.MediaAssets(UserId);
CREATE INDEX IX_StockTransfers_From ON dbo.StockTransfers(FromStoreId,Status,CreatedAt);
CREATE INDEX IX_StockTransfers_To ON dbo.StockTransfers(ToStoreId,Status,CreatedAt);
CREATE INDEX IX_StockTransferItems_Copy ON dbo.StockTransferItems(CopyId);
CREATE INDEX IX_Stocktakes_Store ON dbo.Stocktakes(StoreId,CreatedAt);
CREATE INDEX IX_StocktakeItems_Copy ON dbo.StocktakeItems(CopyId);
CREATE INDEX IX_Carts_Store ON dbo.Carts(StoreId);
CREATE INDEX IX_CartItems_Copy ON dbo.CartItems(CopyId);
CREATE INDEX IX_Orders_StoreDateStatus ON dbo.Orders(StoreId,CreatedAt,Status);
CREATE INDEX IX_Orders_Customer ON dbo.Orders(CustomerId,CreatedAt);
CREATE INDEX IX_OrderItems_Copy ON dbo.OrderItems(CopyId);
CREATE INDEX IX_StockReservations_Order ON dbo.StockReservations(OrderId,CopyId);
CREATE INDEX IX_StockReservations_Expiry ON dbo.StockReservations(ExpiresAt) INCLUDE(CopyId,OrderId) WHERE Status='ACTIVE';
CREATE INDEX IX_Payments_OrderStatus ON dbo.Payments(OrderId,Status);
CREATE INDEX IX_OrderStatusHistory_OrderDate ON dbo.OrderStatusHistory(OrderId,ChangedAt);
CREATE INDEX IX_SalesReturns_Order ON dbo.SalesReturns(OrderId,ReceivingStoreId);
CREATE INDEX IX_SalesReturnItems_OrderItem ON dbo.SalesReturnItems(OrderItemId,OrderId);
CREATE INDEX IX_Refunds_Payment ON dbo.Refunds(PaymentId,OrderId,Status);
CREATE INDEX IX_Refunds_Return ON dbo.Refunds(ReturnId,OrderId);
CREATE INDEX IX_RefreshTokens_UserFamily ON dbo.RefreshTokens(UserId,FamilyId);
CREATE INDEX IX_RefreshTokens_Expiry ON dbo.RefreshTokens(ExpiresAt);
CREATE INDEX IX_Notifications_UserRead ON dbo.Notifications(UserId,ReadAt,CreatedAt);
CREATE INDEX IX_AuditLogs_EntityDate ON dbo.AuditLogs(EntityType,EntityId,CreatedAt);
CREATE INDEX IX_AuditLogs_ActorDate ON dbo.AuditLogs(ActorId,CreatedAt);
CREATE INDEX IX_InventoryMovements_CopyDate ON dbo.InventoryMovements(CopyId,OccurredAt);
CREATE INDEX IX_InventoryMovements_FromDate ON dbo.InventoryMovements(FromStoreId,OccurredAt);
CREATE INDEX IX_InventoryMovements_ToDate ON dbo.InventoryMovements(ToStoreId,OccurredAt);

-- Reference values only: no fabricated accounts, stores, stock or orders.
INSERT dbo.Roles(RoleCode,RoleName) VALUES ('ADMIN',N'Quản trị hệ thống'),('CUSTOMER',N'Khách hàng');
INSERT dbo.BookConditions(ConditionCode,ConditionName,Description,SortOrder) VALUES
 ('LIKE_NEW',N'Như mới',N'Sách đã qua sử dụng, gần như không có dấu vết sử dụng.',1),
 ('GOOD',N'Tốt',N'Có dấu vết sử dụng nhẹ, đủ trang và đọc rõ.',2),
 ('FAIR',N'Khá',N'Có nếp gấp, ố hoặc ghi chú; cần mô tả cụ thể từng cuốn.',3),
 ('WORN',N'Cũ nhiều',N'Hao mòn rõ; cần kiểm tra và ghi chú trước khi bán.',4);

IF (SELECT COUNT(*) FROM @expected e JOIN sys.tables t ON t.name=e.TableName AND t.schema_id=SCHEMA_ID('dbo'))<>30
 THROW 51003, 'The 30 core tables were not all created.', 1;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
 THROW 51004, 'Untrusted or disabled foreign keys found.', 1;
COMMIT TRANSACTION;
PRINT 'Migration 002 committed: 30 core tables created; catalog data unchanged.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
