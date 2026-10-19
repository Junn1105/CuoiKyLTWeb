# Dữ liệu mẫu và test case

Ngày thực hiện: **14/10/2026**. Database: **WebsiteQuanLyCuaHangSachCu**, SQL Server localhost.

Đã thêm **1.215 bản ghi** vào **28 bảng còn trống**. Hai bảng Roles và BookConditions đã có đủ danh mục nên được sử dụng lại. Cả **35 bảng đều có dữ liệu**; 83 sách, 122 tác giả, 134 liên kết sách–tác giả, 10 danh mục và 40 nhà xuất bản được giữ nguyên.

Đây là bộ mẫu phục vụ các nhánh nghiệp vụ và ràng buộc của schema hiện tại. Đã có dữ liệu cho mọi giá trị trạng thái/loại liệt kê trong ma trận bên dưới; không có nghĩa là mọi tổ hợp đầu vào hay mọi lỗi của ứng dụng tương lai đều đã được kiểm thử.

## 1. Tài khoản mẫu

Đã cập nhật tên đăng nhập và họ tên bằng script `008-rename-demo-accounts.sql`. Tên đăng nhập không dấu (ví dụ `hoang`, `van`); họ tên hiển thị có dấu. ID, quyền, trạng thái và email giả lập vẫn giữ nguyên để các tình huống kiểm thử tiếp tục hoạt động.

**Mật khẩu chung: `123456`**. Database lưu BCrypt cost 12, mỗi tài khoản có salt riêng. Dùng BCryptPasswordEncoder khi xây dựng đăng nhập; nếu dùng DelegatingPasswordEncoder cần cấu hình nhận hash BCrypt không có tiền tố `{bcrypt}` hoặc chuyển định dạng rõ ràng trong migration riêng.

Chưa có ứng dụng đăng nhập để thử qua giao diện. Tài khoản, tên, email `example.invalid`, số điện thoại và địa chỉ đều là dữ liệu giả lập; các thanh toán dùng provider DEMO, không kết nối cổng thu tiền thật.

| Tài khoản | Mục đích / quyền dự kiến |
|---|---|
| admin | ADMIN và CUSTOMER, kiểm thử nhiều vai trò |
| manager / manager2 / manager3 | MANAGER tại DEMO-S1 / S2 / S3 tương ứng |
| staff / staff2 / staff3 | STAFF tại chi nhánh tương ứng |
| staff4 | Phân công đã ENDED; kiểm thử từ chối thao tác chi nhánh |
| staff5 | Tài khoản LOCKED dù phân công còn ACTIVE |
| khang / hoang / van | Khách đang hoạt động, có các đơn và lịch sử khác nhau |
| minh | Khách bị khóa |
| linh | Tài khoản chờ duyệt |
| nam | Khách mới, giỏ trống, chưa mua hàng và chưa có địa chỉ |
| huy | Không có vai trò hoặc phân công |

Mã cửa hàng: **DEMO-S1, DEMO-S2, DEMO-S3** hoạt động; **DEMO-S4** tạm nghỉ; **DEMO-S5** đã đóng. Khi chạy kiểm thử phân quyền, cần kiểm tra đồng thời trạng thái tài khoản, phân công và chi nhánh; dữ liệu trong bảng không tự thực thi quyền.

## 2. Kho và danh mục

- **249 cuốn sách**, ban đầu một cuốn cho mỗi đầu sách tại mỗi chi nhánh S1/S2/S3, nhận qua 3 phiếu nhập hoàn tất. Giá/tình trạng có thể khác giữa các cuốn cùng đầu sách.
- 2 phiếu nhập còn lại ở DRAFT/CANCELLED, có dòng hàng nhưng không sinh tồn kho.
- Mã `DEMO-C1-001` nghĩa là cuốn số 1 của lô chi nhánh 1; mã không phải IDENTITY. Một cuốn chuyển chi nhánh vẫn giữ CopyCode.
- 6 trạng thái cuốn có dữ liệu: AVAILABLE, RESERVED, SOLD, IN_TRANSIT, DAMAGED, LOST.
- Cuốn `DEMO-C1-021` có giá vốn và giá bán 0, dùng trong đơn miễn phí; các giá trị tiền âm thuộc bộ kiểm thử từ chối và không được lưu.

## 3. Các đơn mẫu và kết quả mong đợi

