# Website quản lý chuỗi cửa hàng sách cũ

Đã xây dựng ứng dụng Spring Boot: đăng nhập, đăng ký OTP, quên/đặt lại mật khẩu, ghi nhớ tên đăng nhập và ẩn/hiện mật khẩu. Database gồm 35 bảng nghiệp vụ đã seed, AuthChallenges phục vụ OTP và BookReviews phục vụ đánh giá sách. Xem [hướng dẫn chạy và cấu hình Gmail](docs/DangNhapVaGmail.md). Trang chủ tại `/home`: [chức năng và cách tính đề xuất](docs/TrangChu.md).

- [Dữ liệu mẫu, tài khoản và test case](docs/DuLieuMauVaTestCase.md)
- [Truy vấn xem nhanh các tình huống mẫu](database/007-demo-scenario-queries.sql)
- [Cấu trúc database đã triển khai](docs/CauTrucDatabase.md)
- [Từ điển cột, khóa ngoại và ràng buộc thực tế](docs/TuDienDuLieu.md)
- [Bản thiết kế và các phần mở rộng chưa triển khai](docs/DeXuatCoSoDuLieu.md)
- [Danh sách đường dẫn ảnh trước/sau](docs/image-path-mapping.csv)
- [13 ảnh bìa thiếu tại nguồn](docs/missing-images.csv)
- [72 ảnh đã sao chép và checksum](docs/image-manifest.csv)

## Quy ước ảnh

Ảnh tĩnh nằm ở `src/main/resources/static/images/`.

| Loại | URL lưu trong database | Tệp trong project |
|---|---|---|
| Bìa sách | `/images/books/truyen-kieu.jpg` | `src/main/resources/static/images/books/truyen-kieu.jpg` |
| Tác giả | `/images/authors/george-orwell.jpg` | `src/main/resources/static/images/authors/george-orwell.jpg` |
| Ảnh dự phòng | `/images/book-placeholder.svg` | `src/main/resources/static/images/book-placeholder.svg` |

Không lưu đường dẫn ổ D:/F: hoặc tiền tố `src/main/resources/static` vào database. Với JSP/JSTL, tạo URL nội bộ qua `<c:url value="${book.coverImage}"/>` để hỗ trợ context path, rồi escape khi đưa vào thuộc tính HTML. Khi xây dựng giao diện, xử lý cả ảnh NULL và tải lỗi bằng ảnh dự phòng. Cho phép truy cập ảnh tĩnh trong cấu hình bảo mật.

Khi tích hợp Cloudinary, giữ URL HTTPS ngoài ứng dụng và render có escape, không ghép context path; lưu PublicId để quản lý tài nguyên. Chưa tải ảnh lên Cloudinary trong bước này.

## Database

Đã đổi tên đăng nhập mẫu thành `admin`, `manager`, `staff`, `khang`, `hoang`, `van`… và đặt mật khẩu chung `123456` bằng `database/008-rename-demo-accounts.sql`. Giữ nguyên ID, quyền và trạng thái kiểm thử. Tên đăng nhập không dấu; họ tên hiển thị có dấu. Email giả lập vẫn giữ nguyên để nhận diện dữ liệu mẫu.

Đã chạy `database/004-seed-demo-data.sql`: thêm 1.215 dòng vào 28 bảng trước đó trống, gồm 16 tài khoản, 5 chi nhánh, 249 cuốn sách, 27 đơn và đầy đủ các nhóm dữ liệu liên quan. Mật khẩu mẫu là `123456`, lưu bằng BCrypt; danh sách tài khoản và phạm vi quyền nằm trong tài liệu test case. Script có transaction và marker chống thêm trùng khi chạy lại.

