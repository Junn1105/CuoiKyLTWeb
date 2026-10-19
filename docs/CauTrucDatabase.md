# Cấu trúc database đã triển khai

Ngày tạo schema: 11/10/2026. Cập nhật dữ liệu mẫu: 14/10/2026. Máy chủ: SQL Server localhost. Database: **WebsiteQuanLyCuaHangSachCu**.

Đã tạo chính thức **30 bảng mới**, tổng **35 bảng**. Toàn bộ dữ liệu 5 bảng danh mục, bao gồm đường dẫn ảnh, được đối chiếu trước/sau và không thay đổi.

## Danh sách bảng

| Nhóm | Bảng |
|---|---|
| Danh mục cũ giữ nguyên | Books, Authors, BookAuthors, Categories, Publishers |
| Tài khoản và quyền | Users, Roles, UserRoles, StaffStoreAssignments, CustomerAddresses |
| Chi nhánh và từng cuốn sách | Stores, BookConditions, BookCopies, MediaAssets |
| Thu mua/nhập | Suppliers, PurchaseReceipts, PurchaseReceiptItems |
| Biến động và kiểm soát kho | InventoryMovements, StockTransfers, StockTransferItems, Stocktakes, StocktakeItems |
| Giỏ hàng và đơn hàng | Carts, CartItems, Orders, OrderItems, StockReservations, OrderStatusHistory |
| Thanh toán và trả hàng | Payments, SalesReturns, SalesReturnItems, Refunds |
| Phiên đăng nhập và thông báo | RefreshTokens, Notifications, AuditLogs |

## Dữ liệu ban đầu

- Roles: ADMIN — Quản trị hệ thống; CUSTOMER — Khách hàng. Vai trò MANAGER/STAFF được lưu theo chi nhánh trong StaffStoreAssignments.
- BookConditions: LIKE_NEW — Như mới; GOOD — Tốt; FAIR — Khá; WORN — Cũ nhiều.
- Đã thêm 1.215 dòng dữ liệu mẫu vào 28 bảng còn lại ngày 14/10/2026; gồm tài khoản, chi nhánh, giá sách và tồn kho giả lập. Xem [Dữ liệu mẫu và test case](DuLieuMauVaTestCase.md). Không coi đây là tồn kho thực tế của cửa hàng.
- Danh mục cũ: 83 Books, 122 Authors, 134 BookAuthors, 10 Categories, 40 Publishers.

## Ràng buộc đã tạo

- Toàn database có 74 khóa ngoại và 70 CHECK, đều được bật và tin cậy; mỗi bảng có khóa chính. Khóa ngoại không xóa dây chuyền lịch sử.
- Username/Email duy nhất, không phân biệt hoa thường. Chỉ có một địa chỉ mặc định mỗi tài khoản và một giỏ ACTIVE mỗi khách/chi nhánh.
- Một cuốn chỉ có một giữ chỗ ACTIVE. Giữ chỗ phải tham chiếu đúng cuốn trong đơn; hạn giữ phải sau thời điểm tạo.
- OrderItems lưu ảnh chụp thông tin tên/tình trạng/giá/giá vốn. Cuốn được phép xuất hiện trong đơn khác để hỗ trợ bán lại sau trả hàng.
- Giá và số tiền được kiểm tra không âm; Payments/Refunds phải dương. Orders và OrderItems có CHECK cho phép tính tổng ngay trong từng dòng.
- SalesReturns dùng khóa ngoại ghép tới đơn và chi nhánh bán. SalesReturnItems có OrderId để buộc dòng trả thuộc đúng đơn; một OrderItem chỉ có một dòng trả ACCEPTED.
- Refunds có OrderId để đảm bảo khoản thanh toán và phiếu trả thuộc cùng đơn. ReturnId được phép NULL để hỗ trợ hoàn tiền khi hủy đơn.
- Payments và Refunds có IdempotencyKey duy nhất; mã giao dịch ngoài duy nhất trong từng Provider khi có giá trị.
- BookCopies tham chiếu cặp ReceiptItemId/BookId để tránh gắn cuốn vào dòng nhập của đầu sách khác.
- MediaAssets buộc đúng một chủ thể, tối đa một ảnh chính cho từng chủ thể và mã Cloudinary duy nhất theo provider. Dữ liệu mẫu đã tham chiếu ảnh danh mục trong MediaAssets; các cột ảnh cũ được giữ nguyên. Khi triển khai ứng dụng cần chọn nguồn ảnh chính và quy tắc đồng bộ.
- RefreshTokens lưu SHA-256 dạng binary(32); liên kết token thay thế cùng tài khoản và FamilyId. Đã có 5 hash fixture cho vòng đời token, không lưu/phát hành token thô. Tài khoản mẫu dùng BCrypt như tài liệu dữ liệu mẫu.
- InventoryMovements phân biệt nguồn chứng từ theo loại biến động; các tham chiếu bán/điều chuyển/kiểm kê buộc đúng cuốn. Khi ghi RETURN phải truyền cả ReturnItemId và OrderItemId.

## Quy ước dành cho bước Spring Boot/JPA

