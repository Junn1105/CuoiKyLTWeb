# Mộc Sách — bản bàn giao 0.1.0

Ứng dụng Spring Boot, JSP/JSTL và SQL Server. Bản này gồm đăng nhập, đăng ký qua OTP, quên/đặt lại mật khẩu, ghi nhớ tên đăng nhập, quản lý tài khoản cá nhân (ảnh đại diện, họ tên, số điện thoại, email qua OTP, mật khẩu) và trang chủ giới thiệu sách theo đánh giá/lượt mua. Giỏ hàng, yêu thích, đơn hàng và chi tiết sách hiện là nút chờ theo phạm vi đã thống nhất.

## Chạy trên Windows

1. Giải nén toàn bộ ZIP vào thư mục, ví dụ `D:\MocSach`.
2. Cài Java 21 hoặc 25 x64 hoạt động, đặt `JAVA_HOME`. Không cần Maven để chạy bản đóng gói.
3. SQL Server phải đang chạy tại localhost:1433, có database `WebsiteQuanLyCuaHangSachCu` hiện tại và tài khoản Windows được cấp quyền. Gói này không chứa bản sao dữ liệu SQL Server; chuyển máy cần sao lưu/khôi phục database riêng. Không chạy lại seed để tránh ghi đè dữ liệu.
4. Database cần có migration `009-authentication.sql` và `010-book-reviews.sql` và `011-account-settings.sql`. Máy dự án hiện tại đã áp dụng; chỉ áp dụng trên bản database cũ còn thiếu.
5. Nhấp `Chay-MocSach.cmd`, mở http://127.0.0.1:8080. Nếu Java không tự được tìm thấy, chạy PowerShell: `powershell -ExecutionPolicy Bypass -File tools/start-app.ps1 -JavaHome "C:\duong-dan\jdk-21"`.
6. Dừng bằng Ctrl+C. JWT secret được tạo riêng trong `.local/application.properties` khi chạy lần đầu; giữ lại file này giữa các lần khởi động.

Tài khoản mẫu trên database dự án: `admin`, `staff`, `khang`, `hoang`, `van`; mật khẩu `123456`. Đây là tài khoản demo, cần đổi mật khẩu trước khi triển khai thực tế.

## Email OTP thật

Chạy `powershell -ExecutionPolicy Bypass -File tools/configure-gmail.ps1`, nhập Gmail gửi thư và mật khẩu ứng dụng Google 16 ký tự, sau đó khởi động lại. Bí mật được lưu riêng trên máy, không có trong gói bàn giao. Kiểm thử tự động dùng SMTP GreenMail; không thay thế việc kiểm tra giao thư Gmail thật sau khi cấu hình.

## Cấu hình và giới hạn

Cấu hình mặc định chỉ lắng nghe localhost. Có thể dùng biến môi trường `PORT`, `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` nếu thay đổi máy chủ. Windows Authentication dùng DLL SQL Server x64 đã kèm trong `.local/native` (Microsoft JDBC 13.2.1 từ Maven Central). Không đưa thư mục cấu hình cá nhân vào nơi công khai.

Gói WAR đã chứa giao diện, thư viện và ảnh bìa; 16 sách thiếu ảnh gốc dùng bìa minh họa có nhãn. Database không tự tạo/cập nhật schema khi khởi động. Báo cáo kiểm thử nằm trong `test-results`, mã SHA256 WAR trong `SHA256SUMS.txt`.

Đây là bản chạy cục bộ cho phạm vi đăng nhập/trang chủ hiện tại. Khi triển khai Internet cần cấu hình HTTPS, cookie bảo mật, database và tài khoản vận hành phù hợp.