| Mã đơn | Tình huống / kết quả |
|---|---|
| DEMO-POS-CASH | Bán tại quầy 2 cuốn, tiền mặt, giảm 5.000 đồng; tổng đơn khớp dòng hàng |
| DEMO-PARTIAL-RETURN | Khách trả cuốn, hoàn 50% giá dòng; không hoàn phí giao; cuốn sau đó được bán lại |
| DEMO-DAMAGED-RETURN | Nhận lại sách hỏng, hoàn giá dòng; cuốn chuyển DAMAGED, không vào tồn bán được |
| DEMO-RETURN-REQUESTED | Yêu cầu trả đang chờ xử lý, chưa nhận sách hoặc hoàn tiền |
| DEMO-RETURN-REJECTED | Yêu cầu trả bị từ chối, không đổi kho và không hoàn tiền |
| DEMO-RETURN-APPROVED | Đã duyệt yêu cầu, còn chờ nhận/kiểm tra cuốn |
| DEMO-RETURN-CANCELLED | Khách hủy yêu cầu trả, dòng trả không được chấp nhận |
| DEMO-HOLD-ACTIVE | Chờ thanh toán, giữ hàng còn hạn tại mốc seed |
| DEMO-CONFIRMED | Đơn đã xác nhận, đã thanh toán, đang giữ hàng |
| DEMO-PROCESSING | Đang chuẩn bị đơn, đã thanh toán, chưa xuất kho |
| DEMO-SHIPPED-COD | Đã xuất kho/giao vận, COD chưa thu; không ghi đã thanh toán sớm |
| DEMO-EXPIRED | Thanh toán thất bại, giữ chỗ đã hết hạn và giải phóng, đơn bị hủy |
| DEMO-CANCELLED | Hủy trước thanh toán, giữ chỗ đã giải phóng |
| DEMO-PAYMENT-RETRY | Lần thanh toán thất bại rồi thử lại thành công; chỉ lần thành công tính vào tiền thu |
| DEMO-PAID-CANCELLED | Hủy đơn đã thanh toán, hoàn đủ tiền đơn, Refunds.ReturnId NULL |
| DEMO-RESALE | Bán lại cuốn DEMO-C1-003 sau khi nhận trả từ DEMO-PARTIAL-RETURN |
| DEMO-GUEST | Khách vãng lai, CustomerId NULL, có nhân viên lập đơn và tiền mặt |
| DEMO-REFUND-RETRY | Đơn 2 cuốn, chỉ trả 1 cuốn; hoàn tiền thất bại rồi có lần thử mới PENDING |
| DEMO-REFUND-CANCELLED-RETRY | Lần hoàn tiền CANCELLED, lần sau SUCCEEDED, không cộng trùng |
| DEMO-FREE | Tổng đơn 0, không tạo bản ghi thanh toán 0 đồng |
| DEMO-HOLD-OVERDUE | Giữ chỗ ACTIVE nhưng đã quá hạn: dữ liệu đầu vào để kiểm thử tác vụ giải phóng |
| DEMO-SHIPPING | Có phí giao 30.000 đồng, COD đã thu sau khi hoàn tất |
| DEMO-MULTI-HOLD | Một đơn giữ 2 cuốn, cần thao tác nguyên tử trên cả hai |
| DEMO-POS-CANCELLED | Đơn tại quầy bị hủy, không xuất bán hoặc ghi thu tiền |
| DEMO-ZERO-RETURN-QUOTE | Đề nghị trả đang chờ, số tiền dự kiến 0, không tự phát sinh refund 0 |
| DEMO-CANCELLED-REFUND-PENDING | Đơn đã hủy, đã giải phóng hàng, khoản hoàn tiền đang chờ |
| DEMO-HISTORY-NULLS | Đơn tại quầy khách vãng lai, không có thông tin giao hàng |

Đơn giữ chỗ mới hết hạn sau khoảng 30 phút tính từ mốc seed. Các kiểm tra dữ liệu dùng mốc `AuditLogs.CreatedAt` của `DEMO_SEED_V1` để kết quả có thể tái lập; tác vụ ứng dụng phải dùng thời gian hiện tại. Sau một thời gian, các giữ chỗ mới cũng sẽ đến hạn, đây không phải lỗi seed.

## 4. Các ca kho, giỏ hàng và ảnh

