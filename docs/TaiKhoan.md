# Tài khoản cá nhân

Mở `/account` bằng nút **Tài khoản** hoặc ảnh/tên người dùng trên trang chủ.

- Họ tên: 2–150 ký tự; số điện thoại: 9–15 chữ số, chấp nhận dấu + đầu số và khoảng cách. Không yêu cầu OTP cho số điện thoại.
- Ảnh đại diện: JPG/PNG tối đa 5 MB, tối đa 4096 × 4096 pixel. Máy chủ đọc ảnh thật, cắt vuông ở giữa và mã hóa lại PNG 384 × 384; không sử dụng tên file do khách gửi.
- Email: nhập mật khẩu hiện tại, nhận OTP ở email mới rồi xác nhận. Không đổi email nếu gửi mail thất bại, mã sai/hết hạn hoặc email đã được sử dụng.
- OTP: 5 phút, tối đa 5 lần sai, 60 giây giữa hai lần gửi, tối đa 5 lần gửi mỗi phiên và giới hạn theo tài khoản/email. Yêu cầu mới thay thế yêu cầu cũ. OTP gắn với người dùng và phiên bản bảo mật tài khoản.
- Mật khẩu: cần mật khẩu hiện tại và nhập lại mật khẩu mới, tối thiểu 8 ký tự, tối đa 72 byte. Mật khẩu lưu BCrypt. Đổi mật khẩu sẽ yêu cầu đăng nhập lại; đổi email cấp cookie mới cho phiên hiện tại và vô hiệu hóa cookie cũ. Các yêu cầu khôi phục mật khẩu trước đó cũng bị hủy.

## Lưu trữ và cấu hình

Áp dụng `database/011-account-settings.sql` sau 009: thêm `Users.AvatarPath`, `AuthChallenges.VersionAtIssue` và cho phép mục đích OTP `EMAIL`. Cột `Users.Phone` đã có sẵn. Migration đã áp dụng trên database dự án hiện tại.

Ảnh được lưu bền vững tại `.local/avatars`, ngoài WAR, không cần Cloudinary. Có thể đổi thư mục bằng `app.avatar.directory`. Khi chuyển máy cần sao lưu thư mục ảnh cùng database; không đưa thư mục này vào gói phát hành công khai. Việc tích hợp Cloudinary chưa nằm trong thay đổi này.

Email thật dùng cấu hình Gmail SMTP sẵn có (`tools/configure-gmail.ps1`). Các bài kiểm thử gửi email tới SMTP GreenMail cục bộ, không gửi thư tới người dùng thật.
