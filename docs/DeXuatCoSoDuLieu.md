# Đề xuất dữ liệu — Website quản lý chuỗi cửa hàng sách cũ

Ngày khảo sát: 11/10/2026. Cập nhật cùng ngày: **người dùng đã duyệt và đã tạo 30 bảng nghiệp vụ chính**, tổng 35 bảng. Chi tiết triển khai: [Cấu trúc đã triển khai](CauTrucDatabase.md). Phần bổ sung cột cho 5 bảng cũ và 11 bảng mở rộng vẫn là đề xuất, chưa thực hiện.

## 1. Database sử dụng

- Dùng tiếp **WebsiteQuanLyCuaHangSachCu** trên SQL Server localhost hiện có. Không cần thêm database nghiệp vụ khác.
- `QuanLyThuVien` là nguồn dữ liệu cũ, không sửa dữ liệu hoặc cấu trúc của database này.
- SQL Server, MySQL và PostgreSQL là các lựa chọn hệ quản trị thay thế. Giai đoạn đầu triển khai SQL Server theo dữ liệu đang có; không vận hành đồng thời cả ba cho cùng nghiệp vụ.
- Nếu sau này cần chạy trên MySQL/PostgreSQL, dùng cấu hình kết nối và migration riêng cho từng hệ. JPA không tự giải quyết mọi khác biệt về ID tự tăng, chỉ mục có điều kiện, kiểu Unicode và kiểu thời gian.
- Môi trường kiểm thử/triển khai có thể có database riêng, nhưng chưa cần tạo trong bước này.
- Cloudinary lưu tệp ảnh; database lưu URL và metadata. JWT/WebSocket không yêu cầu database riêng.

## 2. Hiện trạng đã đọc trực tiếp

| Bảng hiện có | Số dòng | Trường hiện tại |
|---|---:|---|
| Books | 83 | BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description |
| Authors | 122 | AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl |
| BookAuthors | 134 | BookId, AuthorId |
| Categories | 10 | CategoryId, CategoryName, Description |
| Publishers | 40 | PublisherId, PublisherName, Address, Phone |

Không có Quantity/AvailableQuantity trong Books của database mới. Không dùng số lượng sách của thư viện cũ làm tồn kho bán hàng thực tế.

## 3. Năm bảng giữ lại và phần dự kiến bổ sung

| Bảng | Đề xuất |
|---|---|
| Books | Giữ khóa và dữ liệu danh mục; bổ sung Slug, Language, Edition, PageCount, Status, CreatedAt, UpdatedAt, Version. ISBN cho phép thiếu; kiểm tra dữ liệu trước khi tạo ràng buộc duy nhất. Mỗi dòng là một đầu sách/ấn bản, không phải một cuốn vật lý. |
| Authors | Giữ hồ sơ và ảnh; bổ sung Slug, Status, CreatedAt, UpdatedAt khi cần quản trị. |
| Categories | Bổ sung ParentCategoryId (FK tự tham chiếu), Slug, Status, SortOrder; ngăn danh mục cha tạo vòng lặp. |
| Publishers | Giữ thông tin; bổ sung Email, Status, CreatedAt, UpdatedAt. |
| BookAuthors | Giữ quan hệ nhiều–nhiều; khóa ghép BookId + AuthorId. Có thể bổ sung DisplayOrder để sắp thứ tự tác giả. |

CoverImage và AuthorPhoto tiếp tục hỗ trợ URL ảnh hiện tại. Khi tích hợp MediaAssets, xác định một nguồn dữ liệu chính cho ảnh đại diện; các cột cũ chỉ giữ để tương thích hoặc được thay bằng FK sau migration đã duyệt.

## 4. Ba mươi bảng mới đề xuất cho nghiệp vụ chính

Các trường dưới đây là bản thiết kế ban đầu. DDL đã thực thi nằm ở `database/002-create-core-tables.sql`; [từ điển dữ liệu thực tế](TuDienDuLieu.md) phản ánh cột, khóa ngoại và ràng buộc đã tạo. PK là khóa chính, FK là khóa ngoại.

