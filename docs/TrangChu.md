# Trang chủ Mộc Sách

Trang `/` và `/home` hiển thị công khai. Đăng nhập thành công chuyển về `/home`. Chạy lại cấu hình **MocSach - Local SQL Server** trong IntelliJ rồi mở http://localhost:8080/home.

## Đã triển khai

- Giao diện tiếng Việt, tông xanh đồng bộ trang đăng nhập; thanh điều hướng, banner, thẻ sách, danh mục và sách bán chạy; bố cục cho máy tính và điện thoại.
- Tìm theo tên sách hoặc tác giả, lọc danh mục từ database, trạng thái không có kết quả. Hiển thị tối đa 24 kết quả; dùng từ khóa/danh mục để thu hẹp kết quả.
- Bìa từ thư mục ảnh đã chuyển; đường dẫn thiếu/không hợp lệ dùng `book-placeholder.svg`, có thêm xử lý lỗi tải ảnh trên trình duyệt. Không thay dữ liệu bìa cũ.
- Hiển thị giá thấp nhất của các bản sách AVAILABLE và thông báo tạm hết hàng nếu không còn bản AVAILABLE.
- Các nút yêu thích, giỏ hàng, đơn hàng, thông báo và chi tiết sách được bố trí sẵn, hiển thị thông báo chưa mở; chưa thực hiện giao dịch. Đăng nhập/đăng xuất, tìm kiếm, lọc danh mục và trang tài khoản hoạt động thật. Xem thêm TaiKhoan.md.

## Cách đề xuất

Migration `database/010-book-reviews.sql` đã thêm bảng `BookReviews` vào database hiện tại (tổng 37 bảng). Rating từ 1–5; mỗi người đánh giá một lần cho một đầu sách; trạng thái PENDING/APPROVED/HIDDEN. Chỉ APPROVED được tính. Chưa tạo giao diện gửi/duyệt đánh giá và không tự tạo điểm đánh giá giả.

Lượt mua là số dòng OrderItems thuộc đơn COMPLETED, loại các dòng có trả hàng ACCEPTED thuộc phiếu trả COMPLETED. Một dòng tương ứng một bản sách. Không tính đơn hủy/đang xử lý. Tác giả, đánh giá, lượt mua và tồn kho được gom riêng trước khi join để tránh nhân đôi số liệu.

Điểm đề xuất = `(điểm trung bình × số đánh giá + 3.5 × 5) / (số đánh giá + 5) + 0.7 × ln(1 + lượt mua) + 0.15 × ln(1 + số đánh giá)`. Đây là xếp hạng chung, chưa phải gợi ý cá nhân theo lịch sử người dùng. Cùng điểm thì sắp theo BookId để kết quả ổn định. Mục bán chạy sắp theo lượt mua giảm dần, cùng lượt mua thì theo tên sách.

Hiện chưa có đánh giá nên giao diện ghi “Chưa đánh giá”; đề xuất dựa vào lượt mua với mức điểm nền chung. Khi có đánh giá đã duyệt, thứ tự tự cập nhật.

## Kiểm tra

Build Maven và 17 kiểm thử đã đạt: 14 kiểm thử xác thực, 3 kiểm thử danh mục. Các ca danh mục kiểm tra đánh giá bị ẩn/chờ duyệt, đơn hủy, hàng trả, sách nhiều tác giả không bị nhân số liệu, thiếu bìa, hết hàng và thay đổi thứ tự theo lượt mua. Test dùng H2 riêng; không seed đánh giá thử vào SQL Server.

Đã bổ sung 16 bìa SVG minh họa có tên sách và tác giả cho các sách thiếu ảnh nguồn, lưu tại src/main/resources/static/images/books/fallback. Trên bìa ghi rõ BÌA MINH HỌA; đây không phải bìa xuất bản gốc. Ảnh gốc và đường dẫn database được giữ nguyên.