| Dữ liệu | Kết quả cần kiểm thử |
|---|---|
| DEMO-TRANSFER-DRAFT / APPROVED / CANCELLED | Chưa xuất kho; không đổi chi nhánh cuốn |
| DEMO-TRANSFER-TRANSIT | Đã có TRANSFER_OUT, cuốn IN_TRANSIT, chưa ghi nhận tồn nhận |
| DEMO-TRANSFER-RECEIVED | 3 cuốn: nhận tốt, nhận hỏng và thiếu; có TRANSFER_IN cho 2 cuốn thực nhận |
| Kiểm kê FINALIZED | Thiếu chuyển LOST, hỏng chuyển DAMAGED, khớp không tạo điều chỉnh, tìm lại cuốn cũ chuyển AVAILABLE |
| Kiểm kê DRAFT / COUNTING / CANCELLED | Có dòng chưa đếm (ActualPresent NULL); chưa chốt không tự điều chỉnh kho |
| Giỏ khang và hoang tại S1 | Cùng chứa một cuốn: thêm giỏ không giữ hàng, lúc mua phải kiểm tra lại |
| Giỏ van tại S1 đang ACTIVE | Có cuốn đã bán trong giỏ cũ; checkout phải báo không còn hàng |
| Giỏ nam | Trả danh sách rỗng, không lỗi hoặc cho thanh toán giỏ trống |
| CHECKED_OUT / ABANDONED | Lịch sử giỏ giữ lại, không coi là giỏ đang hoạt động |
| MediaAssets của 83 đầu sách | Dùng ảnh có thật, hoặc ảnh dự phòng cho 13 bìa thiếu và 3 sách chưa có đường dẫn; không sửa Books.CoverImage |
| MediaAssets tác giả/cuốn/tài khoản | Có đủ bốn loại chủ thể; ảnh cuốn là ảnh dự phòng được ghi rõ, không giả ảnh chụp tình trạng |
| /images/demo-intentionally-missing.jpg | Một ảnh phụ cố ý không tồn tại, để kiểm thử fallback khi HTTP 404 |
| CLOUDINARY / public_id sample | Ảnh demo công khai tại res.cloudinary.com/demo; là ảnh phụ, không phải ảnh sách. Không tải lên tài khoản Cloudinary của người dùng hoặc kiểm thử API Cloudinary trong bước này |

## 5. Kiểm thử tự động đã chạy

| Bộ kiểm thử | Số kiểm tra | Kết quả |
|---|---:|---|
| 005-verify-demo-data.sql | 85 | Đạt: số dòng 35 bảng, độ phủ enum, tổng tiền, số lượng nhập, quan hệ kho/đơn/hoàn tiền và thời gian |
| 006-test-demo-negative-cases.sql | 49 | Đạt: giá trị âm, enum sai, NULL bắt buộc, vượt độ dài, trùng khóa, FK sai, thời gian sai; hoàn tác dữ liệu |
| 003-verify-core-tables.sql | 24 | Đạt: bộ ràng buộc gốc chạy lại sau seed; hoàn tác dữ liệu |
| test-concurrent-reservation.ps1 | 2 | Đạt: kết nối thứ hai bị khóa khi kết nối thứ nhất giữ cuốn; sau rollback được giữ cuốn, rồi cũng rollback |

**Tổng: 160 kiểm tra tự động**, cộng kiểm tra chạy seed lần hai không thêm trùng, đối chiếu toàn bộ dữ liệu danh mục và schema trước/sau. Bộ kiểm tra đồng thời kiểm chứng khóa/chỉ mục SQL, chưa phải kiểm thử checkout qua API.

Các ràng buộc CHECK/FK vẫn bật và tin cậy. Không lưu bản ghi cố ý vi phạm ràng buộc. IDENTITY có thể có khoảng trống do chạy thử và rollback; truy vấn theo mã mẫu, không giả định ID bắt đầu bằng 1.

## 6. Các test case cần chạy tiếp khi có ứng dụng

Đây là danh sách chuẩn bị dữ liệu và kết quả mong đợi, **chưa phải các ca đã chạy qua Spring Boot/JSP/API**:

