USE [WebsiteQuanLyCuaHangSachCu];
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

-- Clean up any rows previously inserted without -f 65001 (UTF-8 mojibake)
DELETE FROM dbo.BookReviews WHERE Comment LIKE N'%Ã%' OR Comment LIKE N'%áº%' OR Comment LIKE N'%á»%';
DELETE FROM dbo.Notifications WHERE Title LIKE N'%Ã%' OR Title LIKE N'%áº%' OR Title LIKE N'%á»%' OR Content LIKE N'%Ã%' OR Content LIKE N'%áº%' OR Content LIKE N'%á»%';

-- 1. Seed 5 APPROVED reviews and comments for every book in dbo.Books (83 books x 5 = 415 reviews)
;WITH ActiveReviewers AS (
 SELECT UserId, ROW_NUMBER() OVER (ORDER BY UserId) - 1 AS ReviewerIdx, COUNT(*) OVER () AS TotalReviewers
 FROM dbo.Users
 WHERE Status = 'ACTIVE'
),
BookList AS (
 SELECT b.BookId, b.Title, c.CategoryName, ROW_NUMBER() OVER (ORDER BY b.BookId) - 1 AS BookIdx
 FROM dbo.Books b
 JOIN dbo.Categories c ON c.CategoryId = b.CategoryId
),
Slots AS (
 SELECT 0 AS SlotIdx UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
),
ReviewPairs AS (
 SELECT
  bl.BookId,
  bl.Title,
  bl.CategoryName,
  bl.BookIdx,
  s.SlotIdx,
  ar.UserId,
  CASE (bl.BookIdx + s.SlotIdx * 3) % 5
   WHEN 0 THEN 5
   WHEN 1 THEN 5
   WHEN 2 THEN 4
   WHEN 3 THEN 5
   ELSE 4
  END AS Rating,
  CASE (bl.BookIdx + s.SlotIdx * 5) % 15
   WHEN 0 THEN N'Sách cũ nhưng chất lượng còn rất tốt, gáy sách chắc chắn, giấy thơm mùi sách xưa. Nội dung tác phẩm «' + bl.Title + N'» thực sự cuốn hút từ những trang đầu tiên.'
   WHEN 1 THEN N'Mình tìm cuốn «' + bl.Title + N'» bản in cũ này khá lâu rồi mới thấy tại Mộc Sách. Bìa và trang ruột được bảo quản kỹ, đọc rất có cảm xúc.'
   WHEN 2 THEN N'Một cuốn sách rất đáng đọc trong mục ' + bl.CategoryName + N'. Văn phong mạch lạc, nhiều góc nhìn sâu sắc, đọc xong vẫn còn đọng lại nhiều suy ngẫm.'
   WHEN 3 THEN N'Giao hàng nhanh, đóng gói cẩn thận. Cuốn sách tuy đã qua sử dụng nhưng không hề bị rách hay thiếu trang, giá cả lại rất hợp lý cho sinh viên và người yêu sách.'
   WHEN 4 THEN N'Tác phẩm kinh điển mà ai yêu thích ' + bl.CategoryName + N' cũng nên có trên kệ. Bản sách cũ ở cửa hàng giữ được nét hoài niệm rất riêng.'
   WHEN 5 THEN N'Nội dung sách sâu sắc, bố cục chặt chẽ. Mình mua bản tình trạng Tốt tại Mộc Sách mà cầm lên gần như sách mới, rất hài lòng với cách tuyển chọn của tiệm.'
   WHEN 6 THEN N'Đọc «' + bl.Title + N'» vào dịp cuối tuần thực sự thư giãn. Từng chương đều được viết rất chắc tay, dịch thuật và biên tập mượt mà, dễ hiểu.'
   WHEN 7 THEN N'Sách chuẩn, giấy ngả màu nhẹ đúng chất sách cũ mình thích. Kiến thức và câu chuyện trong sách có giá trị vượt thời gian, đọc lại lần hai vẫn thấy hay.'
   WHEN 8 THEN N'Cảm ơn Mộc Sách đã giữ gìn những bản sách quý như thế này. Cuốn «' + bl.Title + N'» giúp mình mở rộng thêm rất nhiều kiến thức bổ ích.'
   WHEN 9 THEN N'Mình mua tặng bạn bè cùng đam mê đọc sách và ai cũng khen. Bìa sách phẳng phiu, chữ in rõ nét, nội dung truyền cảm hứng mạnh mẽ.'
   WHEN 10 THEN N'Đánh giá 5 sao cho cả nội dung sách lẫn chất lượng phục vụ. Sách mô tả đúng tình trạng thực tế, không bị viết vẽ bậy lên trang đọc.'
   WHEN 11 THEN N'Cuốn sách gối đầu giường của mình. Những phân tích và câu chuyện trong «' + bl.Title + N'» rất gần gũi, thiết thực và giàu tính nhân văn.'
   WHEN 12 THEN N'Giá tiết kiệm hơn rất nhiều so với mua mới mà trải nghiệm đọc vẫn trọn vẹn. Rất mong cửa hàng sưu tầm thêm nhiều đầu sách cùng chủ đề ' + bl.CategoryName + N'.'
   WHEN 13 THEN N'Cách dẫn dắt vấn đề của tác giả vô cùng lôi cuốn. Bản sách tại Mộc Sách còn giữ nguyên nếp gấp bìa đẹp, rất đáng đồng tiền bát gạo.'
   ELSE N'Một lựa chọn tuyệt vời cho tủ sách gia đình. Nội dung giàu giá trị, trình bày rõ ràng, cầm cuốn sách cũ trên tay cảm giác rất trân quý.'
  END AS Comment,
  DATEADD(HOUR, -((bl.BookIdx * 7 + s.SlotIdx * 19) % 720 + 2), SYSUTCDATETIME()) AS CreatedAt
 FROM BookList bl
 CROSS JOIN Slots s
 JOIN ActiveReviewers ar
  ON ar.ReviewerIdx = (bl.BookIdx * 3 + s.SlotIdx * 2) % ar.TotalReviewers
)
INSERT INTO dbo.BookReviews(BookId, UserId, Rating, Comment, Status, CreatedAt)
SELECT rp.BookId, rp.UserId, rp.Rating, rp.Comment, 'APPROVED', rp.CreatedAt
FROM ReviewPairs rp
WHERE NOT EXISTS (
 SELECT 1 FROM dbo.BookReviews existing
 WHERE existing.BookId = rp.BookId AND existing.UserId = rp.UserId
);

