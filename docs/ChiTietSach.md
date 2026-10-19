# Trang chi tiết sách

Mở `/books/{BookId}` hoặc bấm bìa/tên sách trên trang chủ.

Bố cục theo ảnh tham khảo: bìa bên trái, nút Thêm vào giỏ hàng / Mua ngay bên dưới; tên, tác giả, nhà xuất bản, giá khởi điểm và số lượng bên phải. Tiếp theo là thông tin chi tiết, mô tả, đánh giá/bình luận và tối đa 8 sách cùng tác giả. Trên điện thoại, các phần xếp thành một cột.

Thông tin lấy từ database, không tạo mô tả/người dịch giả. Trường thiếu hiển thị Đang cập nhật; bìa thiếu dùng bìa minh họa hoặc ảnh dự phòng. Migration `012-book-details.sql` thêm cột `Books.Translator` tùy chọn, đã áp dụng tại database dự án.

Số lượng giới hạn theo số bản sách AVAILABLE; sách hết hàng khóa các nút mua. Giá là mức thấp nhất của các bản sách có sẵn, chưa phải báo giá cố định cho toàn bộ số lượng.

Nút Thêm vào giỏ hàng, Mua ngay trên trang chi tiết sách và nút `+` trên thẻ sách sẽ tự động chọn N bản sách `AVAILABLE` có giá tốt nhất tại các chi nhánh `ACTIVE` để thêm vào giỏ hàng (`dbo.Carts` / `dbo.CartItems`). Trang `/cart` hiển thị danh sách bản sách đã chọn theo từng chi nhánh, tình trạng cuốn, tổng tiền tạm tính và cho phép xóa từng cuốn hoặc làm trống giỏ.

Đánh giá yêu cầu đăng nhập, CSRF, 1–5 sao và bình luận 3–2000 ký tự; tối đa 10 lần gửi/giờ/tài khoản. Mỗi tài khoản một đánh giá/sách, gửi lại sẽ cập nhật. Đánh giá mới được hiển thị ngay; bản ghi HIDDEN không thể tự khôi phục qua form. Nội dung được escape khi hiển thị. Chỉ đánh giá APPROVED được tính số sao và gợi ý trên trang chủ. Hiển thị tối đa 20 bình luận công khai mới nhất.

Sách cùng tác giả được nối theo AuthorId, loại chính sách đang xem và không lặp khi cùng nhiều tác giả.