| STT | Bảng | Mục đích và trường chính |
|---:|---|---|
| 1 | Users | Tài khoản khách/nhân viên/quản trị: UserId PK, Username, Email, PasswordHash, FullName, Phone, Status, CreatedAt, UpdatedAt. |
| 2 | Roles | Vai trò toàn hệ thống: RoleId PK, RoleCode duy nhất, RoleName. Ví dụ ADMIN, CUSTOMER. |
| 3 | UserRoles | UserId FK, RoleId FK; khóa ghép. Vai trò nhân viên theo chi nhánh đặt tại StaffStoreAssignments. |
| 4 | StaffStoreAssignments | Phân công chi nhánh: AssignmentId PK, UserId FK, StoreId FK, StoreRole (MANAGER/STAFF), StartAt, EndAt, Status. Không cấp quyền sang chi nhánh khác chỉ vì có vai trò nhân viên. |
| 5 | CustomerAddresses | AddressId PK, UserId FK, RecipientName, Phone, AddressLine, AdministrativeArea, PostalCode, CountryCode, IsDefault. Đơn hàng lưu bản chụp địa chỉ riêng. |
| 6 | Stores | StoreId PK, StoreCode duy nhất, StoreName, Address, Phone, Status, OpenedAt. |
| 7 | BookConditions | ConditionId PK, ConditionCode duy nhất, ConditionName, Description, SortOrder. Danh mục tình trạng, ví dụ tốt/khá/cũ; không chỉ dùng phần trăm. |
| 8 | BookCopies | Một cuốn vật lý: CopyId PK, CopyCode duy nhất, BookId FK, StoreId FK, ConditionId FK, PurchaseReceiptItemId FK nullable, CostPrice, SalePrice, ConditionNotes, ShelfLocation, Status, Version. Giá và tình trạng có thể khác giữa hai cuốn cùng đầu sách. |
| 9 | MediaAssets | MediaId PK, Provider (LOCAL/CLOUDINARY), Url, PublicId nullable, ResourceType, Format, Width, Height, AltText, SortOrder, IsPrimary; BookId/CopyId/AuthorId/UserId FK nullable. Ràng buộc đúng một chủ thể cho mỗi ảnh; PublicId duy nhất trong phạm vi provider khi có. |
| 10 | Suppliers | Nguồn thu mua là cá nhân/đơn vị: SupplierId PK, SupplierType, SupplierName, Phone, Email, Address, LinkedUserId FK nullable. Không cần tài khoản để bán sách cho cửa hàng. |
| 11 | PurchaseReceipts | Phiếu thu mua/nhập: ReceiptId PK, ReceiptCode duy nhất, SupplierId FK, StoreId FK, CreatedBy FK Users, Status, TotalAmount, ReceivedAt, Note. |
| 12 | PurchaseReceiptItems | ReceiptItemId PK, ReceiptId FK, BookId FK, ConditionId FK, Quantity, UnitCost, Note. Khi chốt nhập, sinh đúng Quantity dòng BookCopies, liên kết về dòng nhập này. |
| 13 | InventoryMovements | Sổ biến động: MovementId PK, CopyId FK, FromStoreId/ToStoreId FK nullable, MovementType, OccurredAt, ActorId FK, ReceiptItemId/OrderItemId/TransferItemId/ReturnItemId/StocktakeItemId FK nullable, Reason, OperationKey duy nhất. Các FK chứng từ được bổ sung sau khi tạo đủ bảng. |
| 14 | StockTransfers | TransferId PK, TransferCode duy nhất, FromStoreId FK, ToStoreId FK, Status, RequestedBy, ApprovedBy, ShippedAt, ReceivedAt. Hai chi nhánh phải khác nhau. |
| 15 | StockTransferItems | TransferItemId PK, TransferId FK, CopyId FK, SentConditionId FK, ReceivedConditionId FK nullable, ReceiptStatus, Note; duy nhất TransferId + CopyId. |
| 16 | Stocktakes | StocktakeId PK, StoreId FK, Status, StartedAt, FinalizedAt, CreatedBy FK, ApprovedBy FK. Chọn khóa hoạt động kho hoặc đối soát biến động trong khoảng kiểm kê. |
| 17 | StocktakeItems | StocktakeItemId PK, StocktakeId FK, CopyId FK, ExpectedPresent, ActualPresent, ActualConditionId FK, DifferenceReason; duy nhất StocktakeId + CopyId. Chỉ khi duyệt mới điều chỉnh kho. |
| 18 | Carts | CartId PK, UserId FK, StoreId FK, Status, UpdatedAt. Giai đoạn đầu giỏ hàng yêu cầu đăng nhập; một giỏ đang hoạt động cho mỗi khách/chi nhánh. |
| 19 | CartItems | CartItemId PK, CartId FK, CopyId FK, AddedAt; duy nhất CartId + CopyId. Mỗi dòng là một cuốn, số lượng bằng 1; thêm giỏ chưa giữ hàng. |
| 20 | Orders | OrderId PK, OrderCode duy nhất, StoreId FK, CustomerId FK nullable cho khách vãng lai, CreatedBy FK nullable, Channel (ONLINE/POS), Status, RecipientName, RecipientPhone, ShippingAddressSnapshot, Subtotal, DiscountAmount, ShippingFee, TotalAmount, CreatedAt, Version. |
| 21 | OrderItems | OrderItemId PK, OrderId FK, CopyId FK, BookTitleSnapshot, ConditionSnapshot, UnitPrice, UnitCostSnapshot, DiscountAmount, LineTotal; duy nhất OrderId + CopyId. Một dòng bán một cuốn. |
| 22 | StockReservations | ReservationId PK, CopyId FK, OrderId FK, Status, ReservedAt, ExpiresAt, ReleasedAt. Tối đa một giữ chỗ ACTIVE trên một cuốn; hết hạn phải được giải phóng bởi tác vụ định kỳ. |
| 23 | Payments | PaymentId PK, OrderId FK, Method, Provider, Amount, Currency, Status, ProviderTransactionId nullable, IdempotencyKey duy nhất, PaidAt. Mỗi lần thử thanh toán là một dòng; không lưu thông tin thẻ. |
| 24 | OrderStatusHistory | HistoryId PK, OrderId FK, FromStatus, ToStatus, ChangedBy FK nullable, ChangedAt, Reason. Lưu lịch sử xử lý đơn. |
| 25 | SalesReturns | ReturnId PK, OrderId FK, ReceivingStoreId FK, Status, RequestedBy FK nullable, ProcessedBy FK, Reason, CreatedAt, ApprovedAt. Giai đoạn đầu trả về chi nhánh bán. |
| 26 | SalesReturnItems | ReturnItemId PK, ReturnId FK, OrderItemId FK, ReceivedConditionId FK, Resolution (RESTOCK/DAMAGED), RefundAmount. Một dòng bán chỉ được hoàn trả thành công một lần. |
| 27 | Refunds | RefundId PK, ReturnId FK nullable, PaymentId FK, Amount, Reason, Status, ProviderRefundId nullable, IdempotencyKey duy nhất, RefundedAt. Cho phép hoàn tiền khi hủy đơn dù không có trả hàng vật lý. |
| 28 | RefreshTokens | RefreshTokenId PK, UserId FK, TokenHash duy nhất, FamilyId, ExpiresAt, RevokedAt, ReplacedByTokenId FK nullable. Lưu bản băm refresh token, hỗ trợ đổi token/đăng xuất; không lưu JWT access token thô. |
| 29 | Notifications | NotificationId PK, UserId FK, StoreId FK nullable, Type, Title, Content, TargetUrl, CreatedAt, ReadAt. Lưu trước rồi phát sự kiện WebSocket sau khi giao dịch thành công. |
| 30 | AuditLogs | AuditId PK, ActorId FK nullable, StoreId FK nullable, Action, EntityType, EntityId, Summary, CreatedAt, CorrelationId. Không ghi mật khẩu/token; phục vụ truy vết quản trị. |