-- 2. Seed Facebook-style notifications for every ACTIVE user if they have fewer than 5 notifications
;WITH TargetUsers AS (
 SELECT u.UserId, u.FullName
 FROM dbo.Users u
 WHERE u.Status = 'ACTIVE'
),
SampleNotifs AS (
 SELECT 1 AS Seq, 'WELCOME' AS Type,
  N'Chào mừng bạn đến với Mộc Sách' AS Title,
  N'Khám phá hơn 80 đầu sách cũ tuyển chọn cùng hàng trăm đánh giá mới từ cộng đồng bạn đọc.' AS Content,
  N'/home' AS TargetUrl, 120 AS HoursAgo, 1 AS IsRead
 UNION ALL
 SELECT 2, 'RECOMMEND',
  N'Gợi ý sách hay dành riêng cho bạn',
  N'Tác phẩm «Truyện Kiều» và các đầu sách Văn học kinh điển vừa được bổ sung thêm bản sách tình trạng Như mới.',
  N'/books/1', 48, 0
 UNION ALL
 SELECT 3, 'REVIEW',
  N'Cộng đồng bạn đọc đang thảo luận sôi nổi',
  N'Nhiều độc giả vừa để lại đánh giá 5 sao cho các đầu sách bán chạy trong tuần. Xem ngay cảm nhận của bạn đọc!',
  N'/home#bestsellers', 24, 0
 UNION ALL
 SELECT 4, 'CART',
  N'Nhắc nhở giỏ sách của bạn',
  N'Các bản sách cũ thường chỉ có 1–3 cuốn tại mỗi chi nhánh. Hãy kiểm tra giỏ hàng để không bỏ lỡ cuốn sách yêu thích nhé.',
  N'/cart', 6, 0
 UNION ALL
 SELECT 5, 'SECURITY',
  N'Bảo mật tài khoản Mộc Sách',
  N'Bạn có thể cập nhật ảnh đại diện, số điện thoại và email xác thực OTP bất cứ lúc nào tại trang Tài khoản.',
  N'/account', 2, 1
)
INSERT INTO dbo.Notifications(UserId, StoreId, Type, Title, Content, TargetUrl, CreatedAt, ReadAt)
SELECT
 tu.UserId,
 NULL,
 sn.Type,
 sn.Title,
 sn.Content,
 sn.TargetUrl,
 DATEADD(HOUR, -sn.HoursAgo, SYSUTCDATETIME()),
 CASE WHEN sn.IsRead = 1 THEN DATEADD(HOUR, -(sn.HoursAgo - 1), SYSUTCDATETIME()) ELSE NULL END
FROM TargetUsers tu
CROSS JOIN SampleNotifs sn
WHERE (SELECT COUNT(*) FROM dbo.Notifications n WHERE n.UserId = tu.UserId) < 5
  AND NOT EXISTS (
   SELECT 1 FROM dbo.Notifications existing
   WHERE existing.UserId = tu.UserId AND existing.Title = sn.Title
  );

COMMIT TRANSACTION;
