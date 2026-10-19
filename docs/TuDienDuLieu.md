# Từ điển dữ liệu SQL Server

Xuất từ WebsiteQuanLyCuaHangSachCu ngày 11/10/2026, sau khi tạo 30 bảng mới. Độ dài NVARCHAR tính theo ký tự; max nghĩa là không cố định.

## AuditLogs

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| AuditId | bigint | Không | Có | — |
| ActorId | int | Có | — | — |
| StoreId | int | Có | — | — |
| Action | varchar(100) | Không | — | — |
| EntityType | varchar(100) | Không | — | — |
| EntityId | varchar(100) | Có | — | — |
| Summary | nvarchar(2000) | Không | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| CorrelationId | uniqueidentifier | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_AuditLogs: PK (AuditId)

Khóa ngoại:

- FK_AuditLogs_Stores: (StoreId) → Stores (StoreId), NO ACTION.
- FK_AuditLogs_Users: (ActorId) → Users (UserId), NO ACTION.

## Authors

Số dòng tại thời điểm kiểm tra: 122.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| AuthorId | int | Không | Có | — |
| AuthorName | nvarchar(150) | Không | — | — |
| Biography | nvarchar(max) | Có | — | — |
| AuthorPhoto | nvarchar(500) | Có | — | — |
| BirthYear | int | Có | — | — |
| DeathYear | int | Có | — | — |
| Nationality | nvarchar(100) | Có | — | — |
| InfoSourceUrl | nvarchar(1000) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_Authors: PK (AuthorId)
- UQ_Authors_Name: UNIQUE (AuthorName)

## BookAuthors

Số dòng tại thời điểm kiểm tra: 134.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| BookId | int | Không | — | — |
| AuthorId | int | Không | — | — |

Khóa chính và khóa duy nhất:

- PK_BookAuthors: PK (BookId, AuthorId)

Khóa ngoại:

- FK_BookAuthors_Authors: (AuthorId) → Authors (AuthorId), NO ACTION.
- FK_BookAuthors_Books: (BookId) → Books (BookId), NO ACTION.

## BookConditions

Số dòng tại thời điểm kiểm tra: 4.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ConditionId | int | Không | Có | — |
| ConditionCode | varchar(30) | Không | — | — |
| ConditionName | nvarchar(100) | Không | — | — |
| Description | nvarchar(500) | Có | — | — |
| SortOrder | int | Không | — | ((0)) |

Khóa chính và khóa duy nhất:

- PK_BookConditions: PK (ConditionId)
- UQ_BookConditions_Code: UNIQUE (ConditionCode)

CHECK:

- CK_BookConditions_Sort: ([SortOrder]>=(0))

## BookCopies

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| CopyId | int | Không | Có | — |
| CopyCode | varchar(50) | Không | — | — |
| BookId | int | Không | — | — |
| StoreId | int | Không | — | — |
| ConditionId | int | Không | — | — |
| PurchaseReceiptItemId | int | Có | — | — |
| CostPrice | decimal(19,2) | Không | — | — |
| SalePrice | decimal(19,2) | Không | — | — |
| ConditionNotes | nvarchar(1000) | Có | — | — |
| ShelfLocation | nvarchar(100) | Có | — | — |
| Status | varchar(20) | Không | — | ('AVAILABLE') |
| Version | bigint | Không | — | ((0)) |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_BookCopies: PK (CopyId)
- UQ_BookCopies_Code: UNIQUE (CopyCode)

Khóa ngoại:

- FK_BookCopies_Books: (BookId) → Books (BookId), NO ACTION.
- FK_BookCopies_Conditions: (ConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_BookCopies_ReceiptItemBook: (PurchaseReceiptItemId, BookId) → PurchaseReceiptItems (ReceiptItemId, BookId), NO ACTION.
- FK_BookCopies_Stores: (StoreId) → Stores (StoreId), NO ACTION.

CHECK:

- CK_BookCopies_Prices: ([CostPrice]>=(0) AND [SalePrice]>=(0))
- CK_BookCopies_Status: ([Status]='LOST' OR [Status]='DAMAGED' OR [Status]='IN_TRANSIT' OR [Status]='SOLD' OR [Status]='RESERVED' OR [Status]='AVAILABLE')
- CK_BookCopies_Version: ([Version]>=(0))

## Books

Số dòng tại thời điểm kiểm tra: 83.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| BookId | int | Không | Có | — |
| ISBN | varchar(20) | Có | — | — |
| Title | nvarchar(255) | Không | — | — |
| CategoryId | int | Không | — | — |
| PublisherId | int | Không | — | — |
| PublishYear | int | Có | — | — |
| CoverImage | nvarchar(255) | Có | — | — |
| Description | nvarchar(max) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_Books: PK (BookId)
- UX_Books_ISBN: UNIQUE (ISBN); điều kiện ([ISBN] IS NOT NULL)

Khóa ngoại:

- FK_Books_Categories: (CategoryId) → Categories (CategoryId), NO ACTION.
- FK_Books_Publishers: (PublisherId) → Publishers (PublisherId), NO ACTION.

## CartItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| CartItemId | int | Không | Có | — |
| CartId | int | Không | — | — |
| CopyId | int | Không | — | — |
| AddedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_CartItems: PK (CartItemId)
- UQ_CartItems_CartCopy: UNIQUE (CartId, CopyId)

Khóa ngoại:

- FK_CartItems_Carts: (CartId) → Carts (CartId), NO ACTION.
- FK_CartItems_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.

## Carts

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| CartId | int | Không | Có | — |
| UserId | int | Không | — | — |
| StoreId | int | Không | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Carts: PK (CartId)
- UX_Carts_Active: UNIQUE (UserId, StoreId); điều kiện ([Status]='ACTIVE')

Khóa ngoại:

- FK_Carts_Stores: (StoreId) → Stores (StoreId), NO ACTION.
- FK_Carts_Users: (UserId) → Users (UserId), NO ACTION.

CHECK:

- CK_Carts_Status: ([Status]='ABANDONED' OR [Status]='CHECKED_OUT' OR [Status]='ACTIVE')

## Categories

Số dòng tại thời điểm kiểm tra: 10.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| CategoryId | int | Không | Có | — |
| CategoryName | nvarchar(100) | Không | — | — |
| Description | nvarchar(500) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_Categories: PK (CategoryId)
- UQ_Categories_Name: UNIQUE (CategoryName)

## CustomerAddresses

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| AddressId | int | Không | Có | — |
| UserId | int | Không | — | — |
| RecipientName | nvarchar(150) | Không | — | — |
| Phone | varchar(20) | Không | — | — |
| AddressLine | nvarchar(500) | Không | — | — |
| AdministrativeArea | nvarchar(255) | Không | — | — |
| PostalCode | varchar(20) | Có | — | — |
| CountryCode | char(2) | Không | — | ('VN') |
| IsDefault | bit | Không | — | ((0)) |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_CustomerAddresses: PK (AddressId)
- UX_CustomerAddresses_Default: UNIQUE (UserId); điều kiện ([IsDefault]=(1))

Khóa ngoại:

- FK_CustomerAddresses_Users: (UserId) → Users (UserId), NO ACTION.

## InventoryMovements

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| MovementId | bigint | Không | Có | — |
| CopyId | int | Không | — | — |
| FromStoreId | int | Có | — | — |
| ToStoreId | int | Có | — | — |
| MovementType | varchar(30) | Không | — | — |
| OccurredAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| ActorId | int | Không | — | — |
| ReceiptItemId | int | Có | — | — |
| OrderItemId | int | Có | — | — |
| TransferItemId | int | Có | — | — |
| ReturnItemId | int | Có | — | — |
| StocktakeItemId | int | Có | — | — |
| Reason | nvarchar(1000) | Có | — | — |
| OperationKey | varchar(100) | Không | — | — |

Khóa chính và khóa duy nhất:

- PK_InventoryMovements: PK (MovementId)
- UQ_InventoryMovements_Operation: UNIQUE (OperationKey)

Khóa ngoại:

- FK_InventoryMovements_Actor: (ActorId) → Users (UserId), NO ACTION.
- FK_InventoryMovements_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.
- FK_InventoryMovements_FromStore: (FromStoreId) → Stores (StoreId), NO ACTION.
- FK_InventoryMovements_OrderCopy: (OrderItemId, CopyId) → OrderItems (OrderItemId, CopyId), NO ACTION.
- FK_InventoryMovements_ReceiptItem: (ReceiptItemId) → PurchaseReceiptItems (ReceiptItemId), NO ACTION.
- FK_InventoryMovements_ReturnItem: (ReturnItemId, OrderItemId) → SalesReturnItems (ReturnItemId, OrderItemId), NO ACTION.
- FK_InventoryMovements_StocktakeCopy: (StocktakeItemId, CopyId) → StocktakeItems (StocktakeItemId, CopyId), NO ACTION.
- FK_InventoryMovements_ToStore: (ToStoreId) → Stores (StoreId), NO ACTION.
- FK_InventoryMovements_TransferCopy: (TransferItemId, CopyId) → StockTransferItems (TransferItemId, CopyId), NO ACTION.

CHECK:

- CK_InventoryMovements_Reference: ([MovementType]='RECEIPT' AND [ReceiptItemId] IS NOT NULL AND [OrderItemId] IS NULL AND [TransferItemId] IS NULL AND [ReturnItemId] IS NULL AND [StocktakeItemId] IS NULL OR [MovementType]='SALE' AND [ReceiptItemId] IS NULL AND [OrderItemId] IS NOT NULL AND [TransferItemId] IS NULL AND [ReturnItemId] IS NULL AND [StocktakeItemId] IS NULL OR ([MovementType]='TRANSFER_IN' OR [MovementType]='TRANSFER_OUT') AND [ReceiptItemId] IS NULL AND [OrderItemId] IS NULL AND [TransferItemId] IS NOT NULL AND [ReturnItemId] IS NULL AND [StocktakeItemId] IS NULL OR [MovementType]='RETURN' AND [ReceiptItemId] IS NULL AND [OrderItemId] IS NOT NULL AND [TransferItemId] IS NULL AND [ReturnItemId] IS NOT NULL AND [StocktakeItemId] IS NULL OR [MovementType]='ADJUSTMENT' AND [ReceiptItemId] IS NULL AND [OrderItemId] IS NULL AND [TransferItemId] IS NULL AND [ReturnItemId] IS NULL AND [StocktakeItemId] IS NOT NULL AND [Reason] IS NOT NULL)
- CK_InventoryMovements_Stores: (([MovementType]='RETURN' OR [MovementType]='RECEIPT') AND [FromStoreId] IS NULL AND [ToStoreId] IS NOT NULL OR [MovementType]='SALE' AND [FromStoreId] IS NOT NULL AND [ToStoreId] IS NULL OR ([MovementType]='TRANSFER_IN' OR [MovementType]='TRANSFER_OUT') AND [FromStoreId] IS NOT NULL AND [ToStoreId] IS NOT NULL AND [FromStoreId]<>[ToStoreId] OR [MovementType]='ADJUSTMENT' AND ([FromStoreId] IS NOT NULL OR [ToStoreId] IS NOT NULL))
- CK_InventoryMovements_Type: ([MovementType]='ADJUSTMENT' OR [MovementType]='RETURN' OR [MovementType]='TRANSFER_IN' OR [MovementType]='TRANSFER_OUT' OR [MovementType]='SALE' OR [MovementType]='RECEIPT')

## MediaAssets

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| MediaId | int | Không | Có | — |
| Provider | varchar(20) | Không | — | — |
| Url | nvarchar(2048) | Không | — | — |
| PublicId | varchar(255) | Có | — | — |
| ResourceType | varchar(20) | Không | — | ('image') |
| Format | varchar(20) | Có | — | — |
| Width | int | Có | — | — |
| Height | int | Có | — | — |
| AltText | nvarchar(255) | Có | — | — |
| SortOrder | int | Không | — | ((0)) |
| IsPrimary | bit | Không | — | ((0)) |
| BookId | int | Có | — | — |
| CopyId | int | Có | — | — |
| AuthorId | int | Có | — | — |
| UserId | int | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_MediaAssets: PK (MediaId)
- UX_MediaAssets_AuthorPrimary: UNIQUE (AuthorId); điều kiện ([AuthorId] IS NOT NULL AND [IsPrimary]=(1))
- UX_MediaAssets_BookPrimary: UNIQUE (BookId); điều kiện ([BookId] IS NOT NULL AND [IsPrimary]=(1))
- UX_MediaAssets_CopyPrimary: UNIQUE (CopyId); điều kiện ([CopyId] IS NOT NULL AND [IsPrimary]=(1))
- UX_MediaAssets_PublicId: UNIQUE (Provider, PublicId); điều kiện ([PublicId] IS NOT NULL)
- UX_MediaAssets_UserPrimary: UNIQUE (UserId); điều kiện ([UserId] IS NOT NULL AND [IsPrimary]=(1))

Khóa ngoại:

- FK_MediaAssets_Authors: (AuthorId) → Authors (AuthorId), NO ACTION.
- FK_MediaAssets_Books: (BookId) → Books (BookId), NO ACTION.
- FK_MediaAssets_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.
- FK_MediaAssets_Users: (UserId) → Users (UserId), NO ACTION.

CHECK:

- CK_MediaAssets_Owner: ((((case when [BookId] IS NULL then (0) else (1) end+case when [CopyId] IS NULL then (0) else (1) end)+case when [AuthorId] IS NULL then (0) else (1) end)+case when [UserId] IS NULL then (0) else (1) end)=(1))
- CK_MediaAssets_Provider: ([Provider]='CLOUDINARY' OR [Provider]='LOCAL')
- CK_MediaAssets_Resource: ([ResourceType]='image')
- CK_MediaAssets_Size: (([Width] IS NULL OR [Width]>(0)) AND ([Height] IS NULL OR [Height]>(0)) AND [SortOrder]>=(0))
- CK_MediaAssets_Url: ([Provider]='LOCAL' AND [Url] like '/images/%' OR [Provider]='CLOUDINARY' AND [Url] like 'https://%' AND [PublicId] IS NOT NULL AND len([PublicId])>(0))

## Notifications

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| NotificationId | bigint | Không | Có | — |
| UserId | int | Không | — | — |
| StoreId | int | Có | — | — |
| Type | varchar(50) | Không | — | — |
| Title | nvarchar(200) | Không | — | — |
| Content | nvarchar(2000) | Không | — | — |
| TargetUrl | nvarchar(2048) | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| ReadAt | datetime2(3) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_Notifications: PK (NotificationId)

Khóa ngoại:

- FK_Notifications_Stores: (StoreId) → Stores (StoreId), NO ACTION.
- FK_Notifications_Users: (UserId) → Users (UserId), NO ACTION.

CHECK:

- CK_Notifications_Read: ([ReadAt] IS NULL OR [ReadAt]>=[CreatedAt])

## OrderItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| OrderItemId | int | Không | Có | — |
| OrderId | int | Không | — | — |
| CopyId | int | Không | — | — |
| BookTitleSnapshot | nvarchar(255) | Không | — | — |
| ConditionSnapshot | nvarchar(255) | Không | — | — |
| UnitPrice | decimal(19,2) | Không | — | — |
| UnitCostSnapshot | decimal(19,2) | Không | — | — |
| DiscountAmount | decimal(19,2) | Không | — | ((0)) |
| LineTotal | decimal(19,2) | Không | — | — |

Khóa chính và khóa duy nhất:

- PK_OrderItems: PK (OrderItemId)
- UQ_OrderItems_ItemCopy: UNIQUE (OrderItemId, CopyId)
- UQ_OrderItems_ItemOrder: UNIQUE (OrderItemId, OrderId)
- UQ_OrderItems_OrderCopy: UNIQUE (OrderId, CopyId)

Khóa ngoại:

- FK_OrderItems_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.
- FK_OrderItems_Orders: (OrderId) → Orders (OrderId), NO ACTION.

CHECK:

- CK_OrderItems_Money: ([UnitPrice]>=(0) AND [UnitCostSnapshot]>=(0) AND [DiscountAmount]>=(0) AND [DiscountAmount]<=[UnitPrice] AND [LineTotal]=([UnitPrice]-[DiscountAmount]))

## Orders

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| OrderId | int | Không | Có | — |
| OrderCode | varchar(40) | Không | — | — |
| StoreId | int | Không | — | — |
| CustomerId | int | Có | — | — |
| CreatedBy | int | Có | — | — |
| Channel | varchar(10) | Không | — | — |
| Status | varchar(20) | Không | — | ('PENDING') |
| RecipientName | nvarchar(150) | Có | — | — |
| RecipientPhone | varchar(20) | Có | — | — |
| ShippingAddressSnapshot | nvarchar(1000) | Có | — | — |
| Subtotal | decimal(19,2) | Không | — | ((0)) |
| DiscountAmount | decimal(19,2) | Không | — | ((0)) |
| ShippingFee | decimal(19,2) | Không | — | ((0)) |
| TotalAmount | decimal(19,2) | Không | — | ((0)) |
| Version | bigint | Không | — | ((0)) |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Orders: PK (OrderId)
- UQ_Orders_Code: UNIQUE (OrderCode)
- UQ_Orders_OrderStore: UNIQUE (OrderId, StoreId)

Khóa ngoại:

- FK_Orders_Creator: (CreatedBy) → Users (UserId), NO ACTION.
- FK_Orders_Customer: (CustomerId) → Users (UserId), NO ACTION.
- FK_Orders_Stores: (StoreId) → Stores (StoreId), NO ACTION.

CHECK:

- CK_Orders_Actor: ([Channel]='ONLINE' AND [CustomerId] IS NOT NULL OR [Channel]='POS' AND [CreatedBy] IS NOT NULL)
- CK_Orders_Channel: ([Channel]='POS' OR [Channel]='ONLINE')
- CK_Orders_Money: ([Subtotal]>=(0) AND [DiscountAmount]>=(0) AND [DiscountAmount]<=[Subtotal] AND [ShippingFee]>=(0) AND [TotalAmount]=(([Subtotal]-[DiscountAmount])+[ShippingFee]))
- CK_Orders_Status: ([Status]='CANCELLED' OR [Status]='COMPLETED' OR [Status]='SHIPPED' OR [Status]='PROCESSING' OR [Status]='CONFIRMED' OR [Status]='PENDING')
- CK_Orders_Version: ([Version]>=(0))

## OrderStatusHistory

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| HistoryId | bigint | Không | Có | — |
| OrderId | int | Không | — | — |
| FromStatus | varchar(20) | Có | — | — |
| ToStatus | varchar(20) | Không | — | — |
| ChangedBy | int | Có | — | — |
| ChangedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| Reason | nvarchar(1000) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_OrderStatusHistory: PK (HistoryId)

Khóa ngoại:

- FK_OrderStatusHistory_Orders: (OrderId) → Orders (OrderId), NO ACTION.
- FK_OrderStatusHistory_Users: (ChangedBy) → Users (UserId), NO ACTION.

CHECK:

- CK_OrderStatusHistory_Change: ([FromStatus] IS NULL OR [FromStatus]<>[ToStatus])
- CK_OrderStatusHistory_From: ([FromStatus] IS NULL OR ([FromStatus]='CANCELLED' OR [FromStatus]='COMPLETED' OR [FromStatus]='SHIPPED' OR [FromStatus]='PROCESSING' OR [FromStatus]='CONFIRMED' OR [FromStatus]='PENDING'))
- CK_OrderStatusHistory_To: ([ToStatus]='CANCELLED' OR [ToStatus]='COMPLETED' OR [ToStatus]='SHIPPED' OR [ToStatus]='PROCESSING' OR [ToStatus]='CONFIRMED' OR [ToStatus]='PENDING')

## Payments

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| PaymentId | int | Không | Có | — |
| OrderId | int | Không | — | — |
| Method | varchar(20) | Không | — | — |
| Provider | varchar(50) | Không | — | — |
| Amount | decimal(19,2) | Không | — | — |
| Currency | char(3) | Không | — | ('VND') |
| Status | varchar(20) | Không | — | ('PENDING') |
| ProviderTransactionId | varchar(150) | Có | — | — |
| IdempotencyKey | varchar(100) | Không | — | — |
| PaidAt | datetime2(3) | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Payments: PK (PaymentId)
- UQ_Payments_Idempotency: UNIQUE (IdempotencyKey)
- UQ_Payments_PaymentOrder: UNIQUE (PaymentId, OrderId)
- UX_Payments_ProviderTransaction: UNIQUE (Provider, ProviderTransactionId); điều kiện ([ProviderTransactionId] IS NOT NULL)

Khóa ngoại:

- FK_Payments_Orders: (OrderId) → Orders (OrderId), NO ACTION.

CHECK:

- CK_Payments_Amount: ([Amount]>(0))
- CK_Payments_Currency: ([Currency]='VND')
- CK_Payments_Method: ([Method]='COD' OR [Method]='E_WALLET' OR [Method]='CARD' OR [Method]='BANK_TRANSFER' OR [Method]='CASH')
- CK_Payments_Paid: ([Status]='SUCCEEDED' AND [PaidAt] IS NOT NULL AND [PaidAt]>=[CreatedAt] OR [Status]<>'SUCCEEDED' AND [PaidAt] IS NULL)
- CK_Payments_Status: ([Status]='CANCELLED' OR [Status]='FAILED' OR [Status]='SUCCEEDED' OR [Status]='PENDING')

## Publishers

Số dòng tại thời điểm kiểm tra: 40.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| PublisherId | int | Không | Có | — |
| PublisherName | nvarchar(150) | Không | — | — |
| Address | nvarchar(255) | Có | — | — |
| Phone | varchar(15) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_Publishers: PK (PublisherId)
- UQ_Publishers_Name: UNIQUE (PublisherName)

## PurchaseReceiptItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ReceiptItemId | int | Không | Có | — |
| ReceiptId | int | Không | — | — |
| BookId | int | Không | — | — |
| ConditionId | int | Không | — | — |
| Quantity | int | Không | — | — |
| UnitCost | decimal(19,2) | Không | — | — |
| Note | nvarchar(1000) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_PurchaseReceiptItems: PK (ReceiptItemId)
- UQ_PurchaseReceiptItems_ItemBook: UNIQUE (ReceiptItemId, BookId)

Khóa ngoại:

- FK_PurchaseReceiptItems_Books: (BookId) → Books (BookId), NO ACTION.
- FK_PurchaseReceiptItems_Conditions: (ConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_PurchaseReceiptItems_Receipts: (ReceiptId) → PurchaseReceipts (ReceiptId), NO ACTION.

CHECK:

- CK_PurchaseReceiptItems_Cost: ([UnitCost]>=(0))
- CK_PurchaseReceiptItems_Quantity: ([Quantity]>(0))

## PurchaseReceipts

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ReceiptId | int | Không | Có | — |
| ReceiptCode | varchar(40) | Không | — | — |
| SupplierId | int | Không | — | — |
| StoreId | int | Không | — | — |
| CreatedBy | int | Không | — | — |
| Status | varchar(20) | Không | — | ('DRAFT') |
| TotalAmount | decimal(19,2) | Không | — | ((0)) |
| ReceivedAt | datetime2(3) | Có | — | — |
| Note | nvarchar(1000) | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_PurchaseReceipts: PK (ReceiptId)
- UQ_PurchaseReceipts_Code: UNIQUE (ReceiptCode)

Khóa ngoại:

- FK_PurchaseReceipts_Creator: (CreatedBy) → Users (UserId), NO ACTION.
- FK_PurchaseReceipts_Stores: (StoreId) → Stores (StoreId), NO ACTION.
- FK_PurchaseReceipts_Suppliers: (SupplierId) → Suppliers (SupplierId), NO ACTION.

CHECK:

- CK_PurchaseReceipts_Received: ([Status]='RECEIVED' AND [ReceivedAt] IS NOT NULL AND [ReceivedAt]>=[CreatedAt] OR ([Status]='CANCELLED' OR [Status]='DRAFT') AND [ReceivedAt] IS NULL)
- CK_PurchaseReceipts_Status: ([Status]='CANCELLED' OR [Status]='RECEIVED' OR [Status]='DRAFT')
- CK_PurchaseReceipts_Total: ([TotalAmount]>=(0))

## RefreshTokens

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| RefreshTokenId | bigint | Không | Có | — |
| UserId | int | Không | — | — |
| TokenHash | binary(32) | Không | — | — |
| FamilyId | uniqueidentifier | Không | — | (newid()) |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| ExpiresAt | datetime2(3) | Không | — | — |
| RevokedAt | datetime2(3) | Có | — | — |
| ReplacedByTokenId | bigint | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_RefreshTokens: PK (RefreshTokenId)
- UQ_RefreshTokens_Hash: UNIQUE (TokenHash)
- UQ_RefreshTokens_TokenUserFamily: UNIQUE (RefreshTokenId, UserId, FamilyId)
- UX_RefreshTokens_Replacement: UNIQUE (ReplacedByTokenId); điều kiện ([ReplacedByTokenId] IS NOT NULL)

Khóa ngoại:

- FK_RefreshTokens_Replacement: (ReplacedByTokenId, UserId, FamilyId) → RefreshTokens (RefreshTokenId, UserId, FamilyId), NO ACTION.
- FK_RefreshTokens_Users: (UserId) → Users (UserId), NO ACTION.

CHECK:

- CK_RefreshTokens_Dates: ([ExpiresAt]>[CreatedAt] AND ([RevokedAt] IS NULL OR [RevokedAt]>=[CreatedAt]))
- CK_RefreshTokens_Replacement: ([ReplacedByTokenId] IS NULL OR [ReplacedByTokenId]<>[RefreshTokenId] AND [RevokedAt] IS NOT NULL)

## Refunds

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| RefundId | int | Không | Có | — |
| ReturnId | int | Có | — | — |
| PaymentId | int | Không | — | — |
| OrderId | int | Không | — | — |
| Amount | decimal(19,2) | Không | — | — |
| Reason | nvarchar(1000) | Không | — | — |
| Status | varchar(20) | Không | — | ('PENDING') |
| Provider | varchar(50) | Không | — | — |
| ProviderRefundId | varchar(150) | Có | — | — |
| IdempotencyKey | varchar(100) | Không | — | — |
| RefundedAt | datetime2(3) | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Refunds: PK (RefundId)
- UQ_Refunds_Idempotency: UNIQUE (IdempotencyKey)
- UX_Refunds_ProviderRefund: UNIQUE (Provider, ProviderRefundId); điều kiện ([ProviderRefundId] IS NOT NULL)

Khóa ngoại:

- FK_Refunds_PaymentOrder: (PaymentId, OrderId) → Payments (PaymentId, OrderId), NO ACTION.
- FK_Refunds_ReturnOrder: (ReturnId, OrderId) → SalesReturns (ReturnId, OrderId), NO ACTION.

CHECK:

- CK_Refunds_Amount: ([Amount]>(0))
- CK_Refunds_Date: ([Status]='SUCCEEDED' AND [RefundedAt] IS NOT NULL AND [RefundedAt]>=[CreatedAt] OR [Status]<>'SUCCEEDED' AND [RefundedAt] IS NULL)
- CK_Refunds_Status: ([Status]='CANCELLED' OR [Status]='FAILED' OR [Status]='SUCCEEDED' OR [Status]='PENDING')

## Roles

Số dòng tại thời điểm kiểm tra: 2.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| RoleId | int | Không | Có | — |
| RoleCode | varchar(30) | Không | — | — |
| RoleName | nvarchar(100) | Không | — | — |

Khóa chính và khóa duy nhất:

- PK_Roles: PK (RoleId)
- UQ_Roles_Code: UNIQUE (RoleCode)

CHECK:

- CK_Roles_Code: (len(ltrim(rtrim([RoleCode])))>(0))

## SalesReturnItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ReturnItemId | int | Không | Có | — |
| ReturnId | int | Không | — | — |
| OrderId | int | Không | — | — |
| OrderItemId | int | Không | — | — |
| ReceivedConditionId | int | Có | — | — |
| Resolution | varchar(20) | Có | — | — |
| RefundAmount | decimal(19,2) | Không | — | — |
| Status | varchar(20) | Không | — | ('PENDING') |

Khóa chính và khóa duy nhất:

- PK_SalesReturnItems: PK (ReturnItemId)
- UQ_SalesReturnItems_ItemOrderItem: UNIQUE (ReturnItemId, OrderItemId)
- UQ_SalesReturnItems_ReturnItem: UNIQUE (ReturnId, OrderItemId)
- UX_SalesReturnItems_Accepted: UNIQUE (OrderItemId); điều kiện ([Status]='ACCEPTED')

Khóa ngoại:

- FK_SalesReturnItems_Conditions: (ReceivedConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_SalesReturnItems_ItemOrder: (OrderItemId, OrderId) → OrderItems (OrderItemId, OrderId), NO ACTION.
- FK_SalesReturnItems_ReturnOrder: (ReturnId, OrderId) → SalesReturns (ReturnId, OrderId), NO ACTION.

CHECK:

- CK_SalesReturnItems_Accepted: ([Status]<>'ACCEPTED' OR [ReceivedConditionId] IS NOT NULL AND [Resolution] IS NOT NULL)
- CK_SalesReturnItems_Refund: ([RefundAmount]>=(0))
- CK_SalesReturnItems_Resolution: ([Resolution] IS NULL OR ([Resolution]='DAMAGED' OR [Resolution]='RESTOCK'))
- CK_SalesReturnItems_Status: ([Status]='REJECTED' OR [Status]='ACCEPTED' OR [Status]='PENDING')

## SalesReturns

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ReturnId | int | Không | Có | — |
| OrderId | int | Không | — | — |
| ReceivingStoreId | int | Không | — | — |
| Status | varchar(20) | Không | — | ('REQUESTED') |
| RequestedBy | int | Có | — | — |
| ProcessedBy | int | Có | — | — |
| Reason | nvarchar(1000) | Không | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| ApprovedAt | datetime2(3) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_SalesReturns: PK (ReturnId)
- UQ_SalesReturns_ReturnOrder: UNIQUE (ReturnId, OrderId)

Khóa ngoại:

- FK_SalesReturns_OrderStore: (OrderId, ReceivingStoreId) → Orders (OrderId, StoreId), NO ACTION.
- FK_SalesReturns_Processor: (ProcessedBy) → Users (UserId), NO ACTION.
- FK_SalesReturns_Requester: (RequestedBy) → Users (UserId), NO ACTION.

CHECK:

- CK_SalesReturns_Approval: (NOT ([Status]='COMPLETED' OR [Status]='APPROVED') OR [ProcessedBy] IS NOT NULL AND [ApprovedAt] IS NOT NULL AND [ApprovedAt]>=[CreatedAt])
- CK_SalesReturns_Status: ([Status]='CANCELLED' OR [Status]='REJECTED' OR [Status]='COMPLETED' OR [Status]='APPROVED' OR [Status]='REQUESTED')

## StaffStoreAssignments

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| AssignmentId | int | Không | Có | — |
| UserId | int | Không | — | — |
| StoreId | int | Không | — | — |
| StoreRole | varchar(20) | Không | — | — |
| StartAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| EndAt | datetime2(3) | Có | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |

Khóa chính và khóa duy nhất:

- PK_StaffStoreAssignments: PK (AssignmentId)
- UX_StaffAssignments_Active: UNIQUE (UserId, StoreId); điều kiện ([Status]='ACTIVE')

Khóa ngoại:

- FK_StaffAssignments_Stores: (StoreId) → Stores (StoreId), NO ACTION.
- FK_StaffAssignments_Users: (UserId) → Users (UserId), NO ACTION.

CHECK:

- CK_StaffAssignments_Dates: ([Status]='ACTIVE' AND [EndAt] IS NULL OR [Status]='ENDED' AND [EndAt] IS NOT NULL AND [EndAt]>=[StartAt])
- CK_StaffAssignments_Role: ([StoreRole]='STAFF' OR [StoreRole]='MANAGER')
- CK_StaffAssignments_Status: ([Status]='ENDED' OR [Status]='ACTIVE')

## StockReservations

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| ReservationId | int | Không | Có | — |
| CopyId | int | Không | — | — |
| OrderId | int | Không | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |
| ReservedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| ExpiresAt | datetime2(3) | Không | — | — |
| ReleasedAt | datetime2(3) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_StockReservations: PK (ReservationId)
- UX_StockReservations_ActiveCopy: UNIQUE (CopyId); điều kiện ([Status]='ACTIVE')

Khóa ngoại:

- FK_StockReservations_OrderCopy: (OrderId, CopyId) → OrderItems (OrderId, CopyId), NO ACTION.

CHECK:

- CK_StockReservations_Dates: ([ExpiresAt]>[ReservedAt] AND ([Status]='ACTIVE' AND [ReleasedAt] IS NULL OR [Status]<>'ACTIVE' AND [ReleasedAt] IS NOT NULL AND [ReleasedAt]>=[ReservedAt]))
- CK_StockReservations_Status: ([Status]='CANCELLED' OR [Status]='EXPIRED' OR [Status]='CONSUMED' OR [Status]='ACTIVE')

## StocktakeItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| StocktakeItemId | int | Không | Có | — |
| StocktakeId | int | Không | — | — |
| CopyId | int | Không | — | — |
| ExpectedPresent | bit | Không | — | — |
| ActualPresent | bit | Có | — | — |
| ActualConditionId | int | Có | — | — |
| DifferenceReason | nvarchar(1000) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_StocktakeItems: PK (StocktakeItemId)
- UQ_StocktakeItems_ItemCopy: UNIQUE (StocktakeItemId, CopyId)
- UQ_StocktakeItems_StocktakeCopy: UNIQUE (StocktakeId, CopyId)

Khóa ngoại:

- FK_StocktakeItems_Conditions: (ActualConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_StocktakeItems_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.
- FK_StocktakeItems_Stocktakes: (StocktakeId) → Stocktakes (StocktakeId), NO ACTION.

CHECK:

- CK_StocktakeItems_Condition: ([ActualPresent] IS NULL OR [ActualPresent]=(0) OR [ActualConditionId] IS NOT NULL)

## Stocktakes

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| StocktakeId | int | Không | Có | — |
| StoreId | int | Không | — | — |
| Status | varchar(20) | Không | — | ('DRAFT') |
| StartedAt | datetime2(3) | Có | — | — |
| FinalizedAt | datetime2(3) | Có | — | — |
| CreatedBy | int | Không | — | — |
| ApprovedBy | int | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Stocktakes: PK (StocktakeId)
- UX_Stocktakes_Counting: UNIQUE (StoreId); điều kiện ([Status]='COUNTING')

Khóa ngoại:

- FK_Stocktakes_Approver: (ApprovedBy) → Users (UserId), NO ACTION.
- FK_Stocktakes_Creator: (CreatedBy) → Users (UserId), NO ACTION.
- FK_Stocktakes_Stores: (StoreId) → Stores (StoreId), NO ACTION.

CHECK:

- CK_Stocktakes_Dates: (([StartedAt] IS NULL OR [StartedAt]>=[CreatedAt]) AND ([FinalizedAt] IS NULL OR [StartedAt] IS NOT NULL AND [FinalizedAt]>=[StartedAt]))
- CK_Stocktakes_Finalized: ([Status]<>'FINALIZED' OR [FinalizedAt] IS NOT NULL AND [ApprovedBy] IS NOT NULL)
- CK_Stocktakes_Started: (NOT ([Status]='FINALIZED' OR [Status]='COUNTING') OR [StartedAt] IS NOT NULL)
- CK_Stocktakes_Status: ([Status]='CANCELLED' OR [Status]='FINALIZED' OR [Status]='COUNTING' OR [Status]='DRAFT')

## StockTransferItems

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| TransferItemId | int | Không | Có | — |
| TransferId | int | Không | — | — |
| CopyId | int | Không | — | — |
| SentConditionId | int | Không | — | — |
| ReceivedConditionId | int | Có | — | — |
| ReceiptStatus | varchar(20) | Không | — | ('PENDING') |
| Note | nvarchar(1000) | Có | — | — |

Khóa chính và khóa duy nhất:

- PK_StockTransferItems: PK (TransferItemId)
- UQ_StockTransferItems_ItemCopy: UNIQUE (TransferItemId, CopyId)
- UQ_StockTransferItems_TransferCopy: UNIQUE (TransferId, CopyId)

Khóa ngoại:

- FK_StockTransferItems_Copies: (CopyId) → BookCopies (CopyId), NO ACTION.
- FK_StockTransferItems_ReceivedCondition: (ReceivedConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_StockTransferItems_SentCondition: (SentConditionId) → BookConditions (ConditionId), NO ACTION.
- FK_StockTransferItems_Transfers: (TransferId) → StockTransfers (TransferId), NO ACTION.

CHECK:

- CK_StockTransferItems_Condition: (NOT ([ReceiptStatus]='DAMAGED' OR [ReceiptStatus]='RECEIVED') OR [ReceivedConditionId] IS NOT NULL)
- CK_StockTransferItems_Status: ([ReceiptStatus]='DAMAGED' OR [ReceiptStatus]='MISSING' OR [ReceiptStatus]='RECEIVED' OR [ReceiptStatus]='PENDING')

## StockTransfers

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| TransferId | int | Không | Có | — |
| TransferCode | varchar(40) | Không | — | — |
| FromStoreId | int | Không | — | — |
| ToStoreId | int | Không | — | — |
| Status | varchar(20) | Không | — | ('DRAFT') |
| RequestedBy | int | Không | — | — |
| ApprovedBy | int | Có | — | — |
| ShippedAt | datetime2(3) | Có | — | — |
| ReceivedAt | datetime2(3) | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_StockTransfers: PK (TransferId)
- UQ_StockTransfers_Code: UNIQUE (TransferCode)

Khóa ngoại:

- FK_StockTransfers_Approver: (ApprovedBy) → Users (UserId), NO ACTION.
- FK_StockTransfers_FromStore: (FromStoreId) → Stores (StoreId), NO ACTION.
- FK_StockTransfers_Requester: (RequestedBy) → Users (UserId), NO ACTION.
- FK_StockTransfers_ToStore: (ToStoreId) → Stores (StoreId), NO ACTION.

CHECK:

- CK_StockTransfers_Approval: (NOT ([Status]='RECEIVED' OR [Status]='IN_TRANSIT' OR [Status]='APPROVED') OR [ApprovedBy] IS NOT NULL)
- CK_StockTransfers_Dates: (([ShippedAt] IS NULL OR [ShippedAt]>=[CreatedAt]) AND ([ReceivedAt] IS NULL OR [ShippedAt] IS NOT NULL AND [ReceivedAt]>=[ShippedAt]))
- CK_StockTransfers_Received: ([Status]<>'RECEIVED' OR [ReceivedAt] IS NOT NULL)
- CK_StockTransfers_Shipped: (NOT ([Status]='RECEIVED' OR [Status]='IN_TRANSIT') OR [ShippedAt] IS NOT NULL)
- CK_StockTransfers_Status: ([Status]='CANCELLED' OR [Status]='RECEIVED' OR [Status]='IN_TRANSIT' OR [Status]='APPROVED' OR [Status]='DRAFT')
- CK_StockTransfers_Stores: ([FromStoreId]<>[ToStoreId])

## Stores

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| StoreId | int | Không | Có | — |
| StoreCode | varchar(30) | Không | — | — |
| StoreName | nvarchar(150) | Không | — | — |
| Address | nvarchar(500) | Không | — | — |
| Phone | varchar(20) | Có | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |
| OpenedAt | date | Có | — | — |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Stores: PK (StoreId)
- UQ_Stores_Code: UNIQUE (StoreCode)

CHECK:

- CK_Stores_Code: (len(ltrim(rtrim([StoreCode])))>(0))
- CK_Stores_Status: ([Status]='CLOSED' OR [Status]='TEMPORARILY_CLOSED' OR [Status]='ACTIVE')

## Suppliers

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| SupplierId | int | Không | Có | — |
| SupplierType | varchar(20) | Không | — | — |
| SupplierName | nvarchar(200) | Không | — | — |
| Phone | varchar(20) | Có | — | — |
| Email | nvarchar(254) | Có | — | — |
| Address | nvarchar(500) | Có | — | — |
| LinkedUserId | int | Có | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Suppliers: PK (SupplierId)

Khóa ngoại:

- FK_Suppliers_Users: (LinkedUserId) → Users (UserId), NO ACTION.

CHECK:

- CK_Suppliers_Status: ([Status]='INACTIVE' OR [Status]='ACTIVE')
- CK_Suppliers_Type: ([SupplierType]='ORGANIZATION' OR [SupplierType]='INDIVIDUAL')

## UserRoles

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| UserId | int | Không | — | — |
| RoleId | int | Không | — | — |
| AssignedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_UserRoles: PK (UserId, RoleId)

Khóa ngoại:

- FK_UserRoles_Roles: (RoleId) → Roles (RoleId), NO ACTION.
- FK_UserRoles_Users: (UserId) → Users (UserId), NO ACTION.

## Users

Số dòng tại thời điểm kiểm tra: 0.

| Cột | Kiểu | NULL | IDENTITY | Mặc định |
|---|---|---|---|---|
| UserId | int | Không | Có | — |
| Username | nvarchar(50) | Không | — | — |
| Email | nvarchar(254) | Không | — | — |
| PasswordHash | varchar(255) | Không | — | — |
| FullName | nvarchar(150) | Không | — | — |
| Phone | varchar(20) | Có | — | — |
| Status | varchar(20) | Không | — | ('ACTIVE') |
| CreatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |
| UpdatedAt | datetime2(3) | Không | — | (sysutcdatetime()) |

Khóa chính và khóa duy nhất:

- PK_Users: PK (UserId)
- UQ_Users_Email: UNIQUE (Email)
- UQ_Users_Username: UNIQUE (Username)

CHECK:

- CK_Users_Required: (len(ltrim(rtrim([Username])))>(0) AND len(ltrim(rtrim([Email])))>(0) AND len(ltrim(rtrim([FullName])))>(0) AND len([PasswordHash])>(0))
- CK_Users_Status: ([Status]='PENDING' OR [Status]='LOCKED' OR [Status]='ACTIVE')
- CK_Users_Timestamps: ([UpdatedAt]>=[CreatedAt])