**Tổng giai đoạn chính: 5 bảng hiện có + 30 bảng mới = 35 bảng.** Đây là đề xuất cho phạm vi có quản lý chuỗi, thu mua, kho, bán tại quầy và đặt hàng trực tuyến; có thể cắt bớt module nếu đồ án có phạm vi nhỏ hơn.

## 5. Mười một bảng mở rộng, chỉ thêm nếu chọn chức năng

| Nhóm | Bảng | Trường/quan hệ chính |
|---|---|---|
| Khuyến mãi | Promotions | PromotionId, Code, Type, Value, StartAt, EndAt, MinOrderAmount, MaxDiscount, UsageLimit, Status. |
| Khuyến mãi | PromotionBooks | PromotionId FK + BookId FK; phạm vi đầu sách. |
| Khuyến mãi | PromotionStores | PromotionId FK + StoreId FK; phạm vi chi nhánh. |
| Khuyến mãi | OrderPromotions | OrderId FK, PromotionId FK, DiscountAmount, CodeSnapshot; lịch sử áp dụng và kiểm soát lượt dùng trong giao dịch. |
| Giao vận | Shipments | ShipmentId, OrderId FK, Carrier, TrackingCode, Status, ShippedAt, DeliveredAt. |
| Giao vận | ShipmentEvents | ShipmentEventId, ShipmentId FK, Status, Description, OccurredAt, ExternalEventId chống sự kiện lặp. |
| Tương tác | Reviews | ReviewId, UserId FK, BookId FK, OrderItemId FK, Rating (1–5), Content, ModerationStatus; kiểm tra người đánh giá đã mua. |
| Tương tác | Favorites | UserId FK + BookId FK, CreatedAt; khóa ghép. |
| Chat | Conversations | ConversationId, StoreId FK, Status, CreatedAt; cuộc hội thoại hỗ trợ khách hàng. |
| Chat | ConversationParticipants | ConversationId FK + UserId FK, JoinedAt, LastReadMessageId FK nullable; thành viên và mốc đã đọc. |
| Chat | Messages | MessageId, ConversationId FK, SenderId FK, Body, SentAt, ClientMessageId duy nhất theo người gửi để chống gửi trùng. |