Đã đạt 160 kiểm tra: 85 kiểm tra dữ liệu/độ phủ, 49 ca từ chối dữ liệu sai, 24 ca ràng buộc gốc và 2 ca tranh chấp giữ hàng ở SQL. Đã xác minh chạy seed lần hai không thêm trùng, dữ liệu danh mục và cấu trúc giữ nguyên. Đây là kiểm thử database; kiểm thử ứng dụng được mô tả riêng trong tài liệu đăng nhập.

`database/005-verify-demo-data.sql` kiểm tra dataset nguyên trạng; `006-test-demo-negative-cases.sql` chạy ca lỗi rồi rollback; `007-demo-scenario-queries.sql` chỉ đọc dữ liệu. Bộ đếm dòng của 005 có thể báo lệch sau khi bạn chủ động tạo giao dịch mới. Các giữ chỗ có hạn sử dụng tương đối với mốc seed trong AuditLogs, không được tự gia hạn khi chạy lại script.

Đã chạy `database/002-create-core-tables.sql`: tạo 30 bảng mới với khóa chính, khóa ngoại, CHECK và chỉ mục; thêm 2 vai trò ADMIN/CUSTOMER và 4 mức tình trạng sách. Migration này chỉ chạy một lần, tự hoàn tác nếu lỗi và từ chối chạy lại khi có bảng đích tồn tại. Dữ liệu nghiệp vụ mẫu được thêm riêng bằng script 004.

Đã chạy `database/003-verify-core-tables.sql`: 24 tình huống kiểm tra đạt; toàn bộ dữ liệu kiểm thử được rollback. Không chạy lại migration 002 trên database đã triển khai. Có thể chạy lại kiểm thử 003 khi cần trên môi trường phát triển; IDENTITY có thể có khoảng trống do rollback, ứng dụng không được giả định ID liên tục hoặc bắt đầu bằng 1.

`database/before-core-migration.json` và `after-core-migration.json` chứa dữ liệu đầy đủ của 5 bảng danh mục để đối chiếu. `core-schema-snapshot.json` lưu cột, ràng buộc, khóa ngoại và chỉ mục của 35 bảng. Đây là snapshot phục vụ kiểm chứng, không phải backup đầy đủ để khôi phục SQL Server.

Đã chạy `database/001-update-image-paths.sql` trên **WebsiteQuanLyCuaHangSachCu**: 80 đường dẫn bìa + 5 ảnh tác giả. Script chạy trong transaction, kiểm tra giá trị cũ/mới và có thể chạy lại khi dữ liệu vẫn phù hợp. Không tạo thêm bảng.

`database/001-rollback-image-paths.sql` khôi phục các đường dẫn cũ, chỉ chạy khi cần quay lại quy ước của ứng dụng cũ. Có kiểm tra xung đột nếu ảnh đã được thay đổi về sau. Snapshot `before-image-migration.json` và `after-image-migration.json` chỉ gồm đường dẫn ảnh, cột và số lượng bản ghi; không thay thế bản backup toàn database.

`tools/prepare-image-migration.ps1` tạo lại manifest và script từ snapshot trước migration, kiểm tra tệp với project nguồn. Không chạy script chuẩn bị này để tạo một migration mới sau khi đã thay đổi ảnh; cần khảo sát/snapshot mới.

Nguồn và ghi chú ảnh cũ được giữ ở `docs/BookCoverSources.md` và `docs/VietnameseBookCoverSources.md`. Đây là tài liệu nguồn sao chép từ project thư viện, không phải xác nhận mới về độ chính xác của từng bìa.

## Tài khoản cá nhân
Đã bổ sung đổi ảnh đại diện, họ tên, số điện thoại, đổi email qua OTP và đổi mật khẩu tại /account. Xem [hướng dẫn tài khoản](docs/TaiKhoan.md). Migration bổ sung: database/011-account-settings.sql.

## Chi tiết sách
Trang /books/{BookId}: thông tin sách, bìa, số lượng, mô tả, bình luận và gợi ý cùng tác giả. Xem [chi tiết phạm vi](docs/ChiTietSach.md).
