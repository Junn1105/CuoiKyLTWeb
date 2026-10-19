# Mộc Sách — đăng nhập và xác thực email

Ứng dụng Spring Boot 3.5.16, Java 21+, JSP/JSTL, Bootstrap tự lưu trong ứng dụng, JPA và SQL Server. Giao diện gồm đăng nhập, đăng ký, xác thực OTP, quên mật khẩu, đặt lại mật khẩu và trang xác nhận đăng nhập. Chưa triển khai dashboard bán hàng.

## Khởi chạy

Mở PowerShell tại thư mục project:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\start-app.ps1 -Build
```

Lần sau có thể bỏ `-Build` nếu mã nguồn không đổi. Truy cập http://127.0.0.1:8080/login. Dừng bằng Ctrl+C. Script nhận `-JavaHome` và `-MavenCommand` nếu cần chỉ định công cụ. Trên máy hiện tại dùng Java đi kèm IntelliJ vì bản JDK 21 cài riêng bị lỗi. Thư mục tạm đặt trong `.local` để tránh lỗi socket của Java trên Windows.

Database mặc định là SQL Server `localhost:1433`, Windows Authentication, database `WebsiteQuanLyCuaHangSachCu`. Cần bật TCP/IP và tài khoản Windows có quyền database. Migration `database/009-authentication.sql` đã được áp dụng trên máy này, thêm `Users.AuthVersion` và bảng `AuthChallenges` (tổng 36 bảng). Không cần chạy lại các migration tạo/seed cũ. Hibernate chỉ kiểm tra cấu trúc, không tự sửa database.

Tài khoản mẫu: `admin`, `staff`, `khang`, `hoang`, `van` / mật khẩu `123456`. Tài khoản LOCKED/PENDING bị từ chối đăng nhập. Mật khẩu đăng ký/đặt lại mới cần ít nhất 8 ký tự; tài khoản mẫu cũ vẫn đăng nhập được.

## Gmail gửi OTP thật

1. Bật xác minh 2 bước cho tài khoản Google gửi thư, tạo **Mật khẩu ứng dụng** tại https://myaccount.google.com/apppasswords. Một số tài khoản tổ chức không cho phép tính năng này.
2. Chạy công cụ dưới đây trong PowerShell. Nhập địa chỉ Gmail gửi thư và mật khẩu ứng dụng 16 chữ cái ở lời nhắc được che. Không gửi mật khẩu vào chat.

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\configure-gmail.ps1
```

3. Dừng ứng dụng rồi chạy lại `start-app.ps1` để nạp cấu hình.
4. Đăng ký bằng một email bạn có thể nhận thư, nhập OTP được gửi về. Sau khi đăng ký, thử quên mật khẩu với chính email đó. Kiểm tra cả thư rác.

Công cụ lưu cấu hình riêng tại `.local/mail.properties`, giới hạn quyền tệp cho người dùng Windows hiện tại; `.local` được gitignore. Không chia sẻ hoặc commit thư mục này. Có thể dùng biến môi trường `GMAIL_USERNAME`, `GMAIL_APP_PASSWORD` thay thế nếu chưa tạo tệp cấu hình. SMTP sử dụng `smtp.gmail.com:587` với STARTTLS bắt buộc. Hướng dẫn chính thức: https://support.google.com/mail/answer/7104828.

Chưa có thông tin Gmail trên máy nên **chưa kiểm chứng gửi đến hộp thư Gmail thật**. Bộ kiểm thử đã gửi/nhận SMTP qua GreenMail và kiểm tra các luồng OTP. Ứng dụng không tạo OTP giả hoặc hiển thị OTP trên giao diện/log khi chưa cấu hình mail. Email `example.invalid` của tài khoản mẫu không nhận thư; hãy đăng ký tài khoản mới với email thật để thử chức năng.

## Hành vi và bảo mật

- Ghi nhớ chỉ lưu tên đăng nhập trong localStorage, không lưu mật khẩu.
- Mật khẩu lưu BCrypt. OTP 6 số chỉ lưu HMAC, hết hạn sau 5 phút; tối đa 5 lần nhập sai; chờ 60 giây trước khi gửi lại, tối đa 5 lần gửi cho mỗi phiên.
- Tài khoản chỉ được tạo sau khi OTP đăng ký đúng. Yêu cầu reset cho email không tồn tại không tạo tài khoản và không cho phép đặt mật khẩu.
- Sau OTP reset đúng, có 10 phút đặt lại mật khẩu. Mã đã dùng không dùng lại được. Đổi mật khẩu tăng AuthVersion và thu hồi refresh token, khiến JWT cũ mất hiệu lực.
- JWT 2 giờ trong cookie HttpOnly/SameSite=Lax; biểu mẫu có CSRF, dữ liệu xuất JSP được escape. Có giới hạn yêu cầu theo IP/tên đăng nhập/email.
- Cấu hình mặc định chỉ lắng nghe localhost. Khi triển khai qua HTTPS cần `SECURE_COOKIE=true`, secret riêng đủ mạnh, quản lý cấu hình riêng và giới hạn yêu cầu dùng chung nếu chạy nhiều instance. Giới hạn IP hiện ở bộ nhớ một instance.

## Kiểm thử

`mvn test` chạy `AuthFlowTest`: đăng ký SMTP và gán CUSTOMER, OTP sai/hết hạn/dùng lại, gửi lại, thông tin đăng ký trùng, reset và thu hồi phiên, trạng thái tài khoản, cookie JWT, CSRF, phiên xác thực, các luồng form và giới hạn yêu cầu. Test dùng H2 + GreenMail độc lập, không thay đổi dữ liệu mẫu SQL Server.

## Chạy trực tiếp trong IntelliJ IDEA

Chọn cấu hình **MocSach - Local SQL Server** ở danh sách bên cạnh nút Run (không chọn Current File), rồi Run/Debug. Cấu hình được lưu trong `.run/MocSach.run.xml`; nếu chưa xuất hiện, đóng/mở lại project và Reload All Maven Projects.

Cấu hình này dùng Java 25 tại `D:/IntelliJ IDEA 2026.2.1/jbr`, bật dependency provided để chạy Tomcat/JSP, đặt working directory là project và truyền đường dẫn `.local/native` cho JDBC Windows Authentication. Project vẫn biên dịch theo Java 21 trong pom.xml. SDK 26 sẵn có của IDE được giữ để không ảnh hưởng các project khác; cấu hình Run dùng riêng Java 25.

Lỗi `This driver is not configured for integrated authentication` trong ảnh xuất phát từ lần chạy thiếu `-Djava.library.path`. Không cần đổi sang SQL Authentication hoặc sửa mật khẩu database. DLL x64 đúng phiên bản đã có trong `.local/native`. Nếu chạy cùng lúc bản PowerShell và bản IntelliJ trên 8080, hãy dừng bản đang chạy trước để tránh trùng cổng.