Nếu chọn cả 11 bảng mở rộng: **46 bảng tổng cộng**. WebSocket có thể phục vụ thông báo ngay ở giai đoạn chính; không bắt buộc triển khai chat.

## 6. Quan hệ và nguyên tắc cần chốt

1. Books liên kết nhiều Authors qua BookAuthors; Books có nhiều BookCopies. BookCopies thuộc một chi nhánh ở một thời điểm và một mức tình trạng.
2. Một đơn hàng thuộc một chi nhánh. Nếu khách mua ở nhiều chi nhánh, tạo các đơn riêng. Tất cả cuốn trong đơn phải cùng chi nhánh với đơn tại thời điểm đặt.
3. Không có bảng tồn kho tổng hợp bắt buộc: tồn kho là thống kê BookCopies theo StoreId, BookId, ConditionId và Status. Chưa thêm bảng tổng số lượng để tránh hai nguồn tồn kho không khớp.
4. Trạng thái cuốn dự kiến: AVAILABLE, RESERVED, SOLD, IN_TRANSIT, DAMAGED, LOST. Chỉ cuốn AVAILABLE được đặt/bán; khi hoàn trả cần kiểm tra trước khi đưa về AVAILABLE.
5. Đặt hàng/giữ hàng/bán hàng phải thay trạng thái cuốn có điều kiện và ghi chứng từ trong cùng giao dịch. Dùng Version để chống ghi đè và khóa/ràng buộc cho giữ chỗ; chỉ kiểm tra tại giao diện là không đủ. SQL Server dùng chỉ mục duy nhất có điều kiện cho giữ chỗ ACTIVE; hệ khác cần phương án migration tương đương.
6. Xác nhận thanh toán lặp lại không được trừ kho hoặc ghi doanh thu hai lần. Webhook đến sau khi giữ chỗ hết hạn phải được đối soát, không tự bán cuốn đã cấp cho đơn khác.
7. Phiếu nhập, điều chuyển và trả hàng chỉ cập nhật kho khi đạt trạng thái được phép. Điều chuyển đưa sách sang IN_TRANSIT khi xuất, đổi StoreId khi chi nhánh đích nhận. InventoryMovements lưu lịch sử bất biến; sửa sai bằng bút toán bù.
8. Lưu tiền bằng DECIMAL(19,2), mặc định VND. Giá, giảm giá, hoàn tiền không âm; hoàn tiền thành công không vượt tiền thực thu. Tổng đơn bằng tổng dòng sau giảm giá cộng phí; snapshot giá vốn giúp báo cáo lợi nhuận không bị thay đổi theo giá hiện tại.
9. Đơn hàng lưu tên sách, tình trạng, giá và địa chỉ tại thời điểm mua; thay đổi hồ sơ hiện tại không sửa lịch sử. Một cuốn có thể bán lại sau khi đã được hoàn trả, vì vậy không đặt CopyId duy nhất trên toàn bộ OrderItems.
10. Username/Email cần quy tắc chuẩn hóa và duy nhất. Tài khoản được khóa thay vì xóa khi đã phát sinh giao dịch. Chi nhánh đóng cửa vẫn giữ lịch sử đơn/kho. FK lịch sử dùng RESTRICT/NO ACTION thay vì xóa dây chuyền.
11. Các bảng chính cần chỉ mục theo FK và truy vấn: BookCopies(StoreId, BookId, Status), Orders(StoreId, CreatedAt, Status), Payments(OrderId, Status), Notifications(UserId, ReadAt), InventoryMovements(CopyId, OccurredAt). Chỉ mục chi tiết chốt sau khi duyệt truy vấn và DB đích.
12. Sách nhập từ thư viện hiện chỉ là danh mục, chưa có giá vốn/giá bán/tình trạng/chi nhánh thực tế. Không tự sinh tồn kho hoặc số liệu thu mua giả từ 83 đầu sách.
13. Không chuyển các bảng mượn trả thư viện như Readers, Borrows, BorrowDetails, Fines, CardRenewalRequests sang nghiệp vụ bán sách. Nếu cần nhập tài khoản cũ thì phải có bước chuyển đổi vai trò/mật khẩu riêng, chưa nằm trong lần này.
14. Trước DDL sẽ kiểm tra dữ liệu ISBN, độ dài URL ảnh, khóa ngoại và ràng buộc đang tồn tại. Bản khảo sát hiện tại lưu danh sách cột/số dòng, chưa phải bản sao đầy đủ mọi index/constraint của database.

