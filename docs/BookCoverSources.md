# Nguồn ảnh bìa sách

Kiểm tra ngày 01/10/2026: 67/80 đầu sách trong dữ liệu khởi tạo có ảnh JPEG tại `src/QuanLyThuVien.App/books/`; 13 đầu sách còn dùng ô thay thế. Tệp bìa được đặt đúng tên đã lưu trong `Books.CoverImage`; không cập nhật database.

Đối với các dòng Open Library, bản ghi ấn bản được tra theo ISBN đang lưu, ISBN-13 hoặc ISBN-10 tương đương và tên sách đều được đối chiếu trước khi lấy ID ảnh trong trường `covers`. Liên kết “Ảnh” bên dưới là ID ảnh đã dùng. Không chạy lại thao tác tải theo lô từ Covers API: [hướng dẫn Open Library](https://openlibrary.org/dev/docs/api/covers) yêu cầu không crawl dịch vụ này. Các ảnh bổ sung riêng lẻ lấy từ trang nhà xuất bản, trang tác giả hoặc nhà sách có thông tin ấn bản.

Tất cả 67 tệp đã qua kiểm tra magic bytes JPEG và giải mã ảnh; tổng dung lượng 3,08 MB. Ảnh `domain-driven-design.jpg` chỉ có 154×210 px nên sẽ kém sắc nét ở trang chi tiết. Bìa sách có bản quyền riêng, không mặc nhiên thuộc giấy phép mã nguồn; cần kiểm tra quyền sử dụng trước khi phân phối thương mại.

Đối với sách Việt Nam, [ghi chú kiểm chứng chi tiết](VietnameseBookCoverSources.md) nêu các năm tái bản và điểm chưa chắc chắn về ISBN; các liên kết nguồn trực tiếp vẫn được liệt kê ở bảng dưới.

## Ảnh hiện có

| ID | Sách | ISBN/mã | Tệp | Cỡ ảnh | Nguồn và ảnh gốc |
| ---: | --- | --- | --- | ---: | --- |
| 1 | Truyện Kiều | 9786043948479 | `books/truyen-kieu.jpg` | 386×581 | [NXB Văn Học / Tiền Phong](https://nxbvanhoc.com.vn/truyen-kieu-dai-mai-books) · [Ảnh](https://bizweb.dktcdn.net/thumb/1024x1024/100/441/742/products/8935343700688.jpg?v=1748888096320) |
| 2 | Số đỏ | 9786049889721 | `books/so-do.jpg` | 320×499 | [NXB Văn Học](https://nxbvanhoc.com.vn/so-do-tai-ban-nam-2020) · [Ảnh](https://bizweb.dktcdn.net/thumb/1024x1024/100/370/339/products/so-do-minh-thang.jpg?v=1589963152457) |
| 3 | Chí Phèo | 9786043942156 | `books/chi-pheo.jpg` | 500×654 | [Nhà sách Minh Thắng](https://nhasachminhthang.vn/sach-van-hoc-viet-nam/chi-pheo-bia-mem-tai-ban-3486-1635.html) · [Ảnh](https://nhasachminhthang.vn/UserFiles/files/Vanhocvietnam/ch%C3%AD%20ph%C3%A8o%20m%E1%BB%81m.png) |
| 4 | Tắt đèn | 9786049766749 | `books/tat-den.jpg` | 200×280 | [Minh Khai / NXB Văn Học](https://minhkhai.com.vn/store2/index.aspx?isbn=9786049766749&q=view) · [Ảnh](https://minhkhai.com.vn/hinhlon/9786049766749.jpg) |
| 6 | Dế Mèn phiêu lưu ký | 9786042189590 | `books/de-men-phieu-luu-ky.jpg` | 444×600 | [NXB Kim Đồng](https://nxbkimdong.com.vn/products/de-men-phieu-luu-ky-2) · [Ảnh](https://bizweb.dktcdn.net/thumb/grande/100/576/749/products/de-men-phieu-luu-ky-phien-ban-dau-dua-tb-2021-ef4ae91d8cdf4ea88aa1d9b5b76f8c7a.jpg?v=1760789051823) |
| 8 | Cánh đồng bất tận | 9786041266001 | `books/canh-dong-bat-tan.jpg` | 500×769 | [NXB Trẻ](https://www.nxbtre.com.vn/sach/canh-dong-bat-tan-158920.html) · [Ảnh](https://www.nxbtre.com.vn/Images/Book/copy_29_nxbtre_full_30122019_111202.jpg) |
| 9 | Pride and Prejudice | 9780141439518 | `books/pride-and-prejudice.jpg` | 320×500 | [Open Library](https://openlibrary.org/isbn/9780141439518) · [Ảnh 12645114](https://covers.openlibrary.org/b/id/12645114-L.jpg?default=false) |
| 10 | 1984 | 9780451524935 | `books/1984.jpg` | 251×450 | [Penguin Random House](https://penguinrandomhouselibrary.com/book/?isbn=9780451524935) · [Ảnh](https://images.penguinrandomhouse.com/cover/9780451524935) |
| 11 | The Great Gatsby | 9780743273565 | `books/the-great-gatsby.jpg` | 305×500 | [Open Library](https://openlibrary.org/isbn/9780743273565) · [Ảnh 13028546](https://covers.openlibrary.org/b/id/13028546-L.jpg?default=false) |
| 12 | To Kill a Mockingbird | 9780061120084 | `books/to-kill-a-mockingbird.jpg` | 332×500 | [Open Library](https://openlibrary.org/isbn/9780061120084) · [Ảnh 15162569](https://covers.openlibrary.org/b/id/15162569-L.jpg?default=false) |
| 13 | Norwegian Wood | 9780375704024 | `books/norwegian-wood.jpg` | 305×475 | [Open Library](https://openlibrary.org/isbn/9780375704024) · [Ảnh 6376119](https://covers.openlibrary.org/b/id/6376119-L.jpg?default=false) |
| 14 | One Hundred Years of Solitude | 9780060883287 | `books/one-hundred-years-of-solitude.jpg` | 331×500 | [Open Library](https://openlibrary.org/isbn/9780060883287) · [Ảnh 38979](https://covers.openlibrary.org/b/id/38979-L.jpg?default=false) |
| 15 | The Little Prince | 9780156012195 | `books/the-little-prince.jpg` | 309×475 | [Open Library](https://openlibrary.org/isbn/9780156012195) · [Ảnh 115508](https://covers.openlibrary.org/b/id/115508-L.jpg?default=false) |
| 16 | Crime and Punishment | 9780140449136 | `books/crime-and-punishment.jpg` | 293×450 | [Penguin Random House](https://www.penguinrandomhouse.com/books/286337/crime-and-punishment-by-fyodor-dostoyevsky/9780140449136/readers-guide/) · [Ảnh](https://images.penguinrandomhouse.com/cover/9780140449136) |
| 17 | The Wealth of Nations | 9780140432084 | `books/wealth-of-nations.jpg` | 324×500 | [Open Library](https://openlibrary.org/isbn/9780140432084) · [Ảnh 103128](https://covers.openlibrary.org/b/id/103128-L.jpg?default=false) |
| 18 | Capital: Volume I | 9780140445688 | `books/capital-volume-one.jpg` | 319×500 | [Open Library](https://openlibrary.org/isbn/9780140445688) · [Ảnh 104115](https://covers.openlibrary.org/b/id/104115-L.jpg?default=false) |
| 19 | The General Theory of Employment, Interest and Money | 9780230004764 | `books/general-theory.jpg` | 335×500 | [Open Library](https://openlibrary.org/isbn/9780230004764) · [Ảnh 2336450](https://covers.openlibrary.org/b/id/2336450-L.jpg?default=false) |
| 20 | Why Nations Fail | 9780307719225 | `books/why-nations-fail.jpg` | 302×450 | [Penguin Random House](https://www.penguinrandomhouse.com/books/205014/why-nations-fail-by-daron-acemoglu-and-james-a-robinson/) · [Ảnh](https://images.penguinrandomhouse.com/cover/9780307719225) |
| 21 | Capital in the Twenty-First Century | 9780674979857 | `books/capital-21st-century.jpg` | 306×500 | [Open Library](https://openlibrary.org/isbn/9780674979857) · [Ảnh 14448967](https://covers.openlibrary.org/b/id/14448967-L.jpg?default=false) |
| 23 | Poor Economics | 9781610390934 | `books/poor-economics.jpg` | 333×500 | [Open Library](https://openlibrary.org/isbn/9781610390934) · [Ảnh 8315340](https://covers.openlibrary.org/b/id/8315340-L.jpg?default=false) |
| 24 | Political Order and Political Decay | 9780374535629 | `books/political-order-decay.jpg` | 333×500 | [Open Library](https://openlibrary.org/isbn/9780374535629) · [Ảnh 9381734](https://covers.openlibrary.org/b/id/9381734-L.jpg?default=false) |
| 25 | English Grammar in Use | 9781108457651 | `books/english-grammar-in-use.jpg` | 374×500 | [Open Library](https://openlibrary.org/isbn/9781108457651) · [Ảnh 8665352](https://covers.openlibrary.org/b/id/8665352-L.jpg?default=false) |
| 27 | The Official Cambridge Guide to IELTS | 9781107620698 | `books/official-cambridge-ielts.jpg` | 375×500 | [Open Library](https://openlibrary.org/isbn/9781107620698) · [Ảnh 12804892](https://covers.openlibrary.org/b/id/12804892-L.jpg?default=false) |
| 28 | Practical English Usage | 9780194202435 | `books/practical-english-usage.jpg` | 500×750 | [Oxford University Press Japan](https://www.oupjapan.co.jp/en/node/24189) · [Ảnh](https://www.oupjapan.co.jp/sites/default/files/images/product/sku/9780194202435.jpg) |
| 29 | Academic Vocabulary in Use | 9781107591660 | `books/academic-vocabulary-in-use.jpg` | 669×900 | [Thalia](https://www.thalia.de/shop/home/artikeldetails/A1038455901) · [Ảnh](https://images.thalia.media/-/BF2000-2000/b4f8e9da0aca4dbaa83317c3ef3984a9/academic-vocabulary-in-use-edition-with-answers-2nd-edition-knv-besorgung.jpeg) |
| 31 | Minna no Nihongo Shokyu I, 2nd Edition | 9784883196036 | `books/minna-no-nihongo-1.jpg` | 354×500 | [Open Library](https://openlibrary.org/isbn/9784883196036) · [Ảnh 10621003](https://covers.openlibrary.org/b/id/10621003-L.jpg?default=false) |
| 32 | Minna no Nihongo Shokyu II, 2nd Edition | 9784883196463 | `books/minna-no-nihongo-2.jpg` | 360×500 | [Open Library](https://openlibrary.org/isbn/9784883196463) · [Ảnh 10495141](https://covers.openlibrary.org/b/id/10495141-L.jpg?default=false) |
| 33 | GENKI I: An Integrated Course in Elementary Japanese | 9784789017305 | `books/genki-1.jpg` | 356×500 | [Open Library](https://openlibrary.org/isbn/9784789017305) · [Ảnh 10450975](https://covers.openlibrary.org/b/id/10450975-L.jpg?default=false) |
| 34 | GENKI II: An Integrated Course in Elementary Japanese | 9784789017329 | `books/genki-2.jpg` | 200×282 | [The Japan Times Publishing](https://bookclub.japantimes.co.jp/en/book/b531517.html) · [Ảnh](https://bookclub.japantimes.co.jp/images/book/531517.jpg) |
| 35 | Basic Kanji Book, Volume 1 | 9784893580917 | `books/basic-kanji-book-1.jpg` | 369×475 | [Open Library](https://openlibrary.org/isbn/9784893580917) · [Ảnh 1045056](https://covers.openlibrary.org/b/id/1045056-L.jpg?default=false) |
| 36 | Japanese From Zero! 1 | 9780976998129 | `books/japanese-from-zero-1.jpg` | 384×500 | [Open Library](https://openlibrary.org/isbn/9780976998129) · [Ảnh 14420377](https://covers.openlibrary.org/b/id/14420377-L.jpg?default=false) |
| 37 | Clean Code | 9780132350884 | `books/clean-code.jpg` | 375×500 | [Open Library](https://openlibrary.org/isbn/9780132350884) · [Ảnh 15126503](https://covers.openlibrary.org/b/id/15126503-L.jpg?default=false) |
| 38 | The Pragmatic Programmer | 9780135957059 | `books/pragmatic-programmer.jpg` | 382×500 | [Open Library](https://openlibrary.org/isbn/9780135957059) · [Ảnh 10143650](https://covers.openlibrary.org/b/id/10143650-L.jpg?default=false) |
| 39 | Design Patterns | 9780201633610 | `books/design-patterns.jpg` | 318×396 | [Open Library](https://openlibrary.org/isbn/9780201633610) · [Ảnh 10827044](https://covers.openlibrary.org/b/id/10827044-L.jpg?default=false) |
| 40 | Code Complete | 9780735619678 | `books/code-complete.jpg` | 409×500 | [Open Library](https://openlibrary.org/isbn/9780735619678) · [Ảnh 15247726](https://covers.openlibrary.org/b/id/15247726-L.jpg?default=false) |
| 41 | Refactoring | 9780134757599 | `books/refactoring.jpg` | 381×500 | [Open Library](https://openlibrary.org/isbn/9780134757599) · [Ảnh 8507565](https://covers.openlibrary.org/b/id/8507565-L.jpg?default=false) |
| 42 | Domain-Driven Design | 9780321125217 | `books/domain-driven-design.jpg` | 154×210 | [Open Library](https://openlibrary.org/isbn/9780321125217) · [Ảnh 14596704](https://covers.openlibrary.org/b/id/14596704-L.jpg?default=false) |
| 43 | The C Programming Language | 9780131103627 | `books/c-programming-language.jpg` | 356×500 | [Open Library](https://openlibrary.org/isbn/9780131103627) · [Ảnh 86185](https://covers.openlibrary.org/b/id/86185-L.jpg?default=false) |
| 44 | Effective Java | 9780134685991 | `books/effective-java.jpg` | 306×400 | [Open Library](https://openlibrary.org/isbn/9780134685991) · [Ảnh 12420356](https://covers.openlibrary.org/b/id/12420356-L.jpg?default=false) |
| 45 | Python Crash Course | 9781718502703 | `books/python-crash-course.jpg` | 227×300 | [Open Library](https://openlibrary.org/isbn/9781718502703) · [Ảnh 15225531](https://covers.openlibrary.org/b/id/15225531-L.jpg?default=false) |
| 46 | Deep Learning | 9780262035613 | `books/deep-learning.jpg` | 375×499 | [Open Library](https://openlibrary.org/isbn/9780262035613) · [Ảnh 8183675](https://covers.openlibrary.org/b/id/8183675-L.jpg?default=false) |
| 47 | Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow | 9781098125974 | `books/hands-on-machine-learning.jpg` | 229×300 | [Open Library](https://openlibrary.org/isbn/9781098125974) · [Ảnh 15225435](https://covers.openlibrary.org/b/id/15225435-L.jpg?default=false) |
| 49 | Shigley's Mechanical Engineering Design | 9780073398204 | `books/shigleys-mechanical-design.jpg` | 318×400 | [Yes24](https://www.yes24.com/product/goods/17093517) · [Ảnh](https://image.yes24.com/goods/17093517/xl) |
| 50 | Manufacturing Engineering and Technology | 9780133128741 | `books/manufacturing-engineering.jpg` | 381×500 | [Open Library](https://openlibrary.org/isbn/9780133128741) · [Ảnh 10157106](https://covers.openlibrary.org/b/id/10157106-L.jpg?default=false) |
| 51 | Introduction to Algorithms | 9780262046305 | `books/introduction-to-algorithms.jpg` | 439×500 | [Open Library](https://openlibrary.org/isbn/9780262046305) · [Ảnh 13768952](https://covers.openlibrary.org/b/id/13768952-L.jpg?default=false) |
| 53 | Operating System Concepts | 9781119800361 | `books/operating-system-concepts.jpg` | 680×850 | [Trang tác giả Operating System Concepts](https://os-book.com/) · [Ảnh](https://os-book.com/images/os10c-cover.jpg) |
| 54 | Database System Concepts | 9780078022159 | `books/database-system-concepts.jpg` | 404×500 | [Open Library](https://openlibrary.org/isbn/9780078022159) · [Ảnh 10385525](https://covers.openlibrary.org/b/id/10385525-L.jpg?default=false) |
| 55 | Artificial Intelligence: A Modern Approach | 9780134610993 | `books/artificial-intelligence-modern-approach.jpg` | 394×500 | [Open Library](https://openlibrary.org/isbn/9780134610993) · [Ảnh 13530046](https://covers.openlibrary.org/b/id/13530046-L.jpg?default=false) |
| 56 | Thomas' Calculus | 9780134438986 | `books/thomas-calculus.jpg` | 390×500 | [Open Library](https://openlibrary.org/isbn/9780134438986) · [Ảnh 10282834](https://covers.openlibrary.org/b/id/10282834-L.jpg?default=false) |
| 57 | University Physics with Modern Physics | 9780135159552 | `books/university-physics.jpg` | 414×500 | [Open Library](https://openlibrary.org/isbn/9780135159552) · [Ảnh 10174229](https://covers.openlibrary.org/b/id/10174229-L.jpg?default=false) |
| 58 | Engineering Mechanics: Statics | 9780133918922 | `books/engineering-mechanics-statics.jpg` | 431×500 | [Open Library](https://openlibrary.org/isbn/9780133918922) · [Ảnh 8737517](https://covers.openlibrary.org/b/id/8737517-L.jpg?default=false) |
| 59 | Engineering Mechanics: Dynamics | 9780133915389 | `books/engineering-mechanics-dynamics.jpg` | 431×500 | [Open Library](https://openlibrary.org/isbn/9780133915389) · [Ảnh 10298857](https://covers.openlibrary.org/b/id/10298857-L.jpg?default=false) |
| 60 | Mechanics of Materials | 9780134319650 | `books/mechanics-of-materials.jpg` | 225×300 | [Open Library](https://openlibrary.org/isbn/9780134319650) · [Ảnh 15225851](https://covers.openlibrary.org/b/id/15225851-L.jpg?default=false) |
| 61 | Fluid Mechanics: Fundamentals and Applications | 9781259696534 | `books/fluid-mechanics-cengel.jpg` | 418×500 | [Open Library](https://openlibrary.org/isbn/9781259696534) · [Ảnh 8294029](https://covers.openlibrary.org/b/id/8294029-L.jpg?default=false) |
| 64 | Calculus: Early Transcendentals | 9781337613927 | `books/calculus-early-transcendentals.jpg` | 425×500 | [Open Library](https://openlibrary.org/isbn/9781337613927) · [Ảnh 10375550](https://covers.openlibrary.org/b/id/10375550-L.jpg?default=false) |
| 65 | Linear Algebra and Its Applications | 9780321982384 | `books/linear-algebra-applications.jpg` | 396×500 | [Open Library](https://openlibrary.org/isbn/9780321982384) · [Ảnh 15243302](https://covers.openlibrary.org/b/id/15243302-L.jpg?default=false) |
| 66 | Discrete Mathematics and Its Applications | 9781259676512 | `books/discrete-mathematics.jpg` | 386×500 | [Open Library](https://openlibrary.org/isbn/9781259676512) · [Ảnh 10375823](https://covers.openlibrary.org/b/id/10375823-L.jpg?default=false) |
| 67 | Sapiens: A Brief History of Humankind | 9780062316097 | `books/sapiens.jpg` | 316×499 | [Open Library](https://openlibrary.org/isbn/9780062316097) · [Ảnh 8594920](https://covers.openlibrary.org/b/id/8594920-L.jpg?default=false) |
| 68 | Guns, Germs, and Steel | 9780393354324 | `books/guns-germs-steel.jpg` | 331×500 | [Open Library](https://openlibrary.org/isbn/9780393354324) · [Ảnh 14631255](https://covers.openlibrary.org/b/id/14631255-L.jpg?default=false) |
| 69 | The Silk Roads | 9781101912379 | `books/the-silk-roads.jpg` | 331×500 | [Open Library](https://openlibrary.org/isbn/9781101912379) · [Ảnh 8848108](https://covers.openlibrary.org/b/id/8848108-L.jpg?default=false) |
| 70 | Vietnam: A New History | 9780465094363 | `books/vietnam-a-new-history.jpg` | 298×500 | [Open Library](https://openlibrary.org/isbn/9780465094363) · [Ảnh 12887264](https://covers.openlibrary.org/b/id/12887264-L.jpg?default=false) |
| 74 | Bowling Alone | 9780743203043 | `books/bowling-alone.jpg` | 303×475 | [Open Library](https://openlibrary.org/isbn/9780743203043) · [Ảnh 471286](https://covers.openlibrary.org/b/id/471286-L.jpg?default=false) |
| 75 | The Culture Map | 9781610392501 | `books/the-culture-map.jpg` | 314×500 | [Open Library](https://openlibrary.org/isbn/9781610392501) · [Ảnh 15119076](https://covers.openlibrary.org/b/id/15119076-L.jpg?default=false) |
| 76 | Orientalism | 9780394740676 | `books/orientalism.jpg` | 326×500 | [Open Library](https://openlibrary.org/isbn/9780394740676) · [Ảnh 14609385](https://covers.openlibrary.org/b/id/14609385-L.jpg?default=false) |
| 77 | Imagined Communities | 9781784786755 | `books/imagined-communities.jpg` | 333×500 | [Open Library](https://openlibrary.org/isbn/9781784786755) · [Ảnh 7999346](https://covers.openlibrary.org/b/id/7999346-L.jpg?default=false) |
| 78 | The Righteous Mind | 9780307455772 | `books/the-righteous-mind.jpg` | 324×500 | [Open Library](https://openlibrary.org/isbn/9780307455772) · [Ảnh 14630309](https://covers.openlibrary.org/b/id/14630309-L.jpg?default=false) |
| 79 | Outliers | 9780316017930 | `books/outliers.jpg` | 600×900 | [Hachette Book Group](https://www.hachettebookgroup.com/titles/malcolm-gladwell/outliers/9780316017930/) · [Ảnh](https://www.hachettebookgroup.com/wp-content/uploads/2026/02/9780316017930.jpg) |

## Chưa có ảnh xác minh

| ID | Sách | ISBN/mã đang lưu | Lý do giữ ô thay thế |
| ---: | --- | --- | --- |
| 5 | Vợ nhặt | 9786043496079 | [NXB Văn Học](https://nxbvanhoc.com.vn/vo-nhat-1) gắn ISBN này cho ấn bản của họ, nhưng dữ liệu đang ghi NXB Hội Nhà Văn; chưa chọn bìa khi thông tin ấn bản còn mâu thuẫn. |
| 7 | Nỗi buồn chiến tranh | 9781573223325 | Mã ISBN-13 sai chữ số kiểm tra; dữ liệu còn ghi NXB Trẻ 2022 nên không gắn bìa của một ấn bản khác. |
| 22 | Freakonomics | 9780060731335 | ISBN được ghi nhận cho ebook, còn seed mô tả sách in năm 2006; chưa xác nhận được bìa đúng định dạng. |
| 26 | Oxford Word Skills: Basic | 9780194620079 | Nguồn OUP cho biết ISBN này thuộc *Intermediate Student's Pack*; bản *Basic* dùng ISBN khác. |
| 30 | ETS TOEIC Official Test-Preparation Guide | 9788917230601 | Mã ISBN-13 sai chữ số kiểm tra; chưa xác nhận ấn bản. |
| 48 | Fluid Mechanics | 9781119456339 | ISBN này thuộc *Operating System Concepts, 10e EPUB Reg Card Abridged Print Companion Set*, không phải sách Frank M. White/Henry Xue. |
| 52 | Computer Networking: A Top-Down Approach | 9780136681557 | [Pearson xác nhận ISBN/bản 8](https://www.pearson.com/en-us/subject-catalog/p/computer-networking/P200000003334/9780136681557), nhưng chưa có URL ảnh trực tiếp được xác minh. |
| 62 | Fundamentals of Heat and Mass Transfer | 9781119320425 | ISBN thuộc bản EPUB thứ 8; chưa xác minh được bìa riêng cho định dạng này. |
| 63 | Materials Science and Engineering: An Introduction | 9781119405498 | ISBN thuộc bản Enhanced EPUB thứ 10; chưa xác minh được bìa riêng cho định dạng này. |
| 71 | Đại Việt sử ký toàn thư | 9786043236347 | [Thư viện TP.HCM](https://phucvu.thuvientphcm.gov.vn/Item/ItemDetail/779324) xác nhận ISBN cho quyển 1 của bộ, nhưng chưa tìm được bìa đúng quyển. |
| 72 | Lịch sử Việt Nam từ nguồn gốc đến giữa thế kỷ XX | 9786043923377 | [Thư viện TP.HCM](https://phucvu.thuvientphcm.gov.vn/Item/ItemDetail/781129) ghi NXB Thế Giới/Nhã Nam, 2023, khác NXB/năm trong seed; chưa chọn bìa. |
| 73 | Vietnam 1945: The Quest for Power | 9780674003302 | Mã ISBN-13 sai chữ số kiểm tra; chưa xác nhận ấn bản. |
| 80 | Người Việt: Phẩm chất và thói hư tật xấu | 8935077025125 | Mã đang lưu là EAN 893, chưa xác minh được ảnh đúng sản phẩm. |

## Sai khác ấn bản cần rà trong dữ liệu

- `Why Nations Fail` có ISBN 9780307719225 của bản paperback Penguin Random House phát hành năm 2013, trong khi seed ghi năm 2012. Ảnh hiện lưu theo ISBN.
- `Outliers` có ISBN 9780316017930 của bản paperback Hachette phát hành năm 2011, trong khi seed ghi năm 2008. Ảnh hiện lưu theo ISBN.
- `Academic Vocabulary in Use` dùng ảnh sạch từ trang Thalia xác nhận đúng ISBN 9781107591660 và bản thứ 2 năm 2016; ảnh Open Library ban đầu có watermark nên đã được thay.
- `Operating System Concepts` ISBN 9781119800361 được bán dưới dạng loose-leaf. Ảnh hiện lưu từ trang chính thức của nhóm tác giả, thể hiện bản 10; chưa xác minh có bìa riêng cho dạng loose-leaf.
- Một số bìa tiếng Việt là hình của lần tái bản cùng tựa; xem trang nguồn trước khi dùng cho một thư viện sở hữu bản in cụ thể. Chưa đổi ISBN, năm hay nhà xuất bản trong database.
