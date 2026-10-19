# Kết quả kiểm thử chức năng tài khoản — 18/10/2026

Lệnh: `mvn -B -q verify` — thành công, đóng gói `target/moc-sach.war`.

| Nhóm | Kết quả |
|---|---|
| AuthFlowTest | 25 đạt, 0 lỗi, 0 bỏ qua |
| AvatarStorageTest | 2 đạt, 0 lỗi, 0 bỏ qua |
| CatalogServiceTest | 3 đạt, 0 lỗi, 0 bỏ qua |

Tổng: **30/30**.

Các trường hợp tài khoản đã kiểm tra:
- Lưu họ tên/số điện thoại; kiểm tra dữ liệu sai; không gửi OTP; chỉ cập nhật tài khoản đăng nhập dù khách truyền UserId khác.
- Upload ảnh qua HTTP có CSRF, lưu được ảnh và đọc lại PNG 384 × 384; không đọc được ảnh của tài khoản khác; từ chối file giả ảnh, SVG, ảnh quá kích thước/dung lượng và tên file có đường dẫn.
- Đổi email cần mật khẩu hiện tại; gửi OTP đúng email đích; email không thay đổi trước xác nhận; sai mã, hết hạn, khóa sau 5 lần, cooldown gửi lại, email trùng, mã của người khác, mã cũ sau yêu cầu mới đều bị từ chối.
- Gửi SMTP thất bại không lưu yêu cầu đổi email hoặc thay đổi email hiện tại.
- Đổi email vô hiệu hóa JWT cũ, cấp cookie mới và hủy yêu cầu khôi phục gửi đến email cũ.
- Đổi mật khẩu qua HTTP; từ chối mật khẩu hiện tại sai, mật khẩu mới quá ngắn; xóa cookie, vô hiệu JWT cũ; mật khẩu cũ không đăng nhập được, mật khẩu mới đăng nhập được.
- Các ca đăng ký, quên mật khẩu, danh mục trước đó vẫn đạt.

Kiểm tra thêm trên bản WAR với SQL Server thực: đăng nhập tài khoản mẫu, render JSP tài khoản, upload multipart có CSRF và thông báo từ chối file không phải ảnh đã đạt. Trang tài khoản được kiểm tra trực quan ở chiều rộng 1086px, không tràn ngang.

Gmail SMTP: kết nối STARTTLS và xác thực tài khoản cấu hình thành công. Không gửi thư thật trong lần kiểm tra này. Kiểm thử luồng OTP tự động dùng GreenMail; việc giao thư Gmail thực tế vào Inbox/Spam chưa được xác minh.

Dữ liệu kiểm thử chức năng được tạo trong H2 và thư mục ảnh tạm; không thay đổi họ tên, ảnh, email hoặc mật khẩu của tài khoản thật để kiểm thử.