## 7. Ảnh đã chuyển và phạm vi thực hiện

- Sao chép 67 ảnh bìa + 5 ảnh tác giả từ `F:/CNPM/QuanLyThuVien/src/QuanLyThuVien.App/` sang `src/main/resources/static/images/books/` và `images/authors/`.
- Đối chiếu SHA-256 của cả 72 tệp với nguồn: khớp.
- Đã sửa 80 giá trị Books.CoverImage từ `books/...` sang `/images/books/...` và 5 Authors.AuthorPhoto từ `authors/...` sang `/images/authors/...` trong database mới.
- 13 đường dẫn bìa chưa có tệp tại nguồn được chuyển sang cùng quy ước để bổ sung ảnh sau; không tự thay bằng bìa của sách khác. Chi tiết tại `missing-images.csv`.
- 3 sách BookId 1002, 1003, 1004 có CoverImage NULL; giữ nguyên. 117 tác giả chưa có ảnh; giữ nguyên NULL.
- Có thêm ảnh dự phòng tự tạo `images/book-placeholder.svg`; chưa có giao diện để gắn fallback tự động.
- Đã kiểm tra 85 đường dẫn sau cập nhật, số dòng và danh sách cột không đổi. Lưu snapshot trước/sau và SQL khôi phục đường dẫn tại `database/`.
- Project mới ban đầu trống, chưa có Spring Boot/JSP/controller; chưa thể kiểm thử ảnh qua HTTP. Thư mục static đã chuẩn bị cho bước xây dựng ứng dụng.

## 8. Phạm vi đã được duyệt và thực hiện

- Dùng SQL Server hiện tại cho lần triển khai đầu tiên.
- Theo dõi mỗi cuốn sách cũ bằng mã riêng, giá riêng, tình trạng riêng.
- Đã tạo 30 bảng mới ở phần 4; 11 bảng ở phần 5 chưa triển khai.
- Quy tắc một đơn hàng/một chi nhánh và trả hàng về chi nhánh bán.

Đã thực thi migration tạo bảng, khóa ngoại, chỉ mục và 6 dòng danh mục hệ thống (2 vai trò, 4 mức tình trạng sách). Đã kiểm tra 24 tình huống toàn vẹn và đối chiếu nguyên vẹn dữ liệu 5 bảng cũ. Entity JPA và các luồng xử lý nghiệp vụ chưa được triển khai trong bước tạo database này.