1. ID chính dùng INT IDENTITY; bảng lịch sử/thông báo/token dùng BIGINT IDENTITY. Tham chiếu 5 bảng cũ giữ INT. Không giả định ID liên tục: các lần kiểm thử rollback có thể tiêu thụ giá trị IDENTITY.
2. BookCopies.Version và Orders.Version là BIGINT phục vụ `@Version`. JPA phải tăng version; database không tự tăng trường này.
3. Thời gian giao dịch là DATETIME2(3), mặc định UTC bằng SYSUTCDATETIME(). Hiển thị chuyển sang Asia/Saigon. UpdatedAt chỉ có giá trị mặc định khi INSERT; service/auditing phải cập nhật khi sửa.
4. Tiền dùng DECIMAL(19,2)/BigDecimal, giai đoạn này VND. Orders.Subtotal là tổng UnitPrice; DiscountAmount là tổng giảm giá trên dòng cộng giảm giá cấp đơn. TotalAmount = Subtotal - DiscountAmount + ShippingFee. OrderItems.LineTotal = UnitPrice - DiscountAmount.
5. Mỗi dòng OrderItems/CartItems là một cuốn, không có Quantity. PurchaseReceiptItems.Quantity là số cuốn cần sinh sau khi chốt nhập.
6. Trạng thái lưu bằng VARCHAR, ánh xạ enum dạng STRING, không dùng thứ tự enum. Kiểu Unicode dùng NVARCHAR. Các trường URL dài tới 2048 ký tự trong MediaAssets/Notifications.
7. Migration là nguồn quản lý cấu trúc. Khi bổ sung JPA, đặt ddl-auto=validate để phát hiện lệch mapping; không để ứng dụng tự sửa schema đã duyệt.

## Phần phải thực hiện ở tầng nghiệp vụ

Cấu trúc bảng không tự thực hiện quy trình bán hàng. Các việc sau cần service có transaction và kiểm tra quyền:

- Giới hạn quyền nhân viên theo chi nhánh, chuẩn hóa Username/Email, băm mật khẩu và cấp/thu hồi token.
- Sinh đúng số cuốn khi nhận hàng; đối chiếu tổng phiếu nhập với các dòng.
- Kiểm tra cuốn cùng chi nhánh với giỏ/đơn ở thời điểm mua và cuốn còn AVAILABLE. Không dùng FK tới StoreId hiện tại của cuốn trên dòng đơn cũ, vì lịch sử phải tồn tại khi cuốn được điều chuyển sau này.
- Thay trạng thái cuốn, giữ hàng, ghi đơn và biến động kho trong cùng transaction. UNIQUE giữ chỗ chỉ chống trùng ACTIVE, không tự đổi trạng thái BookCopies hoặc tự giải phóng giữ chỗ hết hạn.
- Khóa/đối soát tồn kho khi kiểm kê; kiểm tra cuốn và chi nhánh khớp chứng từ nhập/điều chuyển; cập nhật StoreId khi nhận chuyển kho.
- Kiểm tra tổng đơn bằng các dòng, xử lý thanh toán thành công lặp lại, tổng hoàn tiền không vượt tiền thực thu và số tiền từng dòng trả không vượt giá trị được hoàn.
- Kiểm tra thứ tự chuyển trạng thái, quyền duyệt trả hàng và chỉ cho bán lại sau hoàn trả thực tế. CHECK chỉ giới hạn giá trị hợp lệ, không thay thế state machine.
- Ghi InventoryMovements/AuditLogs theo kiểu chỉ thêm. Chưa cấp tài khoản database với quyền chặn UPDATE/DELETE các log; chưa triển khai trigger bất biến.
- Phát WebSocket sau commit, phục hồi thông báo chưa đọc từ Notifications; thực hiện rotation token và phát hiện tái sử dụng token đã thu hồi.

## Kiểm chứng và tệp tra cứu

- Đã chạy thử migration trong giao dịch hoàn tác trước khi chạy chính thức.
- 24 tình huống kiểm tra đạt, gồm giữ chỗ trùng, sai quan hệ đơn/trả hàng, trùng thanh toán, giá âm, ảnh không chủ thể và bán lại cùng cuốn. Dữ liệu kiểm thử đã rollback.
- So sánh toàn bộ dữ liệu 5 bảng danh mục trước/sau: giống nhau. Sau đợt seed ngày 14/10/2026 có 6 dòng danh mục hệ thống và 1.215 dòng mẫu; các bản ghi tạm của kiểm thử ràng buộc đã rollback.
- [SQL tạo bảng](../database/002-create-core-tables.sql), [SQL kiểm thử](../database/003-verify-core-tables.sql), [kết quả kiểm thử](../database/core-integrity-test-results.txt).
- [Từ điển dữ liệu](TuDienDuLieu.md), [số dòng từng bảng](database-table-inventory.csv), [snapshot cấu trúc](../database/core-schema-snapshot.json).

Chưa bổ sung các cột đề xuất cho 5 bảng cũ, 11 bảng tùy chọn, entity JPA hay giao diện trong lần tạo 30 bảng này.

## Bổ sung xác thực ngày 15/10/2026
Migration 009-authentication.sql đã thêm bảng AuthChallenges lưu phiên OTP và cột Users.AuthVersion để thu hồi JWT khi đổi mật khẩu. Tổng số bảng hiện tại: 36. Xem docs/DangNhapVaGmail.md và migration 009 để biết cấu trúc đầy đủ; các snapshot 35 bảng trước đó là lịch sử trước bước này.


## Bổ sung trang chủ ngày 17/10/2026
Migration 010-book-reviews.sql bổ sung BookReviews để tổng hợp điểm và số lượt đánh giá đã duyệt. Tổng số bảng hiện tại: 37. Cấu trúc và quy tắc đề xuất được mô tả tại docs/TrangChu.md.