| Mã | Ca kiểm thử | Dữ liệu / kỳ vọng |
|---|---|---|
| AUTH-01 | Đăng nhập đúng/sai mật khẩu | khang; đúng thì thành công, sai thì từ chối |
| AUTH-02 | Khóa/chờ duyệt/chưa phân quyền | minh, linh, huy; không truy cập trái quyền |
| AUTH-03 | Phân quyền chi nhánh | staff không sửa S2; manager không quản trị toàn hệ thống |
| AUTH-04 | Phân công hết hiệu lực/tài khoản khóa | staff4, staff5; từ chối thao tác |
| AUTH-05 | Refresh token | 5 dòng gồm còn hạn, hết hạn, thu hồi, đã rotate và token thay thế; tái sử dụng token cũ phải bị từ chối. Hash fixture không đi kèm token thô, cần phiên đăng nhập thật để kiểm thử endpoint |
| STORE-01 | Chi nhánh tạm nghỉ/đã đóng | S4/S5 không nhận đơn mới theo quy tắc đã chọn |
| ORDER-01 | Checkout nhiều cuốn | DEMO-MULTI-HOLD; thất bại một cuốn phải hoàn tác toàn giao dịch |
| ORDER-02 | Hết hạn giữ hàng | DEMO-HOLD-OVERDUE; giải phóng đúng một lần, không bán cuốn đã cấp cho đơn khác |
| ORDER-03 | Tranh chấp giữa hai khách | Hai giỏ có cùng cuốn; qua API chỉ một người đặt thành công |
| PAY-01 | Callback lặp | DEMO-PAYMENT-RETRY; không cộng tiền hoặc trừ kho lần hai |
| PAY-02 | Callback đến sau hủy/hết hạn | DEMO-EXPIRED; chuyển đối soát/hoàn tiền theo quy tắc, không tự xuất cuốn đã được đặt lại |
| REFUND-01 | Hoàn vượt tiền thu hoặc giá trị trả | Từ chối ở service có khóa/giao dịch; tổng hoàn nhiều dòng không được CHECK đơn lẻ tự bảo đảm |
| RETURN-01 | Trả trùng/sai người mua/chưa nhận | Từ chối sai quyền hoặc trạng thái; chỉ nhập lại sau kiểm tra thực tế |
| STOCK-01 | Nhập hàng/chuyển kho gọi lặp | Không sinh trùng BookCopies hoặc InventoryMovements |
| STOCK-02 | Kiểm kê khi có giao dịch mới | Khóa kho hoặc đối soát biến động theo quy tắc triển khai |
| MEDIA-01 | Ảnh NULL, 404, URL ngoài | Dùng ảnh dự phòng; không ghép context path vào URL Cloudinary |
| WS-01 | Thông báo và kết nối lại | Có đã đọc/chưa đọc, có/không chi nhánh; chỉ người nhận được xem; lấy lại thông báo sau reconnect |
| DATA-01 | Danh sách trống, Unicode, phân trang | nam, tên sách tiếng Việt, 249 cuốn, 27 đơn; đếm/trang/tìm kiếm chính xác |

## 7. Tệp và cách dùng

- [SQL seed](../database/004-seed-demo-data.sql): đã chạy. Chạy lại nhận thông báo đã cài v1 và không thêm dữ liệu. Không xóa marker để cố chạy lại.
- [SQL xem nhanh các tình huống](../database/007-demo-scenario-queries.sql): chỉ đọc, có tài khoản, đơn, tồn kho, hoàn tiền và dòng thời gian cuốn bán lại.
- [Kiểm tra dữ liệu](../database/005-verify-demo-data.sql), [kiểm thử từ chối](../database/006-test-demo-negative-cases.sql), [kiểm thử đồng thời](../tools/test-concurrent-reservation.ps1).
- [Danh sách bảng và số dòng thực tế](database-table-inventory.csv), [mã đơn và số tiền thực tế](demo-actual-summary.json).
- Kết quả chạy nằm trong `database/demo-*-results.txt` và `core-integrity-test-results.txt`.
- `before-demo-catalog.json` / `after-demo-catalog.json` và snapshot schema lưu đối chiếu; không thay thế backup đầy đủ SQL Server.

Bộ 005 kiểm tra số dòng của dataset nguyên trạng. Khi bạn thêm/sửa dữ liệu nghiệp vụ để thử ứng dụng, kiểm tra này có thể báo lệch; nó không tự xóa hoặc reset dữ liệu. Những dữ liệu thời gian phải được xem theo mốc seed hoặc qua tác vụ thực tế của ứng dụng.
