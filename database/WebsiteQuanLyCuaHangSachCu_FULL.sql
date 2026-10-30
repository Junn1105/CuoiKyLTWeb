-- ==============================================================================
-- CƠ SỞ DỮ LIỆU TOÀN DIỆN CHO WEBSITE QUẢN LÝ CHUỖI CỬA HÀNG SÁCH CŨ "MỘC SÁCH"
-- Database Name : WebsiteQuanLyCuaHangSachCu
-- Hệ quản trị   : Microsoft SQL Server (2019 / 2022)
-- Mô tả         : Bao gồm cấu trúc hoàn chỉnh 37 bảng nghiệp vụ, 74 khóa ngoại,
--                 70 ràng buộc CHECK, chỉ mục lọc Unique, toàn bộ dữ liệu danh mục,
--                 1.215+ dòng dữ liệu mẫu (16 tài khoản, 5 chi nhánh, 249 bản sách, 27 đơn).
-- Hướng dẫn     : Mở file trong SQL Server Management Studio (SSMS) và bấm Execute (F5).
-- ==============================================================================

USE master;
GO

IF DB_ID(N'WebsiteQuanLyCuaHangSachCu') IS NULL
BEGIN
    CREATE DATABASE [WebsiteQuanLyCuaHangSachCu];
END;
GO

USE [WebsiteQuanLyCuaHangSachCu];
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO


-- ============================================================================
-- BƯỚC 1: KHỞI TẠO 5 BẢNG DANH MỤC CƠ SỞ & DỮ LIỆU SÁCH GỐC
-- File gốc: database/000-init-base-catalog.sql
-- ============================================================================

-- 000-init-base-catalog.sql: Create database and base catalog tables (Categories, Publishers, Authors, Books, BookAuthors)
IF DB_ID(N'WebsiteQuanLyCuaHangSachCu') IS NULL CREATE DATABASE [WebsiteQuanLyCuaHangSachCu];
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL BEGIN
 CREATE TABLE dbo.Categories (CategoryId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categories PRIMARY KEY, CategoryName NVARCHAR(100) NOT NULL, Description NVARCHAR(500) NULL);
 CREATE TABLE dbo.Publishers (PublisherId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Publishers PRIMARY KEY, PublisherName NVARCHAR(150) NOT NULL, Address NVARCHAR(255) NULL, Phone VARCHAR(15) NULL);
 CREATE TABLE dbo.Authors (AuthorId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Authors PRIMARY KEY, AuthorName NVARCHAR(150) NOT NULL, Biography NVARCHAR(MAX) NULL, AuthorPhoto NVARCHAR(500) NULL, BirthYear INT NULL, DeathYear INT NULL, Nationality NVARCHAR(100) NULL, InfoSourceUrl NVARCHAR(1000) NULL);
 CREATE TABLE dbo.Books (BookId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Books PRIMARY KEY, ISBN VARCHAR(20) NULL, Title NVARCHAR(255) NOT NULL, CategoryId INT NOT NULL CONSTRAINT FK_Books_Categories FOREIGN KEY REFERENCES dbo.Categories(CategoryId), PublisherId INT NOT NULL CONSTRAINT FK_Books_Publishers FOREIGN KEY REFERENCES dbo.Publishers(PublisherId), PublishYear INT NULL, CoverImage NVARCHAR(255) NULL, Description NVARCHAR(MAX) NULL);
 CREATE TABLE dbo.BookAuthors (BookId INT NOT NULL CONSTRAINT FK_BookAuthors_Books FOREIGN KEY REFERENCES dbo.Books(BookId), AuthorId INT NOT NULL CONSTRAINT FK_BookAuthors_Authors FOREIGN KEY REFERENCES dbo.Authors(AuthorId), CONSTRAINT PK_BookAuthors PRIMARY KEY (BookId, AuthorId));
 SET IDENTITY_INSERT dbo.Categories ON;
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (1, N'Văn học Việt Nam', N'Tác phẩm văn học tiêu biểu của các tác giả Việt Nam.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (2, N'Văn học nước ngoài', N'Tác phẩm văn học kinh điển và hiện đại được biết đến rộng rãi trên thế giới.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (3, N'Kinh tế - Chính trị', N'Kinh tế học, kinh doanh, phát triển và khoa học chính trị.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (4, N'Ngoại ngữ - Tiếng Anh', N'Giáo trình và tài liệu học tiếng Anh, IELTS, TOEIC.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (5, N'Ngoại ngữ - Tiếng Nhật', N'Giáo trình tiếng Nhật, ngữ pháp và chữ Kanji.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (6, N'Sách tham khảo', N'Tài liệu chuyên ngành CNTT và kỹ thuật dùng để tra cứu, tự học.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (7, N'Giáo trình', N'Giáo trình đại học cho CNTT, Khoa học & Kỹ thuật và Cơ khí.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (8, N'Lịch sử', N'Lịch sử Việt Nam và lịch sử thế giới.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (9, N'Văn hóa - Xã hội', N'Văn hóa học, xã hội học và nghiên cứu con người.');
 INSERT INTO dbo.Categories(CategoryId, CategoryName, Description) VALUES (1002, N'Sách test', N'Tài liệu giả lập dùng để kiểm thử giao diện, không phải sách phát hành thật.');
 SET IDENTITY_INSERT dbo.Categories OFF;
 SET IDENTITY_INSERT dbo.Publishers ON;
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (1, N'NXB Văn Học', N'Hà Nội, Việt Nam', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (2, N'NXB Kim Đồng', N'Hà Nội, Việt Nam', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (3, N'NXB Hội Nhà Văn', N'Hà Nội, Việt Nam', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (4, N'NXB Trẻ', N'TP. Hồ Chí Minh, Việt Nam', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (5, N'NXB Chính trị quốc gia Sự thật', N'Hà Nội, Việt Nam', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (6, N'Penguin Classics', N'London, United Kingdom', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (7, N'Penguin Books', N'London, United Kingdom', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (8, N'Vintage', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (9, N'Scribner', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (10, N'Harper Perennial Modern Classics', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (11, N'HarperOne', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (12, N'Mariner Books', N'Boston, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (13, N'Basic Books', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (14, N'PublicAffairs', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (15, N'Harvard University Press', N'Cambridge, Massachusetts, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (16, N'Farrar, Straus and Giroux', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (17, N'Cambridge University Press', N'Cambridge, United Kingdom', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (18, N'Oxford University Press', N'Oxford, United Kingdom', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (19, N'ETS', N'Princeton, New Jersey, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (20, N'3A Corporation', N'Tokyo, Japan', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (21, N'The Japan Times Publishing', N'Tokyo, Japan', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (22, N'Bonjinsha', N'Tokyo, Japan', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (23, N'Learn From Zero', N'Las Vegas, Nevada, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (24, N'Prentice Hall', N'Hoboken, New Jersey, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (25, N'Addison-Wesley Professional', N'Boston, Massachusetts, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (26, N'MIT Press', N'Cambridge, Massachusetts, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (27, N'Wiley', N'Hoboken, New Jersey, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (28, N'McGraw-Hill Education', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (29, N'O''Reilly Media', N'Sebastopol, California, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (30, N'Cengage Learning', N'Boston, Massachusetts, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (31, N'Pearson', N'Hoboken, New Jersey, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (32, N'W. W. Norton & Company', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (33, N'Random House', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (34, N'Bloomsbury', N'London, United Kingdom', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (35, N'University of California Press', N'Oakland, California, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (36, N'Knopf', N'New York, United States', NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (37, N'Little, Brown and Company', NULL, NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (38, N'No Starch Press', NULL, NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (39, N'Verso', NULL, NULL);
 INSERT INTO dbo.Publishers(PublisherId, PublisherName, Address, Phone) VALUES (1002, N'Nhà xuất bản minh họa (dữ liệu mẫu)', NULL, NULL);
 SET IDENTITY_INSERT dbo.Publishers OFF;
 SET IDENTITY_INSERT dbo.Authors ON;
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (1, N'Henry Xue', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (2, N'Yukari Takenaka', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (3, N'S. Sudarshan', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (4, N'Joel R. Hass', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (5, N'Kyoko Tokashiki', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (6, N'Antoine de Saint-Exupéry', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (7, N'Yuval Noah Harari', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (8, N'Michael McCarthy', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (9, N'Stephen J. Dubner', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (10, N'Maurice D. Weir', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (11, N'Hiroko Takenaka', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (12, N'Adam Smith', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (13, N'Abraham Silberschatz', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (14, N'Vanessa Jakeman', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (15, N'Aaron Courville', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (16, N'Frank M. White', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (17, N'Ngô Sĩ Liên và các sử thần triều Lê', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (18, N'Jonathan Haidt', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (19, N'George Orwell', N'George Orwell (1903–1950) là bút danh của Eric Arthur Blair, nhà văn và nhà báo Anh. Ông viết cả tiểu thuyết, tiểu luận và các tác phẩm ghi lại trải nghiệm về chiến tranh, nghèo đói và xã hội. Hai tiểu thuyết nổi tiếng của ông là Animal Farm và Nineteen Eighty-Four (1984).', N'/images/authors/george-orwell.jpg', 1903, 1950, N'Anh', N'https://www.orwellfoundation.com/the-orwell-foundation/about/about-george-orwell/');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (20, N'Michael Swan', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (21, N'Yoshua Bengio', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (22, N'Raymond Murphy', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (23, N'George Trombley', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (24, N'Christopher Heil', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (25, N'F. Scott Fitzgerald', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (26, N'Esther Duflo', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (27, N'Peter Frankopan', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (28, N'Stuart Redman', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (29, N'Pauline Cullen', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (30, N'Gabriel García Márquez', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (31, N'Serope Kalpakjian', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (32, N'Benedict Anderson', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (33, N'John M. Cimbala', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (34, N'Martin Fowler', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (35, N'Theodore L. Bergman', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (36, N'Clifford Stein', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (37, N'Dennis M. Ritchie', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (38, N'Felicity O''Dell', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (39, N'Ronald L. Rivest', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (40, N'Nguyễn Du', N'Nguyễn Du (1765–1820), tên chữ Tố Như, hiệu Thanh Hiên, là nhà thơ Việt Nam sinh tại Thăng Long. Di sản của ông gồm thơ chữ Hán và các tác phẩm chữ Nôm, trong đó Truyện Kiều là tác phẩm nổi tiếng nhất. Ông từng đi sứ sang Trung Quốc và để lại tập thơ Bắc hành tạp lục.', NULL, 1765, 1820, N'Việt Nam', N'https://audioguide.nguyendu.com.vn/en/audioguide/12.html');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (41, N'Fyodor Dostoevsky', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (42, N'Thomas Piketty', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (43, N'Malcolm Gladwell', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (44, N'Bảo Ninh', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (45, N'Lê Thành Khôi', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (46, N'Adrienne S. Lavine', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (47, N'Aurélien Géron', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (48, N'Steven R. Schmid', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (49, N'Peter B. Galvin', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (50, N'Karl Marx', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (51, N'Ralph Johnson', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (52, N'Eri Banno', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (53, N'Robert C. Martin', N'Robert C. Martin, thường được gọi là Uncle Bob, là lập trình viên, tác giả và giảng viên về phát triển phần mềm. Ông tham gia cuộc họp năm 2001 dẫn tới Tuyên ngôn Agile và từng là chủ tịch đầu tiên của Agile Alliance. Các sách của ông gồm Clean Code, The Clean Coder và Clean Architecture, tập trung vào chất lượng mã nguồn và nghề lập trình.', NULL, NULL, NULL, NULL, N'https://www.cleancoder.com/files/about.md');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (54, N'Eriko Ishii', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (55, N'Educational Testing Service', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (56, N'Harper Lee', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (57, N'3A Corporation', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (58, N'Ngô Tất Tố', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (59, N'Yunus A. Çengel', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (60, N'Andrew Hunt', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (61, N'Joshua Bloch', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (62, N'Stuart Russell', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (63, N'Abhijit V. Banerjee', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (64, N'Eric Evans', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (65, N'Eric Matthes', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (66, N'James F. Kurose', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (67, N'Vũ Trọng Phụng', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (68, N'David Thomas', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (69, N'Nhiều tác giả', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (70, N'Chikako Shinagawa', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (71, N'Yuri Shimizu', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (72, N'Richard G. Budynas', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (73, N'Steven R. Lay', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (74, N'Edward W. Said', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (75, N'Roger A. Freedman', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (76, N'J. Keith Nisbett', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (77, N'Keith W. Ross', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (78, N'David G. Marr', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (79, N'Christopher Goscha', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (80, N'Ruth Gairns', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (81, N'Daron Acemoglu', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (82, N'Erich Gamma', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (83, N'Yoko Ikeda', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (84, N'Nguyễn Ngọc Tư', N'Nguyễn Ngọc Tư sinh năm 1976 tại Đầm Dơi, Cà Mau, là nhà văn Việt Nam với giọng văn gắn bó với đời sống và con người Nam Bộ. Ngọn đèn không tắt đạt giải Nhất cuộc vận động sáng tác Văn học tuổi 20 năm 2000. Tập truyện Cánh đồng bất tận nhận Giải thưởng Hội Nhà văn Việt Nam năm 2006 và giải LiBeraturpreis năm 2018.', N'/images/authors/nguyen-ngoc-tu.jpg', 1976, NULL, N'Việt Nam', N'https://www.nxbtre.com.vn/en/authors/nguyen-ngoc-tu-3524.html');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (85, N'Yutaka Ohno', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (86, N'Greg Gagne', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (87, N'Frank P. Incropera', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (88, N'William D. Callister Jr.', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (89, N'Steven D. Levitt', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (90, N'Ian Goodfellow', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (91, N'Robert D. Putnam', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (92, N'Peter Norvig', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (93, N'Tô Hoài', N'Tô Hoài (1920–2014), tên thật Nguyễn Sen, là nhà văn Việt Nam sinh tại Nghĩa Đô, Hà Nội. Ông sáng tác ở nhiều thể loại, từ truyện thiếu nhi, truyện ngắn đến tiểu thuyết và hồi ký; Dế Mèn phiêu lưu ký là một tác phẩm tiêu biểu. Ông được trao Giải thưởng Hồ Chí Minh về Văn học – Nghệ thuật năm 1996.', N'/images/authors/to-hoai.jpg', 1920, 2014, N'Việt Nam', N'https://nxbkimdong.com.vn/nhung-ngay-dau');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (94, N'Francis Fukuyama', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (95, N'Thomas H. Cormen', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (96, N'Henry F. Korth', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (97, N'John Maynard Keynes', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (98, N'James Stewart', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (99, N'Jane Austen', N'Jane Austen (1775–1817) là nhà văn Anh lớn lên tại Steventon, Hampshire. Trong những năm sống tại Chawton, bà chỉnh sửa các bản thảo cũ và viết thêm tiểu thuyết; Pride and Prejudice được xuất bản năm 1813. Bà qua đời tại Winchester và được an táng ở nhà thờ chính tòa của thành phố.', N'/images/authors/jane-austen.jpg', 1775, 1817, N'Anh', N'https://janeaustens.house/jane-austen/jane-austen-a-life/');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (100, N'Haruki Murakami', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (101, N'Nam Cao', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (102, N'Charles E. Leiserson', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (103, N'Brian W. Kernighan', N'Brian W. Kernighan là nhà khoa học máy tính người Canada và giảng viên tại Đại học Princeton. Ông làm việc tại Bell Laboratories khoảng 30 năm trước khi trở lại Princeton năm 2000. Ông cùng Dennis Ritchie viết The C Programming Language, cuốn sách trình bày các nền tảng của ngôn ngữ lập trình C bằng những ví dụ thực tế.', N'/images/authors/brian-kernighan.jpg', NULL, NULL, N'Canada', N'https://www.cs.princeton.edu/news/computer-languages-clarity-key');
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (104, N'Kim Lân', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (105, N'George B. Thomas', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (106, N'Erin Meyer', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (107, N'Jared Diamond', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (108, N'Hugh D. Young', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (109, N'Kenneth H. Rosen', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (110, N'James A. Robinson', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (111, N'David C. Lay', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (112, N'David G. Rethwisch', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (113, N'John Vlissides', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (114, N'Russell C. Hibbeler', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (115, N'Judi J. McDonald', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (116, N'Chieko Kano', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (117, N'Amanda French', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (118, N'David P. DeWitt', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (119, N'Richard Helm', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (120, N'Steve McConnell', NULL, NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (1002, N'Tác giả minh họa (dữ liệu mẫu)', N'Hồ sơ giả lập dùng để kiểm thử giao diện. Không đại diện cho tác giả có thật.', NULL, NULL, NULL, NULL, NULL);
 INSERT INTO dbo.Authors(AuthorId, AuthorName, Biography, AuthorPhoto, BirthYear, DeathYear, Nationality, InfoSourceUrl) VALUES (1003, N'sang', NULL, NULL, NULL, NULL, NULL, NULL);
 SET IDENTITY_INSERT dbo.Authors OFF;
 SET IDENTITY_INSERT dbo.Books ON;
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (1, N'9786043948479', N'Truyện Kiều', 1, 1, 2020, N'/images/books/truyen-kieu.jpg', N'Kiệt tác thơ Nôm kể về cuộc đời và số phận của Thúy Kiều.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (2, N'9786049889721', N'Số đỏ', 1, 1, 2021, N'/images/books/so-do.jpg', N'Tiểu thuyết trào phúng nổi tiếng về xã hội Việt Nam đầu thế kỷ XX.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (3, N'9786043942156', N'Chí Phèo', 1, 1, 2022, N'/images/books/chi-pheo.jpg', N'Tác phẩm hiện thực về bi kịch tha hóa và khát vọng làm người.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (4, N'9786049766749', N'Tắt đèn', 1, 1, 2021, N'/images/books/tat-den.jpg', N'Tiểu thuyết hiện thực phê phán về đời sống nông dân trước Cách mạng.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (5, N'9786043496079', N'Vợ nhặt', 1, 3, 2022, N'/images/books/vo-nhat.jpg', N'Truyện ngắn tiêu biểu viết về nạn đói năm 1945 và tình người.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (6, N'9786042189590', N'Dế Mèn phiêu lưu ký', 1, 2, 2023, N'/images/books/de-men-phieu-luu-ky.jpg', N'Dế Mèn phiêu lưu ký kể về hành trình trưởng thành của một chú dế trẻ tuổi, khỏe mạnh nhưng từng kiêu căng và bồng bột. Sau biến cố khiến Dế Choắt qua đời, Dế Mèn bắt đầu chuỗi phiêu lưu qua nhiều miền đất, gặp gỡ những người bạn mới và học cách sống có trách nhiệm, giàu lòng nhân ái. Tác phẩm của Tô Hoài hấp dẫn bởi thế giới loài vật sinh động, ngôn ngữ trong sáng và những bài học nhẹ nhàng về tình bạn, lòng dũng cảm.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (7, N'9781573223325', N'Nỗi buồn chiến tranh', 1, 4, 2022, N'/images/books/noi-buon-chien-tranh.jpg', N'Tiểu thuyết về ký ức, mất mát và hậu chấn thương chiến tranh.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (8, N'9786041266001', N'Cánh đồng bất tận', 1, 4, 2022, N'/images/books/canh-dong-bat-tan.jpg', N'Tập truyện về con người và miền sông nước Nam Bộ.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (9, N'9780141439518', N'Pride and Prejudice', 2, 6, 2003, N'/images/books/pride-and-prejudice.jpg', N'Classic novel of manners, family, love and social expectations.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (10, N'9780451524935', N'1984', 2, 7, 1950, N'/images/books/1984.jpg', N'Dystopian novel about surveillance, propaganda and totalitarian power.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (11, N'9780743273565', N'The Great Gatsby', 2, 9, 2004, N'/images/books/the-great-gatsby.jpg', N'Novel about ambition, class and the American Dream in the Jazz Age.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (12, N'9780061120084', N'To Kill a Mockingbird', 2, 10, 2006, N'/images/books/to-kill-a-mockingbird.jpg', N'Novel exploring justice, prejudice and moral courage.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (13, N'9780375704024', N'Norwegian Wood', 2, 8, 2000, N'/images/books/norwegian-wood.jpg', N'Coming-of-age novel about memory, love and loss.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (14, N'9780060883287', N'One Hundred Years of Solitude', 2, 10, 2006, N'/images/books/one-hundred-years-of-solitude.jpg', N'Magical-realist chronicle of the Buendía family and Macondo.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (15, N'9780156012195', N'The Little Prince', 2, 12, 2000, N'/images/books/the-little-prince.jpg', N'Philosophical tale about friendship, love and seeing with the heart.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (16, N'9780140449136', N'Crime and Punishment', 2, 6, 2003, N'/images/books/crime-and-punishment.jpg', N'Psychological novel about guilt, morality and redemption.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (17, N'9780140432084', N'The Wealth of Nations', 3, 6, 1999, N'/images/books/wealth-of-nations.jpg', N'Foundational work on markets, specialization and political economy.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (18, N'9780140445688', N'Capital: Volume I', 3, 6, 1990, N'/images/books/capital-volume-one.jpg', N'Classic critique of capitalist production and political economy.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (19, N'9780230004764', N'The General Theory of Employment, Interest and Money', 3, 15, 2018, N'/images/books/general-theory.jpg', N'Major work explaining aggregate demand, employment and macroeconomics.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (20, N'9780307719225', N'Why Nations Fail', 3, 33, 2012, N'/images/books/why-nations-fail.jpg', N'Analysis of how political and economic institutions shape prosperity.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (21, N'9780674979857', N'Capital in the Twenty-First Century', 3, 15, 2017, N'/images/books/capital-21st-century.jpg', N'Study of wealth, income and long-run inequality.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (22, N'9780060731335', N'Freakonomics', 3, 10, 2006, N'/images/books/freakonomics.jpg', N'Uses economic reasoning to investigate incentives in everyday life.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (23, N'9781610390934', N'Poor Economics', 3, 14, 2012, N'/images/books/poor-economics.jpg', N'Evidence-based study of poverty and development interventions.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (24, N'9780374535629', N'Political Order and Political Decay', 3, 16, 2015, N'/images/books/political-order-decay.jpg', N'Study of institutions, state development and political accountability.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (25, N'9781108457651', N'English Grammar in Use', 4, 17, 2019, N'/images/books/english-grammar-in-use.jpg', N'Self-study reference and practice book for intermediate English grammar.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (26, N'9780194620079', N'Oxford Word Skills: Basic', 4, 18, 2020, N'/images/books/oxford-word-skills-basic.jpg', N'Vocabulary course for basic-level English learners.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (27, N'9781107620698', N'The Official Cambridge Guide to IELTS', 4, 17, 2014, N'/images/books/official-cambridge-ielts.jpg', N'Official preparation guide covering all four IELTS skills.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (28, N'9780194202435', N'Practical English Usage', 4, 18, 2016, N'/images/books/practical-english-usage.jpg', N'Reference guide to common English grammar and usage questions.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (29, N'9781107591660', N'Academic Vocabulary in Use', 4, 17, 2016, N'/images/books/academic-vocabulary-in-use.jpg', N'Vocabulary practice for academic reading, writing and study.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (30, N'9788917230601', N'ETS TOEIC Official Test-Preparation Guide', 4, 19, 2019, N'/images/books/ets-toeic-guide.jpg', N'Official TOEIC listening and reading preparation material.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (31, N'9784883196036', N'Minna no Nihongo Shokyu I, 2nd Edition', 5, 20, 2012, N'/images/books/minna-no-nihongo-1.jpg', N'Giáo trình tiếng Nhật sơ cấp tập I được sử dụng rộng rãi.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (32, N'9784883196463', N'Minna no Nihongo Shokyu II, 2nd Edition', 5, 20, 2013, N'/images/books/minna-no-nihongo-2.jpg', N'Giáo trình tiếng Nhật sơ cấp tập II tiếp nối trình độ nền tảng.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (33, N'9784789017305', N'GENKI I: An Integrated Course in Elementary Japanese', 5, 21, 2020, N'/images/books/genki-1.jpg', N'Integrated beginner course in Japanese language and communication.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (34, N'9784789017329', N'GENKI II: An Integrated Course in Elementary Japanese', 5, 21, 2020, N'/images/books/genki-2.jpg', N'Second volume of the integrated elementary Japanese course.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (35, N'9784893580917', N'Basic Kanji Book, Volume 1', 5, 22, 1990, N'/images/books/basic-kanji-book-1.jpg', N'Introduction and practice for foundational Japanese kanji.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (36, N'9780976998129', N'Japanese From Zero! 1', 5, 23, 2015, N'/images/books/japanese-from-zero-1.jpg', N'Progressive beginner course with grammar, vocabulary and writing.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (37, N'9780132350884', N'Clean Code', 6, 24, 2008, N'/images/books/clean-code.jpg', N'Principles and practices for writing readable, maintainable software.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (38, N'9780135957059', N'The Pragmatic Programmer', 6, 25, 2019, N'/images/books/pragmatic-programmer.jpg', N'Practical approaches to software craftsmanship and professional development.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (39, N'9780201633610', N'Design Patterns', 6, 25, 1994, N'/images/books/design-patterns.jpg', N'Catalog of reusable object-oriented software design patterns.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (40, N'9780735619678', N'Code Complete', 6, 25, 2004, N'/images/books/code-complete.jpg', N'Comprehensive guide to practical software construction.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (41, N'9780134757599', N'Refactoring', 6, 25, 2018, N'/images/books/refactoring.jpg', N'Techniques for improving existing code without changing behavior.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (42, N'9780321125217', N'Domain-Driven Design', 6, 25, 2003, N'/images/books/domain-driven-design.jpg', N'Patterns for connecting complex domain models with software design.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (43, N'9780131103627', N'The C Programming Language', 6, 24, 1988, N'/images/books/c-programming-language.jpg', N'Classic concise reference to the C programming language.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (44, N'9780134685991', N'Effective Java', 6, 25, 2018, N'/images/books/effective-java.jpg', N'Best practices and idioms for robust Java programs.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (45, N'9781718502703', N'Python Crash Course', 6, 38, 2023, N'/images/books/python-crash-course.jpg', N'Hands-on introduction to Python programming and projects.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (46, N'9780262035613', N'Deep Learning', 6, 26, 2016, N'/images/books/deep-learning.jpg', N'Foundational reference covering modern deep learning methods.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (47, N'9781098125974', N'Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow', 6, 29, 2022, N'/images/books/hands-on-machine-learning.jpg', N'Practical machine-learning guide using popular Python frameworks.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (48, N'9781119456339', N'Fluid Mechanics', 6, 27, 2021, N'/images/books/fluid-mechanics-white.jpg', N'Engineering reference on fluid statics, dynamics and applications.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (49, N'9780073398204', N'Shigley''s Mechanical Engineering Design', 6, 28, 2014, N'/images/books/shigleys-mechanical-design.jpg', N'Reference for analysis and design of mechanical components.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (50, N'9780133128741', N'Manufacturing Engineering and Technology', 6, 31, 2013, N'/images/books/manufacturing-engineering.jpg', N'Reference on manufacturing processes, materials and production systems.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (51, N'9780262046305', N'Introduction to Algorithms', 7, 26, 2022, N'/images/books/introduction-to-algorithms.jpg', N'Giáo trình thuật toán và cấu trúc dữ liệu dùng rộng rãi trong ngành CNTT.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (52, N'9780136681557', N'Computer Networking: A Top-Down Approach', 7, 31, 2021, N'/images/books/computer-networking-top-down.jpg', N'Giáo trình mạng máy tính theo cách tiếp cận từ tầng ứng dụng.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (53, N'9781119800361', N'Operating System Concepts', 7, 27, 2021, N'/images/books/operating-system-concepts.jpg', N'Giáo trình hệ điều hành, tiến trình, bộ nhớ, lưu trữ và bảo mật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (54, N'9780078022159', N'Database System Concepts', 7, 28, 2019, N'/images/books/database-system-concepts.jpg', N'Giáo trình cơ sở dữ liệu quan hệ, giao dịch và thiết kế hệ thống.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (55, N'9780134610993', N'Artificial Intelligence: A Modern Approach', 7, 31, 2020, N'/images/books/artificial-intelligence-modern-approach.jpg', N'Giáo trình nền tảng trình bày toàn diện các nguyên lý và kỹ thuật của trí tuệ nhân tạo hiện đại. Sách bao quát tác tử thông minh, tìm kiếm, suy luận, biểu diễn tri thức, học máy, xử lý ngôn ngữ tự nhiên, thị giác máy tính và robot. Nội dung kết hợp nền tảng lý thuyết với ví dụ thực tế, phù hợp cho sinh viên, giảng viên và người muốn nghiên cứu chuyên sâu về AI.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (56, N'9780134438986', N'Thomas'' Calculus', 7, 31, 2018, N'/images/books/thomas-calculus.jpg', N'Giáo trình giải tích cho các ngành khoa học và kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (57, N'9780135159552', N'University Physics with Modern Physics', 7, 31, 2019, N'/images/books/university-physics.jpg', N'Giáo trình vật lý đại cương và vật lý hiện đại cho sinh viên kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (58, N'9780133918922', N'Engineering Mechanics: Statics', 7, 31, 2015, N'/images/books/engineering-mechanics-statics.jpg', N'Giáo trình cơ học kỹ thuật phần tĩnh học.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (59, N'9780133915389', N'Engineering Mechanics: Dynamics', 7, 31, 2015, N'/images/books/engineering-mechanics-dynamics.jpg', N'Giáo trình cơ học kỹ thuật phần động lực học.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (60, N'9780134319650', N'Mechanics of Materials', 7, 31, 2017, N'/images/books/mechanics-of-materials.jpg', N'Giáo trình sức bền vật liệu và phân tích ứng suất, biến dạng.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (61, N'9781259696534', N'Fluid Mechanics: Fundamentals and Applications', 7, 28, 2017, N'/images/books/fluid-mechanics-cengel.jpg', N'Giáo trình cơ học lưu chất cho khối ngành kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (62, N'9781119320425', N'Fundamentals of Heat and Mass Transfer', 7, 27, 2017, N'/images/books/heat-mass-transfer.jpg', N'Giáo trình truyền nhiệt và truyền khối trong kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (63, N'9781119405498', N'Materials Science and Engineering: An Introduction', 7, 27, 2018, N'/images/books/materials-science-engineering.jpg', N'Giáo trình vật liệu học và kỹ thuật vật liệu.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (64, N'9781337613927', N'Calculus: Early Transcendentals', 7, 30, 2016, N'/images/books/calculus-early-transcendentals.jpg', N'Giáo trình giải tích cơ bản cho khoa học, công nghệ và kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (65, N'9780321982384', N'Linear Algebra and Its Applications', 7, 31, 2015, N'/images/books/linear-algebra-applications.jpg', N'Giáo trình đại số tuyến tính gắn với các bài toán ứng dụng.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (66, N'9781259676512', N'Discrete Mathematics and Its Applications', 7, 28, 2018, N'/images/books/discrete-mathematics.jpg', N'Giáo trình toán rời rạc cho khoa học máy tính và kỹ thuật.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (67, N'9780062316097', N'Sapiens: A Brief History of Humankind', 8, 11, 2015, N'/images/books/sapiens.jpg', N'Survey of human history from early Homo sapiens to modern society.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (68, N'9780393354324', N'Guns, Germs, and Steel', 8, 32, 2017, N'/images/books/guns-germs-steel.jpg', N'Analysis of geography, environment and unequal societal development.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (69, N'9781101912379', N'The Silk Roads', 8, 8, 2017, N'/images/books/the-silk-roads.jpg', N'Global history centered on the networks connecting East and West.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (70, N'9780465094363', N'Vietnam: A New History', 8, 13, 2016, N'/images/books/vietnam-a-new-history.jpg', N'Broad modern history of Vietnam in regional and global context.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (71, N'9786043236347', N'Đại Việt sử ký toàn thư', 8, 1, 2021, N'/images/books/dai-viet-su-ky-toan-thu.jpg', N'Bộ quốc sử quan trọng ghi chép lịch sử Việt Nam thời quân chủ.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (72, N'9786043923377', N'Lịch sử Việt Nam từ nguồn gốc đến giữa thế kỷ XX', 8, 5, 2020, N'/images/books/lich-su-viet-nam-le-thanh-khoi.jpg', N'Công trình khái quát tiến trình lịch sử Việt Nam đến giữa thế kỷ XX.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (73, N'9780674003302', N'Vietnam 1945: The Quest for Power', 8, 35, 1997, N'/images/books/vietnam-1945.jpg', N'Study of Vietnam and the struggle for power in the pivotal year 1945.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (74, N'9780743203043', N'Bowling Alone', 9, 9, 2001, N'/images/books/bowling-alone.jpg', N'Study of social capital and changing civic participation in America.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (75, N'9781610392501', N'The Culture Map', 9, 14, 2014, N'/images/books/the-culture-map.jpg', N'Framework for understanding communication across national cultures.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (76, N'9780394740676', N'Orientalism', 9, 8, 1979, N'/images/books/orientalism.jpg', N'Influential critique of Western representations of the East.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (77, N'9781784786755', N'Imagined Communities', 9, 39, 2016, N'/images/books/imagined-communities.jpg', N'Study of nationalism and the cultural construction of political communities.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (78, N'9780307455772', N'The Righteous Mind', 9, 8, 2013, N'/images/books/the-righteous-mind.jpg', N'Exploration of moral psychology, politics and social division.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (79, N'9780316017930', N'Outliers', 9, 37, 2008, N'/images/books/outliers.jpg', N'Popular analysis of opportunity, culture and exceptional achievement.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (80, N'8935077025125', N'Người Việt: Phẩm chất và thói hư tật xấu', 9, 1, 2019, N'/images/books/nguoi-viet-pham-chat-thoi-hu.jpg', N'Tuyển tập góc nhìn về đặc điểm văn hóa và tính cách người Việt.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (1002, NULL, N'[DỮ LIỆU MẪU] Sách tạm hết', 1002, 1002, 2026, NULL, N'Đây là dữ liệu mẫu, không phải ấn bản thật. Cuốn sách này chỉ dùng để kiểm tra nhãn màu đỏ khi không còn sách và nút mượn bị vô hiệu hóa.');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (1003, N'978532123232', N'dsa', 1, 19, 2026, NULL, N'test');
 INSERT INTO dbo.Books(BookId, ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description) VALUES (1004, N'9786042345765', N'Sách test', 7, 1002, 2021, NULL, N'hello');
 SET IDENTITY_INSERT dbo.Books OFF;
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1, 40);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (2, 67);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (3, 101);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (4, 58);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (5, 104);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (6, 93);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (7, 44);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (8, 84);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (9, 99);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (10, 19);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (11, 25);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (12, 56);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (13, 100);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (14, 30);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (15, 6);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (16, 41);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (17, 12);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (18, 50);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (19, 97);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (20, 81);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (20, 110);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (21, 42);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (22, 9);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (22, 89);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (23, 26);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (23, 63);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (24, 94);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (25, 22);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (26, 28);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (26, 80);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (27, 14);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (27, 29);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (27, 117);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (28, 20);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (29, 8);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (29, 38);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (30, 55);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (31, 57);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (32, 57);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (33, 5);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (33, 52);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (33, 70);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (33, 83);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (33, 85);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (34, 5);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (34, 52);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (34, 70);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (34, 83);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (34, 85);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (35, 11);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (35, 54);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (35, 71);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (35, 116);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (36, 2);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (36, 23);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (37, 53);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (38, 60);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (38, 68);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (39, 51);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (39, 82);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (39, 113);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (39, 119);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (40, 120);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (41, 34);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (42, 64);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (43, 37);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (43, 103);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (44, 61);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (45, 65);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (46, 15);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (46, 21);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (46, 90);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (47, 47);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (48, 1);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (48, 16);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (49, 72);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (49, 76);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (50, 31);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (50, 48);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (51, 36);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (51, 39);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (51, 95);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (51, 102);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (52, 66);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (52, 77);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (53, 13);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (53, 49);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (53, 86);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (54, 3);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (54, 13);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (54, 96);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (55, 62);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (55, 92);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (56, 4);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (56, 10);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (56, 24);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (56, 105);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (57, 75);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (57, 108);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (58, 114);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (59, 114);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (60, 114);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (61, 33);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (61, 59);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (62, 35);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (62, 46);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (62, 87);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (62, 118);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (63, 88);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (63, 112);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (64, 98);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (65, 73);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (65, 111);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (65, 115);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (66, 109);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (67, 7);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (68, 107);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (69, 27);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (70, 79);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (71, 17);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (72, 45);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (73, 78);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (74, 91);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (75, 106);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (76, 74);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (77, 32);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (78, 18);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (79, 43);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (80, 69);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1002, 1002);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1003, 1);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1003, 1003);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1004, 2);
 INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES (1004, 3);
END;
GO
GO


-- ============================================================================
-- BƯỚC 2: KHỞI TẠO 30 BẢNG NGHIỆP VỤ LÕI (CHI NHÁNH, KHO, ĐƠN HÀNG, GIỮ CHỖ)
-- File gốc: database/002-create-core-tables.sql
-- ============================================================================

-- SQL Server. Run once using sqlcmd -b -f 65001 against the named database.
-- No existing catalog data is changed. Any failure rolls back all 30 tables.
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
BEGIN TRANSACTION;
DECLARE @lockResult int;
EXEC @lockResult = sys.sp_getapplock @Resource=N'WebsiteQuanLyCuaHangSachCu:002',
    @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=10000;
IF @lockResult < 0 THROW 51000, 'Cannot acquire migration lock.', 1;

IF OBJECT_ID(N'dbo.Books', N'U') IS NULL OR OBJECT_ID(N'dbo.Authors', N'U') IS NULL
 OR OBJECT_ID(N'dbo.Categories', N'U') IS NULL OR OBJECT_ID(N'dbo.Publishers', N'U') IS NULL
 OR OBJECT_ID(N'dbo.BookAuthors', N'U') IS NULL
 THROW 51001, 'The five catalog tables must exist before this migration.', 1;

DECLARE @expected TABLE (TableName sysname PRIMARY KEY);
INSERT @expected VALUES
 ('Users'),('Roles'),('UserRoles'),('StaffStoreAssignments'),('CustomerAddresses'),
 ('Stores'),('BookConditions'),('BookCopies'),('MediaAssets'),('Suppliers'),
 ('PurchaseReceipts'),('PurchaseReceiptItems'),('InventoryMovements'),('StockTransfers'),
 ('StockTransferItems'),('Stocktakes'),('StocktakeItems'),('Carts'),('CartItems'),
 ('Orders'),('OrderItems'),('StockReservations'),('Payments'),('OrderStatusHistory'),
 ('SalesReturns'),('SalesReturnItems'),('Refunds'),('RefreshTokens'),('Notifications'),('AuditLogs');
IF EXISTS (SELECT 1 FROM @expected WHERE OBJECT_ID(N'dbo.' + QUOTENAME(TableName)) IS NOT NULL)
 THROW 51002, 'A target object already exists. Migration is one-shot; inspect schema instead of rerunning.', 1;

CREATE TABLE dbo.Users (
 UserId int IDENTITY(1,1) CONSTRAINT PK_Users PRIMARY KEY,
 Username nvarchar(50) COLLATE Latin1_General_100_CI_AS NOT NULL,
 Email nvarchar(254) COLLATE Latin1_General_100_CI_AS NOT NULL,
 PasswordHash varchar(255) NOT NULL,
 FullName nvarchar(150) NOT NULL,
 Phone varchar(20) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Users_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Users_Username UNIQUE(Username),
 CONSTRAINT UQ_Users_Email UNIQUE(Email),
 CONSTRAINT CK_Users_Status CHECK(Status IN ('ACTIVE','LOCKED','PENDING')),
 CONSTRAINT CK_Users_Required CHECK(LEN(LTRIM(RTRIM(Username))) > 0 AND LEN(LTRIM(RTRIM(Email))) > 0
  AND LEN(LTRIM(RTRIM(FullName))) > 0 AND LEN(PasswordHash) > 0),
 CONSTRAINT CK_Users_Timestamps CHECK(UpdatedAt >= CreatedAt)
);
CREATE TABLE dbo.Roles (
 RoleId int IDENTITY(1,1) CONSTRAINT PK_Roles PRIMARY KEY,
 RoleCode varchar(30) NOT NULL CONSTRAINT UQ_Roles_Code UNIQUE,
 RoleName nvarchar(100) NOT NULL,
 CONSTRAINT CK_Roles_Code CHECK(LEN(LTRIM(RTRIM(RoleCode))) > 0)
);
CREATE TABLE dbo.UserRoles (
 UserId int NOT NULL CONSTRAINT FK_UserRoles_Users REFERENCES dbo.Users(UserId),
 RoleId int NOT NULL CONSTRAINT FK_UserRoles_Roles REFERENCES dbo.Roles(RoleId),
 AssignedAt datetime2(3) NOT NULL CONSTRAINT DF_UserRoles_AssignedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT PK_UserRoles PRIMARY KEY(UserId,RoleId)
);
CREATE TABLE dbo.Stores (
 StoreId int IDENTITY(1,1) CONSTRAINT PK_Stores PRIMARY KEY,
 StoreCode varchar(30) NOT NULL CONSTRAINT UQ_Stores_Code UNIQUE,
 StoreName nvarchar(150) NOT NULL,
 Address nvarchar(500) NOT NULL,
 Phone varchar(20) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Stores_Status DEFAULT ('ACTIVE'),
 OpenedAt date NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stores_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stores_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Stores_Status CHECK(Status IN ('ACTIVE','TEMPORARILY_CLOSED','CLOSED')),
 CONSTRAINT CK_Stores_Code CHECK(LEN(LTRIM(RTRIM(StoreCode))) > 0)
);
CREATE TABLE dbo.StaffStoreAssignments (
 AssignmentId int IDENTITY(1,1) CONSTRAINT PK_StaffStoreAssignments PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_StaffAssignments_Users REFERENCES dbo.Users(UserId),
 StoreId int NOT NULL CONSTRAINT FK_StaffAssignments_Stores REFERENCES dbo.Stores(StoreId),
 StoreRole varchar(20) NOT NULL,
 StartAt datetime2(3) NOT NULL CONSTRAINT DF_StaffAssignments_StartAt DEFAULT SYSUTCDATETIME(),
 EndAt datetime2(3) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_StaffAssignments_Status DEFAULT ('ACTIVE'),
 CONSTRAINT CK_StaffAssignments_Role CHECK(StoreRole IN ('MANAGER','STAFF')),
 CONSTRAINT CK_StaffAssignments_Status CHECK(Status IN ('ACTIVE','ENDED')),
 CONSTRAINT CK_StaffAssignments_Dates CHECK((Status='ACTIVE' AND EndAt IS NULL)
  OR (Status='ENDED' AND EndAt IS NOT NULL AND EndAt >= StartAt))
);
CREATE UNIQUE INDEX UX_StaffAssignments_Active ON dbo.StaffStoreAssignments(UserId,StoreId) WHERE Status='ACTIVE';
CREATE TABLE dbo.CustomerAddresses (
 AddressId int IDENTITY(1,1) CONSTRAINT PK_CustomerAddresses PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_CustomerAddresses_Users REFERENCES dbo.Users(UserId),
 RecipientName nvarchar(150) NOT NULL,
 Phone varchar(20) NOT NULL,
 AddressLine nvarchar(500) NOT NULL,
 AdministrativeArea nvarchar(255) NOT NULL,
 PostalCode varchar(20) NULL,
 CountryCode char(2) NOT NULL CONSTRAINT DF_CustomerAddresses_Country DEFAULT ('VN'),
 IsDefault bit NOT NULL CONSTRAINT DF_CustomerAddresses_IsDefault DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_CustomerAddresses_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_CustomerAddresses_UpdatedAt DEFAULT SYSUTCDATETIME()
);
CREATE UNIQUE INDEX UX_CustomerAddresses_Default ON dbo.CustomerAddresses(UserId) WHERE IsDefault=1;
CREATE TABLE dbo.BookConditions (
 ConditionId int IDENTITY(1,1) CONSTRAINT PK_BookConditions PRIMARY KEY,
 ConditionCode varchar(30) NOT NULL CONSTRAINT UQ_BookConditions_Code UNIQUE,
 ConditionName nvarchar(100) NOT NULL,
 Description nvarchar(500) NULL,
 SortOrder int NOT NULL CONSTRAINT DF_BookConditions_SortOrder DEFAULT (0),
 CONSTRAINT CK_BookConditions_Sort CHECK(SortOrder >= 0)
);
CREATE TABLE dbo.Suppliers (
 SupplierId int IDENTITY(1,1) CONSTRAINT PK_Suppliers PRIMARY KEY,
 SupplierType varchar(20) NOT NULL,
 SupplierName nvarchar(200) NOT NULL,
 Phone varchar(20) NULL,
 Email nvarchar(254) NULL,
 Address nvarchar(500) NULL,
 LinkedUserId int NULL CONSTRAINT FK_Suppliers_Users REFERENCES dbo.Users(UserId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Suppliers_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Suppliers_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Suppliers_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Suppliers_Type CHECK(SupplierType IN ('INDIVIDUAL','ORGANIZATION')),
 CONSTRAINT CK_Suppliers_Status CHECK(Status IN ('ACTIVE','INACTIVE'))
);
CREATE TABLE dbo.PurchaseReceipts (
 ReceiptId int IDENTITY(1,1) CONSTRAINT PK_PurchaseReceipts PRIMARY KEY,
 ReceiptCode varchar(40) NOT NULL CONSTRAINT UQ_PurchaseReceipts_Code UNIQUE,
 SupplierId int NOT NULL CONSTRAINT FK_PurchaseReceipts_Suppliers REFERENCES dbo.Suppliers(SupplierId),
 StoreId int NOT NULL CONSTRAINT FK_PurchaseReceipts_Stores REFERENCES dbo.Stores(StoreId),
 CreatedBy int NOT NULL CONSTRAINT FK_PurchaseReceipts_Creator REFERENCES dbo.Users(UserId),
 Status varchar(20) NOT NULL CONSTRAINT DF_PurchaseReceipts_Status DEFAULT ('DRAFT'),
 TotalAmount decimal(19,2) NOT NULL CONSTRAINT DF_PurchaseReceipts_Total DEFAULT (0),
 ReceivedAt datetime2(3) NULL,
 Note nvarchar(1000) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_PurchaseReceipts_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_PurchaseReceipts_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_PurchaseReceipts_Status CHECK(Status IN ('DRAFT','RECEIVED','CANCELLED')),
 CONSTRAINT CK_PurchaseReceipts_Total CHECK(TotalAmount >= 0),
 CONSTRAINT CK_PurchaseReceipts_Received CHECK((Status='RECEIVED' AND ReceivedAt IS NOT NULL AND ReceivedAt >= CreatedAt)
  OR (Status IN ('DRAFT','CANCELLED') AND ReceivedAt IS NULL))
);
CREATE TABLE dbo.PurchaseReceiptItems (
 ReceiptItemId int IDENTITY(1,1) CONSTRAINT PK_PurchaseReceiptItems PRIMARY KEY,
 ReceiptId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Receipts REFERENCES dbo.PurchaseReceipts(ReceiptId),
 BookId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Books REFERENCES dbo.Books(BookId),
 ConditionId int NOT NULL CONSTRAINT FK_PurchaseReceiptItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 Quantity int NOT NULL,
 UnitCost decimal(19,2) NOT NULL,
 Note nvarchar(1000) NULL,
 CONSTRAINT UQ_PurchaseReceiptItems_ItemBook UNIQUE(ReceiptItemId,BookId),
 CONSTRAINT CK_PurchaseReceiptItems_Quantity CHECK(Quantity > 0),
 CONSTRAINT CK_PurchaseReceiptItems_Cost CHECK(UnitCost >= 0)
);
CREATE TABLE dbo.BookCopies (
 CopyId int IDENTITY(1,1) CONSTRAINT PK_BookCopies PRIMARY KEY,
 CopyCode varchar(50) NOT NULL CONSTRAINT UQ_BookCopies_Code UNIQUE,
 BookId int NOT NULL CONSTRAINT FK_BookCopies_Books REFERENCES dbo.Books(BookId),
 StoreId int NOT NULL CONSTRAINT FK_BookCopies_Stores REFERENCES dbo.Stores(StoreId),
 ConditionId int NOT NULL CONSTRAINT FK_BookCopies_Conditions REFERENCES dbo.BookConditions(ConditionId),
 PurchaseReceiptItemId int NULL,
 CostPrice decimal(19,2) NOT NULL,
 SalePrice decimal(19,2) NOT NULL,
 ConditionNotes nvarchar(1000) NULL,
 ShelfLocation nvarchar(100) NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_BookCopies_Status DEFAULT ('AVAILABLE'),
 Version bigint NOT NULL CONSTRAINT DF_BookCopies_Version DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_BookCopies_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_BookCopies_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT FK_BookCopies_ReceiptItemBook FOREIGN KEY(PurchaseReceiptItemId,BookId)
  REFERENCES dbo.PurchaseReceiptItems(ReceiptItemId,BookId),
 CONSTRAINT CK_BookCopies_Prices CHECK(CostPrice >= 0 AND SalePrice >= 0),
 CONSTRAINT CK_BookCopies_Version CHECK(Version >= 0),
 CONSTRAINT CK_BookCopies_Status CHECK(Status IN ('AVAILABLE','RESERVED','SOLD','IN_TRANSIT','DAMAGED','LOST'))
);
CREATE TABLE dbo.MediaAssets (
 MediaId int IDENTITY(1,1) CONSTRAINT PK_MediaAssets PRIMARY KEY,
 Provider varchar(20) NOT NULL,
 Url nvarchar(2048) NOT NULL,
 PublicId varchar(255) COLLATE Latin1_General_100_BIN2 NULL,
 ResourceType varchar(20) NOT NULL CONSTRAINT DF_MediaAssets_ResourceType DEFAULT ('image'),
 Format varchar(20) NULL,
 Width int NULL,
 Height int NULL,
 AltText nvarchar(255) NULL,
 SortOrder int NOT NULL CONSTRAINT DF_MediaAssets_SortOrder DEFAULT (0),
 IsPrimary bit NOT NULL CONSTRAINT DF_MediaAssets_IsPrimary DEFAULT (0),
 BookId int NULL CONSTRAINT FK_MediaAssets_Books REFERENCES dbo.Books(BookId),
 CopyId int NULL CONSTRAINT FK_MediaAssets_Copies REFERENCES dbo.BookCopies(CopyId),
 AuthorId int NULL CONSTRAINT FK_MediaAssets_Authors REFERENCES dbo.Authors(AuthorId),
 UserId int NULL CONSTRAINT FK_MediaAssets_Users REFERENCES dbo.Users(UserId),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_MediaAssets_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_MediaAssets_Provider CHECK(Provider IN ('LOCAL','CLOUDINARY')),
 CONSTRAINT CK_MediaAssets_Resource CHECK(ResourceType='image'),
 CONSTRAINT CK_MediaAssets_Url CHECK((Provider='LOCAL' AND Url LIKE '/images/%') OR
  (Provider='CLOUDINARY' AND Url LIKE 'https://%' AND PublicId IS NOT NULL AND LEN(PublicId)>0)),
 CONSTRAINT CK_MediaAssets_Size CHECK((Width IS NULL OR Width>0) AND (Height IS NULL OR Height>0) AND SortOrder>=0),
 CONSTRAINT CK_MediaAssets_Owner CHECK(
  (CASE WHEN BookId IS NULL THEN 0 ELSE 1 END)+(CASE WHEN CopyId IS NULL THEN 0 ELSE 1 END)+
  (CASE WHEN AuthorId IS NULL THEN 0 ELSE 1 END)+(CASE WHEN UserId IS NULL THEN 0 ELSE 1 END)=1)
);
CREATE UNIQUE INDEX UX_MediaAssets_PublicId ON dbo.MediaAssets(Provider,PublicId) WHERE PublicId IS NOT NULL;
CREATE UNIQUE INDEX UX_MediaAssets_BookPrimary ON dbo.MediaAssets(BookId) WHERE BookId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_CopyPrimary ON dbo.MediaAssets(CopyId) WHERE CopyId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_AuthorPrimary ON dbo.MediaAssets(AuthorId) WHERE AuthorId IS NOT NULL AND IsPrimary=1;
CREATE UNIQUE INDEX UX_MediaAssets_UserPrimary ON dbo.MediaAssets(UserId) WHERE UserId IS NOT NULL AND IsPrimary=1;
CREATE TABLE dbo.StockTransfers (
 TransferId int IDENTITY(1,1) CONSTRAINT PK_StockTransfers PRIMARY KEY,
 TransferCode varchar(40) NOT NULL CONSTRAINT UQ_StockTransfers_Code UNIQUE,
 FromStoreId int NOT NULL CONSTRAINT FK_StockTransfers_FromStore REFERENCES dbo.Stores(StoreId),
 ToStoreId int NOT NULL CONSTRAINT FK_StockTransfers_ToStore REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_StockTransfers_Status DEFAULT ('DRAFT'),
 RequestedBy int NOT NULL CONSTRAINT FK_StockTransfers_Requester REFERENCES dbo.Users(UserId),
 ApprovedBy int NULL CONSTRAINT FK_StockTransfers_Approver REFERENCES dbo.Users(UserId),
 ShippedAt datetime2(3) NULL,
 ReceivedAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_StockTransfers_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_StockTransfers_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_StockTransfers_Stores CHECK(FromStoreId<>ToStoreId),
 CONSTRAINT CK_StockTransfers_Status CHECK(Status IN ('DRAFT','APPROVED','IN_TRANSIT','RECEIVED','CANCELLED')),
 CONSTRAINT CK_StockTransfers_Dates CHECK((ShippedAt IS NULL OR ShippedAt>=CreatedAt)
  AND (ReceivedAt IS NULL OR (ShippedAt IS NOT NULL AND ReceivedAt>=ShippedAt))),
 CONSTRAINT CK_StockTransfers_Approval CHECK(Status NOT IN ('APPROVED','IN_TRANSIT','RECEIVED') OR ApprovedBy IS NOT NULL),
 CONSTRAINT CK_StockTransfers_Shipped CHECK(Status NOT IN ('IN_TRANSIT','RECEIVED') OR ShippedAt IS NOT NULL),
 CONSTRAINT CK_StockTransfers_Received CHECK(Status<>'RECEIVED' OR ReceivedAt IS NOT NULL)
);
CREATE TABLE dbo.StockTransferItems (
 TransferItemId int IDENTITY(1,1) CONSTRAINT PK_StockTransferItems PRIMARY KEY,
 TransferId int NOT NULL CONSTRAINT FK_StockTransferItems_Transfers REFERENCES dbo.StockTransfers(TransferId),
 CopyId int NOT NULL CONSTRAINT FK_StockTransferItems_Copies REFERENCES dbo.BookCopies(CopyId),
 SentConditionId int NOT NULL CONSTRAINT FK_StockTransferItems_SentCondition REFERENCES dbo.BookConditions(ConditionId),
 ReceivedConditionId int NULL CONSTRAINT FK_StockTransferItems_ReceivedCondition REFERENCES dbo.BookConditions(ConditionId),
 ReceiptStatus varchar(20) NOT NULL CONSTRAINT DF_StockTransferItems_Status DEFAULT ('PENDING'),
 Note nvarchar(1000) NULL,
 CONSTRAINT UQ_StockTransferItems_TransferCopy UNIQUE(TransferId,CopyId),
 CONSTRAINT UQ_StockTransferItems_ItemCopy UNIQUE(TransferItemId,CopyId),
 CONSTRAINT CK_StockTransferItems_Status CHECK(ReceiptStatus IN ('PENDING','RECEIVED','MISSING','DAMAGED')),
 CONSTRAINT CK_StockTransferItems_Condition CHECK(ReceiptStatus NOT IN ('RECEIVED','DAMAGED') OR ReceivedConditionId IS NOT NULL)
);
CREATE TABLE dbo.Stocktakes (
 StocktakeId int IDENTITY(1,1) CONSTRAINT PK_Stocktakes PRIMARY KEY,
 StoreId int NOT NULL CONSTRAINT FK_Stocktakes_Stores REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Stocktakes_Status DEFAULT ('DRAFT'),
 StartedAt datetime2(3) NULL,
 FinalizedAt datetime2(3) NULL,
 CreatedBy int NOT NULL CONSTRAINT FK_Stocktakes_Creator REFERENCES dbo.Users(UserId),
 ApprovedBy int NULL CONSTRAINT FK_Stocktakes_Approver REFERENCES dbo.Users(UserId),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Stocktakes_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Stocktakes_Status CHECK(Status IN ('DRAFT','COUNTING','FINALIZED','CANCELLED')),
 CONSTRAINT CK_Stocktakes_Dates CHECK((StartedAt IS NULL OR StartedAt>=CreatedAt)
  AND (FinalizedAt IS NULL OR (StartedAt IS NOT NULL AND FinalizedAt>=StartedAt))),
 CONSTRAINT CK_Stocktakes_Started CHECK(Status NOT IN ('COUNTING','FINALIZED') OR StartedAt IS NOT NULL),
 CONSTRAINT CK_Stocktakes_Finalized CHECK(Status<>'FINALIZED' OR (FinalizedAt IS NOT NULL AND ApprovedBy IS NOT NULL))
);
CREATE UNIQUE INDEX UX_Stocktakes_Counting ON dbo.Stocktakes(StoreId) WHERE Status='COUNTING';
CREATE TABLE dbo.StocktakeItems (
 StocktakeItemId int IDENTITY(1,1) CONSTRAINT PK_StocktakeItems PRIMARY KEY,
 StocktakeId int NOT NULL CONSTRAINT FK_StocktakeItems_Stocktakes REFERENCES dbo.Stocktakes(StocktakeId),
 CopyId int NOT NULL CONSTRAINT FK_StocktakeItems_Copies REFERENCES dbo.BookCopies(CopyId),
 ExpectedPresent bit NOT NULL,
 ActualPresent bit NULL,
 ActualConditionId int NULL CONSTRAINT FK_StocktakeItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 DifferenceReason nvarchar(1000) NULL,
 CONSTRAINT UQ_StocktakeItems_StocktakeCopy UNIQUE(StocktakeId,CopyId),
 CONSTRAINT UQ_StocktakeItems_ItemCopy UNIQUE(StocktakeItemId,CopyId),
 CONSTRAINT CK_StocktakeItems_Condition CHECK(ActualPresent IS NULL OR ActualPresent=0 OR ActualConditionId IS NOT NULL)
);
CREATE TABLE dbo.Carts (
 CartId int IDENTITY(1,1) CONSTRAINT PK_Carts PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_Carts_Users REFERENCES dbo.Users(UserId),
 StoreId int NOT NULL CONSTRAINT FK_Carts_Stores REFERENCES dbo.Stores(StoreId),
 Status varchar(20) NOT NULL CONSTRAINT DF_Carts_Status DEFAULT ('ACTIVE'),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Carts_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Carts_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT CK_Carts_Status CHECK(Status IN ('ACTIVE','CHECKED_OUT','ABANDONED'))
);
CREATE UNIQUE INDEX UX_Carts_Active ON dbo.Carts(UserId,StoreId) WHERE Status='ACTIVE';
CREATE TABLE dbo.CartItems (
 CartItemId int IDENTITY(1,1) CONSTRAINT PK_CartItems PRIMARY KEY,
 CartId int NOT NULL CONSTRAINT FK_CartItems_Carts REFERENCES dbo.Carts(CartId),
 CopyId int NOT NULL CONSTRAINT FK_CartItems_Copies REFERENCES dbo.BookCopies(CopyId),
 AddedAt datetime2(3) NOT NULL CONSTRAINT DF_CartItems_AddedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_CartItems_CartCopy UNIQUE(CartId,CopyId)
);
CREATE TABLE dbo.Orders (
 OrderId int IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
 OrderCode varchar(40) NOT NULL CONSTRAINT UQ_Orders_Code UNIQUE,
 StoreId int NOT NULL CONSTRAINT FK_Orders_Stores REFERENCES dbo.Stores(StoreId),
 CustomerId int NULL CONSTRAINT FK_Orders_Customer REFERENCES dbo.Users(UserId),
 CreatedBy int NULL CONSTRAINT FK_Orders_Creator REFERENCES dbo.Users(UserId),
 Channel varchar(10) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('PENDING'),
 RecipientName nvarchar(150) NULL,
 RecipientPhone varchar(20) NULL,
 ShippingAddressSnapshot nvarchar(1000) NULL,
 Subtotal decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT (0),
 DiscountAmount decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Discount DEFAULT (0),
 ShippingFee decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Shipping DEFAULT (0),
 TotalAmount decimal(19,2) NOT NULL CONSTRAINT DF_Orders_Total DEFAULT (0),
 Version bigint NOT NULL CONSTRAINT DF_Orders_Version DEFAULT (0),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSUTCDATETIME(),
 UpdatedAt datetime2(3) NOT NULL CONSTRAINT DF_Orders_UpdatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Orders_OrderStore UNIQUE(OrderId,StoreId),
 CONSTRAINT CK_Orders_Channel CHECK(Channel IN ('ONLINE','POS')),
 CONSTRAINT CK_Orders_Actor CHECK((Channel='ONLINE' AND CustomerId IS NOT NULL) OR (Channel='POS' AND CreatedBy IS NOT NULL)),
 CONSTRAINT CK_Orders_Status CHECK(Status IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_Orders_Money CHECK(Subtotal>=0 AND DiscountAmount>=0 AND DiscountAmount<=Subtotal AND ShippingFee>=0
  AND TotalAmount=Subtotal-DiscountAmount+ShippingFee),
 CONSTRAINT CK_Orders_Version CHECK(Version>=0)
);
CREATE TABLE dbo.OrderItems (
 OrderItemId int IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_OrderItems_Orders REFERENCES dbo.Orders(OrderId),
 CopyId int NOT NULL CONSTRAINT FK_OrderItems_Copies REFERENCES dbo.BookCopies(CopyId),
 BookTitleSnapshot nvarchar(255) NOT NULL,
 ConditionSnapshot nvarchar(255) NOT NULL,
 UnitPrice decimal(19,2) NOT NULL,
 UnitCostSnapshot decimal(19,2) NOT NULL,
 DiscountAmount decimal(19,2) NOT NULL CONSTRAINT DF_OrderItems_Discount DEFAULT (0),
 LineTotal decimal(19,2) NOT NULL,
 CONSTRAINT UQ_OrderItems_OrderCopy UNIQUE(OrderId,CopyId),
 CONSTRAINT UQ_OrderItems_ItemOrder UNIQUE(OrderItemId,OrderId),
 CONSTRAINT UQ_OrderItems_ItemCopy UNIQUE(OrderItemId,CopyId),
 CONSTRAINT CK_OrderItems_Money CHECK(UnitPrice>=0 AND UnitCostSnapshot>=0 AND DiscountAmount>=0
  AND DiscountAmount<=UnitPrice AND LineTotal=UnitPrice-DiscountAmount)
);
CREATE TABLE dbo.StockReservations (
 ReservationId int IDENTITY(1,1) CONSTRAINT PK_StockReservations PRIMARY KEY,
 CopyId int NOT NULL,
 OrderId int NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_StockReservations_Status DEFAULT ('ACTIVE'),
 ReservedAt datetime2(3) NOT NULL CONSTRAINT DF_StockReservations_ReservedAt DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NOT NULL,
 ReleasedAt datetime2(3) NULL,
 CONSTRAINT FK_StockReservations_OrderCopy FOREIGN KEY(OrderId,CopyId) REFERENCES dbo.OrderItems(OrderId,CopyId),
 CONSTRAINT CK_StockReservations_Status CHECK(Status IN ('ACTIVE','CONSUMED','EXPIRED','CANCELLED')),
 CONSTRAINT CK_StockReservations_Dates CHECK(ExpiresAt>ReservedAt AND
  ((Status='ACTIVE' AND ReleasedAt IS NULL) OR (Status<>'ACTIVE' AND ReleasedAt IS NOT NULL AND ReleasedAt>=ReservedAt)))
);
CREATE UNIQUE INDEX UX_StockReservations_ActiveCopy ON dbo.StockReservations(CopyId) WHERE Status='ACTIVE';
CREATE TABLE dbo.Payments (
 PaymentId int IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_Payments_Orders REFERENCES dbo.Orders(OrderId),
 Method varchar(20) NOT NULL,
 Provider varchar(50) NOT NULL,
 Amount decimal(19,2) NOT NULL,
 Currency char(3) NOT NULL CONSTRAINT DF_Payments_Currency DEFAULT ('VND'),
 Status varchar(20) NOT NULL CONSTRAINT DF_Payments_Status DEFAULT ('PENDING'),
 ProviderTransactionId varchar(150) COLLATE Latin1_General_100_BIN2 NULL,
 IdempotencyKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_Payments_Idempotency UNIQUE,
 PaidAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT UQ_Payments_PaymentOrder UNIQUE(PaymentId,OrderId),
 CONSTRAINT CK_Payments_Method CHECK(Method IN ('CASH','BANK_TRANSFER','CARD','E_WALLET','COD')),
 CONSTRAINT CK_Payments_Status CHECK(Status IN ('PENDING','SUCCEEDED','FAILED','CANCELLED')),
 CONSTRAINT CK_Payments_Amount CHECK(Amount>0),
 CONSTRAINT CK_Payments_Currency CHECK(Currency='VND'),
 CONSTRAINT CK_Payments_Paid CHECK((Status='SUCCEEDED' AND PaidAt IS NOT NULL AND PaidAt>=CreatedAt)
  OR (Status<>'SUCCEEDED' AND PaidAt IS NULL))
);
CREATE UNIQUE INDEX UX_Payments_ProviderTransaction ON dbo.Payments(Provider,ProviderTransactionId) WHERE ProviderTransactionId IS NOT NULL;
CREATE TABLE dbo.OrderStatusHistory (
 HistoryId bigint IDENTITY(1,1) CONSTRAINT PK_OrderStatusHistory PRIMARY KEY,
 OrderId int NOT NULL CONSTRAINT FK_OrderStatusHistory_Orders REFERENCES dbo.Orders(OrderId),
 FromStatus varchar(20) NULL,
 ToStatus varchar(20) NOT NULL,
 ChangedBy int NULL CONSTRAINT FK_OrderStatusHistory_Users REFERENCES dbo.Users(UserId),
 ChangedAt datetime2(3) NOT NULL CONSTRAINT DF_OrderStatusHistory_ChangedAt DEFAULT SYSUTCDATETIME(),
 Reason nvarchar(1000) NULL,
 CONSTRAINT CK_OrderStatusHistory_From CHECK(FromStatus IS NULL OR FromStatus IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_OrderStatusHistory_To CHECK(ToStatus IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED')),
 CONSTRAINT CK_OrderStatusHistory_Change CHECK(FromStatus IS NULL OR FromStatus<>ToStatus)
);
CREATE TABLE dbo.SalesReturns (
 ReturnId int IDENTITY(1,1) CONSTRAINT PK_SalesReturns PRIMARY KEY,
 OrderId int NOT NULL,
 ReceivingStoreId int NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_SalesReturns_Status DEFAULT ('REQUESTED'),
 RequestedBy int NULL CONSTRAINT FK_SalesReturns_Requester REFERENCES dbo.Users(UserId),
 ProcessedBy int NULL CONSTRAINT FK_SalesReturns_Processor REFERENCES dbo.Users(UserId),
 Reason nvarchar(1000) NOT NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_SalesReturns_CreatedAt DEFAULT SYSUTCDATETIME(),
 ApprovedAt datetime2(3) NULL,
 CONSTRAINT UQ_SalesReturns_ReturnOrder UNIQUE(ReturnId,OrderId),
 CONSTRAINT FK_SalesReturns_OrderStore FOREIGN KEY(OrderId,ReceivingStoreId) REFERENCES dbo.Orders(OrderId,StoreId),
 CONSTRAINT CK_SalesReturns_Status CHECK(Status IN ('REQUESTED','APPROVED','COMPLETED','REJECTED','CANCELLED')),
 CONSTRAINT CK_SalesReturns_Approval CHECK(Status NOT IN ('APPROVED','COMPLETED') OR
  (ProcessedBy IS NOT NULL AND ApprovedAt IS NOT NULL AND ApprovedAt>=CreatedAt))
);
CREATE TABLE dbo.SalesReturnItems (
 ReturnItemId int IDENTITY(1,1) CONSTRAINT PK_SalesReturnItems PRIMARY KEY,
 ReturnId int NOT NULL,
 OrderId int NOT NULL,
 OrderItemId int NOT NULL,
 ReceivedConditionId int NULL CONSTRAINT FK_SalesReturnItems_Conditions REFERENCES dbo.BookConditions(ConditionId),
 Resolution varchar(20) NULL,
 RefundAmount decimal(19,2) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_SalesReturnItems_Status DEFAULT ('PENDING'),
 CONSTRAINT FK_SalesReturnItems_ReturnOrder FOREIGN KEY(ReturnId,OrderId) REFERENCES dbo.SalesReturns(ReturnId,OrderId),
 CONSTRAINT FK_SalesReturnItems_ItemOrder FOREIGN KEY(OrderItemId,OrderId) REFERENCES dbo.OrderItems(OrderItemId,OrderId),
 CONSTRAINT UQ_SalesReturnItems_ReturnItem UNIQUE(ReturnId,OrderItemId),
 CONSTRAINT UQ_SalesReturnItems_ItemOrderItem UNIQUE(ReturnItemId,OrderItemId),
 CONSTRAINT CK_SalesReturnItems_Resolution CHECK(Resolution IS NULL OR Resolution IN ('RESTOCK','DAMAGED')),
 CONSTRAINT CK_SalesReturnItems_Status CHECK(Status IN ('PENDING','ACCEPTED','REJECTED')),
 CONSTRAINT CK_SalesReturnItems_Refund CHECK(RefundAmount>=0),
 CONSTRAINT CK_SalesReturnItems_Accepted CHECK(Status<>'ACCEPTED' OR (ReceivedConditionId IS NOT NULL AND Resolution IS NOT NULL))
);
CREATE UNIQUE INDEX UX_SalesReturnItems_Accepted ON dbo.SalesReturnItems(OrderItemId) WHERE Status='ACCEPTED';
CREATE TABLE dbo.Refunds (
 RefundId int IDENTITY(1,1) CONSTRAINT PK_Refunds PRIMARY KEY,
 ReturnId int NULL,
 PaymentId int NOT NULL,
 OrderId int NOT NULL,
 Amount decimal(19,2) NOT NULL,
 Reason nvarchar(1000) NOT NULL,
 Status varchar(20) NOT NULL CONSTRAINT DF_Refunds_Status DEFAULT ('PENDING'),
 Provider varchar(50) NOT NULL,
 ProviderRefundId varchar(150) COLLATE Latin1_General_100_BIN2 NULL,
 IdempotencyKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_Refunds_Idempotency UNIQUE,
 RefundedAt datetime2(3) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Refunds_CreatedAt DEFAULT SYSUTCDATETIME(),
 CONSTRAINT FK_Refunds_ReturnOrder FOREIGN KEY(ReturnId,OrderId) REFERENCES dbo.SalesReturns(ReturnId,OrderId),
 CONSTRAINT FK_Refunds_PaymentOrder FOREIGN KEY(PaymentId,OrderId) REFERENCES dbo.Payments(PaymentId,OrderId),
 CONSTRAINT CK_Refunds_Amount CHECK(Amount>0),
 CONSTRAINT CK_Refunds_Status CHECK(Status IN ('PENDING','SUCCEEDED','FAILED','CANCELLED')),
 CONSTRAINT CK_Refunds_Date CHECK((Status='SUCCEEDED' AND RefundedAt IS NOT NULL AND RefundedAt>=CreatedAt)
  OR (Status<>'SUCCEEDED' AND RefundedAt IS NULL))
);
CREATE UNIQUE INDEX UX_Refunds_ProviderRefund ON dbo.Refunds(Provider,ProviderRefundId) WHERE ProviderRefundId IS NOT NULL;
CREATE TABLE dbo.RefreshTokens (
 RefreshTokenId bigint IDENTITY(1,1) CONSTRAINT PK_RefreshTokens PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_RefreshTokens_Users REFERENCES dbo.Users(UserId),
 TokenHash binary(32) NOT NULL CONSTRAINT UQ_RefreshTokens_Hash UNIQUE,
 FamilyId uniqueidentifier NOT NULL CONSTRAINT DF_RefreshTokens_Family DEFAULT NEWID(),
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_RefreshTokens_CreatedAt DEFAULT SYSUTCDATETIME(),
 ExpiresAt datetime2(3) NOT NULL,
 RevokedAt datetime2(3) NULL,
 ReplacedByTokenId bigint NULL,
 CONSTRAINT UQ_RefreshTokens_TokenUserFamily UNIQUE(RefreshTokenId,UserId,FamilyId),
 CONSTRAINT FK_RefreshTokens_Replacement FOREIGN KEY(ReplacedByTokenId,UserId,FamilyId)
  REFERENCES dbo.RefreshTokens(RefreshTokenId,UserId,FamilyId),
 CONSTRAINT CK_RefreshTokens_Dates CHECK(ExpiresAt>CreatedAt AND (RevokedAt IS NULL OR RevokedAt>=CreatedAt)),
 CONSTRAINT CK_RefreshTokens_Replacement CHECK(ReplacedByTokenId IS NULL OR
  (ReplacedByTokenId<>RefreshTokenId AND RevokedAt IS NOT NULL))
);
CREATE UNIQUE INDEX UX_RefreshTokens_Replacement ON dbo.RefreshTokens(ReplacedByTokenId) WHERE ReplacedByTokenId IS NOT NULL;
CREATE TABLE dbo.Notifications (
 NotificationId bigint IDENTITY(1,1) CONSTRAINT PK_Notifications PRIMARY KEY,
 UserId int NOT NULL CONSTRAINT FK_Notifications_Users REFERENCES dbo.Users(UserId),
 StoreId int NULL CONSTRAINT FK_Notifications_Stores REFERENCES dbo.Stores(StoreId),
 Type varchar(50) NOT NULL,
 Title nvarchar(200) NOT NULL,
 Content nvarchar(2000) NOT NULL,
 TargetUrl nvarchar(2048) NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT SYSUTCDATETIME(),
 ReadAt datetime2(3) NULL,
 CONSTRAINT CK_Notifications_Read CHECK(ReadAt IS NULL OR ReadAt>=CreatedAt)
);
CREATE TABLE dbo.AuditLogs (
 AuditId bigint IDENTITY(1,1) CONSTRAINT PK_AuditLogs PRIMARY KEY,
 ActorId int NULL CONSTRAINT FK_AuditLogs_Users REFERENCES dbo.Users(UserId),
 StoreId int NULL CONSTRAINT FK_AuditLogs_Stores REFERENCES dbo.Stores(StoreId),
 Action varchar(100) NOT NULL,
 EntityType varchar(100) NOT NULL,
 EntityId varchar(100) NULL,
 Summary nvarchar(2000) NOT NULL,
 CreatedAt datetime2(3) NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt DEFAULT SYSUTCDATETIME(),
 CorrelationId uniqueidentifier NULL
);
CREATE TABLE dbo.InventoryMovements (
 MovementId bigint IDENTITY(1,1) CONSTRAINT PK_InventoryMovements PRIMARY KEY,
 CopyId int NOT NULL CONSTRAINT FK_InventoryMovements_Copies REFERENCES dbo.BookCopies(CopyId),
 FromStoreId int NULL CONSTRAINT FK_InventoryMovements_FromStore REFERENCES dbo.Stores(StoreId),
 ToStoreId int NULL CONSTRAINT FK_InventoryMovements_ToStore REFERENCES dbo.Stores(StoreId),
 MovementType varchar(30) NOT NULL,
 OccurredAt datetime2(3) NOT NULL CONSTRAINT DF_InventoryMovements_OccurredAt DEFAULT SYSUTCDATETIME(),
 ActorId int NOT NULL CONSTRAINT FK_InventoryMovements_Actor REFERENCES dbo.Users(UserId),
 ReceiptItemId int NULL CONSTRAINT FK_InventoryMovements_ReceiptItem REFERENCES dbo.PurchaseReceiptItems(ReceiptItemId),
 OrderItemId int NULL,
 TransferItemId int NULL,
 ReturnItemId int NULL,
 StocktakeItemId int NULL,
 Reason nvarchar(1000) NULL,
 OperationKey varchar(100) COLLATE Latin1_General_100_BIN2 NOT NULL CONSTRAINT UQ_InventoryMovements_Operation UNIQUE,
 CONSTRAINT FK_InventoryMovements_OrderCopy FOREIGN KEY(OrderItemId,CopyId) REFERENCES dbo.OrderItems(OrderItemId,CopyId),
 CONSTRAINT FK_InventoryMovements_TransferCopy FOREIGN KEY(TransferItemId,CopyId) REFERENCES dbo.StockTransferItems(TransferItemId,CopyId),
 CONSTRAINT FK_InventoryMovements_ReturnItem FOREIGN KEY(ReturnItemId,OrderItemId) REFERENCES dbo.SalesReturnItems(ReturnItemId,OrderItemId),
 CONSTRAINT FK_InventoryMovements_StocktakeCopy FOREIGN KEY(StocktakeItemId,CopyId) REFERENCES dbo.StocktakeItems(StocktakeItemId,CopyId),
 CONSTRAINT CK_InventoryMovements_Type CHECK(MovementType IN ('RECEIPT','SALE','TRANSFER_OUT','TRANSFER_IN','RETURN','ADJUSTMENT')),
 CONSTRAINT CK_InventoryMovements_Reference CHECK(
  (MovementType='RECEIPT' AND ReceiptItemId IS NOT NULL AND OrderItemId IS NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType='SALE' AND ReceiptItemId IS NULL AND OrderItemId IS NOT NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType IN ('TRANSFER_OUT','TRANSFER_IN') AND ReceiptItemId IS NULL AND OrderItemId IS NULL AND TransferItemId IS NOT NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NULL)
  OR (MovementType='RETURN' AND ReceiptItemId IS NULL AND OrderItemId IS NOT NULL AND TransferItemId IS NULL AND ReturnItemId IS NOT NULL AND StocktakeItemId IS NULL)
  OR (MovementType='ADJUSTMENT' AND ReceiptItemId IS NULL AND OrderItemId IS NULL AND TransferItemId IS NULL AND ReturnItemId IS NULL AND StocktakeItemId IS NOT NULL AND Reason IS NOT NULL)),
 CONSTRAINT CK_InventoryMovements_Stores CHECK(
  (MovementType IN ('RECEIPT','RETURN') AND FromStoreId IS NULL AND ToStoreId IS NOT NULL)
  OR (MovementType='SALE' AND FromStoreId IS NOT NULL AND ToStoreId IS NULL)
  OR (MovementType IN ('TRANSFER_OUT','TRANSFER_IN') AND FromStoreId IS NOT NULL AND ToStoreId IS NOT NULL AND FromStoreId<>ToStoreId)
  OR (MovementType='ADJUSTMENT' AND (FromStoreId IS NOT NULL OR ToStoreId IS NOT NULL)))
);

-- Query and FK support indexes. Foreign keys use NO ACTION; history is never cascade-deleted.
CREATE INDEX IX_UserRoles_Role ON dbo.UserRoles(RoleId);
CREATE INDEX IX_StaffAssignments_Store ON dbo.StaffStoreAssignments(StoreId,Status);
CREATE INDEX IX_CustomerAddresses_User ON dbo.CustomerAddresses(UserId);
CREATE INDEX IX_Suppliers_User ON dbo.Suppliers(LinkedUserId);
CREATE INDEX IX_PurchaseReceipts_StoreDate ON dbo.PurchaseReceipts(StoreId,CreatedAt,Status);
CREATE INDEX IX_PurchaseReceipts_Supplier ON dbo.PurchaseReceipts(SupplierId);
CREATE INDEX IX_PurchaseReceiptItems_Receipt ON dbo.PurchaseReceiptItems(ReceiptId);
CREATE INDEX IX_PurchaseReceiptItems_Book ON dbo.PurchaseReceiptItems(BookId);
CREATE INDEX IX_BookCopies_StoreBookStatus ON dbo.BookCopies(StoreId,BookId,Status) INCLUDE(ConditionId,SalePrice);
CREATE INDEX IX_BookCopies_Book ON dbo.BookCopies(BookId);
CREATE INDEX IX_BookCopies_ReceiptItem ON dbo.BookCopies(PurchaseReceiptItemId,BookId);
CREATE INDEX IX_MediaAssets_Book ON dbo.MediaAssets(BookId,SortOrder);
CREATE INDEX IX_MediaAssets_Copy ON dbo.MediaAssets(CopyId,SortOrder);
CREATE INDEX IX_MediaAssets_Author ON dbo.MediaAssets(AuthorId);
CREATE INDEX IX_MediaAssets_User ON dbo.MediaAssets(UserId);
CREATE INDEX IX_StockTransfers_From ON dbo.StockTransfers(FromStoreId,Status,CreatedAt);
CREATE INDEX IX_StockTransfers_To ON dbo.StockTransfers(ToStoreId,Status,CreatedAt);
CREATE INDEX IX_StockTransferItems_Copy ON dbo.StockTransferItems(CopyId);
CREATE INDEX IX_Stocktakes_Store ON dbo.Stocktakes(StoreId,CreatedAt);
CREATE INDEX IX_StocktakeItems_Copy ON dbo.StocktakeItems(CopyId);
CREATE INDEX IX_Carts_Store ON dbo.Carts(StoreId);
CREATE INDEX IX_CartItems_Copy ON dbo.CartItems(CopyId);
CREATE INDEX IX_Orders_StoreDateStatus ON dbo.Orders(StoreId,CreatedAt,Status);
CREATE INDEX IX_Orders_Customer ON dbo.Orders(CustomerId,CreatedAt);
CREATE INDEX IX_OrderItems_Copy ON dbo.OrderItems(CopyId);
CREATE INDEX IX_StockReservations_Order ON dbo.StockReservations(OrderId,CopyId);
CREATE INDEX IX_StockReservations_Expiry ON dbo.StockReservations(ExpiresAt) INCLUDE(CopyId,OrderId) WHERE Status='ACTIVE';
CREATE INDEX IX_Payments_OrderStatus ON dbo.Payments(OrderId,Status);
CREATE INDEX IX_OrderStatusHistory_OrderDate ON dbo.OrderStatusHistory(OrderId,ChangedAt);
CREATE INDEX IX_SalesReturns_Order ON dbo.SalesReturns(OrderId,ReceivingStoreId);
CREATE INDEX IX_SalesReturnItems_OrderItem ON dbo.SalesReturnItems(OrderItemId,OrderId);
CREATE INDEX IX_Refunds_Payment ON dbo.Refunds(PaymentId,OrderId,Status);
CREATE INDEX IX_Refunds_Return ON dbo.Refunds(ReturnId,OrderId);
CREATE INDEX IX_RefreshTokens_UserFamily ON dbo.RefreshTokens(UserId,FamilyId);
CREATE INDEX IX_RefreshTokens_Expiry ON dbo.RefreshTokens(ExpiresAt);
CREATE INDEX IX_Notifications_UserRead ON dbo.Notifications(UserId,ReadAt,CreatedAt);
CREATE INDEX IX_AuditLogs_EntityDate ON dbo.AuditLogs(EntityType,EntityId,CreatedAt);
CREATE INDEX IX_AuditLogs_ActorDate ON dbo.AuditLogs(ActorId,CreatedAt);
CREATE INDEX IX_InventoryMovements_CopyDate ON dbo.InventoryMovements(CopyId,OccurredAt);
CREATE INDEX IX_InventoryMovements_FromDate ON dbo.InventoryMovements(FromStoreId,OccurredAt);
CREATE INDEX IX_InventoryMovements_ToDate ON dbo.InventoryMovements(ToStoreId,OccurredAt);

-- Reference values only: no fabricated accounts, stores, stock or orders.
INSERT dbo.Roles(RoleCode,RoleName) VALUES ('ADMIN',N'Quản trị hệ thống'),('CUSTOMER',N'Khách hàng');
INSERT dbo.BookConditions(ConditionCode,ConditionName,Description,SortOrder) VALUES
 ('LIKE_NEW',N'Như mới',N'Sách đã qua sử dụng, gần như không có dấu vết sử dụng.',1),
 ('GOOD',N'Tốt',N'Có dấu vết sử dụng nhẹ, đủ trang và đọc rõ.',2),
 ('FAIR',N'Khá',N'Có nếp gấp, ố hoặc ghi chú; cần mô tả cụ thể từng cuốn.',3),
 ('WORN',N'Cũ nhiều',N'Hao mòn rõ; cần kiểm tra và ghi chú trước khi bán.',4);

IF (SELECT COUNT(*) FROM @expected e JOIN sys.tables t ON t.name=e.TableName AND t.schema_id=SCHEMA_ID('dbo'))<>30
 THROW 51003, 'The 30 core tables were not all created.', 1;
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1)
 THROW 51004, 'Untrusted or disabled foreign keys found.', 1;
COMMIT TRANSACTION;
PRINT 'Migration 002 committed: 30 core tables created; catalog data unchanged.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO


-- ============================================================================
-- BƯỚC 3: NẠP 1.215 DÒNG DỮ LIỆU MẪU (16 TÀI KHOẢN, 5 CHI NHÁNH, 249 BẢN SÁCH, 27 ĐƠN HÀNG)
-- File gốc: database/004-seed-demo-data.sql
-- ============================================================================

-- Generated demo-only dataset. Existing catalog remains unchanged.
-- Password: 123456; BCrypt cost 12. Raw refresh tokens are not issued.
SET NOCOUNT ON; SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @lock int;
EXEC @lock=sys.sp_getapplock @Resource=N'DEMO_SEED_V1',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
IF @lock<0 THROW 51200,'Cannot lock demo seed.',1;
IF EXISTS(SELECT 1 FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1' AND EntityType='DemoDataset')
BEGIN COMMIT TRANSACTION; PRINT 'DEMO v1 already installed; no data changed.'; RETURN; END;
IF EXISTS(SELECT 1 FROM dbo.Users WHERE Username LIKE 'demo.%') OR EXISTS(SELECT 1 FROM dbo.Stores WHERE StoreCode LIKE 'DEMO-%') OR EXISTS(SELECT 1 FROM dbo.Orders WHERE OrderCode LIKE 'DEMO-%')
 THROW 51201,'Demo namespace is already in use; inspect before seeding.',1;
DECLARE @asof datetime2(3)=SYSUTCDATETIME();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'admin',N'demo.admin@example.invalid',N'$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.',N'Quản trị viên',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_admin int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_admin,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='ADMIN'),DATEADD(minute,-92160,@asof));
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_admin,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'manager',N'demo.manager1@example.invalid',N'$2a$12$h/V9eOyEmJHWg/jK9jmmAuRJl6.RtivUMG/t8Rd3CcWhCF2BcPtoe',N'Nguyễn Đức Long',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_manager1 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'manager2',N'demo.manager2@example.invalid',N'$2a$12$GBN8xQVfueGzURql9Hn4GejEbNMiPKy8qglaHXehCsGGy0GQat95e',N'Trần Quốc Hùng',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_manager2 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'manager3',N'demo.manager3@example.invalid',N'$2a$12$Z.pF43Vu0h8LbAIv7WzGqeAnVgHDNwvP1Gjx/cHOFZEp/aYwd3IkG',N'Lê Thanh Hà',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_manager3 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'staff',N'demo.staff1@example.invalid',N'$2a$12$rJsNblLj8g/F0BlacJjegOBajYuf8l9HfTT2TxmlTVbrclnoq1EsO',N'Nguyễn Quốc Bảo',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_staff1 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'staff2',N'demo.staff2@example.invalid',N'$2a$12$ur8HJ7atr9yRfoKslQZdauGe4COWMQ0CNJVfAZm2FGbg77IOvLy9W',N'Trần Ngọc Mai',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_staff2 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'staff3',N'demo.staff3@example.invalid',N'$2a$12$D5IblYQH.m52BZ9N24NpY.gGSOmf7CIKHjmo1s9bGzjLuM0ywZL7i',N'Lê Tuấn Anh',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_staff3 int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'staff4',N'demo.former@example.invalid',N'$2a$12$atr9So0g8TIPqoFzktf6rOl28GCfU6yrSqDJ5oOQvgpKQz5kIKEFK',N'Phạm Minh Đức',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_former int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'staff5',N'demo.lockedstaff@example.invalid',N'$2a$12$lB5e8PUkOYTBQUONPq3Z3e8F6gXKMG1rD5rHpwaKuXM/dcEL5b4QO',N'Đỗ Thanh Tâm',NULL,N'LOCKED',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_lockedstaff int=SCOPE_IDENTITY();
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'khang',N'demo.customer1@example.invalid',N'$2a$12$q4Q/bX9x8Vx7IKe7Qa8P4O1ad.ZPRwOMqDO7Aplq14a.y0aR4vuli',N'Nguyễn Minh Khang',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_customer1 int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_customer1,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'hoang',N'demo.customer2@example.invalid',N'$2a$12$1eQpYloy/C2qxgG1aMVL1uekYHqwrKGzhaD7JA.4Xw3H5YI39N6rG',N'Trần Hoàng',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_customer2 int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_customer2,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'van',N'demo.customer3@example.invalid',N'$2a$12$6XPhmt6tTWm/2hVM6/l3ceRkpFMjdDcQ/eWhsAaSy/sq3wcCWhpL2',N'Lê Ngọc Vân',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_customer3 int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_customer3,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'minh',N'demo.locked@example.invalid',N'$2a$12$tt6uWQRseJ4YaRDgSHDJqewArJTNR2M107ldJZ.fitMAUL03/IgLi',N'Phạm Minh',NULL,N'LOCKED',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_locked int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_locked,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'linh',N'demo.pending@example.invalid',N'$2a$12$jOsyJ676O.c1fAXy7ji/q.SyEFIWcEXM5X6H/T/V1m2YfD.8OfHIq',N'Đỗ Thùy Linh',NULL,N'PENDING',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_pending int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_pending,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'nam',N'demo.empty@example.invalid',N'$2a$12$F5RkjAybyX/A26doqExmneWfrInAWopF9qRxU7pOjgKnHeBMcS/Li',N'Nguyễn Hoài Nam',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_empty int=SCOPE_IDENTITY();
INSERT dbo.[UserRoles] ([UserId],[RoleId],[AssignedAt]) VALUES (@Users_empty,(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER'),DATEADD(minute,-92160,@asof));
INSERT dbo.[Users] ([Username],[Email],[PasswordHash],[FullName],[Phone],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'huy',N'demo.unassigned@example.invalid',N'$2a$12$Yl.z3sbdw93sKF/EgEYLTey244ylprrzy5tpQGgn3RlWEVNgjAvDO',N'Trần Quang Huy',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Users_unassigned int=SCOPE_IDENTITY();
INSERT dbo.[Stores] ([StoreCode],[StoreName],[Address],[Phone],[Status],[OpenedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-S1',N'Kho sách mẫu Thủ Đức',N'Địa chỉ giả lập chi nhánh 1, TP. Hồ Chí Minh',NULL,N'ACTIVE',N'2025-01-01',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Stores_1 int=SCOPE_IDENTITY();
INSERT dbo.[Stores] ([StoreCode],[StoreName],[Address],[Phone],[Status],[OpenedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-S2',N'Kho sách mẫu Bình Thạnh',N'Địa chỉ giả lập chi nhánh 2, TP. Hồ Chí Minh',NULL,N'ACTIVE',N'2025-01-01',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Stores_2 int=SCOPE_IDENTITY();
INSERT dbo.[Stores] ([StoreCode],[StoreName],[Address],[Phone],[Status],[OpenedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-S3',N'Kho sách mẫu Quận 7',N'Địa chỉ giả lập chi nhánh 3, TP. Hồ Chí Minh',NULL,N'ACTIVE',N'2025-01-01',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Stores_3 int=SCOPE_IDENTITY();
INSERT dbo.[Stores] ([StoreCode],[StoreName],[Address],[Phone],[Status],[OpenedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-S4',N'Chi nhánh mẫu tạm nghỉ',N'Địa chỉ giả lập chi nhánh 4, TP. Hồ Chí Minh',NULL,N'TEMPORARILY_CLOSED',N'2025-01-01',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Stores_4 int=SCOPE_IDENTITY();
INSERT dbo.[Stores] ([StoreCode],[StoreName],[Address],[Phone],[Status],[OpenedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-S5',N'Chi nhánh mẫu đã đóng',N'Địa chỉ giả lập chi nhánh 5, TP. Hồ Chí Minh',NULL,N'CLOSED',N'2025-01-01',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Stores_5 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_manager1,@Stores_1,N'MANAGER',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_MANAGER1 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_staff1,@Stores_1,N'STAFF',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_STAFF1 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_manager2,@Stores_2,N'MANAGER',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_MANAGER2 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_staff2,@Stores_2,N'STAFF',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_STAFF2 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_manager3,@Stores_3,N'MANAGER',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_MANAGER3 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_staff3,@Stores_3,N'STAFF',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_STAFF3 int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_former,@Stores_1,N'STAFF',DATEADD(minute,-92160,@asof),DATEADD(minute,-28800,@asof),N'ENDED');
DECLARE @StaffStoreAssignments_former int=SCOPE_IDENTITY();
INSERT dbo.[StaffStoreAssignments] ([UserId],[StoreId],[StoreRole],[StartAt],[EndAt],[Status]) VALUES (@Users_lockedstaff,@Stores_2,N'STAFF',DATEADD(minute,-92160,@asof),NULL,N'ACTIVE');
DECLARE @StaffStoreAssignments_locked int=SCOPE_IDENTITY();
INSERT dbo.[CustomerAddresses] ([UserId],[RecipientName],[Phone],[AddressLine],[AdministrativeArea],[PostalCode],[CountryCode],[IsDefault],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer1,N'Người nhận mẫu 1',N'0000000000',N'Địa chỉ kiểm thử 1 (không giao hàng)',N'TP. Hồ Chí Minh',N'700000',N'VN',1,DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @CustomerAddresses_1 int=SCOPE_IDENTITY();
INSERT dbo.[CustomerAddresses] ([UserId],[RecipientName],[Phone],[AddressLine],[AdministrativeArea],[PostalCode],[CountryCode],[IsDefault],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer1,N'Người nhận mẫu 2',N'0000000000',N'Địa chỉ kiểm thử 2 (không giao hàng)',N'TP. Hồ Chí Minh',NULL,N'VN',0,DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @CustomerAddresses_2 int=SCOPE_IDENTITY();
INSERT dbo.[CustomerAddresses] ([UserId],[RecipientName],[Phone],[AddressLine],[AdministrativeArea],[PostalCode],[CountryCode],[IsDefault],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer2,N'Người nhận mẫu 3',N'0000000000',N'Địa chỉ kiểm thử 3 (không giao hàng)',N'TP. Hồ Chí Minh',N'700000',N'VN',1,DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @CustomerAddresses_3 int=SCOPE_IDENTITY();
INSERT dbo.[CustomerAddresses] ([UserId],[RecipientName],[Phone],[AddressLine],[AdministrativeArea],[PostalCode],[CountryCode],[IsDefault],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer3,N'Người nhận mẫu 4',N'0000000000',N'Địa chỉ kiểm thử 4 (không giao hàng)',N'TP. Hồ Chí Minh',N'700000',N'VN',1,DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @CustomerAddresses_4 int=SCOPE_IDENTITY();
INSERT dbo.[CustomerAddresses] ([UserId],[RecipientName],[Phone],[AddressLine],[AdministrativeArea],[PostalCode],[CountryCode],[IsDefault],[CreatedAt],[UpdatedAt]) VALUES (@Users_locked,N'Người nhận mẫu 5',N'0000000000',N'Địa chỉ kiểm thử 5 (không giao hàng)',N'TP. Hồ Chí Minh',N'700000',N'VN',1,DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @CustomerAddresses_5 int=SCOPE_IDENTITY();
INSERT dbo.[Suppliers] ([SupplierType],[SupplierName],[Phone],[Email],[Address],[LinkedUserId],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'INDIVIDUAL',N'DEMO - Nguồn thu mua 1',N'0000000000',N'supplier1@example.invalid',N'Địa chỉ thu mua giả lập',@Users_customer1,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Suppliers_1 int=SCOPE_IDENTITY();
INSERT dbo.[Suppliers] ([SupplierType],[SupplierName],[Phone],[Email],[Address],[LinkedUserId],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'INDIVIDUAL',N'DEMO - Nguồn thu mua 2',NULL,NULL,NULL,NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Suppliers_2 int=SCOPE_IDENTITY();
INSERT dbo.[Suppliers] ([SupplierType],[SupplierName],[Phone],[Email],[Address],[LinkedUserId],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'ORGANIZATION',N'DEMO - Nguồn thu mua 3',N'0000000000',N'supplier3@example.invalid',N'Địa chỉ thu mua giả lập',NULL,N'ACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Suppliers_3 int=SCOPE_IDENTITY();
INSERT dbo.[Suppliers] ([SupplierType],[SupplierName],[Phone],[Email],[Address],[LinkedUserId],[Status],[CreatedAt],[UpdatedAt]) VALUES (N'ORGANIZATION',N'DEMO - Nguồn thu mua 4',N'0000000000',N'supplier4@example.invalid',N'Địa chỉ thu mua giả lập',NULL,N'INACTIVE',DATEADD(minute,-93600,@asof),DATEADD(minute,-93600,@asof));
DECLARE @Suppliers_4 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceipts] ([ReceiptCode],[SupplierId],[StoreId],[CreatedBy],[Status],[TotalAmount],[ReceivedAt],[CreatedAt],[UpdatedAt],[Note]) VALUES (N'DEMO-IN-1',@Suppliers_1,@Stores_1,@Users_staff1,N'RECEIVED',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-86400,@asof),DATEADD(minute,-84960,@asof),N'Lô sách mẫu phục vụ kiểm thử, không phải tồn kho thực tế.');
DECLARE @PurchaseReceipts_1 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_0 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-001',1,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_0,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_0 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_0,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_0,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_0');
DECLARE @InventoryMovements_in_1_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_1 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-002',2,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_1,25000,55000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_1 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_1,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_1,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_1');
DECLARE @InventoryMovements_in_1_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_2 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-003',3,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_2,30000,60000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_2 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_2,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_2,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_2');
DECLARE @InventoryMovements_in_1_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,4,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_3 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-004',4,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_3,35000,65000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_3 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_3,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_3,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_3');
DECLARE @InventoryMovements_in_1_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,5,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_4 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-005',5,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_4,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_4 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_4,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_4,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_4');
DECLARE @InventoryMovements_in_1_4 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,6,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_5 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-006',6,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_5,45000,75000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_5 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_5,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_5,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_5');
DECLARE @InventoryMovements_in_1_5 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,7,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_6 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-007',7,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_6,50000,80000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_6 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_6,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_6,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_6');
DECLARE @InventoryMovements_in_1_6 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,8,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_7 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-008',8,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_7,55000,85000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_7 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_7,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_7,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_7');
DECLARE @InventoryMovements_in_1_7 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,9,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_8 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-009',9,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_8,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_8 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_8,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_8,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_8');
DECLARE @InventoryMovements_in_1_8 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,10,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_9 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-010',10,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_9,25000,55000,NULL,N'S1-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_9 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_9,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_9,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_9');
DECLARE @InventoryMovements_in_1_9 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,11,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_10 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-011',11,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_10,30000,60000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_10 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_10,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_10,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_10');
DECLARE @InventoryMovements_in_1_10 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,12,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_11 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-012',12,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_11,35000,65000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_11 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_11,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_11,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_11');
DECLARE @InventoryMovements_in_1_11 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,13,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_12 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-013',13,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_12,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_12 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_12,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_12,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_12');
DECLARE @InventoryMovements_in_1_12 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,14,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_13 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-014',14,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_13,45000,75000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_13 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_13,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_13,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_13');
DECLARE @InventoryMovements_in_1_13 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,15,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_14 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-015',15,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_14,50000,80000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_14 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_14,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_14,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_14');
DECLARE @InventoryMovements_in_1_14 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,16,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_15 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-016',16,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_15,55000,85000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_15 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_15,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_15,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_15');
DECLARE @InventoryMovements_in_1_15 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,17,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_16 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-017',17,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_16,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_16 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_16,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_16,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_16');
DECLARE @InventoryMovements_in_1_16 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,18,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_17 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-018',18,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_17,25000,55000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_17 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_17,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_17,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_17');
DECLARE @InventoryMovements_in_1_17 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,19,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_18 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-019',19,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_18,30000,60000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_18 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_18,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_18,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_18');
DECLARE @InventoryMovements_in_1_18 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,20,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_19 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-020',20,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_19,35000,65000,NULL,N'S1-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_19 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_19,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_19,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_19');
DECLARE @InventoryMovements_in_1_19 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,21,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,0,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_20 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-021',21,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_20,0,0,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_20 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_20,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_20,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_20');
DECLARE @InventoryMovements_in_1_20 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,22,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_21 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-022',22,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_21,45000,75000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_21 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_21,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_21,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_21');
DECLARE @InventoryMovements_in_1_21 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,23,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_22 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-023',23,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_22,50000,80000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_22 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_22,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_22,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_22');
DECLARE @InventoryMovements_in_1_22 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,24,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_23 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-024',24,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_23,55000,85000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_23 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_23,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_23,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_23');
DECLARE @InventoryMovements_in_1_23 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,25,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_24 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-025',25,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_24,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_24 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_24,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_24,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_24');
DECLARE @InventoryMovements_in_1_24 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,26,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_25 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-026',26,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_25,25000,55000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_25 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_25,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_25,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_25');
DECLARE @InventoryMovements_in_1_25 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,27,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_26 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-027',27,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_26,30000,60000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_26 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_26,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_26,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_26');
DECLARE @InventoryMovements_in_1_26 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,28,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_27 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-028',28,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_27,35000,65000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_27 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_27,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_27,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_27');
DECLARE @InventoryMovements_in_1_27 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,29,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_28 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-029',29,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_28,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_28 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_28,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_28,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_28');
DECLARE @InventoryMovements_in_1_28 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,30,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_29 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-030',30,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_29,45000,75000,NULL,N'S1-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_29 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_29,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_29,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_29');
DECLARE @InventoryMovements_in_1_29 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,31,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_30 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-031',31,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_30,50000,80000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_30 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_30,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_30,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_30');
DECLARE @InventoryMovements_in_1_30 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,32,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_31 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-032',32,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_31,55000,85000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_31 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_31,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_31,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_31');
DECLARE @InventoryMovements_in_1_31 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,33,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_32 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-033',33,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_32,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_32 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_32,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_32,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_32');
DECLARE @InventoryMovements_in_1_32 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,34,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_33 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-034',34,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_33,25000,55000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_33 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_33,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_33,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_33');
DECLARE @InventoryMovements_in_1_33 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,35,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_34 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-035',35,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_34,30000,60000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_34 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_34,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_34,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_34');
DECLARE @InventoryMovements_in_1_34 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,36,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_35 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-036',36,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_35,35000,65000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_35 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_35,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_35,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_35');
DECLARE @InventoryMovements_in_1_35 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,37,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_36 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-037',37,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_36,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_36 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_36,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_36,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_36');
DECLARE @InventoryMovements_in_1_36 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,38,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_37 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-038',38,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_37,45000,75000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_37 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_37,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_37,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_37');
DECLARE @InventoryMovements_in_1_37 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,39,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_38 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-039',39,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_38,50000,80000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_38 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_38,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_38,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_38');
DECLARE @InventoryMovements_in_1_38 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,40,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_39 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-040',40,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_39,55000,85000,NULL,N'S1-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_39 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_39,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_39,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_39');
DECLARE @InventoryMovements_in_1_39 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,41,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_40 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-041',41,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_40,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_40 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_40,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_40,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_40');
DECLARE @InventoryMovements_in_1_40 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,42,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_41 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-042',42,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_41,25000,55000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_41 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_41,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_41,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_41');
DECLARE @InventoryMovements_in_1_41 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,43,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_42 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-043',43,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_42,30000,60000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_42 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_42,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_42,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_42');
DECLARE @InventoryMovements_in_1_42 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,44,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_43 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-044',44,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_43,35000,65000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_43 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_43,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_43,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_43');
DECLARE @InventoryMovements_in_1_43 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,45,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_44 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-045',45,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_44,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_44 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_44,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_44,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_44');
DECLARE @InventoryMovements_in_1_44 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,46,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_45 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-046',46,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_45,45000,75000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_45 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_45,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_45,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_45');
DECLARE @InventoryMovements_in_1_45 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,47,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_46 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-047',47,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_46,50000,80000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_46 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_46,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_46,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_46');
DECLARE @InventoryMovements_in_1_46 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,48,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_47 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-048',48,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_47,55000,85000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_47 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_47,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_47,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_47');
DECLARE @InventoryMovements_in_1_47 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,49,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_48 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-049',49,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_48,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_48 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_48,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_48,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_48');
DECLARE @InventoryMovements_in_1_48 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,50,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_49 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-050',50,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_49,25000,55000,NULL,N'S1-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_49 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_49,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_49,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_49');
DECLARE @InventoryMovements_in_1_49 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,51,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_50 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-051',51,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_50,30000,60000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_50 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_50,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_50,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_50');
DECLARE @InventoryMovements_in_1_50 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,52,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_51 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-052',52,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_51,35000,65000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_51 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_51,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_51,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_51');
DECLARE @InventoryMovements_in_1_51 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,53,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_52 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-053',53,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_52,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_52 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_52,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_52,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_52');
DECLARE @InventoryMovements_in_1_52 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,54,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_53 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-054',54,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_53,45000,75000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_53 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_53,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_53,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_53');
DECLARE @InventoryMovements_in_1_53 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,55,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_54 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-055',55,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_54,50000,80000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_54 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_54,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_54,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_54');
DECLARE @InventoryMovements_in_1_54 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,56,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_55 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-056',56,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_55,55000,85000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_55 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_55,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_55,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_55');
DECLARE @InventoryMovements_in_1_55 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,57,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_56 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-057',57,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_56,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_56 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_56,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_56,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_56');
DECLARE @InventoryMovements_in_1_56 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,58,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_57 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-058',58,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_57,25000,55000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_57 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_57,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_57,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_57');
DECLARE @InventoryMovements_in_1_57 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,59,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_58 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-059',59,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_58,30000,60000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_58 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_58,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_58,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_58');
DECLARE @InventoryMovements_in_1_58 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,60,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_59 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-060',60,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_59,35000,65000,NULL,N'S1-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_59 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_59,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_59,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_59');
DECLARE @InventoryMovements_in_1_59 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,61,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_60 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-061',61,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_60,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_60 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_60,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_60,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_60');
DECLARE @InventoryMovements_in_1_60 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,62,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_61 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-062',62,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_61,45000,75000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_61 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_61,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_61,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_61');
DECLARE @InventoryMovements_in_1_61 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,63,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_62 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-063',63,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_62,50000,80000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_62 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_62,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_62,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_62');
DECLARE @InventoryMovements_in_1_62 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,64,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_63 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-064',64,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_63,55000,85000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_63 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_63,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_63,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_63');
DECLARE @InventoryMovements_in_1_63 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,65,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_64 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-065',65,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_64,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_64 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_64,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_64,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_64');
DECLARE @InventoryMovements_in_1_64 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,66,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_65 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-066',66,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_65,25000,55000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_65 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_65,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_65,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_65');
DECLARE @InventoryMovements_in_1_65 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,67,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_66 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-067',67,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_66,30000,60000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_66 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_66,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_66,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_66');
DECLARE @InventoryMovements_in_1_66 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,68,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_67 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-068',68,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_67,35000,65000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_67 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_67,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_67,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_67');
DECLARE @InventoryMovements_in_1_67 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,69,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_68 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-069',69,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_68,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_68 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_68,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_68,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_68');
DECLARE @InventoryMovements_in_1_68 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,70,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_69 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-070',70,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_69,45000,75000,NULL,N'S1-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_69 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_69,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_69,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_69');
DECLARE @InventoryMovements_in_1_69 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,71,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_70 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-071',71,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_70,50000,80000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_70 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_70,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_70,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_70');
DECLARE @InventoryMovements_in_1_70 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,72,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_71 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-072',72,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_71,55000,85000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_71 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_71,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_71,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_71');
DECLARE @InventoryMovements_in_1_71 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,73,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_72 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-073',73,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_72,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_72 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_72,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_72,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_72');
DECLARE @InventoryMovements_in_1_72 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,74,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_73 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-074',74,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_73,25000,55000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_73 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_73,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_73,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_73');
DECLARE @InventoryMovements_in_1_73 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,75,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_74 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-075',75,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_74,30000,60000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_74 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_74,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_74,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_74');
DECLARE @InventoryMovements_in_1_74 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,76,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_1_75 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-076',76,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_75,35000,65000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_75 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_75,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_75,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_75');
DECLARE @InventoryMovements_in_1_75 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,77,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_76 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-077',77,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_76,40000,70000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_76 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_76,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_76,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_76');
DECLARE @InventoryMovements_in_1_76 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,78,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_1_77 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-078',78,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_77,45000,75000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_77 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_77,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_77,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_77');
DECLARE @InventoryMovements_in_1_77 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,79,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_1_78 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-079',79,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_78,50000,80000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_78 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_78,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_78,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_78');
DECLARE @InventoryMovements_in_1_78 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,80,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_1_79 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-080',80,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_1_79,55000,85000,NULL,N'S1-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_79 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_79,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_79,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_79');
DECLARE @InventoryMovements_in_1_79 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,1002,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_1_80 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-081',1002,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_1_80,20000,50000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S1-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_80 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_80,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_80,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_80');
DECLARE @InventoryMovements_in_1_80 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,1003,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_1_81 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-082',1003,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_1_81,25000,55000,NULL,N'S1-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_81 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_81,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_81,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_81');
DECLARE @InventoryMovements_in_1_81 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_1,1004,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_1_82 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C1-083',1004,@Stores_1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_1_82,30000,60000,NULL,N'S1-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_1_82 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_82,NULL,@Stores_1,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff1,@PurchaseReceiptItems_1_82,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-1_82');
DECLARE @InventoryMovements_in_1_82 bigint=SCOPE_IDENTITY();
UPDATE dbo.[PurchaseReceipts] SET [TotalAmount]=3035000 WHERE [ReceiptId]=@PurchaseReceipts_1;
INSERT dbo.[PurchaseReceipts] ([ReceiptCode],[SupplierId],[StoreId],[CreatedBy],[Status],[TotalAmount],[ReceivedAt],[CreatedAt],[UpdatedAt],[Note]) VALUES (N'DEMO-IN-2',@Suppliers_2,@Stores_2,@Users_staff2,N'RECEIVED',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-86400,@asof),DATEADD(minute,-84960,@asof),N'Lô sách mẫu phục vụ kiểm thử, không phải tồn kho thực tế.');
DECLARE @PurchaseReceipts_2 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_0 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-001',1,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_0,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_0 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_0,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_0,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_0');
DECLARE @InventoryMovements_in_2_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_1 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-002',2,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_1,25000,60000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_1 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_1,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_1,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_1');
DECLARE @InventoryMovements_in_2_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_2 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-003',3,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_2,30000,65000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_2 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_2,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_2,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_2');
DECLARE @InventoryMovements_in_2_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,4,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_3 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-004',4,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_3,35000,70000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_3 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_3,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_3,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_3');
DECLARE @InventoryMovements_in_2_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,5,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_4 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-005',5,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_4,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_4 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_4,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_4,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_4');
DECLARE @InventoryMovements_in_2_4 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,6,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_5 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-006',6,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_5,45000,80000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_5 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_5,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_5,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_5');
DECLARE @InventoryMovements_in_2_5 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,7,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_6 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-007',7,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_6,50000,85000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_6 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_6,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_6,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_6');
DECLARE @InventoryMovements_in_2_6 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,8,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_7 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-008',8,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_7,55000,90000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_7 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_7,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_7,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_7');
DECLARE @InventoryMovements_in_2_7 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,9,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_8 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-009',9,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_8,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_8 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_8,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_8,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_8');
DECLARE @InventoryMovements_in_2_8 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,10,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_9 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-010',10,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_9,25000,60000,NULL,N'S2-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_9 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_9,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_9,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_9');
DECLARE @InventoryMovements_in_2_9 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,11,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_10 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-011',11,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_10,30000,65000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_10 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_10,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_10,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_10');
DECLARE @InventoryMovements_in_2_10 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,12,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_11 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-012',12,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_11,35000,70000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_11 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_11,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_11,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_11');
DECLARE @InventoryMovements_in_2_11 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,13,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_12 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-013',13,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_12,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_12 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_12,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_12,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_12');
DECLARE @InventoryMovements_in_2_12 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,14,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_13 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-014',14,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_13,45000,80000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_13 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_13,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_13,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_13');
DECLARE @InventoryMovements_in_2_13 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,15,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_14 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-015',15,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_14,50000,85000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_14 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_14,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_14,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_14');
DECLARE @InventoryMovements_in_2_14 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,16,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_15 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-016',16,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_15,55000,90000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_15 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_15,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_15,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_15');
DECLARE @InventoryMovements_in_2_15 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,17,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_16 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-017',17,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_16,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_16 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_16,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_16,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_16');
DECLARE @InventoryMovements_in_2_16 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,18,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_17 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-018',18,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_17,25000,60000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_17 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_17,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_17,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_17');
DECLARE @InventoryMovements_in_2_17 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,19,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_18 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-019',19,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_18,30000,65000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_18 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_18,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_18,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_18');
DECLARE @InventoryMovements_in_2_18 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,20,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_19 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-020',20,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_19,35000,70000,NULL,N'S2-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_19 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_19,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_19,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_19');
DECLARE @InventoryMovements_in_2_19 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,21,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_20 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-021',21,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_20,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_20 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_20,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_20,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_20');
DECLARE @InventoryMovements_in_2_20 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,22,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_21 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-022',22,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_21,45000,80000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_21 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_21,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_21,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_21');
DECLARE @InventoryMovements_in_2_21 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,23,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_22 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-023',23,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_22,50000,85000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_22 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_22,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_22,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_22');
DECLARE @InventoryMovements_in_2_22 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,24,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_23 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-024',24,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_23,55000,90000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_23 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_23,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_23,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_23');
DECLARE @InventoryMovements_in_2_23 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,25,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_24 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-025',25,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_24,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_24 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_24,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_24,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_24');
DECLARE @InventoryMovements_in_2_24 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,26,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_25 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-026',26,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_25,25000,60000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_25 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_25,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_25,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_25');
DECLARE @InventoryMovements_in_2_25 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,27,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_26 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-027',27,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_26,30000,65000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_26 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_26,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_26,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_26');
DECLARE @InventoryMovements_in_2_26 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,28,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_27 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-028',28,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_27,35000,70000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_27 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_27,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_27,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_27');
DECLARE @InventoryMovements_in_2_27 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,29,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_28 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-029',29,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_28,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_28 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_28,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_28,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_28');
DECLARE @InventoryMovements_in_2_28 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,30,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_29 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-030',30,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_29,45000,80000,NULL,N'S2-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_29 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_29,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_29,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_29');
DECLARE @InventoryMovements_in_2_29 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,31,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_30 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-031',31,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_30,50000,85000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_30 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_30,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_30,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_30');
DECLARE @InventoryMovements_in_2_30 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,32,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_31 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-032',32,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_31,55000,90000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_31 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_31,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_31,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_31');
DECLARE @InventoryMovements_in_2_31 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,33,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_32 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-033',33,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_32,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_32 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_32,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_32,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_32');
DECLARE @InventoryMovements_in_2_32 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,34,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_33 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-034',34,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_33,25000,60000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_33 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_33,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_33,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_33');
DECLARE @InventoryMovements_in_2_33 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,35,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_34 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-035',35,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_34,30000,65000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_34 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_34,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_34,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_34');
DECLARE @InventoryMovements_in_2_34 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,36,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_35 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-036',36,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_35,35000,70000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_35 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_35,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_35,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_35');
DECLARE @InventoryMovements_in_2_35 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,37,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_36 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-037',37,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_36,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_36 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_36,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_36,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_36');
DECLARE @InventoryMovements_in_2_36 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,38,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_37 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-038',38,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_37,45000,80000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_37 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_37,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_37,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_37');
DECLARE @InventoryMovements_in_2_37 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,39,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_38 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-039',39,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_38,50000,85000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_38 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_38,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_38,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_38');
DECLARE @InventoryMovements_in_2_38 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,40,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_39 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-040',40,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_39,55000,90000,NULL,N'S2-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_39 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_39,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_39,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_39');
DECLARE @InventoryMovements_in_2_39 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,41,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_40 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-041',41,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_40,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_40 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_40,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_40,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_40');
DECLARE @InventoryMovements_in_2_40 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,42,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_41 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-042',42,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_41,25000,60000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_41 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_41,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_41,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_41');
DECLARE @InventoryMovements_in_2_41 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,43,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_42 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-043',43,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_42,30000,65000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_42 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_42,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_42,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_42');
DECLARE @InventoryMovements_in_2_42 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,44,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_43 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-044',44,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_43,35000,70000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_43 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_43,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_43,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_43');
DECLARE @InventoryMovements_in_2_43 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,45,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_44 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-045',45,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_44,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_44 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_44,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_44,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_44');
DECLARE @InventoryMovements_in_2_44 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,46,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_45 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-046',46,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_45,45000,80000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_45 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_45,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_45,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_45');
DECLARE @InventoryMovements_in_2_45 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,47,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_46 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-047',47,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_46,50000,85000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_46 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_46,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_46,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_46');
DECLARE @InventoryMovements_in_2_46 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,48,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_47 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-048',48,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_47,55000,90000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_47 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_47,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_47,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_47');
DECLARE @InventoryMovements_in_2_47 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,49,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_48 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-049',49,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_48,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_48 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_48,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_48,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_48');
DECLARE @InventoryMovements_in_2_48 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,50,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_49 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-050',50,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_49,25000,60000,NULL,N'S2-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_49 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_49,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_49,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_49');
DECLARE @InventoryMovements_in_2_49 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,51,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_50 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-051',51,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_50,30000,65000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_50 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_50,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_50,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_50');
DECLARE @InventoryMovements_in_2_50 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,52,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_51 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-052',52,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_51,35000,70000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_51 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_51,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_51,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_51');
DECLARE @InventoryMovements_in_2_51 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,53,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_52 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-053',53,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_52,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_52 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_52,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_52,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_52');
DECLARE @InventoryMovements_in_2_52 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,54,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_53 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-054',54,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_53,45000,80000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_53 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_53,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_53,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_53');
DECLARE @InventoryMovements_in_2_53 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,55,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_54 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-055',55,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_54,50000,85000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_54 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_54,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_54,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_54');
DECLARE @InventoryMovements_in_2_54 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,56,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_55 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-056',56,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_55,55000,90000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_55 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_55,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_55,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_55');
DECLARE @InventoryMovements_in_2_55 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,57,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_56 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-057',57,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_56,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_56 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_56,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_56,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_56');
DECLARE @InventoryMovements_in_2_56 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,58,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_57 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-058',58,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_57,25000,60000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_57 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_57,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_57,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_57');
DECLARE @InventoryMovements_in_2_57 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,59,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_58 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-059',59,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_58,30000,65000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_58 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_58,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_58,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_58');
DECLARE @InventoryMovements_in_2_58 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,60,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_59 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-060',60,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_59,35000,70000,NULL,N'S2-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_59 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_59,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_59,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_59');
DECLARE @InventoryMovements_in_2_59 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,61,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_60 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-061',61,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_60,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_60 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_60,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_60,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_60');
DECLARE @InventoryMovements_in_2_60 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,62,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_61 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-062',62,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_61,45000,80000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_61 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_61,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_61,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_61');
DECLARE @InventoryMovements_in_2_61 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,63,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_62 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-063',63,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_62,50000,85000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_62 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_62,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_62,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_62');
DECLARE @InventoryMovements_in_2_62 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,64,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_63 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-064',64,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_63,55000,90000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_63 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_63,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_63,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_63');
DECLARE @InventoryMovements_in_2_63 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,65,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_64 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-065',65,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_64,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_64 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_64,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_64,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_64');
DECLARE @InventoryMovements_in_2_64 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,66,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_65 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-066',66,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_65,25000,60000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_65 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_65,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_65,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_65');
DECLARE @InventoryMovements_in_2_65 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,67,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_66 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-067',67,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_66,30000,65000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_66 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_66,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_66,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_66');
DECLARE @InventoryMovements_in_2_66 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,68,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_67 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-068',68,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_67,35000,70000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_67 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_67,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_67,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_67');
DECLARE @InventoryMovements_in_2_67 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,69,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_68 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-069',69,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_68,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_68 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_68,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_68,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_68');
DECLARE @InventoryMovements_in_2_68 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,70,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_69 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-070',70,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_69,45000,80000,NULL,N'S2-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_69 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_69,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_69,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_69');
DECLARE @InventoryMovements_in_2_69 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,71,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_70 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-071',71,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_70,50000,85000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_70 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_70,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_70,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_70');
DECLARE @InventoryMovements_in_2_70 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,72,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_71 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-072',72,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_71,55000,90000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_71 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_71,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_71,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_71');
DECLARE @InventoryMovements_in_2_71 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,73,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_72 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-073',73,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_72,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_72 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_72,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_72,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_72');
DECLARE @InventoryMovements_in_2_72 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,74,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_73 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-074',74,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_73,25000,60000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_73 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_73,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_73,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_73');
DECLARE @InventoryMovements_in_2_73 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,75,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_74 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-075',75,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_74,30000,65000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_74 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_74,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_74,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_74');
DECLARE @InventoryMovements_in_2_74 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,76,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_2_75 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-076',76,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_75,35000,70000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_75 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_75,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_75,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_75');
DECLARE @InventoryMovements_in_2_75 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,77,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_76 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-077',77,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_76,40000,75000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_76 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_76,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_76,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_76');
DECLARE @InventoryMovements_in_2_76 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,78,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_2_77 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-078',78,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_77,45000,80000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_77 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_77,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_77,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_77');
DECLARE @InventoryMovements_in_2_77 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,79,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_2_78 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-079',79,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_78,50000,85000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_78 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_78,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_78,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_78');
DECLARE @InventoryMovements_in_2_78 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,80,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_2_79 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-080',80,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_2_79,55000,90000,NULL,N'S2-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_79 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_79,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_79,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_79');
DECLARE @InventoryMovements_in_2_79 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,1002,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_2_80 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-081',1002,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_2_80,20000,55000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S2-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_80 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_80,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_80,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_80');
DECLARE @InventoryMovements_in_2_80 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,1003,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_2_81 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-082',1003,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_2_81,25000,60000,NULL,N'S2-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_81 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_81,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_81,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_81');
DECLARE @InventoryMovements_in_2_81 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_2,1004,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_2_82 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C2-083',1004,@Stores_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_2_82,30000,65000,NULL,N'S2-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_2_82 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_2_82,NULL,@Stores_2,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff2,@PurchaseReceiptItems_2_82,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-2_82');
DECLARE @InventoryMovements_in_2_82 bigint=SCOPE_IDENTITY();
UPDATE dbo.[PurchaseReceipts] SET [TotalAmount]=3075000 WHERE [ReceiptId]=@PurchaseReceipts_2;
INSERT dbo.[PurchaseReceipts] ([ReceiptCode],[SupplierId],[StoreId],[CreatedBy],[Status],[TotalAmount],[ReceivedAt],[CreatedAt],[UpdatedAt],[Note]) VALUES (N'DEMO-IN-3',@Suppliers_3,@Stores_3,@Users_staff3,N'RECEIVED',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-86400,@asof),DATEADD(minute,-84960,@asof),N'Lô sách mẫu phục vụ kiểm thử, không phải tồn kho thực tế.');
DECLARE @PurchaseReceipts_3 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_0 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-001',1,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_0,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_0 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_0,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_0,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_0');
DECLARE @InventoryMovements_in_3_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_1 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-002',2,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_1,25000,65000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_1 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_1,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_1,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_1');
DECLARE @InventoryMovements_in_3_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_2 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-003',3,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_2,30000,70000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_2 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_2,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_2,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_2');
DECLARE @InventoryMovements_in_3_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,4,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_3 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-004',4,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_3,35000,75000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_3 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_3,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_3,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_3');
DECLARE @InventoryMovements_in_3_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,5,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_4 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-005',5,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_4,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_4 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_4,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_4,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_4');
DECLARE @InventoryMovements_in_3_4 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,6,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_5 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-006',6,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_5,45000,85000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_5 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_5,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_5,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_5');
DECLARE @InventoryMovements_in_3_5 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,7,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_6 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-007',7,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_6,50000,90000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_6 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_6,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_6,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_6');
DECLARE @InventoryMovements_in_3_6 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,8,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_7 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-008',8,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_7,55000,95000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_7 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_7,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_7,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_7');
DECLARE @InventoryMovements_in_3_7 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,9,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_8 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-009',9,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_8,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_8 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_8,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_8,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_8');
DECLARE @InventoryMovements_in_3_8 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,10,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_9 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-010',10,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_9,25000,65000,NULL,N'S3-K1',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_9 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_9,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_9,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_9');
DECLARE @InventoryMovements_in_3_9 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,11,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_10 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-011',11,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_10,30000,70000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_10 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_10,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_10,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_10');
DECLARE @InventoryMovements_in_3_10 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,12,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_11 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-012',12,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_11,35000,75000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_11 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_11,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_11,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_11');
DECLARE @InventoryMovements_in_3_11 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,13,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_12 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-013',13,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_12,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_12 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_12,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_12,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_12');
DECLARE @InventoryMovements_in_3_12 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,14,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_13 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-014',14,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_13,45000,85000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_13 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_13,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_13,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_13');
DECLARE @InventoryMovements_in_3_13 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,15,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_14 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-015',15,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_14,50000,90000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_14 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_14,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_14,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_14');
DECLARE @InventoryMovements_in_3_14 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,16,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_15 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-016',16,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_15,55000,95000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_15 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_15,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_15,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_15');
DECLARE @InventoryMovements_in_3_15 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,17,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_16 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-017',17,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_16,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_16 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_16,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_16,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_16');
DECLARE @InventoryMovements_in_3_16 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,18,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_17 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-018',18,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_17,25000,65000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_17 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_17,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_17,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_17');
DECLARE @InventoryMovements_in_3_17 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,19,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_18 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-019',19,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_18,30000,70000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_18 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_18,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_18,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_18');
DECLARE @InventoryMovements_in_3_18 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,20,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_19 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-020',20,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_19,35000,75000,NULL,N'S3-K2',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_19 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_19,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_19,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_19');
DECLARE @InventoryMovements_in_3_19 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,21,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_20 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-021',21,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_20,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_20 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_20,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_20,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_20');
DECLARE @InventoryMovements_in_3_20 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,22,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_21 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-022',22,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_21,45000,85000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_21 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_21,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_21,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_21');
DECLARE @InventoryMovements_in_3_21 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,23,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_22 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-023',23,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_22,50000,90000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_22 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_22,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_22,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_22');
DECLARE @InventoryMovements_in_3_22 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,24,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_23 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-024',24,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_23,55000,95000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_23 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_23,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_23,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_23');
DECLARE @InventoryMovements_in_3_23 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,25,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_24 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-025',25,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_24,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_24 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_24,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_24,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_24');
DECLARE @InventoryMovements_in_3_24 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,26,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_25 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-026',26,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_25,25000,65000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_25 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_25,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_25,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_25');
DECLARE @InventoryMovements_in_3_25 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,27,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_26 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-027',27,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_26,30000,70000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_26 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_26,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_26,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_26');
DECLARE @InventoryMovements_in_3_26 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,28,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_27 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-028',28,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_27,35000,75000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_27 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_27,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_27,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_27');
DECLARE @InventoryMovements_in_3_27 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,29,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_28 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-029',29,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_28,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_28 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_28,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_28,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_28');
DECLARE @InventoryMovements_in_3_28 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,30,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_29 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-030',30,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_29,45000,85000,NULL,N'S3-K3',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_29 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_29,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_29,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_29');
DECLARE @InventoryMovements_in_3_29 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,31,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_30 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-031',31,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_30,50000,90000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_30 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_30,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_30,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_30');
DECLARE @InventoryMovements_in_3_30 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,32,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_31 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-032',32,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_31,55000,95000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_31 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_31,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_31,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_31');
DECLARE @InventoryMovements_in_3_31 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,33,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_32 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-033',33,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_32,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_32 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_32,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_32,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_32');
DECLARE @InventoryMovements_in_3_32 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,34,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_33 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-034',34,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_33,25000,65000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_33 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_33,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_33,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_33');
DECLARE @InventoryMovements_in_3_33 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,35,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_34 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-035',35,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_34,30000,70000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_34 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_34,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_34,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_34');
DECLARE @InventoryMovements_in_3_34 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,36,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_35 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-036',36,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_35,35000,75000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_35 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_35,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_35,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_35');
DECLARE @InventoryMovements_in_3_35 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,37,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_36 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-037',37,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_36,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_36 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_36,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_36,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_36');
DECLARE @InventoryMovements_in_3_36 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,38,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_37 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-038',38,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_37,45000,85000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_37 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_37,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_37,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_37');
DECLARE @InventoryMovements_in_3_37 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,39,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_38 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-039',39,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_38,50000,90000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_38 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_38,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_38,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_38');
DECLARE @InventoryMovements_in_3_38 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,40,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_39 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-040',40,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_39,55000,95000,NULL,N'S3-K4',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_39 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_39,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_39,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_39');
DECLARE @InventoryMovements_in_3_39 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,41,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_40 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-041',41,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_40,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_40 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_40,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_40,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_40');
DECLARE @InventoryMovements_in_3_40 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,42,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_41 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-042',42,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_41,25000,65000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_41 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_41,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_41,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_41');
DECLARE @InventoryMovements_in_3_41 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,43,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_42 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-043',43,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_42,30000,70000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_42 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_42,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_42,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_42');
DECLARE @InventoryMovements_in_3_42 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,44,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_43 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-044',44,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_43,35000,75000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_43 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_43,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_43,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_43');
DECLARE @InventoryMovements_in_3_43 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,45,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_44 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-045',45,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_44,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_44 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_44,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_44,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_44');
DECLARE @InventoryMovements_in_3_44 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,46,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_45 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-046',46,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_45,45000,85000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_45 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_45,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_45,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_45');
DECLARE @InventoryMovements_in_3_45 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,47,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_46 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-047',47,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_46,50000,90000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_46 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_46,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_46,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_46');
DECLARE @InventoryMovements_in_3_46 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,48,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_47 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-048',48,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_47,55000,95000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_47 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_47,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_47,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_47');
DECLARE @InventoryMovements_in_3_47 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,49,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_48 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-049',49,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_48,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_48 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_48,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_48,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_48');
DECLARE @InventoryMovements_in_3_48 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,50,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_49 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-050',50,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_49,25000,65000,NULL,N'S3-K5',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_49 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_49,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_49,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_49');
DECLARE @InventoryMovements_in_3_49 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,51,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_50 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-051',51,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_50,30000,70000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_50 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_50,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_50,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_50');
DECLARE @InventoryMovements_in_3_50 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,52,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_51 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-052',52,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_51,35000,75000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_51 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_51,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_51,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_51');
DECLARE @InventoryMovements_in_3_51 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,53,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_52 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-053',53,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_52,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_52 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_52,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_52,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_52');
DECLARE @InventoryMovements_in_3_52 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,54,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_53 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-054',54,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_53,45000,85000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_53 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_53,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_53,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_53');
DECLARE @InventoryMovements_in_3_53 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,55,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_54 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-055',55,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_54,50000,90000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_54 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_54,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_54,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_54');
DECLARE @InventoryMovements_in_3_54 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,56,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_55 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-056',56,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_55,55000,95000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_55 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_55,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_55,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_55');
DECLARE @InventoryMovements_in_3_55 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,57,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_56 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-057',57,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_56,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_56 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_56,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_56,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_56');
DECLARE @InventoryMovements_in_3_56 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,58,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_57 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-058',58,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_57,25000,65000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_57 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_57,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_57,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_57');
DECLARE @InventoryMovements_in_3_57 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,59,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_58 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-059',59,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_58,30000,70000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_58 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_58,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_58,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_58');
DECLARE @InventoryMovements_in_3_58 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,60,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_59 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-060',60,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_59,35000,75000,NULL,N'S3-K6',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_59 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_59,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_59,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_59');
DECLARE @InventoryMovements_in_3_59 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,61,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_60 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-061',61,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_60,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_60 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_60,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_60,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_60');
DECLARE @InventoryMovements_in_3_60 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,62,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_61 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-062',62,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_61,45000,85000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_61 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_61,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_61,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_61');
DECLARE @InventoryMovements_in_3_61 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,63,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_62 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-063',63,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_62,50000,90000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_62 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_62,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_62,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_62');
DECLARE @InventoryMovements_in_3_62 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,64,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_63 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-064',64,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_63,55000,95000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_63 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_63,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_63,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_63');
DECLARE @InventoryMovements_in_3_63 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,65,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_64 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-065',65,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_64,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_64 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_64,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_64,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_64');
DECLARE @InventoryMovements_in_3_64 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,66,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_65 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-066',66,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_65,25000,65000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_65 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_65,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_65,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_65');
DECLARE @InventoryMovements_in_3_65 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,67,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_66 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-067',67,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_66,30000,70000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_66 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_66,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_66,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_66');
DECLARE @InventoryMovements_in_3_66 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,68,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_67 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-068',68,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_67,35000,75000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_67 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_67,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_67,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_67');
DECLARE @InventoryMovements_in_3_67 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,69,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_68 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-069',69,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_68,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_68 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_68,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_68,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_68');
DECLARE @InventoryMovements_in_3_68 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,70,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_69 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-070',70,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_69,45000,85000,NULL,N'S3-K7',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_69 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_69,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_69,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_69');
DECLARE @InventoryMovements_in_3_69 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,71,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_70 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-071',71,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_70,50000,90000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_70 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_70,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_70,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_70');
DECLARE @InventoryMovements_in_3_70 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,72,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_71 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-072',72,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_71,55000,95000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_71 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_71,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_71,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_71');
DECLARE @InventoryMovements_in_3_71 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,73,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_72 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-073',73,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_72,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_72 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_72,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_72,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_72');
DECLARE @InventoryMovements_in_3_72 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,74,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_73 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-074',74,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_73,25000,65000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_73 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_73,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_73,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_73');
DECLARE @InventoryMovements_in_3_73 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,75,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_74 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-075',75,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_74,30000,70000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_74 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_74,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_74,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_74');
DECLARE @InventoryMovements_in_3_74 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,76,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,35000,NULL);
DECLARE @PurchaseReceiptItems_3_75 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-076',76,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_75,35000,75000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_75 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_75,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_75,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_75');
DECLARE @InventoryMovements_in_3_75 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,77,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,40000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_76 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-077',77,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_76,40000,80000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_76 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_76,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_76,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_76');
DECLARE @InventoryMovements_in_3_76 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,78,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,45000,NULL);
DECLARE @PurchaseReceiptItems_3_77 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-078',78,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_77,45000,85000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_77 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_77,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_77,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_77');
DECLARE @InventoryMovements_in_3_77 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,79,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,50000,NULL);
DECLARE @PurchaseReceiptItems_3_78 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-079',79,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_78,50000,90000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_78 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_78,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_78,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_78');
DECLARE @InventoryMovements_in_3_78 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,80,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),1,55000,NULL);
DECLARE @PurchaseReceiptItems_3_79 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-080',80,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),@PurchaseReceiptItems_3_79,55000,95000,NULL,N'S3-K8',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_79 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_79,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_79,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_79');
DECLARE @InventoryMovements_in_3_79 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,1002,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),1,20000,N'Bản mẫu có ghi chú tình trạng');
DECLARE @PurchaseReceiptItems_3_80 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-081',1002,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),@PurchaseReceiptItems_3_80,20000,60000,N'Mẫu: có ghi chú bằng bút chì ở trang đầu',N'S3-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_80 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_80,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_80,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_80');
DECLARE @InventoryMovements_in_3_80 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,1003,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),1,25000,NULL);
DECLARE @PurchaseReceiptItems_3_81 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-082',1003,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),@PurchaseReceiptItems_3_81,25000,65000,NULL,N'S3-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_81 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_81,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_81,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_81');
DECLARE @InventoryMovements_in_3_81 bigint=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_3,1004,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),1,30000,NULL);
DECLARE @PurchaseReceiptItems_3_82 int=SCOPE_IDENTITY();
INSERT dbo.[BookCopies] ([CopyCode],[BookId],[StoreId],[ConditionId],[PurchaseReceiptItemId],[CostPrice],[SalePrice],[ConditionNotes],[ShelfLocation],[Status],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-C3-083',1004,@Stores_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),@PurchaseReceiptItems_3_82,30000,70000,NULL,N'S3-K9',N'AVAILABLE',0,DATEADD(minute,-84960,@asof),DATEADD(minute,-84960,@asof));
DECLARE @BookCopies_3_82 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[ReceiptItemId],[Reason],[OperationKey]) VALUES (@BookCopies_3_82,NULL,@Stores_3,N'RECEIPT',DATEADD(minute,-84960,@asof),@Users_staff3,@PurchaseReceiptItems_3_82,N'DEMO: nhận sách vào kho',N'DEMO-RECEIPT-3_82');
DECLARE @InventoryMovements_in_3_82 bigint=SCOPE_IDENTITY();
UPDATE dbo.[PurchaseReceipts] SET [TotalAmount]=3075000 WHERE [ReceiptId]=@PurchaseReceipts_3;
INSERT dbo.[PurchaseReceipts] ([ReceiptCode],[SupplierId],[StoreId],[CreatedBy],[Status],[TotalAmount],[ReceivedAt],[CreatedAt],[UpdatedAt],[Note]) VALUES (N'DEMO-IN-4',@Suppliers_2,@Stores_1,@Users_staff1,N'DRAFT',90000,NULL,DATEADD(minute,-2880,@asof),DATEADD(minute,-1440,@asof),N'Chưa nhận hàng');
DECLARE @PurchaseReceipts_4 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_4,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),3,15000,NULL);
DECLARE @PurchaseReceiptItems_4_0 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_4,2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),3,15000,NULL);
DECLARE @PurchaseReceiptItems_4_1 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceipts] ([ReceiptCode],[SupplierId],[StoreId],[CreatedBy],[Status],[TotalAmount],[ReceivedAt],[CreatedAt],[UpdatedAt],[Note]) VALUES (N'DEMO-IN-5',@Suppliers_2,@Stores_1,@Users_staff1,N'CANCELLED',90000,NULL,DATEADD(minute,-2880,@asof),DATEADD(minute,-1440,@asof),N'Hủy trước khi nhận hàng');
DECLARE @PurchaseReceipts_5 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_5,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),3,15000,NULL);
DECLARE @PurchaseReceiptItems_5_0 int=SCOPE_IDENTITY();
INSERT dbo.[PurchaseReceiptItems] ([ReceiptId],[BookId],[ConditionId],[Quantity],[UnitCost],[Note]) VALUES (@PurchaseReceipts_5,2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),3,15000,NULL);
DECLARE @PurchaseReceiptItems_5_1 int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-POS-CASH',@Stores_1,@Users_customer1,@Users_staff1,N'POS',N'COMPLETED',NULL,NULL,NULL,105000,5000,0,100000,1,DATEADD(minute,-50400,@asof),DATEADD(minute,-50340,@asof));
DECLARE @Orders_POS_CASH int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_POS_CASH,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-50400,@asof),N'DEMO: POS-CASH / PENDING');
DECLARE @OrderStatusHistory_POS_CASH_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_POS_CASH,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-50340,@asof),N'DEMO: POS-CASH / CONFIRMED');
DECLARE @OrderStatusHistory_POS_CASH_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_POS_CASH,N'CONFIRMED',N'COMPLETED',@Users_staff1,DATEADD(minute,-50280,@asof),N'DEMO: POS-CASH / COMPLETED');
DECLARE @OrderStatusHistory_POS_CASH_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-50280,@asof),[Version]=2 WHERE [OrderId]=@Orders_POS_CASH;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_POS_CASH,@BookCopies_1_0,N'Truyện Kiều',N'LIKE_NEW',50000,20000,5000,45000);
DECLARE @OrderItems_POS_CASH_0 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_0,@Stores_1,NULL,N'SALE',DATEADD(minute,-50280,@asof),@Users_staff1,@OrderItems_POS_CASH_0,N'DEMO: xuất bán',N'DEMO-SALE-POS-CASH-0');
DECLARE @InventoryMovements_sale_POS_CASH_0 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-50280,@asof) WHERE [CopyId]=@BookCopies_1_0;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_POS_CASH,@BookCopies_1_1,N'Số đỏ',N'GOOD',55000,25000,0,55000);
DECLARE @OrderItems_POS_CASH_1 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_1,@Stores_1,NULL,N'SALE',DATEADD(minute,-50280,@asof),@Users_staff1,@OrderItems_POS_CASH_1,N'DEMO: xuất bán',N'DEMO-SALE-POS-CASH-1');
DECLARE @InventoryMovements_sale_POS_CASH_1 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-50280,@asof) WHERE [CopyId]=@BookCopies_1_1;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_POS_CASH,N'CASH',N'DEMO_CASH',100000,N'VND',N'SUCCEEDED',N'DEMO-TXN-POS-CASH',N'DEMO-PAY-POS-CASH',DATEADD(minute,-50340,@asof),DATEADD(minute,-50400,@asof));
DECLARE @Payments_POS_CASH int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-PARTIAL-RETURN',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',60000,0,20000,80000,1,DATEADD(minute,-43200,@asof),DATEADD(minute,-43140,@asof));
DECLARE @Orders_PARTIAL_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PARTIAL_RETURN,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-43200,@asof),N'DEMO: PARTIAL-RETURN / PENDING');
DECLARE @OrderStatusHistory_PARTIAL_RETURN_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PARTIAL_RETURN,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-43140,@asof),N'DEMO: PARTIAL-RETURN / CONFIRMED');
DECLARE @OrderStatusHistory_PARTIAL_RETURN_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PARTIAL_RETURN,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-43080,@asof),N'DEMO: PARTIAL-RETURN / PROCESSING');
DECLARE @OrderStatusHistory_PARTIAL_RETURN_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PARTIAL_RETURN,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-43020,@asof),N'DEMO: PARTIAL-RETURN / SHIPPED');
DECLARE @OrderStatusHistory_PARTIAL_RETURN_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PARTIAL_RETURN,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-42960,@asof),N'DEMO: PARTIAL-RETURN / COMPLETED');
DECLARE @OrderStatusHistory_PARTIAL_RETURN_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-42960,@asof),[Version]=4 WHERE [OrderId]=@Orders_PARTIAL_RETURN;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_PARTIAL_RETURN,@BookCopies_1_2,N'Chí Phèo',N'FAIR',60000,30000,0,60000);
DECLARE @OrderItems_PARTIAL_RETURN_2 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_2,@Orders_PARTIAL_RETURN,N'CONSUMED',DATEADD(minute,-43200,@asof),DATEADD(minute,-41760,@asof),DATEADD(minute,-42960,@asof));
DECLARE @StockReservations_PARTIAL_RETURN_2 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_2,@Stores_1,NULL,N'SALE',DATEADD(minute,-43020,@asof),@Users_staff1,@OrderItems_PARTIAL_RETURN_2,N'DEMO: xuất bán',N'DEMO-SALE-PARTIAL-RETURN-2');
DECLARE @InventoryMovements_sale_PARTIAL_RETURN_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-43020,@asof) WHERE [CopyId]=@BookCopies_1_2;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_PARTIAL_RETURN,N'BANK_TRANSFER',N'DEMO_GATEWAY',80000,N'VND',N'SUCCEEDED',N'DEMO-TXN-PARTIAL-RETURN',N'DEMO-PAY-PARTIAL-RETURN',DATEADD(minute,-43140,@asof),DATEADD(minute,-43200,@asof));
DECLARE @Payments_PARTIAL_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-DAMAGED-RETURN',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',65000,0,20000,85000,1,DATEADD(minute,-41760,@asof),DATEADD(minute,-41700,@asof));
DECLARE @Orders_DAMAGED_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_DAMAGED_RETURN,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-41760,@asof),N'DEMO: DAMAGED-RETURN / PENDING');
DECLARE @OrderStatusHistory_DAMAGED_RETURN_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_DAMAGED_RETURN,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-41700,@asof),N'DEMO: DAMAGED-RETURN / CONFIRMED');
DECLARE @OrderStatusHistory_DAMAGED_RETURN_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_DAMAGED_RETURN,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-41640,@asof),N'DEMO: DAMAGED-RETURN / PROCESSING');
DECLARE @OrderStatusHistory_DAMAGED_RETURN_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_DAMAGED_RETURN,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-41580,@asof),N'DEMO: DAMAGED-RETURN / SHIPPED');
DECLARE @OrderStatusHistory_DAMAGED_RETURN_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_DAMAGED_RETURN,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-41520,@asof),N'DEMO: DAMAGED-RETURN / COMPLETED');
DECLARE @OrderStatusHistory_DAMAGED_RETURN_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-41520,@asof),[Version]=4 WHERE [OrderId]=@Orders_DAMAGED_RETURN;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_DAMAGED_RETURN,@BookCopies_1_3,N'Tắt đèn',N'WORN',65000,35000,0,65000);
DECLARE @OrderItems_DAMAGED_RETURN_3 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_3,@Orders_DAMAGED_RETURN,N'CONSUMED',DATEADD(minute,-41760,@asof),DATEADD(minute,-40320,@asof),DATEADD(minute,-41520,@asof));
DECLARE @StockReservations_DAMAGED_RETURN_3 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_3,@Stores_1,NULL,N'SALE',DATEADD(minute,-41580,@asof),@Users_staff1,@OrderItems_DAMAGED_RETURN_3,N'DEMO: xuất bán',N'DEMO-SALE-DAMAGED-RETURN-3');
DECLARE @InventoryMovements_sale_DAMAGED_RETURN_3 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-41580,@asof) WHERE [CopyId]=@BookCopies_1_3;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_DAMAGED_RETURN,N'E_WALLET',N'DEMO_GATEWAY',85000,N'VND',N'SUCCEEDED',N'DEMO-TXN-DAMAGED-RETURN',N'DEMO-PAY-DAMAGED-RETURN',DATEADD(minute,-41700,@asof),DATEADD(minute,-41760,@asof));
DECLARE @Payments_DAMAGED_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-RETURN-REQUESTED',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',70000,0,20000,90000,1,DATEADD(minute,-40320,@asof),DATEADD(minute,-40260,@asof));
DECLARE @Orders_RETURN_REQUESTED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REQUESTED,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-40320,@asof),N'DEMO: RETURN-REQUESTED / PENDING');
DECLARE @OrderStatusHistory_RETURN_REQUESTED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REQUESTED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-40260,@asof),N'DEMO: RETURN-REQUESTED / CONFIRMED');
DECLARE @OrderStatusHistory_RETURN_REQUESTED_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REQUESTED,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-40200,@asof),N'DEMO: RETURN-REQUESTED / PROCESSING');
DECLARE @OrderStatusHistory_RETURN_REQUESTED_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REQUESTED,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-40140,@asof),N'DEMO: RETURN-REQUESTED / SHIPPED');
DECLARE @OrderStatusHistory_RETURN_REQUESTED_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REQUESTED,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-40080,@asof),N'DEMO: RETURN-REQUESTED / COMPLETED');
DECLARE @OrderStatusHistory_RETURN_REQUESTED_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-40080,@asof),[Version]=4 WHERE [OrderId]=@Orders_RETURN_REQUESTED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_RETURN_REQUESTED,@BookCopies_1_4,N'Vợ nhặt',N'LIKE_NEW',70000,40000,0,70000);
DECLARE @OrderItems_RETURN_REQUESTED_4 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_4,@Orders_RETURN_REQUESTED,N'CONSUMED',DATEADD(minute,-40320,@asof),DATEADD(minute,-38880,@asof),DATEADD(minute,-40080,@asof));
DECLARE @StockReservations_RETURN_REQUESTED_4 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_4,@Stores_1,NULL,N'SALE',DATEADD(minute,-40140,@asof),@Users_staff1,@OrderItems_RETURN_REQUESTED_4,N'DEMO: xuất bán',N'DEMO-SALE-RETURN-REQUESTED-4');
DECLARE @InventoryMovements_sale_RETURN_REQUESTED_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-40140,@asof) WHERE [CopyId]=@BookCopies_1_4;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_RETURN_REQUESTED,N'CARD',N'DEMO_GATEWAY',90000,N'VND',N'SUCCEEDED',N'DEMO-TXN-RETURN-REQUESTED',N'DEMO-PAY-RETURN-REQUESTED',DATEADD(minute,-40260,@asof),DATEADD(minute,-40320,@asof));
DECLARE @Payments_RETURN_REQUESTED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-RETURN-REJECTED',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',75000,0,20000,95000,1,DATEADD(minute,-38880,@asof),DATEADD(minute,-38820,@asof));
DECLARE @Orders_RETURN_REJECTED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REJECTED,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-38880,@asof),N'DEMO: RETURN-REJECTED / PENDING');
DECLARE @OrderStatusHistory_RETURN_REJECTED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REJECTED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-38820,@asof),N'DEMO: RETURN-REJECTED / CONFIRMED');
DECLARE @OrderStatusHistory_RETURN_REJECTED_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REJECTED,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-38760,@asof),N'DEMO: RETURN-REJECTED / PROCESSING');
DECLARE @OrderStatusHistory_RETURN_REJECTED_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REJECTED,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-38700,@asof),N'DEMO: RETURN-REJECTED / SHIPPED');
DECLARE @OrderStatusHistory_RETURN_REJECTED_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_REJECTED,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-38640,@asof),N'DEMO: RETURN-REJECTED / COMPLETED');
DECLARE @OrderStatusHistory_RETURN_REJECTED_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-38640,@asof),[Version]=4 WHERE [OrderId]=@Orders_RETURN_REJECTED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_RETURN_REJECTED,@BookCopies_1_5,N'Dế Mèn phiêu lưu ký',N'GOOD',75000,45000,0,75000);
DECLARE @OrderItems_RETURN_REJECTED_5 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_5,@Orders_RETURN_REJECTED,N'CONSUMED',DATEADD(minute,-38880,@asof),DATEADD(minute,-37440,@asof),DATEADD(minute,-38640,@asof));
DECLARE @StockReservations_RETURN_REJECTED_5 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_5,@Stores_1,NULL,N'SALE',DATEADD(minute,-38700,@asof),@Users_staff1,@OrderItems_RETURN_REJECTED_5,N'DEMO: xuất bán',N'DEMO-SALE-RETURN-REJECTED-5');
DECLARE @InventoryMovements_sale_RETURN_REJECTED_5 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-38700,@asof) WHERE [CopyId]=@BookCopies_1_5;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_RETURN_REJECTED,N'COD',N'DEMO_GATEWAY',95000,N'VND',N'SUCCEEDED',N'DEMO-TXN-RETURN-REJECTED',N'DEMO-PAY-RETURN-REJECTED',DATEADD(minute,-38640,@asof),DATEADD(minute,-38880,@asof));
DECLARE @Payments_RETURN_REJECTED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-RETURN-APPROVED',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',80000,0,20000,100000,1,DATEADD(minute,-37440,@asof),DATEADD(minute,-37380,@asof));
DECLARE @Orders_RETURN_APPROVED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_APPROVED,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-37440,@asof),N'DEMO: RETURN-APPROVED / PENDING');
DECLARE @OrderStatusHistory_RETURN_APPROVED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_APPROVED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-37380,@asof),N'DEMO: RETURN-APPROVED / CONFIRMED');
DECLARE @OrderStatusHistory_RETURN_APPROVED_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_APPROVED,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-37320,@asof),N'DEMO: RETURN-APPROVED / PROCESSING');
DECLARE @OrderStatusHistory_RETURN_APPROVED_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_APPROVED,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-37260,@asof),N'DEMO: RETURN-APPROVED / SHIPPED');
DECLARE @OrderStatusHistory_RETURN_APPROVED_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_APPROVED,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-37200,@asof),N'DEMO: RETURN-APPROVED / COMPLETED');
DECLARE @OrderStatusHistory_RETURN_APPROVED_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-37200,@asof),[Version]=4 WHERE [OrderId]=@Orders_RETURN_APPROVED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_RETURN_APPROVED,@BookCopies_1_6,N'Nỗi buồn chiến tranh',N'FAIR',80000,50000,0,80000);
DECLARE @OrderItems_RETURN_APPROVED_6 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_6,@Orders_RETURN_APPROVED,N'CONSUMED',DATEADD(minute,-37440,@asof),DATEADD(minute,-36000,@asof),DATEADD(minute,-37200,@asof));
DECLARE @StockReservations_RETURN_APPROVED_6 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_6,@Stores_1,NULL,N'SALE',DATEADD(minute,-37260,@asof),@Users_staff1,@OrderItems_RETURN_APPROVED_6,N'DEMO: xuất bán',N'DEMO-SALE-RETURN-APPROVED-6');
DECLARE @InventoryMovements_sale_RETURN_APPROVED_6 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-37260,@asof) WHERE [CopyId]=@BookCopies_1_6;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_RETURN_APPROVED,N'BANK_TRANSFER',N'DEMO_GATEWAY',100000,N'VND',N'SUCCEEDED',N'DEMO-TXN-RETURN-APPROVED',N'DEMO-PAY-RETURN-APPROVED',DATEADD(minute,-37380,@asof),DATEADD(minute,-37440,@asof));
DECLARE @Payments_RETURN_APPROVED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-RETURN-CANCELLED',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',85000,0,20000,105000,1,DATEADD(minute,-36000,@asof),DATEADD(minute,-35940,@asof));
DECLARE @Orders_RETURN_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_CANCELLED,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-36000,@asof),N'DEMO: RETURN-CANCELLED / PENDING');
DECLARE @OrderStatusHistory_RETURN_CANCELLED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_CANCELLED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-35940,@asof),N'DEMO: RETURN-CANCELLED / CONFIRMED');
DECLARE @OrderStatusHistory_RETURN_CANCELLED_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_CANCELLED,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-35880,@asof),N'DEMO: RETURN-CANCELLED / PROCESSING');
DECLARE @OrderStatusHistory_RETURN_CANCELLED_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_CANCELLED,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-35820,@asof),N'DEMO: RETURN-CANCELLED / SHIPPED');
DECLARE @OrderStatusHistory_RETURN_CANCELLED_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RETURN_CANCELLED,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-35760,@asof),N'DEMO: RETURN-CANCELLED / COMPLETED');
DECLARE @OrderStatusHistory_RETURN_CANCELLED_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-35760,@asof),[Version]=4 WHERE [OrderId]=@Orders_RETURN_CANCELLED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_RETURN_CANCELLED,@BookCopies_1_7,N'Cánh đồng bất tận',N'WORN',85000,55000,0,85000);
DECLARE @OrderItems_RETURN_CANCELLED_7 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_7,@Orders_RETURN_CANCELLED,N'CONSUMED',DATEADD(minute,-36000,@asof),DATEADD(minute,-34560,@asof),DATEADD(minute,-35760,@asof));
DECLARE @StockReservations_RETURN_CANCELLED_7 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_7,@Stores_1,NULL,N'SALE',DATEADD(minute,-35820,@asof),@Users_staff1,@OrderItems_RETURN_CANCELLED_7,N'DEMO: xuất bán',N'DEMO-SALE-RETURN-CANCELLED-7');
DECLARE @InventoryMovements_sale_RETURN_CANCELLED_7 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-35820,@asof) WHERE [CopyId]=@BookCopies_1_7;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_RETURN_CANCELLED,N'CARD',N'DEMO_GATEWAY',105000,N'VND',N'SUCCEEDED',N'DEMO-TXN-RETURN-CANCELLED',N'DEMO-PAY-RETURN-CANCELLED',DATEADD(minute,-35940,@asof),DATEADD(minute,-36000,@asof));
DECLARE @Payments_RETURN_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-HOLD-ACTIVE',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'PENDING',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',50000,0,20000,70000,1,DATEADD(minute,-20,@asof),DATEADD(minute,-15,@asof));
DECLARE @Orders_HOLD_ACTIVE int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_HOLD_ACTIVE,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-20,@asof),N'DEMO: HOLD-ACTIVE / PENDING');
DECLARE @OrderStatusHistory_HOLD_ACTIVE_0 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-20,@asof),[Version]=0 WHERE [OrderId]=@Orders_HOLD_ACTIVE;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_HOLD_ACTIVE,@BookCopies_1_8,N'Pride and Prejudice',N'LIKE_NEW',50000,20000,0,50000);
DECLARE @OrderItems_HOLD_ACTIVE_8 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_8,@Orders_HOLD_ACTIVE,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,30,@asof),NULL);
DECLARE @StockReservations_HOLD_ACTIVE_8 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_8;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_HOLD_ACTIVE,N'CARD',N'DEMO_GATEWAY',70000,N'VND',N'PENDING',NULL,N'DEMO-PAY-HOLD-ACTIVE',NULL,DATEADD(minute,-20,@asof));
DECLARE @Payments_HOLD_ACTIVE int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-CONFIRMED',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'CONFIRMED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',55000,0,20000,75000,1,DATEADD(minute,-20,@asof),DATEADD(minute,-15,@asof));
DECLARE @Orders_CONFIRMED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CONFIRMED,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-20,@asof),N'DEMO: CONFIRMED / PENDING');
DECLARE @OrderStatusHistory_CONFIRMED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CONFIRMED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-15,@asof),N'DEMO: CONFIRMED / CONFIRMED');
DECLARE @OrderStatusHistory_CONFIRMED_1 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-15,@asof),[Version]=1 WHERE [OrderId]=@Orders_CONFIRMED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_CONFIRMED,@BookCopies_1_9,N'1984',N'GOOD',55000,25000,0,55000);
DECLARE @OrderItems_CONFIRMED_9 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_9,@Orders_CONFIRMED,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,30,@asof),NULL);
DECLARE @StockReservations_CONFIRMED_9 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_9;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_CONFIRMED,N'BANK_TRANSFER',N'DEMO_GATEWAY',75000,N'VND',N'SUCCEEDED',N'DEMO-TXN-CONFIRMED',N'DEMO-PAY-CONFIRMED',DATEADD(minute,-15,@asof),DATEADD(minute,-20,@asof));
DECLARE @Payments_CONFIRMED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-PROCESSING',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'PROCESSING',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',60000,0,20000,80000,1,DATEADD(minute,-20,@asof),DATEADD(minute,-15,@asof));
DECLARE @Orders_PROCESSING int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PROCESSING,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-20,@asof),N'DEMO: PROCESSING / PENDING');
DECLARE @OrderStatusHistory_PROCESSING_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PROCESSING,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-15,@asof),N'DEMO: PROCESSING / CONFIRMED');
DECLARE @OrderStatusHistory_PROCESSING_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PROCESSING,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-10,@asof),N'DEMO: PROCESSING / PROCESSING');
DECLARE @OrderStatusHistory_PROCESSING_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-10,@asof),[Version]=2 WHERE [OrderId]=@Orders_PROCESSING;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_PROCESSING,@BookCopies_1_10,N'The Great Gatsby',N'FAIR',60000,30000,0,60000);
DECLARE @OrderItems_PROCESSING_10 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_10,@Orders_PROCESSING,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,30,@asof),NULL);
DECLARE @StockReservations_PROCESSING_10 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_10;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_PROCESSING,N'E_WALLET',N'DEMO_GATEWAY',80000,N'VND',N'SUCCEEDED',N'DEMO-TXN-PROCESSING',N'DEMO-PAY-PROCESSING',DATEADD(minute,-15,@asof),DATEADD(minute,-20,@asof));
DECLARE @Payments_PROCESSING int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-SHIPPED-COD',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'SHIPPED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',65000,0,20000,85000,1,DATEADD(minute,-2880,@asof),DATEADD(minute,-2820,@asof));
DECLARE @Orders_SHIPPED_COD int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPED_COD,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-2880,@asof),N'DEMO: SHIPPED-COD / PENDING');
DECLARE @OrderStatusHistory_SHIPPED_COD_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPED_COD,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-2820,@asof),N'DEMO: SHIPPED-COD / CONFIRMED');
DECLARE @OrderStatusHistory_SHIPPED_COD_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPED_COD,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-2760,@asof),N'DEMO: SHIPPED-COD / PROCESSING');
DECLARE @OrderStatusHistory_SHIPPED_COD_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPED_COD,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-2700,@asof),N'DEMO: SHIPPED-COD / SHIPPED');
DECLARE @OrderStatusHistory_SHIPPED_COD_3 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-2700,@asof),[Version]=3 WHERE [OrderId]=@Orders_SHIPPED_COD;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_SHIPPED_COD,@BookCopies_1_11,N'To Kill a Mockingbird',N'WORN',65000,35000,0,65000);
DECLARE @OrderItems_SHIPPED_COD_11 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_11,@Orders_SHIPPED_COD,N'CONSUMED',DATEADD(minute,-2880,@asof),DATEADD(minute,-1440,@asof),DATEADD(minute,-2700,@asof));
DECLARE @StockReservations_SHIPPED_COD_11 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_11,@Stores_1,NULL,N'SALE',DATEADD(minute,-2700,@asof),@Users_staff1,@OrderItems_SHIPPED_COD_11,N'DEMO: xuất bán',N'DEMO-SALE-SHIPPED-COD-11');
DECLARE @InventoryMovements_sale_SHIPPED_COD_11 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-2700,@asof) WHERE [CopyId]=@BookCopies_1_11;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_SHIPPED_COD,N'COD',N'DEMO_GATEWAY',85000,N'VND',N'PENDING',NULL,N'DEMO-PAY-SHIPPED-COD',NULL,DATEADD(minute,-2880,@asof));
DECLARE @Payments_SHIPPED_COD int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-EXPIRED',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'CANCELLED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',70000,0,20000,90000,1,DATEADD(minute,-2880,@asof),DATEADD(minute,-2820,@asof));
DECLARE @Orders_EXPIRED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_EXPIRED,NULL,N'PENDING',NULL,DATEADD(minute,-2880,@asof),N'DEMO: EXPIRED / PENDING');
DECLARE @OrderStatusHistory_EXPIRED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_EXPIRED,N'PENDING',N'CANCELLED',NULL,DATEADD(minute,-2820,@asof),N'DEMO: EXPIRED / CANCELLED');
DECLARE @OrderStatusHistory_EXPIRED_1 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-2820,@asof),[Version]=1 WHERE [OrderId]=@Orders_EXPIRED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_EXPIRED,@BookCopies_1_12,N'Norwegian Wood',N'LIKE_NEW',70000,40000,0,70000);
DECLARE @OrderItems_EXPIRED_12 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_12,@Orders_EXPIRED,N'EXPIRED',DATEADD(minute,-2880,@asof),DATEADD(minute,-2865,@asof),DATEADD(minute,-2865,@asof));
DECLARE @StockReservations_EXPIRED_12 int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_EXPIRED,N'CARD',N'DEMO_GATEWAY',90000,N'VND',N'FAILED',N'DEMO-TXN-EXPIRED',N'DEMO-PAY-EXPIRED',NULL,DATEADD(minute,-2880,@asof));
DECLARE @Payments_EXPIRED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-CANCELLED',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'CANCELLED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',75000,0,20000,95000,1,DATEADD(minute,-4320,@asof),DATEADD(minute,-4260,@asof));
DECLARE @Orders_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CANCELLED,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-4320,@asof),N'DEMO: CANCELLED / PENDING');
DECLARE @OrderStatusHistory_CANCELLED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CANCELLED,N'PENDING',N'CANCELLED',@Users_staff1,DATEADD(minute,-4260,@asof),N'DEMO: CANCELLED / CANCELLED');
DECLARE @OrderStatusHistory_CANCELLED_1 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-4260,@asof),[Version]=1 WHERE [OrderId]=@Orders_CANCELLED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_CANCELLED,@BookCopies_1_13,N'One Hundred Years of Solitude',N'GOOD',75000,45000,0,75000);
DECLARE @OrderItems_CANCELLED_13 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_13,@Orders_CANCELLED,N'CANCELLED',DATEADD(minute,-4320,@asof),DATEADD(minute,-2880,@asof),DATEADD(minute,-4260,@asof));
DECLARE @StockReservations_CANCELLED_13 int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_CANCELLED,N'BANK_TRANSFER',N'DEMO_GATEWAY',95000,N'VND',N'CANCELLED',N'DEMO-TXN-CANCELLED',N'DEMO-PAY-CANCELLED',NULL,DATEADD(minute,-4320,@asof));
DECLARE @Payments_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-PAYMENT-RETRY',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',80000,0,20000,100000,1,DATEADD(minute,-28800,@asof),DATEADD(minute,-28740,@asof));
DECLARE @Orders_PAYMENT_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAYMENT_RETRY,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-28800,@asof),N'DEMO: PAYMENT-RETRY / PENDING');
DECLARE @OrderStatusHistory_PAYMENT_RETRY_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAYMENT_RETRY,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-28740,@asof),N'DEMO: PAYMENT-RETRY / CONFIRMED');
DECLARE @OrderStatusHistory_PAYMENT_RETRY_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAYMENT_RETRY,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-28680,@asof),N'DEMO: PAYMENT-RETRY / PROCESSING');
DECLARE @OrderStatusHistory_PAYMENT_RETRY_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAYMENT_RETRY,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-28620,@asof),N'DEMO: PAYMENT-RETRY / SHIPPED');
DECLARE @OrderStatusHistory_PAYMENT_RETRY_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAYMENT_RETRY,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-28560,@asof),N'DEMO: PAYMENT-RETRY / COMPLETED');
DECLARE @OrderStatusHistory_PAYMENT_RETRY_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-28560,@asof),[Version]=4 WHERE [OrderId]=@Orders_PAYMENT_RETRY;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_PAYMENT_RETRY,@BookCopies_1_14,N'The Little Prince',N'FAIR',80000,50000,0,80000);
DECLARE @OrderItems_PAYMENT_RETRY_14 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_14,@Orders_PAYMENT_RETRY,N'CONSUMED',DATEADD(minute,-28800,@asof),DATEADD(minute,-27360,@asof),DATEADD(minute,-28560,@asof));
DECLARE @StockReservations_PAYMENT_RETRY_14 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_14,@Stores_1,NULL,N'SALE',DATEADD(minute,-28620,@asof),@Users_staff1,@OrderItems_PAYMENT_RETRY_14,N'DEMO: xuất bán',N'DEMO-SALE-PAYMENT-RETRY-14');
DECLARE @InventoryMovements_sale_PAYMENT_RETRY_14 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-28620,@asof) WHERE [CopyId]=@BookCopies_1_14;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_PAYMENT_RETRY,N'E_WALLET',N'DEMO_GATEWAY',100000,N'VND',N'FAILED',N'DEMO-FAILED-PAYMENT-RETRY',N'DEMO-PAY-FAILED-PAYMENT-RETRY',NULL,DATEADD(minute,-28799,@asof));
DECLARE @Payments_PAYMENT_RETRY_failed int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_PAYMENT_RETRY,N'E_WALLET',N'DEMO_GATEWAY',100000,N'VND',N'SUCCEEDED',N'DEMO-TXN-PAYMENT-RETRY',N'DEMO-PAY-PAYMENT-RETRY',DATEADD(minute,-28740,@asof),DATEADD(minute,-28798,@asof));
DECLARE @Payments_PAYMENT_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-PAID-CANCELLED',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'CANCELLED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',85000,0,20000,105000,1,DATEADD(minute,-27360,@asof),DATEADD(minute,-27300,@asof));
DECLARE @Orders_PAID_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAID_CANCELLED,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-27360,@asof),N'DEMO: PAID-CANCELLED / PENDING');
DECLARE @OrderStatusHistory_PAID_CANCELLED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAID_CANCELLED,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-27300,@asof),N'DEMO: PAID-CANCELLED / CONFIRMED');
DECLARE @OrderStatusHistory_PAID_CANCELLED_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_PAID_CANCELLED,N'CONFIRMED',N'CANCELLED',@Users_staff1,DATEADD(minute,-27240,@asof),N'DEMO: PAID-CANCELLED / CANCELLED');
DECLARE @OrderStatusHistory_PAID_CANCELLED_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-27240,@asof),[Version]=2 WHERE [OrderId]=@Orders_PAID_CANCELLED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_PAID_CANCELLED,@BookCopies_1_15,N'Crime and Punishment',N'WORN',85000,55000,0,85000);
DECLARE @OrderItems_PAID_CANCELLED_15 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_15,@Orders_PAID_CANCELLED,N'CANCELLED',DATEADD(minute,-27360,@asof),DATEADD(minute,-25920,@asof),DATEADD(minute,-27240,@asof));
DECLARE @StockReservations_PAID_CANCELLED_15 int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_PAID_CANCELLED,N'CARD',N'DEMO_GATEWAY',105000,N'VND',N'SUCCEEDED',N'DEMO-TXN-PAID-CANCELLED',N'DEMO-PAY-PAID-CANCELLED',DATEADD(minute,-27300,@asof),DATEADD(minute,-27360,@asof));
DECLARE @Payments_PAID_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-RESALE',@Stores_1,@Users_customer2,@Users_staff1,N'POS',N'COMPLETED',NULL,NULL,NULL,60000,0,0,60000,1,DATEADD(minute,-14400,@asof),DATEADD(minute,-14340,@asof));
DECLARE @Orders_RESALE int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RESALE,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-14400,@asof),N'DEMO: RESALE / PENDING');
DECLARE @OrderStatusHistory_RESALE_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RESALE,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-14340,@asof),N'DEMO: RESALE / CONFIRMED');
DECLARE @OrderStatusHistory_RESALE_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_RESALE,N'CONFIRMED',N'COMPLETED',@Users_staff1,DATEADD(minute,-14280,@asof),N'DEMO: RESALE / COMPLETED');
DECLARE @OrderStatusHistory_RESALE_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-14280,@asof),[Version]=2 WHERE [OrderId]=@Orders_RESALE;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_RESALE,@BookCopies_1_2,N'Chí Phèo',N'FAIR',60000,30000,0,60000);
DECLARE @OrderItems_RESALE_2 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_2,@Stores_1,NULL,N'SALE',DATEADD(minute,-14280,@asof),@Users_staff1,@OrderItems_RESALE_2,N'DEMO: xuất bán',N'DEMO-SALE-RESALE-2');
DECLARE @InventoryMovements_sale_RESALE_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-14280,@asof) WHERE [CopyId]=@BookCopies_1_2;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_RESALE,N'CASH',N'DEMO_CASH',60000,N'VND',N'SUCCEEDED',N'DEMO-TXN-RESALE',N'DEMO-PAY-RESALE',DATEADD(minute,-14340,@asof),DATEADD(minute,-14400,@asof));
DECLARE @Payments_RESALE int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-GUEST',@Stores_1,NULL,@Users_staff1,N'POS',N'COMPLETED',NULL,NULL,NULL,50000,0,0,50000,1,DATEADD(minute,-21600,@asof),DATEADD(minute,-21540,@asof));
DECLARE @Orders_GUEST int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_GUEST,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-21600,@asof),N'DEMO: GUEST / PENDING');
DECLARE @OrderStatusHistory_GUEST_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_GUEST,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-21540,@asof),N'DEMO: GUEST / CONFIRMED');
DECLARE @OrderStatusHistory_GUEST_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_GUEST,N'CONFIRMED',N'COMPLETED',@Users_staff1,DATEADD(minute,-21480,@asof),N'DEMO: GUEST / COMPLETED');
DECLARE @OrderStatusHistory_GUEST_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-21480,@asof),[Version]=2 WHERE [OrderId]=@Orders_GUEST;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_GUEST,@BookCopies_1_16,N'The Wealth of Nations',N'LIKE_NEW',50000,20000,0,50000);
DECLARE @OrderItems_GUEST_16 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_16,@Stores_1,NULL,N'SALE',DATEADD(minute,-21480,@asof),@Users_staff1,@OrderItems_GUEST_16,N'DEMO: xuất bán',N'DEMO-SALE-GUEST-16');
DECLARE @InventoryMovements_sale_GUEST_16 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-21480,@asof) WHERE [CopyId]=@BookCopies_1_16;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_GUEST,N'CASH',N'DEMO_CASH',50000,N'VND',N'SUCCEEDED',N'DEMO-TXN-GUEST',N'DEMO-PAY-GUEST',DATEADD(minute,-21540,@asof),DATEADD(minute,-21600,@asof));
DECLARE @Payments_GUEST int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-REFUND-RETRY',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',115000,0,20000,135000,1,DATEADD(minute,-25920,@asof),DATEADD(minute,-25860,@asof));
DECLARE @Orders_REFUND_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_RETRY,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-25920,@asof),N'DEMO: REFUND-RETRY / PENDING');
DECLARE @OrderStatusHistory_REFUND_RETRY_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_RETRY,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-25860,@asof),N'DEMO: REFUND-RETRY / CONFIRMED');
DECLARE @OrderStatusHistory_REFUND_RETRY_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_RETRY,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-25800,@asof),N'DEMO: REFUND-RETRY / PROCESSING');
DECLARE @OrderStatusHistory_REFUND_RETRY_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_RETRY,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-25740,@asof),N'DEMO: REFUND-RETRY / SHIPPED');
DECLARE @OrderStatusHistory_REFUND_RETRY_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_RETRY,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-25680,@asof),N'DEMO: REFUND-RETRY / COMPLETED');
DECLARE @OrderStatusHistory_REFUND_RETRY_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-25680,@asof),[Version]=4 WHERE [OrderId]=@Orders_REFUND_RETRY;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_REFUND_RETRY,@BookCopies_1_17,N'Capital: Volume I',N'GOOD',55000,25000,0,55000);
DECLARE @OrderItems_REFUND_RETRY_17 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_17,@Orders_REFUND_RETRY,N'CONSUMED',DATEADD(minute,-25920,@asof),DATEADD(minute,-24480,@asof),DATEADD(minute,-25680,@asof));
DECLARE @StockReservations_REFUND_RETRY_17 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_17,@Stores_1,NULL,N'SALE',DATEADD(minute,-25740,@asof),@Users_staff1,@OrderItems_REFUND_RETRY_17,N'DEMO: xuất bán',N'DEMO-SALE-REFUND-RETRY-17');
DECLARE @InventoryMovements_sale_REFUND_RETRY_17 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-25740,@asof) WHERE [CopyId]=@BookCopies_1_17;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_REFUND_RETRY,@BookCopies_1_18,N'The General Theory of Employment, Interest and Money',N'FAIR',60000,30000,0,60000);
DECLARE @OrderItems_REFUND_RETRY_18 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_18,@Orders_REFUND_RETRY,N'CONSUMED',DATEADD(minute,-25920,@asof),DATEADD(minute,-24480,@asof),DATEADD(minute,-25680,@asof));
DECLARE @StockReservations_REFUND_RETRY_18 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_18,@Stores_1,NULL,N'SALE',DATEADD(minute,-25740,@asof),@Users_staff1,@OrderItems_REFUND_RETRY_18,N'DEMO: xuất bán',N'DEMO-SALE-REFUND-RETRY-18');
DECLARE @InventoryMovements_sale_REFUND_RETRY_18 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-25740,@asof) WHERE [CopyId]=@BookCopies_1_18;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_REFUND_RETRY,N'BANK_TRANSFER',N'DEMO_GATEWAY',135000,N'VND',N'SUCCEEDED',N'DEMO-TXN-REFUND-RETRY',N'DEMO-PAY-REFUND-RETRY',DATEADD(minute,-25860,@asof),DATEADD(minute,-25920,@asof));
DECLARE @Payments_REFUND_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-REFUND-CANCELLED-RETRY',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',65000,0,20000,85000,1,DATEADD(minute,-24480,@asof),DATEADD(minute,-24420,@asof));
DECLARE @Orders_REFUND_CANCELLED_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_CANCELLED_RETRY,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-24480,@asof),N'DEMO: REFUND-CANCELLED-RETRY / PENDING');
DECLARE @OrderStatusHistory_REFUND_CANCELLED_RETRY_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_CANCELLED_RETRY,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-24420,@asof),N'DEMO: REFUND-CANCELLED-RETRY / CONFIRMED');
DECLARE @OrderStatusHistory_REFUND_CANCELLED_RETRY_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_CANCELLED_RETRY,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-24360,@asof),N'DEMO: REFUND-CANCELLED-RETRY / PROCESSING');
DECLARE @OrderStatusHistory_REFUND_CANCELLED_RETRY_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_CANCELLED_RETRY,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-24300,@asof),N'DEMO: REFUND-CANCELLED-RETRY / SHIPPED');
DECLARE @OrderStatusHistory_REFUND_CANCELLED_RETRY_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_REFUND_CANCELLED_RETRY,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-24240,@asof),N'DEMO: REFUND-CANCELLED-RETRY / COMPLETED');
DECLARE @OrderStatusHistory_REFUND_CANCELLED_RETRY_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-24240,@asof),[Version]=4 WHERE [OrderId]=@Orders_REFUND_CANCELLED_RETRY;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_REFUND_CANCELLED_RETRY,@BookCopies_1_19,N'Why Nations Fail',N'WORN',65000,35000,0,65000);
DECLARE @OrderItems_REFUND_CANCELLED_RETRY_19 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_19,@Orders_REFUND_CANCELLED_RETRY,N'CONSUMED',DATEADD(minute,-24480,@asof),DATEADD(minute,-23040,@asof),DATEADD(minute,-24240,@asof));
DECLARE @StockReservations_REFUND_CANCELLED_RETRY_19 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_19,@Stores_1,NULL,N'SALE',DATEADD(minute,-24300,@asof),@Users_staff1,@OrderItems_REFUND_CANCELLED_RETRY_19,N'DEMO: xuất bán',N'DEMO-SALE-REFUND-CANCELLED-RETRY-19');
DECLARE @InventoryMovements_sale_REFUND_CANCELLED_RETRY_19 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-24300,@asof) WHERE [CopyId]=@BookCopies_1_19;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_REFUND_CANCELLED_RETRY,N'CARD',N'DEMO_GATEWAY',85000,N'VND',N'SUCCEEDED',N'DEMO-TXN-REFUND-CANCELLED-RETRY',N'DEMO-PAY-REFUND-CANCELLED-RETRY',DATEADD(minute,-24420,@asof),DATEADD(minute,-24480,@asof));
DECLARE @Payments_REFUND_CANCELLED_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-FREE',@Stores_1,@Users_customer3,@Users_staff1,N'POS',N'COMPLETED',NULL,NULL,NULL,0,0,0,0,1,DATEADD(minute,-20160,@asof),DATEADD(minute,-20100,@asof));
DECLARE @Orders_FREE int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_FREE,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-20160,@asof),N'DEMO: FREE / PENDING');
DECLARE @OrderStatusHistory_FREE_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_FREE,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-20100,@asof),N'DEMO: FREE / CONFIRMED');
DECLARE @OrderStatusHistory_FREE_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_FREE,N'CONFIRMED',N'COMPLETED',@Users_staff1,DATEADD(minute,-20040,@asof),N'DEMO: FREE / COMPLETED');
DECLARE @OrderStatusHistory_FREE_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-20040,@asof),[Version]=2 WHERE [OrderId]=@Orders_FREE;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_FREE,@BookCopies_1_20,N'Capital in the Twenty-First Century',N'LIKE_NEW',0,0,0,0);
DECLARE @OrderItems_FREE_20 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_20,@Stores_1,NULL,N'SALE',DATEADD(minute,-20040,@asof),@Users_staff1,@OrderItems_FREE_20,N'DEMO: xuất bán',N'DEMO-SALE-FREE-20');
DECLARE @InventoryMovements_sale_FREE_20 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20040,@asof) WHERE [CopyId]=@BookCopies_1_20;
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-HOLD-OVERDUE',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'PENDING',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',75000,0,20000,95000,1,DATEADD(minute,-20,@asof),DATEADD(minute,-15,@asof));
DECLARE @Orders_HOLD_OVERDUE int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_HOLD_OVERDUE,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-20,@asof),N'DEMO: HOLD-OVERDUE / PENDING');
DECLARE @OrderStatusHistory_HOLD_OVERDUE_0 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-20,@asof),[Version]=0 WHERE [OrderId]=@Orders_HOLD_OVERDUE;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_HOLD_OVERDUE,@BookCopies_1_21,N'Freakonomics',N'GOOD',75000,45000,0,75000);
DECLARE @OrderItems_HOLD_OVERDUE_21 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_21,@Orders_HOLD_OVERDUE,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,-5,@asof),NULL);
DECLARE @StockReservations_HOLD_OVERDUE_21 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_21;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_HOLD_OVERDUE,N'CARD',N'DEMO_GATEWAY',95000,N'VND',N'PENDING',NULL,N'DEMO-PAY-HOLD-OVERDUE',NULL,DATEADD(minute,-20,@asof));
DECLARE @Payments_HOLD_OVERDUE int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-SHIPPING',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',80000,0,30000,110000,1,DATEADD(minute,-17280,@asof),DATEADD(minute,-17220,@asof));
DECLARE @Orders_SHIPPING int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPING,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-17280,@asof),N'DEMO: SHIPPING / PENDING');
DECLARE @OrderStatusHistory_SHIPPING_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPING,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-17220,@asof),N'DEMO: SHIPPING / CONFIRMED');
DECLARE @OrderStatusHistory_SHIPPING_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPING,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-17160,@asof),N'DEMO: SHIPPING / PROCESSING');
DECLARE @OrderStatusHistory_SHIPPING_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPING,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-17100,@asof),N'DEMO: SHIPPING / SHIPPED');
DECLARE @OrderStatusHistory_SHIPPING_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_SHIPPING,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-17040,@asof),N'DEMO: SHIPPING / COMPLETED');
DECLARE @OrderStatusHistory_SHIPPING_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-17040,@asof),[Version]=4 WHERE [OrderId]=@Orders_SHIPPING;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_SHIPPING,@BookCopies_1_22,N'Poor Economics',N'FAIR',80000,50000,0,80000);
DECLARE @OrderItems_SHIPPING_22 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_22,@Orders_SHIPPING,N'CONSUMED',DATEADD(minute,-17280,@asof),DATEADD(minute,-15840,@asof),DATEADD(minute,-17040,@asof));
DECLARE @StockReservations_SHIPPING_22 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_22,@Stores_1,NULL,N'SALE',DATEADD(minute,-17100,@asof),@Users_staff1,@OrderItems_SHIPPING_22,N'DEMO: xuất bán',N'DEMO-SALE-SHIPPING-22');
DECLARE @InventoryMovements_sale_SHIPPING_22 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-17100,@asof) WHERE [CopyId]=@BookCopies_1_22;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_SHIPPING,N'COD',N'DEMO_GATEWAY',110000,N'VND',N'SUCCEEDED',N'DEMO-TXN-SHIPPING',N'DEMO-PAY-SHIPPING',DATEADD(minute,-17040,@asof),DATEADD(minute,-17280,@asof));
DECLARE @Payments_SHIPPING int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-MULTI-HOLD',@Stores_1,@Users_customer3,NULL,N'ONLINE',N'PENDING',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',135000,0,20000,155000,1,DATEADD(minute,-20,@asof),DATEADD(minute,-15,@asof));
DECLARE @Orders_MULTI_HOLD int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_MULTI_HOLD,NULL,N'PENDING',@Users_customer3,DATEADD(minute,-20,@asof),N'DEMO: MULTI-HOLD / PENDING');
DECLARE @OrderStatusHistory_MULTI_HOLD_0 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-20,@asof),[Version]=0 WHERE [OrderId]=@Orders_MULTI_HOLD;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_MULTI_HOLD,@BookCopies_1_23,N'Political Order and Political Decay',N'WORN',85000,55000,0,85000);
DECLARE @OrderItems_MULTI_HOLD_23 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_23,@Orders_MULTI_HOLD,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,30,@asof),NULL);
DECLARE @StockReservations_MULTI_HOLD_23 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_23;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_MULTI_HOLD,@BookCopies_1_24,N'English Grammar in Use',N'LIKE_NEW',50000,20000,0,50000);
DECLARE @OrderItems_MULTI_HOLD_24 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_24,@Orders_MULTI_HOLD,N'ACTIVE',DATEADD(minute,-20,@asof),DATEADD(minute,30,@asof),NULL);
DECLARE @StockReservations_MULTI_HOLD_24 int=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'RESERVED',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20,@asof) WHERE [CopyId]=@BookCopies_1_24;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_MULTI_HOLD,N'E_WALLET',N'DEMO_GATEWAY',155000,N'VND',N'PENDING',NULL,N'DEMO-PAY-MULTI-HOLD',NULL,DATEADD(minute,-20,@asof));
DECLARE @Payments_MULTI_HOLD int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-POS-CANCELLED',@Stores_1,NULL,@Users_staff1,N'POS',N'CANCELLED',NULL,NULL,NULL,55000,0,0,55000,1,DATEADD(minute,-15840,@asof),DATEADD(minute,-15780,@asof));
DECLARE @Orders_POS_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_POS_CANCELLED,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-15840,@asof),N'DEMO: POS-CANCELLED / PENDING');
DECLARE @OrderStatusHistory_POS_CANCELLED_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_POS_CANCELLED,N'PENDING',N'CANCELLED',@Users_staff1,DATEADD(minute,-15780,@asof),N'DEMO: POS-CANCELLED / CANCELLED');
DECLARE @OrderStatusHistory_POS_CANCELLED_1 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-15780,@asof),[Version]=1 WHERE [OrderId]=@Orders_POS_CANCELLED;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_POS_CANCELLED,@BookCopies_1_25,N'Oxford Word Skills: Basic',N'GOOD',55000,25000,0,55000);
DECLARE @OrderItems_POS_CANCELLED_25 int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_POS_CANCELLED,N'CASH',N'DEMO_CASH',55000,N'VND',N'CANCELLED',N'DEMO-TXN-POS-CANCELLED',N'DEMO-PAY-POS-CANCELLED',NULL,DATEADD(minute,-15840,@asof));
DECLARE @Payments_POS_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-ZERO-RETURN-QUOTE',@Stores_1,@Users_customer1,NULL,N'ONLINE',N'COMPLETED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',60000,0,20000,80000,1,DATEADD(minute,-12960,@asof),DATEADD(minute,-12900,@asof));
DECLARE @Orders_ZERO_RETURN_QUOTE int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_ZERO_RETURN_QUOTE,NULL,N'PENDING',@Users_customer1,DATEADD(minute,-12960,@asof),N'DEMO: ZERO-RETURN-QUOTE / PENDING');
DECLARE @OrderStatusHistory_ZERO_RETURN_QUOTE_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_ZERO_RETURN_QUOTE,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-12900,@asof),N'DEMO: ZERO-RETURN-QUOTE / CONFIRMED');
DECLARE @OrderStatusHistory_ZERO_RETURN_QUOTE_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_ZERO_RETURN_QUOTE,N'CONFIRMED',N'PROCESSING',@Users_staff1,DATEADD(minute,-12840,@asof),N'DEMO: ZERO-RETURN-QUOTE / PROCESSING');
DECLARE @OrderStatusHistory_ZERO_RETURN_QUOTE_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_ZERO_RETURN_QUOTE,N'PROCESSING',N'SHIPPED',@Users_staff1,DATEADD(minute,-12780,@asof),N'DEMO: ZERO-RETURN-QUOTE / SHIPPED');
DECLARE @OrderStatusHistory_ZERO_RETURN_QUOTE_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_ZERO_RETURN_QUOTE,N'SHIPPED',N'COMPLETED',@Users_staff1,DATEADD(minute,-12720,@asof),N'DEMO: ZERO-RETURN-QUOTE / COMPLETED');
DECLARE @OrderStatusHistory_ZERO_RETURN_QUOTE_4 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-12720,@asof),[Version]=4 WHERE [OrderId]=@Orders_ZERO_RETURN_QUOTE;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_ZERO_RETURN_QUOTE,@BookCopies_1_26,N'The Official Cambridge Guide to IELTS',N'FAIR',60000,30000,0,60000);
DECLARE @OrderItems_ZERO_RETURN_QUOTE_26 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_26,@Orders_ZERO_RETURN_QUOTE,N'CONSUMED',DATEADD(minute,-12960,@asof),DATEADD(minute,-11520,@asof),DATEADD(minute,-12720,@asof));
DECLARE @StockReservations_ZERO_RETURN_QUOTE_26 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_26,@Stores_1,NULL,N'SALE',DATEADD(minute,-12780,@asof),@Users_staff1,@OrderItems_ZERO_RETURN_QUOTE_26,N'DEMO: xuất bán',N'DEMO-SALE-ZERO-RETURN-QUOTE-26');
DECLARE @InventoryMovements_sale_ZERO_RETURN_QUOTE_26 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-12780,@asof) WHERE [CopyId]=@BookCopies_1_26;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_ZERO_RETURN_QUOTE,N'BANK_TRANSFER',N'DEMO_GATEWAY',80000,N'VND',N'SUCCEEDED',N'DEMO-TXN-ZERO-RETURN-QUOTE',N'DEMO-PAY-ZERO-RETURN-QUOTE',DATEADD(minute,-12900,@asof),DATEADD(minute,-12960,@asof));
DECLARE @Payments_ZERO_RETURN_QUOTE int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-CANCELLED-REFUND-PENDING',@Stores_1,@Users_customer2,NULL,N'ONLINE',N'CANCELLED',N'Người nhận kiểm thử',N'0000000000',N'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng',65000,0,20000,85000,1,DATEADD(minute,-11520,@asof),DATEADD(minute,-11460,@asof));
DECLARE @Orders_CANCELLED_REFUND_PENDING int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CANCELLED_REFUND_PENDING,NULL,N'PENDING',@Users_customer2,DATEADD(minute,-11520,@asof),N'DEMO: CANCELLED-REFUND-PENDING / PENDING');
DECLARE @OrderStatusHistory_CANCELLED_REFUND_PENDING_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CANCELLED_REFUND_PENDING,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-11460,@asof),N'DEMO: CANCELLED-REFUND-PENDING / CONFIRMED');
DECLARE @OrderStatusHistory_CANCELLED_REFUND_PENDING_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_CANCELLED_REFUND_PENDING,N'CONFIRMED',N'CANCELLED',@Users_staff1,DATEADD(minute,-11400,@asof),N'DEMO: CANCELLED-REFUND-PENDING / CANCELLED');
DECLARE @OrderStatusHistory_CANCELLED_REFUND_PENDING_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-11400,@asof),[Version]=2 WHERE [OrderId]=@Orders_CANCELLED_REFUND_PENDING;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_CANCELLED_REFUND_PENDING,@BookCopies_1_27,N'Practical English Usage',N'WORN',65000,35000,0,65000);
DECLARE @OrderItems_CANCELLED_REFUND_PENDING_27 int=SCOPE_IDENTITY();
INSERT dbo.[StockReservations] ([CopyId],[OrderId],[Status],[ReservedAt],[ExpiresAt],[ReleasedAt]) VALUES (@BookCopies_1_27,@Orders_CANCELLED_REFUND_PENDING,N'CANCELLED',DATEADD(minute,-11520,@asof),DATEADD(minute,-10080,@asof),DATEADD(minute,-11400,@asof));
DECLARE @StockReservations_CANCELLED_REFUND_PENDING_27 int=SCOPE_IDENTITY();
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_CANCELLED_REFUND_PENDING,N'CARD',N'DEMO_GATEWAY',85000,N'VND',N'SUCCEEDED',N'DEMO-TXN-CANCELLED-REFUND-PENDING',N'DEMO-PAY-CANCELLED-REFUND-PENDING',DATEADD(minute,-11460,@asof),DATEADD(minute,-11520,@asof));
DECLARE @Payments_CANCELLED_REFUND_PENDING int=SCOPE_IDENTITY();
INSERT dbo.[Orders] ([OrderCode],[StoreId],[CustomerId],[CreatedBy],[Channel],[Status],[RecipientName],[RecipientPhone],[ShippingAddressSnapshot],[Subtotal],[DiscountAmount],[ShippingFee],[TotalAmount],[Version],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-HISTORY-NULLS',@Stores_1,NULL,@Users_staff1,N'POS',N'COMPLETED',NULL,NULL,NULL,70000,0,0,70000,1,DATEADD(minute,-10080,@asof),DATEADD(minute,-10020,@asof));
DECLARE @Orders_HISTORY_NULLS int=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_HISTORY_NULLS,NULL,N'PENDING',@Users_staff1,DATEADD(minute,-10080,@asof),N'DEMO: HISTORY-NULLS / PENDING');
DECLARE @OrderStatusHistory_HISTORY_NULLS_0 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_HISTORY_NULLS,N'PENDING',N'CONFIRMED',@Users_staff1,DATEADD(minute,-10020,@asof),N'DEMO: HISTORY-NULLS / CONFIRMED');
DECLARE @OrderStatusHistory_HISTORY_NULLS_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[OrderStatusHistory] ([OrderId],[FromStatus],[ToStatus],[ChangedBy],[ChangedAt],[Reason]) VALUES (@Orders_HISTORY_NULLS,N'CONFIRMED',N'COMPLETED',@Users_staff1,DATEADD(minute,-9960,@asof),N'DEMO: HISTORY-NULLS / COMPLETED');
DECLARE @OrderStatusHistory_HISTORY_NULLS_2 bigint=SCOPE_IDENTITY();
UPDATE dbo.[Orders] SET [UpdatedAt]=DATEADD(minute,-9960,@asof),[Version]=2 WHERE [OrderId]=@Orders_HISTORY_NULLS;
INSERT dbo.[OrderItems] ([OrderId],[CopyId],[BookTitleSnapshot],[ConditionSnapshot],[UnitPrice],[UnitCostSnapshot],[DiscountAmount],[LineTotal]) VALUES (@Orders_HISTORY_NULLS,@BookCopies_1_28,N'Academic Vocabulary in Use',N'LIKE_NEW',70000,40000,0,70000);
DECLARE @OrderItems_HISTORY_NULLS_28 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_28,@Stores_1,NULL,N'SALE',DATEADD(minute,-9960,@asof),@Users_staff1,@OrderItems_HISTORY_NULLS_28,N'DEMO: xuất bán',N'DEMO-SALE-HISTORY-NULLS-28');
DECLARE @InventoryMovements_sale_HISTORY_NULLS_28 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'SOLD',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-9960,@asof) WHERE [CopyId]=@BookCopies_1_28;
INSERT dbo.[Payments] ([OrderId],[Method],[Provider],[Amount],[Currency],[Status],[ProviderTransactionId],[IdempotencyKey],[PaidAt],[CreatedAt]) VALUES (@Orders_HISTORY_NULLS,N'CASH',N'DEMO_CASH',70000,N'VND',N'SUCCEEDED',N'DEMO-TXN-HISTORY-NULLS',N'DEMO-PAY-HISTORY-NULLS',DATEADD(minute,-10020,@asof),DATEADD(minute,-10080,@asof));
DECLARE @Payments_HISTORY_NULLS int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_PARTIAL_RETURN,@Stores_1,N'COMPLETED',@Users_customer1,@Users_staff1,N'DEMO: PARTIAL-RETURN',DATEADD(minute,-38880,@asof),DATEADD(minute,-38820,@asof));
DECLARE @SalesReturns_PARTIAL_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_PARTIAL_RETURN,@Orders_PARTIAL_RETURN,@OrderItems_PARTIAL_RETURN_2,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),N'RESTOCK',30000,N'ACCEPTED');
DECLARE @SalesReturnItems_PARTIAL_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[ReturnItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_2,NULL,@Stores_1,N'RETURN',DATEADD(minute,-38760,@asof),@Users_staff1,@OrderItems_PARTIAL_RETURN_2,@SalesReturnItems_PARTIAL_RETURN,N'DEMO: nhận lại sách',N'DEMO-RETURN-PARTIAL-RETURN');
DECLARE @InventoryMovements_return_PARTIAL_RETURN bigint=SCOPE_IDENTITY();
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_PARTIAL_RETURN,@Payments_PARTIAL_RETURN,@Orders_PARTIAL_RETURN,30000,N'DEMO: PARTIAL-RETURN',N'SUCCEEDED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-PARTIAL-RETURN',N'DEMO-REFUND-PARTIAL-RETURN',DATEADD(minute,-38670,@asof),DATEADD(minute,-38700,@asof));
DECLARE @Refunds_PARTIAL_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_DAMAGED_RETURN,@Stores_1,N'COMPLETED',@Users_customer2,@Users_staff1,N'DEMO: DAMAGED-RETURN',DATEADD(minute,-37440,@asof),DATEADD(minute,-37380,@asof));
DECLARE @SalesReturns_DAMAGED_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_DAMAGED_RETURN,@Orders_DAMAGED_RETURN,@OrderItems_DAMAGED_RETURN_3,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),N'DAMAGED',65000,N'ACCEPTED');
DECLARE @SalesReturnItems_DAMAGED_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[ReturnItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_3,NULL,@Stores_1,N'RETURN',DATEADD(minute,-37320,@asof),@Users_staff1,@OrderItems_DAMAGED_RETURN_3,@SalesReturnItems_DAMAGED_RETURN,N'DEMO: nhận lại sách',N'DEMO-RETURN-DAMAGED-RETURN');
DECLARE @InventoryMovements_return_DAMAGED_RETURN bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'DAMAGED',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-37320,@asof) WHERE [CopyId]=@BookCopies_1_3;
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_DAMAGED_RETURN,@Payments_DAMAGED_RETURN,@Orders_DAMAGED_RETURN,65000,N'DEMO: DAMAGED-RETURN',N'SUCCEEDED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-DAMAGED-RETURN',N'DEMO-REFUND-DAMAGED-RETURN',DATEADD(minute,-37230,@asof),DATEADD(minute,-37260,@asof));
DECLARE @Refunds_DAMAGED_RETURN int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_RETURN_REQUESTED,@Stores_1,N'REQUESTED',@Users_customer3,NULL,N'DEMO: RETURN-REQUESTED',DATEADD(minute,-36000,@asof),NULL);
DECLARE @SalesReturns_RETURN_REQUESTED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_RETURN_REQUESTED,@Orders_RETURN_REQUESTED,@OrderItems_RETURN_REQUESTED_4,NULL,NULL,70000,N'PENDING');
DECLARE @SalesReturnItems_RETURN_REQUESTED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_RETURN_REJECTED,@Stores_1,N'REJECTED',@Users_customer1,@Users_staff1,N'DEMO: RETURN-REJECTED',DATEADD(minute,-34560,@asof),NULL);
DECLARE @SalesReturns_RETURN_REJECTED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_RETURN_REJECTED,@Orders_RETURN_REJECTED,@OrderItems_RETURN_REJECTED_5,NULL,NULL,0,N'REJECTED');
DECLARE @SalesReturnItems_RETURN_REJECTED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_RETURN_APPROVED,@Stores_1,N'APPROVED',@Users_customer2,@Users_staff1,N'DEMO: RETURN-APPROVED',DATEADD(minute,-33120,@asof),DATEADD(minute,-33060,@asof));
DECLARE @SalesReturns_RETURN_APPROVED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_RETURN_APPROVED,@Orders_RETURN_APPROVED,@OrderItems_RETURN_APPROVED_6,NULL,NULL,80000,N'PENDING');
DECLARE @SalesReturnItems_RETURN_APPROVED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_RETURN_CANCELLED,@Stores_1,N'CANCELLED',@Users_customer3,@Users_staff1,N'DEMO: RETURN-CANCELLED',DATEADD(minute,-31680,@asof),NULL);
DECLARE @SalesReturns_RETURN_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_RETURN_CANCELLED,@Orders_RETURN_CANCELLED,@OrderItems_RETURN_CANCELLED_7,NULL,NULL,0,N'REJECTED');
DECLARE @SalesReturnItems_RETURN_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_REFUND_RETRY,@Stores_1,N'COMPLETED',@Users_customer1,@Users_staff1,N'DEMO: REFUND-RETRY',DATEADD(minute,-21600,@asof),DATEADD(minute,-21540,@asof));
DECLARE @SalesReturns_REFUND_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_REFUND_RETRY,@Orders_REFUND_RETRY,@OrderItems_REFUND_RETRY_17,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),N'RESTOCK',55000,N'ACCEPTED');
DECLARE @SalesReturnItems_REFUND_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[ReturnItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_17,NULL,@Stores_1,N'RETURN',DATEADD(minute,-21480,@asof),@Users_staff1,@OrderItems_REFUND_RETRY_17,@SalesReturnItems_REFUND_RETRY,N'DEMO: nhận lại sách',N'DEMO-RETURN-REFUND-RETRY');
DECLARE @InventoryMovements_return_REFUND_RETRY bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'AVAILABLE',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-21480,@asof) WHERE [CopyId]=@BookCopies_1_17;
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_REFUND_RETRY,@Payments_REFUND_RETRY,@Orders_REFUND_RETRY,55000,N'DEMO: REFUND-RETRY_failed',N'FAILED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-REFUND-RETRY_failed',N'DEMO-REFUND-REFUND-RETRY_failed',NULL,DATEADD(minute,-21420,@asof));
DECLARE @Refunds_REFUND_RETRY_failed int=SCOPE_IDENTITY();
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_REFUND_RETRY,@Payments_REFUND_RETRY,@Orders_REFUND_RETRY,55000,N'DEMO: REFUND-RETRY_pending',N'PENDING',N'DEMO_GATEWAY',NULL,N'DEMO-REFUND-REFUND-RETRY_pending',NULL,DATEADD(minute,-21360,@asof));
DECLARE @Refunds_REFUND_RETRY_pending int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_REFUND_CANCELLED_RETRY,@Stores_1,N'COMPLETED',@Users_customer2,@Users_staff1,N'DEMO: REFUND-CANCELLED-RETRY',DATEADD(minute,-20160,@asof),DATEADD(minute,-20100,@asof));
DECLARE @SalesReturns_REFUND_CANCELLED_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_REFUND_CANCELLED_RETRY,@Orders_REFUND_CANCELLED_RETRY,@OrderItems_REFUND_CANCELLED_RETRY_19,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),N'RESTOCK',65000,N'ACCEPTED');
DECLARE @SalesReturnItems_REFUND_CANCELLED_RETRY int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[OrderItemId],[ReturnItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_19,NULL,@Stores_1,N'RETURN',DATEADD(minute,-20040,@asof),@Users_staff1,@OrderItems_REFUND_CANCELLED_RETRY_19,@SalesReturnItems_REFUND_CANCELLED_RETRY,N'DEMO: nhận lại sách',N'DEMO-RETURN-REFUND-CANCELLED-RETRY');
DECLARE @InventoryMovements_return_REFUND_CANCELLED_RETRY bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'AVAILABLE',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-20040,@asof) WHERE [CopyId]=@BookCopies_1_19;
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_REFUND_CANCELLED_RETRY,@Payments_REFUND_CANCELLED_RETRY,@Orders_REFUND_CANCELLED_RETRY,65000,N'DEMO: REFUND-CANCELLED-RETRY_cancelled',N'CANCELLED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-REFUND-CANCELLED-RETRY_cancelled',N'DEMO-REFUND-REFUND-CANCELLED-RETRY_cancelled',NULL,DATEADD(minute,-19980,@asof));
DECLARE @Refunds_REFUND_CANCELLED_RETRY_cancelled int=SCOPE_IDENTITY();
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (@SalesReturns_REFUND_CANCELLED_RETRY,@Payments_REFUND_CANCELLED_RETRY,@Orders_REFUND_CANCELLED_RETRY,65000,N'DEMO: REFUND-CANCELLED-RETRY_success',N'SUCCEEDED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-REFUND-CANCELLED-RETRY_success',N'DEMO-REFUND-REFUND-CANCELLED-RETRY_success',DATEADD(minute,-19890,@asof),DATEADD(minute,-19920,@asof));
DECLARE @Refunds_REFUND_CANCELLED_RETRY_success int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturns] ([OrderId],[ReceivingStoreId],[Status],[RequestedBy],[ProcessedBy],[Reason],[CreatedAt],[ApprovedAt]) VALUES (@Orders_ZERO_RETURN_QUOTE,@Stores_1,N'REQUESTED',@Users_customer1,NULL,N'DEMO: ZERO-RETURN-QUOTE',DATEADD(minute,-8640,@asof),NULL);
DECLARE @SalesReturns_ZERO_RETURN_QUOTE int=SCOPE_IDENTITY();
INSERT dbo.[SalesReturnItems] ([ReturnId],[OrderId],[OrderItemId],[ReceivedConditionId],[Resolution],[RefundAmount],[Status]) VALUES (@SalesReturns_ZERO_RETURN_QUOTE,@Orders_ZERO_RETURN_QUOTE,@OrderItems_ZERO_RETURN_QUOTE_26,NULL,NULL,0,N'PENDING');
DECLARE @SalesReturnItems_ZERO_RETURN_QUOTE int=SCOPE_IDENTITY();
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (NULL,@Payments_PAID_CANCELLED,@Orders_PAID_CANCELLED,105000,N'DEMO: PAID-CANCELLED',N'SUCCEEDED',N'DEMO_GATEWAY',N'DEMO-RF-TXN-PAID-CANCELLED',N'DEMO-REFUND-PAID-CANCELLED',DATEADD(minute,-27150,@asof),DATEADD(minute,-27180,@asof));
DECLARE @Refunds_PAID_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[Refunds] ([ReturnId],[PaymentId],[OrderId],[Amount],[Reason],[Status],[Provider],[ProviderRefundId],[IdempotencyKey],[RefundedAt],[CreatedAt]) VALUES (NULL,@Payments_CANCELLED_REFUND_PENDING,@Orders_CANCELLED_REFUND_PENDING,85000,N'DEMO: CANCELLED-REFUND-PENDING',N'PENDING',N'DEMO_GATEWAY',NULL,N'DEMO-REFUND-CANCELLED-REFUND-PENDING',NULL,DATEADD(minute,-11340,@asof));
DECLARE @Refunds_CANCELLED_REFUND_PENDING int=SCOPE_IDENTITY();
INSERT dbo.[StockTransfers] ([TransferCode],[FromStoreId],[ToStoreId],[Status],[RequestedBy],[ApprovedBy],[ShippedAt],[ReceivedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-TRANSFER-DRAFT',@Stores_1,@Stores_2,N'DRAFT',@Users_staff1,NULL,NULL,NULL,DATEADD(minute,-8640,@asof),DATEADD(minute,-7200,@asof));
DECLARE @StockTransfers_DRAFT int=SCOPE_IDENTITY();
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_DRAFT,@BookCopies_1_30,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),NULL,N'PENDING',NULL);
DECLARE @StockTransferItems_30 int=SCOPE_IDENTITY();
INSERT dbo.[StockTransfers] ([TransferCode],[FromStoreId],[ToStoreId],[Status],[RequestedBy],[ApprovedBy],[ShippedAt],[ReceivedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-TRANSFER-APPROVED',@Stores_1,@Stores_2,N'APPROVED',@Users_staff1,@Users_manager1,NULL,NULL,DATEADD(minute,-8640,@asof),DATEADD(minute,-7200,@asof));
DECLARE @StockTransfers_APPROVED int=SCOPE_IDENTITY();
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_APPROVED,@BookCopies_1_31,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),NULL,N'PENDING',NULL);
DECLARE @StockTransferItems_31 int=SCOPE_IDENTITY();
INSERT dbo.[StockTransfers] ([TransferCode],[FromStoreId],[ToStoreId],[Status],[RequestedBy],[ApprovedBy],[ShippedAt],[ReceivedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-TRANSFER-TRANSIT',@Stores_1,@Stores_2,N'IN_TRANSIT',@Users_staff1,@Users_manager1,DATEADD(minute,-7200,@asof),NULL,DATEADD(minute,-8640,@asof),DATEADD(minute,-7200,@asof));
DECLARE @StockTransfers_TRANSIT int=SCOPE_IDENTITY();
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_TRANSIT,@BookCopies_1_32,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),NULL,N'PENDING',NULL);
DECLARE @StockTransferItems_32 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_32,@Stores_1,@Stores_2,N'TRANSFER_OUT',DATEADD(minute,-7200,@asof),@Users_staff1,@StockTransferItems_32,N'DEMO: xuất điều chuyển',N'DEMO-TRANSFER-OUT-32');
DECLARE @InventoryMovements_transferout_32 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'IN_TRANSIT',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-7200,@asof) WHERE [CopyId]=@BookCopies_1_32;
INSERT dbo.[StockTransfers] ([TransferCode],[FromStoreId],[ToStoreId],[Status],[RequestedBy],[ApprovedBy],[ShippedAt],[ReceivedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-TRANSFER-RECEIVED',@Stores_1,@Stores_2,N'RECEIVED',@Users_staff1,@Users_manager1,DATEADD(minute,-7200,@asof),DATEADD(minute,-5760,@asof),DATEADD(minute,-8640,@asof),DATEADD(minute,-5760,@asof));
DECLARE @StockTransfers_RECEIVED int=SCOPE_IDENTITY();
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_RECEIVED,@BookCopies_1_33,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),N'RECEIVED',NULL);
DECLARE @StockTransferItems_33 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_33,@Stores_1,@Stores_2,N'TRANSFER_OUT',DATEADD(minute,-7200,@asof),@Users_staff1,@StockTransferItems_33,N'DEMO: xuất điều chuyển',N'DEMO-TRANSFER-OUT-33');
DECLARE @InventoryMovements_transferout_33 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'IN_TRANSIT',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-7200,@asof) WHERE [CopyId]=@BookCopies_1_33;
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_33,@Stores_1,@Stores_2,N'TRANSFER_IN',DATEADD(minute,-5760,@asof),@Users_staff2,@StockTransferItems_33,N'DEMO: nhận điều chuyển',N'DEMO-TRANSFER-IN-33');
DECLARE @InventoryMovements_transferin_33 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [StoreId]=@Stores_2,[Status]=N'AVAILABLE',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),[ShelfLocation]=N'S2-KHANGCHUYEN',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-5760,@asof) WHERE [CopyId]=@BookCopies_1_33;
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_RECEIVED,@BookCopies_1_34,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='FAIR'),(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),N'DAMAGED',N'DEMO: hỏng khi vận chuyển');
DECLARE @StockTransferItems_34 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_34,@Stores_1,@Stores_2,N'TRANSFER_OUT',DATEADD(minute,-7200,@asof),@Users_staff1,@StockTransferItems_34,N'DEMO: xuất điều chuyển',N'DEMO-TRANSFER-OUT-34');
DECLARE @InventoryMovements_transferout_34 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'IN_TRANSIT',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-7200,@asof) WHERE [CopyId]=@BookCopies_1_34;
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_34,@Stores_1,@Stores_2,N'TRANSFER_IN',DATEADD(minute,-5760,@asof),@Users_staff2,@StockTransferItems_34,N'DEMO: nhận điều chuyển',N'DEMO-TRANSFER-IN-34');
DECLARE @InventoryMovements_transferin_34 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [StoreId]=@Stores_2,[Status]=N'DAMAGED',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),[ShelfLocation]=N'S2-KHANGCHUYEN',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-5760,@asof) WHERE [CopyId]=@BookCopies_1_34;
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_RECEIVED,@BookCopies_1_35,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),NULL,N'MISSING',N'DEMO: thất lạc trên đường chuyển');
DECLARE @StockTransferItems_35 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[TransferItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_35,@Stores_1,@Stores_2,N'TRANSFER_OUT',DATEADD(minute,-7200,@asof),@Users_staff1,@StockTransferItems_35,N'DEMO: xuất điều chuyển',N'DEMO-TRANSFER-OUT-35');
DECLARE @InventoryMovements_transferout_35 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'LOST',[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-7200,@asof) WHERE [CopyId]=@BookCopies_1_35;
INSERT dbo.[StockTransfers] ([TransferCode],[FromStoreId],[ToStoreId],[Status],[RequestedBy],[ApprovedBy],[ShippedAt],[ReceivedAt],[CreatedAt],[UpdatedAt]) VALUES (N'DEMO-TRANSFER-CANCELLED',@Stores_1,@Stores_2,N'CANCELLED',@Users_staff1,NULL,NULL,NULL,DATEADD(minute,-8640,@asof),DATEADD(minute,-7200,@asof));
DECLARE @StockTransfers_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[StockTransferItems] ([TransferId],[CopyId],[SentConditionId],[ReceivedConditionId],[ReceiptStatus],[Note]) VALUES (@StockTransfers_CANCELLED,@BookCopies_1_36,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),NULL,N'PENDING',NULL);
DECLARE @StockTransferItems_36 int=SCOPE_IDENTITY();
INSERT dbo.[Stocktakes] ([StoreId],[Status],[StartedAt],[FinalizedAt],[CreatedBy],[ApprovedBy],[CreatedAt]) VALUES (@Stores_1,N'FINALIZED',DATEADD(minute,-18710,@asof),DATEADD(minute,-18660,@asof),@Users_staff1,@Users_manager1,DATEADD(minute,-18720,@asof));
DECLARE @Stocktakes_OLD int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_OLD,@BookCopies_1_40,1,0,NULL,N'DEMO: Thiếu khi kiểm kê');
DECLARE @StocktakeItems_OLD_40 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[StocktakeItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_40,@Stores_1,NULL,N'ADJUSTMENT',DATEADD(minute,-18660,@asof),@Users_manager1,@StocktakeItems_OLD_40,N'DEMO: điều chỉnh kiểm kê LOST',N'DEMO-ADJUST-OLD-40');
DECLARE @InventoryMovements_adjust_OLD_40 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'LOST',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-18660,@asof) WHERE [CopyId]=@BookCopies_1_40;
INSERT dbo.[Stocktakes] ([StoreId],[Status],[StartedAt],[FinalizedAt],[CreatedBy],[ApprovedBy],[CreatedAt]) VALUES (@Stores_1,N'FINALIZED',DATEADD(minute,-4310,@asof),DATEADD(minute,-4260,@asof),@Users_staff1,@Users_manager1,DATEADD(minute,-4320,@asof));
DECLARE @Stocktakes_FINAL int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_FINAL,@BookCopies_1_37,1,0,NULL,N'DEMO: Thiếu khi kiểm kê');
DECLARE @StocktakeItems_FINAL_37 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[StocktakeItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_37,@Stores_1,NULL,N'ADJUSTMENT',DATEADD(minute,-4260,@asof),@Users_manager1,@StocktakeItems_FINAL_37,N'DEMO: điều chỉnh kiểm kê LOST',N'DEMO-ADJUST-FINAL-37');
DECLARE @InventoryMovements_adjust_FINAL_37 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'LOST',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='GOOD'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-4260,@asof) WHERE [CopyId]=@BookCopies_1_37;
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_FINAL,@BookCopies_1_38,1,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),N'DEMO: Phát hiện hư hỏng');
DECLARE @StocktakeItems_FINAL_38 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[StocktakeItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_38,@Stores_1,@Stores_1,N'ADJUSTMENT',DATEADD(minute,-4260,@asof),@Users_manager1,@StocktakeItems_FINAL_38,N'DEMO: điều chỉnh kiểm kê DAMAGED',N'DEMO-ADJUST-FINAL-38');
DECLARE @InventoryMovements_adjust_FINAL_38 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'DAMAGED',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-4260,@asof) WHERE [CopyId]=@BookCopies_1_38;
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_FINAL,@BookCopies_1_39,1,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='WORN'),NULL);
DECLARE @StocktakeItems_FINAL_39 int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_FINAL,@BookCopies_1_40,0,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),N'DEMO: Tìm lại cuốn đã ghi thất lạc');
DECLARE @StocktakeItems_FINAL_40 int=SCOPE_IDENTITY();
INSERT dbo.[InventoryMovements] ([CopyId],[FromStoreId],[ToStoreId],[MovementType],[OccurredAt],[ActorId],[StocktakeItemId],[Reason],[OperationKey]) VALUES (@BookCopies_1_40,NULL,@Stores_1,N'ADJUSTMENT',DATEADD(minute,-4260,@asof),@Users_manager1,@StocktakeItems_FINAL_40,N'DEMO: điều chỉnh kiểm kê AVAILABLE',N'DEMO-ADJUST-FINAL-40');
DECLARE @InventoryMovements_adjust_FINAL_40 bigint=SCOPE_IDENTITY();
UPDATE dbo.[BookCopies] SET [Status]=N'AVAILABLE',[ConditionId]=(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),[Version]=Version+1,[UpdatedAt]=DATEADD(minute,-4260,@asof) WHERE [CopyId]=@BookCopies_1_40;
INSERT dbo.[Stocktakes] ([StoreId],[Status],[StartedAt],[FinalizedAt],[CreatedBy],[ApprovedBy],[CreatedAt]) VALUES (@Stores_2,N'DRAFT',NULL,NULL,@Users_staff2,NULL,DATEADD(minute,-1440,@asof));
DECLARE @Stocktakes_DRAFT int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_DRAFT,@BookCopies_2_1,1,NULL,NULL,NULL);
DECLARE @StocktakeItems_DRAFT_1 int=SCOPE_IDENTITY();
INSERT dbo.[Stocktakes] ([StoreId],[Status],[StartedAt],[FinalizedAt],[CreatedBy],[ApprovedBy],[CreatedAt]) VALUES (@Stores_3,N'COUNTING',DATEADD(minute,-50,@asof),NULL,@Users_staff3,NULL,DATEADD(minute,-60,@asof));
DECLARE @Stocktakes_COUNTING int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_COUNTING,@BookCopies_3_1,1,NULL,NULL,NULL);
DECLARE @StocktakeItems_COUNTING_1 int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_COUNTING,@BookCopies_3_2,1,1,(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='LIKE_NEW'),NULL);
DECLARE @StocktakeItems_COUNTING_2 int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_COUNTING,@BookCopies_3_3,1,0,NULL,NULL);
DECLARE @StocktakeItems_COUNTING_3 int=SCOPE_IDENTITY();
INSERT dbo.[Stocktakes] ([StoreId],[Status],[StartedAt],[FinalizedAt],[CreatedBy],[ApprovedBy],[CreatedAt]) VALUES (@Stores_2,N'CANCELLED',DATEADD(minute,-2870,@asof),NULL,@Users_staff2,NULL,DATEADD(minute,-2880,@asof));
DECLARE @Stocktakes_CANCELLED int=SCOPE_IDENTITY();
INSERT dbo.[StocktakeItems] ([StocktakeId],[CopyId],[ExpectedPresent],[ActualPresent],[ActualConditionId],[DifferenceReason]) VALUES (@Stocktakes_CANCELLED,@BookCopies_2_1,1,NULL,NULL,NULL);
DECLARE @StocktakeItems_CANCELLED_1 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer1,@Stores_1,N'ACTIVE',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_A int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_A,@BookCopies_1_41,DATEADD(minute,-30,@asof));
DECLARE @CartItems_A_41 int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_A,@BookCopies_1_42,DATEADD(minute,-30,@asof));
DECLARE @CartItems_A_42 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer2,@Stores_1,N'ACTIVE',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_B int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_B,@BookCopies_1_41,DATEADD(minute,-30,@asof));
DECLARE @CartItems_B_41 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer1,@Stores_2,N'ACTIVE',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_C int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_C,@BookCopies_2_1,DATEADD(minute,-30,@asof));
DECLARE @CartItems_C_1 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer3,@Stores_1,N'CHECKED_OUT',DATEADD(minute,-28860,@asof),DATEADD(minute,-28800,@asof));
DECLARE @Carts_DONE int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_DONE,@BookCopies_1_14,DATEADD(minute,-28860,@asof));
DECLARE @CartItems_DONE_14 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer1,@Stores_1,N'ABANDONED',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_ABANDONED int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_ABANDONED,@BookCopies_1_43,DATEADD(minute,-30,@asof));
DECLARE @CartItems_ABANDONED_43 int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_empty,@Stores_3,N'ACTIVE',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_EMPTY int=SCOPE_IDENTITY();
INSERT dbo.[Carts] ([UserId],[StoreId],[Status],[CreatedAt],[UpdatedAt]) VALUES (@Users_customer3,@Stores_1,N'ACTIVE',DATEADD(minute,-30,@asof),DATEADD(minute,-30,@asof));
DECLARE @Carts_STALE int=SCOPE_IDENTITY();
INSERT dbo.[CartItems] ([CartId],[CopyId],[AddedAt]) VALUES (@Carts_STALE,@BookCopies_1_0,DATEADD(minute,-30,@asof));
DECLARE @CartItems_STALE_0 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/truyen-kieu.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Truyện Kiều',0,1,1,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_1 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/so-do.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Số đỏ',0,1,2,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_2 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/chi-pheo.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Chí Phèo',0,1,3,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_3 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/tat-den.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Tắt đèn',0,1,4,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_4 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Vợ nhặt',0,1,5,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_5 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/de-men-phieu-luu-ky.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Dế Mèn phiêu lưu ký',0,1,6,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_6 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Nỗi buồn chiến tranh',0,1,7,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_7 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/canh-dong-bat-tan.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Cánh đồng bất tận',0,1,8,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_8 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/pride-and-prejudice.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Pride and Prejudice',0,1,9,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_9 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/1984.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa 1984',0,1,10,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_10 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/the-great-gatsby.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Great Gatsby',0,1,11,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_11 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/to-kill-a-mockingbird.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa To Kill a Mockingbird',0,1,12,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_12 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/norwegian-wood.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Norwegian Wood',0,1,13,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_13 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/one-hundred-years-of-solitude.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa One Hundred Years of Solitude',0,1,14,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_14 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/the-little-prince.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Little Prince',0,1,15,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_15 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/crime-and-punishment.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Crime and Punishment',0,1,16,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_16 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/wealth-of-nations.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Wealth of Nations',0,1,17,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_17 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/capital-volume-one.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Capital: Volume I',0,1,18,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_18 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/general-theory.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The General Theory of Employment, Interest and Money',0,1,19,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_19 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/why-nations-fail.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Why Nations Fail',0,1,20,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_20 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/capital-21st-century.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Capital in the Twenty-First Century',0,1,21,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_21 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Freakonomics',0,1,22,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_22 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/poor-economics.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Poor Economics',0,1,23,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_23 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/political-order-decay.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Political Order and Political Decay',0,1,24,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_24 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/english-grammar-in-use.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa English Grammar in Use',0,1,25,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_25 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Oxford Word Skills: Basic',0,1,26,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_26 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/official-cambridge-ielts.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Official Cambridge Guide to IELTS',0,1,27,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_27 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/practical-english-usage.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Practical English Usage',0,1,28,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_28 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/academic-vocabulary-in-use.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Academic Vocabulary in Use',0,1,29,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_29 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: ETS TOEIC Official Test-Preparation Guide',0,1,30,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_30 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/minna-no-nihongo-1.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Minna no Nihongo Shokyu I, 2nd Edition',0,1,31,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_31 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/minna-no-nihongo-2.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Minna no Nihongo Shokyu II, 2nd Edition',0,1,32,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_32 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/genki-1.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa GENKI I: An Integrated Course in Elementary Japanese',0,1,33,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_33 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/genki-2.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa GENKI II: An Integrated Course in Elementary Japanese',0,1,34,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_34 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/basic-kanji-book-1.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Basic Kanji Book, Volume 1',0,1,35,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_35 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/japanese-from-zero-1.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Japanese From Zero! 1',0,1,36,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_36 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/clean-code.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Clean Code',0,1,37,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_37 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/pragmatic-programmer.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Pragmatic Programmer',0,1,38,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_38 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/design-patterns.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Design Patterns',0,1,39,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_39 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/code-complete.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Code Complete',0,1,40,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_40 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/refactoring.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Refactoring',0,1,41,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_41 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/domain-driven-design.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Domain-Driven Design',0,1,42,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_42 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/c-programming-language.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The C Programming Language',0,1,43,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_43 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/effective-java.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Effective Java',0,1,44,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_44 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/python-crash-course.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Python Crash Course',0,1,45,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_45 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/deep-learning.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Deep Learning',0,1,46,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_46 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/hands-on-machine-learning.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Hands-On Machine Learning with Scikit-Learn, Keras, and TensorFlow',0,1,47,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_47 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Fluid Mechanics',0,1,48,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_48 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/shigleys-mechanical-design.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Shigley''s Mechanical Engineering Design',0,1,49,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_49 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/manufacturing-engineering.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Manufacturing Engineering and Technology',0,1,50,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_50 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/introduction-to-algorithms.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Introduction to Algorithms',0,1,51,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_51 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Computer Networking: A Top-Down Approach',0,1,52,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_52 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/operating-system-concepts.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Operating System Concepts',0,1,53,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_53 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/database-system-concepts.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Database System Concepts',0,1,54,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_54 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/artificial-intelligence-modern-approach.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Artificial Intelligence: A Modern Approach',0,1,55,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_55 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/thomas-calculus.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Thomas'' Calculus',0,1,56,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_56 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/university-physics.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa University Physics with Modern Physics',0,1,57,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_57 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/engineering-mechanics-statics.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Engineering Mechanics: Statics',0,1,58,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_58 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/engineering-mechanics-dynamics.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Engineering Mechanics: Dynamics',0,1,59,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_59 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/mechanics-of-materials.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Mechanics of Materials',0,1,60,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_60 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/fluid-mechanics-cengel.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Fluid Mechanics: Fundamentals and Applications',0,1,61,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_61 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Fundamentals of Heat and Mass Transfer',0,1,62,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_62 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Materials Science and Engineering: An Introduction',0,1,63,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_63 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/calculus-early-transcendentals.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Calculus: Early Transcendentals',0,1,64,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_64 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/linear-algebra-applications.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Linear Algebra and Its Applications',0,1,65,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_65 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/discrete-mathematics.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Discrete Mathematics and Its Applications',0,1,66,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_66 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/sapiens.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Sapiens: A Brief History of Humankind',0,1,67,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_67 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/guns-germs-steel.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Guns, Germs, and Steel',0,1,68,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_68 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/the-silk-roads.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Silk Roads',0,1,69,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_69 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/vietnam-a-new-history.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Vietnam: A New History',0,1,70,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_70 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Đại Việt sử ký toàn thư',0,1,71,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_71 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Lịch sử Việt Nam từ nguồn gốc đến giữa thế kỷ XX',0,1,72,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_72 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Vietnam 1945: The Quest for Power',0,1,73,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_73 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/bowling-alone.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Bowling Alone',0,1,74,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_74 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/the-culture-map.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Culture Map',0,1,75,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_75 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/orientalism.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Orientalism',0,1,76,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_76 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/imagined-communities.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Imagined Communities',0,1,77,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_77 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/the-righteous-mind.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa The Righteous Mind',0,1,78,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_78 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/books/outliers.jpg',NULL,N'image',N'jpg',NULL,NULL,N'Bìa Outliers',0,1,79,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_79 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Người Việt: Phẩm chất và thói hư tật xấu',0,1,80,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_80 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: [DỮ LIỆU MẪU] Sách tạm hết',0,1,1002,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_1002 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: dsa',0,1,1003,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_1003 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[BookId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',NULL,N'image',N'svg',400,560,N'Ảnh dự phòng: Sách test',0,1,1004,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_book_1004 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[AuthorId],[CreatedAt]) VALUES (N'LOCAL',N'/images/authors/george-orwell.jpg',N'jpg',N'George Orwell',0,1,19,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_author_19 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[AuthorId],[CreatedAt]) VALUES (N'LOCAL',N'/images/authors/nguyen-ngoc-tu.jpg',N'jpg',N'Nguyễn Ngọc Tư',0,1,84,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_author_84 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[AuthorId],[CreatedAt]) VALUES (N'LOCAL',N'/images/authors/to-hoai.jpg',N'jpg',N'Tô Hoài',0,1,93,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_author_93 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[AuthorId],[CreatedAt]) VALUES (N'LOCAL',N'/images/authors/jane-austen.jpg',N'jpg',N'Jane Austen',0,1,99,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_author_99 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[AuthorId],[CreatedAt]) VALUES (N'LOCAL',N'/images/authors/brian-kernighan.jpg',N'jpg',N'Brian W. Kernighan',0,1,103,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_author_103 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[CopyId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',N'svg',400,560,N'DEMO: ảnh dự phòng cuốn sách, chưa có ảnh chụp thực tế',0,1,@BookCopies_1_41,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_copy_41 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[CopyId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',N'svg',400,560,N'DEMO: ảnh dự phòng cuốn sách, chưa có ảnh chụp thực tế',0,1,@BookCopies_1_42,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_copy_42 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[CopyId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',N'svg',400,560,N'DEMO: ảnh dự phòng cuốn sách, chưa có ảnh chụp thực tế',0,1,@BookCopies_1_43,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_copy_43 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[CopyId],[CreatedAt]) VALUES (N'LOCAL',N'/images/book-placeholder.svg',N'svg',400,560,N'DEMO: ảnh dự phòng cuốn sách, chưa có ảnh chụp thực tế',0,1,@BookCopies_1_44,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_copy_44 int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[Width],[Height],[AltText],[SortOrder],[IsPrimary],[UserId],[CreatedAt]) VALUES (N'LOCAL',N'/images/demo-avatar.svg',N'svg',160,160,N'Avatar tài khoản mẫu',0,1,@Users_customer1,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_avatar int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[Format],[AltText],[SortOrder],[IsPrimary],[CopyId],[CreatedAt]) VALUES (N'LOCAL',N'/images/demo-intentionally-missing.jpg',N'jpg',N'DEMO: ảnh cố ý không tồn tại để kiểm thử fallback',1,0,@BookCopies_1_44,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_missing int=SCOPE_IDENTITY();
INSERT dbo.[MediaAssets] ([Provider],[Url],[PublicId],[ResourceType],[Format],[AltText],[SortOrder],[IsPrimary],[UserId],[CreatedAt]) VALUES (N'CLOUDINARY',N'https://res.cloudinary.com/demo/image/upload/sample.jpg',N'sample',N'image',N'jpg',N'DEMO: tài nguyên Cloudinary công khai, không phải ảnh sách hay người dùng',1,0,@Users_customer1,DATEADD(minute,-93600,@asof));
DECLARE @MediaAssets_cloud int=SCOPE_IDENTITY();
INSERT dbo.[RefreshTokens] ([UserId],[TokenHash],[FamilyId],[CreatedAt],[ExpiresAt],[RevokedAt],[ReplacedByTokenId]) VALUES (@Users_customer1,0x0b4ea0f381941f8330ec14933c994c952ba2a987af78127e9c946d56474eeecc,N'32ef6bc5-2c79-418a-9716-729dde4d6530',DATEADD(minute,-60,@asof),DATEADD(minute,10080,@asof),NULL,NULL);
DECLARE @RefreshTokens_active bigint=SCOPE_IDENTITY();
INSERT dbo.[RefreshTokens] ([UserId],[TokenHash],[FamilyId],[CreatedAt],[ExpiresAt],[RevokedAt],[ReplacedByTokenId]) VALUES (@Users_customer1,0x0abb636e780fbdd54b384879abc717d71db55cc3795be8a3e4f70bed694e259b,N'e4ef20e3-11ba-4dfb-8c05-f6a0cd2a9646',DATEADD(minute,-11520,@asof),DATEADD(minute,-1440,@asof),NULL,NULL);
DECLARE @RefreshTokens_expired bigint=SCOPE_IDENTITY();
INSERT dbo.[RefreshTokens] ([UserId],[TokenHash],[FamilyId],[CreatedAt],[ExpiresAt],[RevokedAt],[ReplacedByTokenId]) VALUES (@Users_customer1,0x03a5c0f22a643bc649c82f84f2b0bc866b5595ad6c72b40d8a9cb88f2d26f405,N'a19ae104-d231-4ab6-a6a9-b23d8d060e66',DATEADD(minute,-4320,@asof),DATEADD(minute,5760,@asof),DATEADD(minute,-1440,@asof),NULL);
DECLARE @RefreshTokens_revoked bigint=SCOPE_IDENTITY();
INSERT dbo.[RefreshTokens] ([UserId],[TokenHash],[FamilyId],[CreatedAt],[ExpiresAt],[RevokedAt],[ReplacedByTokenId]) VALUES (@Users_customer1,0xc97056825f222d57f76c021e602e126b52d55bcf503b5b424f74a7d801e4b6d1,N'836a4392-9aac-41f5-a0d9-0460743295b5',DATEADD(minute,-2880,@asof),DATEADD(minute,7200,@asof),DATEADD(minute,-1440,@asof),NULL);
DECLARE @RefreshTokens_rotated bigint=SCOPE_IDENTITY();
INSERT dbo.[RefreshTokens] ([UserId],[TokenHash],[FamilyId],[CreatedAt],[ExpiresAt],[RevokedAt],[ReplacedByTokenId]) VALUES (@Users_customer1,0xc623bddeff6df3de34d5a841826925ca351fe7754ee967219b219610674337b1,N'836a4392-9aac-41f5-a0d9-0460743295b5',DATEADD(minute,-1440,@asof),DATEADD(minute,8640,@asof),NULL,NULL);
DECLARE @RefreshTokens_replacement bigint=SCOPE_IDENTITY();
UPDATE dbo.[RefreshTokens] SET [ReplacedByTokenId]=@RefreshTokens_replacement WHERE [RefreshTokenId]=@RefreshTokens_rotated;
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_customer1,@Stores_1,N'ORDER',N'Thông báo mẫu ORDER',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',N'/account/notifications',DATEADD(minute,-120,@asof),DATEADD(minute,-60,@asof));
DECLARE @Notifications_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_customer2,@Stores_1,N'PAYMENT',N'Thông báo mẫu PAYMENT',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',N'/account/notifications',DATEADD(minute,-120,@asof),NULL);
DECLARE @Notifications_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_customer3,@Stores_1,N'RETURN',N'Thông báo mẫu RETURN',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',N'/account/notifications',DATEADD(minute,-120,@asof),NULL);
DECLARE @Notifications_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_manager2,@Stores_2,N'TRANSFER',N'Thông báo mẫu TRANSFER',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',N'/account/notifications',DATEADD(minute,-120,@asof),DATEADD(minute,-60,@asof));
DECLARE @Notifications_4 bigint=SCOPE_IDENTITY();
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_staff1,@Stores_1,N'STOCK_ALERT',N'Thông báo mẫu STOCK_ALERT',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',N'/account/notifications',DATEADD(minute,-120,@asof),NULL);
DECLARE @Notifications_5 bigint=SCOPE_IDENTITY();
INSERT dbo.[Notifications] ([UserId],[StoreId],[Type],[Title],[Content],[TargetUrl],[CreatedAt],[ReadAt]) VALUES (@Users_admin,NULL,N'SYSTEM',N'Thông báo mẫu SYSTEM',N'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',NULL,DATEADD(minute,-120,@asof),NULL);
DECLARE @Notifications_6 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (@Users_staff1,@Stores_1,N'ORDER_CREATE',N'DemoScenario',N'1',N'DEMO: nhật ký mẫu ORDER_CREATE',DATEADD(minute,-30,@asof),N'201ee05c-0691-4c7f-915e-bdb6ba99d9c6');
DECLARE @AuditLogs_1 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (NULL,@Stores_1,N'PAYMENT_CALLBACK',N'DemoScenario',N'2',N'DEMO: nhật ký mẫu PAYMENT_CALLBACK',DATEADD(minute,-30,@asof),N'42caec08-b40f-4648-bbd7-5747e2657439');
DECLARE @AuditLogs_2 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (@Users_manager1,@Stores_1,N'STOCK_TRANSFER',N'DemoScenario',N'3',N'DEMO: nhật ký mẫu STOCK_TRANSFER',DATEADD(minute,-30,@asof),N'21541835-ec95-46e3-a558-792af9f2dff5');
DECLARE @AuditLogs_3 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (@Users_locked,@Stores_1,N'LOGIN_REJECTED',N'DemoScenario',N'4',N'DEMO: nhật ký mẫu LOGIN_REJECTED',DATEADD(minute,-30,@asof),N'15bd0cc6-a1af-4c8b-9abd-1cbcc59d56d6');
DECLARE @AuditLogs_4 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (@Users_customer1,NULL,N'TOKEN_ROTATE',N'RefreshTokens',CONVERT(varchar(100),@RefreshTokens_replacement),N'DEMO: nhật ký mẫu TOKEN_ROTATE',DATEADD(minute,-30,@asof),N'4eb690a5-b9e8-4489-93aa-9fea5d40640d');
DECLARE @AuditLogs_5 bigint=SCOPE_IDENTITY();
INSERT dbo.[AuditLogs] ([ActorId],[StoreId],[Action],[EntityType],[EntityId],[Summary],[CreatedAt],[CorrelationId]) VALUES (@Users_admin,NULL,N'DEMO_SEED_V1',N'DemoDataset',N'v1',N'DEMO: bộ dữ liệu mẫu v1; CreatedAt là mốc UTC để kiểm thử thời gian.',@asof,N'64bbe91f-7fd9-4c76-9437-887ffa01ba9e');
DECLARE @AuditLogs_marker bigint=SCOPE_IDENTITY();
-- Read-only verification of the pristine DEMO v1 fixture. Counts intentionally fail after business data changes.
SET NOCOUNT ON;
DECLARE @seedAsOf datetime2(3)=(SELECT MAX(CreatedAt) FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1' AND EntityType='DemoDataset');
IF @seedAsOf IS NULL THROW 51211, 'Demo seed marker not found.', 1;
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[AuditLogs])<>6) THROW 51210, N'Rows AuditLogs', 1;
PRINT N'PASS: Rows AuditLogs';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Authors])<>122) THROW 51210, N'Rows Authors', 1;
PRINT N'PASS: Rows Authors';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[BookAuthors])<>134) THROW 51210, N'Rows BookAuthors', 1;
PRINT N'PASS: Rows BookAuthors';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[BookConditions])<>4) THROW 51210, N'Rows BookConditions', 1;
PRINT N'PASS: Rows BookConditions';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[BookCopies])<>249) THROW 51210, N'Rows BookCopies', 1;
PRINT N'PASS: Rows BookCopies';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Books])<>83) THROW 51210, N'Rows Books', 1;
PRINT N'PASS: Rows Books';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[CartItems])<>7) THROW 51210, N'Rows CartItems', 1;
PRINT N'PASS: Rows CartItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Carts])<>7) THROW 51210, N'Rows Carts', 1;
PRINT N'PASS: Rows Carts';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Categories])<>10) THROW 51210, N'Rows Categories', 1;
PRINT N'PASS: Rows Categories';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[CustomerAddresses])<>5) THROW 51210, N'Rows CustomerAddresses', 1;
PRINT N'PASS: Rows CustomerAddresses';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[InventoryMovements])<>282) THROW 51210, N'Rows InventoryMovements', 1;
PRINT N'PASS: Rows InventoryMovements';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[MediaAssets])<>95) THROW 51210, N'Rows MediaAssets', 1;
PRINT N'PASS: Rows MediaAssets';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Notifications])<>6) THROW 51210, N'Rows Notifications', 1;
PRINT N'PASS: Rows Notifications';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[OrderItems])<>30) THROW 51210, N'Rows OrderItems', 1;
PRINT N'PASS: Rows OrderItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Orders])<>27) THROW 51210, N'Rows Orders', 1;
PRINT N'PASS: Rows Orders';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[OrderStatusHistory])<>94) THROW 51210, N'Rows OrderStatusHistory', 1;
PRINT N'PASS: Rows OrderStatusHistory';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Payments])<>27) THROW 51210, N'Rows Payments', 1;
PRINT N'PASS: Rows Payments';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Publishers])<>40) THROW 51210, N'Rows Publishers', 1;
PRINT N'PASS: Rows Publishers';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[PurchaseReceiptItems])<>253) THROW 51210, N'Rows PurchaseReceiptItems', 1;
PRINT N'PASS: Rows PurchaseReceiptItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[PurchaseReceipts])<>5) THROW 51210, N'Rows PurchaseReceipts', 1;
PRINT N'PASS: Rows PurchaseReceipts';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[RefreshTokens])<>5) THROW 51210, N'Rows RefreshTokens', 1;
PRINT N'PASS: Rows RefreshTokens';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Refunds])<>8) THROW 51210, N'Rows Refunds', 1;
PRINT N'PASS: Rows Refunds';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Roles])<>2) THROW 51210, N'Rows Roles', 1;
PRINT N'PASS: Rows Roles';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[SalesReturnItems])<>9) THROW 51210, N'Rows SalesReturnItems', 1;
PRINT N'PASS: Rows SalesReturnItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[SalesReturns])<>9) THROW 51210, N'Rows SalesReturns', 1;
PRINT N'PASS: Rows SalesReturns';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[StaffStoreAssignments])<>8) THROW 51210, N'Rows StaffStoreAssignments', 1;
PRINT N'PASS: Rows StaffStoreAssignments';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[StockReservations])<>23) THROW 51210, N'Rows StockReservations', 1;
PRINT N'PASS: Rows StockReservations';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[StocktakeItems])<>10) THROW 51210, N'Rows StocktakeItems', 1;
PRINT N'PASS: Rows StocktakeItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Stocktakes])<>5) THROW 51210, N'Rows Stocktakes', 1;
PRINT N'PASS: Rows Stocktakes';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[StockTransferItems])<>7) THROW 51210, N'Rows StockTransferItems', 1;
PRINT N'PASS: Rows StockTransferItems';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[StockTransfers])<>5) THROW 51210, N'Rows StockTransfers', 1;
PRINT N'PASS: Rows StockTransfers';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Stores])<>5) THROW 51210, N'Rows Stores', 1;
PRINT N'PASS: Rows Stores';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Suppliers])<>4) THROW 51210, N'Rows Suppliers', 1;
PRINT N'PASS: Rows Suppliers';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[UserRoles])<>8) THROW 51210, N'Rows UserRoles', 1;
PRINT N'PASS: Rows UserRoles';
IF EXISTS (SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[Users])<>16) THROW 51210, N'Rows Users', 1;
PRINT N'PASS: Rows Users';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'LOCKED'),(N'PENDING')) e(value) EXCEPT SELECT [Status] FROM dbo.[Users]) THROW 51210, N'Coverage Users.Status', 1;
PRINT N'PASS: Coverage Users.Status';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'TEMPORARILY_CLOSED'),(N'CLOSED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Stores]) THROW 51210, N'Coverage Stores.Status', 1;
PRINT N'PASS: Coverage Stores.Status';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'ENDED')) e(value) EXCEPT SELECT [Status] FROM dbo.[StaffStoreAssignments]) THROW 51210, N'Coverage StaffStoreAssignments.Status', 1;
PRINT N'PASS: Coverage StaffStoreAssignments.Status';
IF EXISTS (SELECT value FROM (VALUES (N'MANAGER'),(N'STAFF')) e(value) EXCEPT SELECT [StoreRole] FROM dbo.[StaffStoreAssignments]) THROW 51210, N'Coverage StaffStoreAssignments.StoreRole', 1;
PRINT N'PASS: Coverage StaffStoreAssignments.StoreRole';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'INACTIVE')) e(value) EXCEPT SELECT [Status] FROM dbo.[Suppliers]) THROW 51210, N'Coverage Suppliers.Status', 1;
PRINT N'PASS: Coverage Suppliers.Status';
IF EXISTS (SELECT value FROM (VALUES (N'INDIVIDUAL'),(N'ORGANIZATION')) e(value) EXCEPT SELECT [SupplierType] FROM dbo.[Suppliers]) THROW 51210, N'Coverage Suppliers.SupplierType', 1;
PRINT N'PASS: Coverage Suppliers.SupplierType';
IF EXISTS (SELECT value FROM (VALUES (N'DRAFT'),(N'RECEIVED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[PurchaseReceipts]) THROW 51210, N'Coverage PurchaseReceipts.Status', 1;
PRINT N'PASS: Coverage PurchaseReceipts.Status';
IF EXISTS (SELECT value FROM (VALUES (N'AVAILABLE'),(N'RESERVED'),(N'SOLD'),(N'IN_TRANSIT'),(N'DAMAGED'),(N'LOST')) e(value) EXCEPT SELECT [Status] FROM dbo.[BookCopies]) THROW 51210, N'Coverage BookCopies.Status', 1;
PRINT N'PASS: Coverage BookCopies.Status';
IF EXISTS (SELECT value FROM (VALUES (N'LOCAL'),(N'CLOUDINARY')) e(value) EXCEPT SELECT [Provider] FROM dbo.[MediaAssets]) THROW 51210, N'Coverage MediaAssets.Provider', 1;
PRINT N'PASS: Coverage MediaAssets.Provider';
IF EXISTS (SELECT value FROM (VALUES (N'DRAFT'),(N'APPROVED'),(N'IN_TRANSIT'),(N'RECEIVED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[StockTransfers]) THROW 51210, N'Coverage StockTransfers.Status', 1;
PRINT N'PASS: Coverage StockTransfers.Status';
IF EXISTS (SELECT value FROM (VALUES (N'PENDING'),(N'RECEIVED'),(N'MISSING'),(N'DAMAGED')) e(value) EXCEPT SELECT [ReceiptStatus] FROM dbo.[StockTransferItems]) THROW 51210, N'Coverage StockTransferItems.ReceiptStatus', 1;
PRINT N'PASS: Coverage StockTransferItems.ReceiptStatus';
IF EXISTS (SELECT value FROM (VALUES (N'DRAFT'),(N'COUNTING'),(N'FINALIZED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Stocktakes]) THROW 51210, N'Coverage Stocktakes.Status', 1;
PRINT N'PASS: Coverage Stocktakes.Status';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'CHECKED_OUT'),(N'ABANDONED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Carts]) THROW 51210, N'Coverage Carts.Status', 1;
PRINT N'PASS: Coverage Carts.Status';
IF EXISTS (SELECT value FROM (VALUES (N'PENDING'),(N'CONFIRMED'),(N'PROCESSING'),(N'SHIPPED'),(N'COMPLETED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Orders]) THROW 51210, N'Coverage Orders.Status', 1;
PRINT N'PASS: Coverage Orders.Status';
IF EXISTS (SELECT value FROM (VALUES (N'ONLINE'),(N'POS')) e(value) EXCEPT SELECT [Channel] FROM dbo.[Orders]) THROW 51210, N'Coverage Orders.Channel', 1;
PRINT N'PASS: Coverage Orders.Channel';
IF EXISTS (SELECT value FROM (VALUES (N'ACTIVE'),(N'CONSUMED'),(N'EXPIRED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[StockReservations]) THROW 51210, N'Coverage StockReservations.Status', 1;
PRINT N'PASS: Coverage StockReservations.Status';
IF EXISTS (SELECT value FROM (VALUES (N'PENDING'),(N'SUCCEEDED'),(N'FAILED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Payments]) THROW 51210, N'Coverage Payments.Status', 1;
PRINT N'PASS: Coverage Payments.Status';
IF EXISTS (SELECT value FROM (VALUES (N'CASH'),(N'BANK_TRANSFER'),(N'CARD'),(N'E_WALLET'),(N'COD')) e(value) EXCEPT SELECT [Method] FROM dbo.[Payments]) THROW 51210, N'Coverage Payments.Method', 1;
PRINT N'PASS: Coverage Payments.Method';
IF EXISTS (SELECT value FROM (VALUES (N'REQUESTED'),(N'APPROVED'),(N'COMPLETED'),(N'REJECTED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[SalesReturns]) THROW 51210, N'Coverage SalesReturns.Status', 1;
PRINT N'PASS: Coverage SalesReturns.Status';
IF EXISTS (SELECT value FROM (VALUES (N'PENDING'),(N'ACCEPTED'),(N'REJECTED')) e(value) EXCEPT SELECT [Status] FROM dbo.[SalesReturnItems]) THROW 51210, N'Coverage SalesReturnItems.Status', 1;
PRINT N'PASS: Coverage SalesReturnItems.Status';
IF EXISTS (SELECT value FROM (VALUES (N'RESTOCK'),(N'DAMAGED')) e(value) EXCEPT SELECT [Resolution] FROM dbo.[SalesReturnItems]) THROW 51210, N'Coverage SalesReturnItems.Resolution', 1;
PRINT N'PASS: Coverage SalesReturnItems.Resolution';
IF EXISTS (SELECT value FROM (VALUES (N'PENDING'),(N'SUCCEEDED'),(N'FAILED'),(N'CANCELLED')) e(value) EXCEPT SELECT [Status] FROM dbo.[Refunds]) THROW 51210, N'Coverage Refunds.Status', 1;
PRINT N'PASS: Coverage Refunds.Status';
IF EXISTS (SELECT value FROM (VALUES (N'RECEIPT'),(N'SALE'),(N'TRANSFER_OUT'),(N'TRANSFER_IN'),(N'RETURN'),(N'ADJUSTMENT')) e(value) EXCEPT SELECT [MovementType] FROM dbo.[InventoryMovements]) THROW 51210, N'Coverage InventoryMovements.MovementType', 1;
PRINT N'PASS: Coverage InventoryMovements.MovementType';
IF EXISTS (SELECT r.ReceiptId FROM dbo.PurchaseReceipts r JOIN dbo.PurchaseReceiptItems i ON i.ReceiptId=r.ReceiptId WHERE r.ReceiptCode LIKE 'DEMO-%' GROUP BY r.ReceiptId,r.TotalAmount HAVING r.TotalAmount<>SUM(i.Quantity*i.UnitCost)) THROW 51210, N'Receipt totals', 1;
PRINT N'PASS: Receipt totals';
IF EXISTS (SELECT i.ReceiptItemId FROM dbo.PurchaseReceiptItems i JOIN dbo.PurchaseReceipts r ON r.ReceiptId=i.ReceiptId OUTER APPLY(SELECT COUNT(*) n FROM dbo.BookCopies c WHERE c.PurchaseReceiptItemId=i.ReceiptItemId)x WHERE r.ReceiptCode LIKE 'DEMO-%' AND x.n<>CASE WHEN r.Status='RECEIVED' THEN i.Quantity ELSE 0 END) THROW 51210, N'Received quantities and no stock for drafts', 1;
PRINT N'PASS: Received quantities and no stock for drafts';
IF EXISTS (SELECT o.OrderId FROM dbo.Orders o JOIN dbo.OrderItems i ON i.OrderId=o.OrderId WHERE o.OrderCode LIKE 'DEMO-%' GROUP BY o.OrderId,o.Subtotal,o.DiscountAmount,o.TotalAmount,o.ShippingFee HAVING o.Subtotal<>SUM(i.UnitPrice) OR o.DiscountAmount<>SUM(i.DiscountAmount) OR o.TotalAmount<>SUM(i.LineTotal)+o.ShippingFee) THROW 51210, N'Order totals versus lines', 1;
PRINT N'PASS: Order totals versus lines';
IF EXISTS (SELECT o.OrderId FROM dbo.Orders o OUTER APPLY(SELECT COALESCE(SUM(p.Amount),0) amount FROM dbo.Payments p WHERE p.OrderId=o.OrderId AND p.Status='SUCCEEDED')x WHERE o.OrderCode LIKE 'DEMO-%' AND (x.amount>o.TotalAmount OR (o.Status='COMPLETED' AND x.amount<>o.TotalAmount))) THROW 51210, N'Successful payments reconcile', 1;
PRINT N'PASS: Successful payments reconcile';
IF EXISTS (SELECT p.PaymentId FROM dbo.Payments p JOIN dbo.Refunds r ON r.PaymentId=p.PaymentId WHERE r.IdempotencyKey LIKE 'DEMO-%' AND r.Status IN ('PENDING','SUCCEEDED') GROUP BY p.PaymentId,p.Status,p.Amount HAVING p.Status<>'SUCCEEDED' OR SUM(r.Amount)>p.Amount) THROW 51210, N'Refund amounts bounded by successful payments', 1;
PRINT N'PASS: Refund amounts bounded by successful payments';
IF EXISTS (SELECT r.ReturnItemId FROM dbo.SalesReturnItems r JOIN dbo.OrderItems i ON i.OrderItemId=r.OrderItemId WHERE r.RefundAmount>i.LineTotal) THROW 51210, N'Return line amounts bounded', 1;
PRINT N'PASS: Return line amounts bounded';
IF EXISTS (SELECT r.ReturnId FROM dbo.SalesReturns r CROSS APPLY(SELECT COALESCE(SUM(x.RefundAmount),0) amount FROM dbo.SalesReturnItems x WHERE x.ReturnId=r.ReturnId AND x.Status='ACCEPTED')a CROSS APPLY(SELECT COALESCE(SUM(x.Amount),0) amount FROM dbo.Refunds x WHERE x.ReturnId=r.ReturnId AND x.Status IN ('SUCCEEDED','PENDING'))b WHERE b.amount>a.amount) THROW 51210, N'Refunds tied to accepted return value', 1;
PRINT N'PASS: Refunds tied to accepted return value';
IF EXISTS (SELECT c.CopyId FROM dbo.BookCopies c OUTER APPLY(SELECT COUNT(*) n FROM dbo.StockReservations r WHERE r.CopyId=c.CopyId AND r.Status='ACTIVE')x WHERE c.CopyCode LIKE 'DEMO-%' AND ((c.Status='RESERVED' AND x.n<>1) OR (c.Status<>'RESERVED' AND x.n<>0))) THROW 51210, N'Reserved copies and active reservations agree', 1;
PRINT N'PASS: Reserved copies and active reservations agree';
IF EXISTS (SELECT o.OrderId FROM dbo.Orders o OUTER APPLY(SELECT TOP(1) h.ToStatus FROM dbo.OrderStatusHistory h WHERE h.OrderId=o.OrderId ORDER BY h.ChangedAt DESC,h.HistoryId DESC)x WHERE o.OrderCode LIKE 'DEMO-%' AND (x.ToStatus IS NULL OR x.ToStatus<>o.Status)) THROW 51210, N'Last order history matches current status', 1;
PRINT N'PASS: Last order history matches current status';
IF EXISTS (SELECT OrderId FROM (SELECT h.*,LAG(ToStatus) OVER(PARTITION BY OrderId ORDER BY ChangedAt,HistoryId) previous FROM dbo.OrderStatusHistory h)x WHERE (previous IS NULL AND FromStatus IS NOT NULL) OR (previous IS NOT NULL AND (FromStatus IS NULL OR FromStatus<>previous))) THROW 51210, N'Order history chain and timestamps', 1;
PRINT N'PASS: Order history chain and timestamps';
IF EXISTS (SELECT c.CopyId FROM dbo.StockTransferItems i JOIN dbo.StockTransfers t ON t.TransferId=i.TransferId JOIN dbo.BookCopies c ON c.CopyId=i.CopyId WHERE t.TransferCode LIKE 'DEMO-%' AND ((t.Status='IN_TRANSIT' AND c.Status<>'IN_TRANSIT') OR (i.ReceiptStatus='RECEIVED' AND (c.StoreId<>t.ToStoreId OR c.Status<>'AVAILABLE')) OR (i.ReceiptStatus='DAMAGED' AND (c.StoreId<>t.ToStoreId OR c.Status<>'DAMAGED')) OR (i.ReceiptStatus='MISSING' AND c.Status<>'LOST'))) THROW 51210, N'Transfer receipt state matches copies', 1;
PRINT N'PASS: Transfer receipt state matches copies';
IF EXISTS (SELECT c.CopyId FROM dbo.BookCopies c WHERE c.CopyCode LIKE 'DEMO-%' AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.CopyId=c.CopyId AND m.MovementType='RECEIPT' AND m.ReceiptItemId=c.PurchaseReceiptItemId)) THROW 51210, N'Receipt movement for every seeded copy', 1;
PRINT N'PASS: Receipt movement for every seeded copy';
IF EXISTS (SELECT i.OrderItemId FROM dbo.OrderItems i JOIN dbo.Orders o ON o.OrderId=i.OrderId WHERE o.OrderCode LIKE 'DEMO-%' AND o.Status IN ('SHIPPED','COMPLETED') AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.OrderItemId=i.OrderItemId AND m.MovementType='SALE')) THROW 51210, N'Sale movement for each fulfilled order line', 1;
PRINT N'PASS: Sale movement for each fulfilled order line';
IF EXISTS (SELECT i.ReturnItemId FROM dbo.SalesReturnItems i WHERE i.Status='ACCEPTED' AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.ReturnItemId=i.ReturnItemId AND m.MovementType='RETURN')) THROW 51210, N'Return movement for every accepted return line', 1;
PRINT N'PASS: Return movement for every accepted return line';
IF EXISTS (SELECT c.CopyId FROM dbo.BookCopies c CROSS APPLY(SELECT TOP(1) m.* FROM dbo.InventoryMovements m WHERE m.CopyId=c.CopyId ORDER BY m.OccurredAt DESC,m.MovementId DESC)m WHERE c.CopyCode LIKE 'DEMO-%' AND ((m.MovementType='SALE' AND c.Status<>'SOLD') OR (m.MovementType='TRANSFER_OUT' AND c.Status NOT IN ('IN_TRANSIT','LOST')) OR (m.MovementType IN ('RECEIPT','RETURN','TRANSFER_IN') AND c.Status NOT IN ('AVAILABLE','RESERVED','DAMAGED')))) THROW 51210, N'Latest movement and copy disposition', 1;
PRINT N'PASS: Latest movement and copy disposition';
IF EXISTS (SELECT i.StocktakeItemId FROM dbo.StocktakeItems i JOIN dbo.Stocktakes s ON s.StocktakeId=i.StocktakeId WHERE s.Status='FINALIZED' AND i.ActualPresent IS NULL) THROW 51210, N'Finalized stocktakes fully counted', 1;
PRINT N'PASS: Finalized stocktakes fully counted';
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1 UNION ALL SELECT 1 FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1) THROW 51210, N'No disabled or untrusted constraints', 1;
PRINT N'PASS: No disabled or untrusted constraints';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.StockReservations WHERE Status='ACTIVE' AND ExpiresAt>@seedAsOf) OR NOT EXISTS(SELECT 1 FROM dbo.StockReservations WHERE Status='ACTIVE' AND ExpiresAt<@seedAsOf)) THROW 51210, N'Active and overdue hold fixtures at seed time', 1;
PRINT N'PASS: Active and overdue hold fixtures at seed time';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ExpiresAt>@seedAsOf AND RevokedAt IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ExpiresAt<@seedAsOf) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE RevokedAt IS NOT NULL AND ReplacedByTokenId IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ReplacedByTokenId IS NOT NULL)) THROW 51210, N'Token expiry revocation and rotation coverage', 1;
PRINT N'PASS: Token expiry revocation and rotation coverage';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Notifications WHERE ReadAt IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.Notifications WHERE ReadAt IS NOT NULL)) THROW 51210, N'Read and unread notifications', 1;
PRINT N'PASS: Read and unread notifications';
IF EXISTS (SELECT ReservationId FROM dbo.StockReservations WHERE Status='EXPIRED' AND ReleasedAt<ExpiresAt) THROW 51210, N'Expired reservations released after expiration', 1;
PRINT N'PASS: Expired reservations released after expiration';
IF EXISTS (SELECT r.ReservationId FROM dbo.StockReservations r JOIN dbo.Orders o ON o.OrderId=r.OrderId WHERE o.Status='CANCELLED' AND (r.ReleasedAt IS NULL OR r.ReleasedAt>o.UpdatedAt)) THROW 51210, N'Cancelled orders have released holds by cancellation', 1;
PRINT N'PASS: Cancelled orders have released holds by cancellation';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Payments f JOIN dbo.Payments s ON s.OrderId=f.OrderId WHERE f.IdempotencyKey='DEMO-PAY-FAILED-PAYMENT-RETRY' AND s.IdempotencyKey='DEMO-PAY-PAYMENT-RETRY' AND f.CreatedAt<s.CreatedAt)) THROW 51210, N'Payment retry follows failed attempt', 1;
PRINT N'PASS: Payment retry follows failed attempt';
IF EXISTS (SELECT b.BookId,s.StoreId FROM dbo.Books b CROSS JOIN dbo.Stores s WHERE s.StoreCode IN ('DEMO-S1','DEMO-S2','DEMO-S3') AND NOT EXISTS(SELECT 1 FROM dbo.BookCopies c JOIN dbo.PurchaseReceiptItems i ON i.ReceiptItemId=c.PurchaseReceiptItemId JOIN dbo.PurchaseReceipts r ON r.ReceiptId=i.ReceiptId WHERE c.BookId=b.BookId AND r.StoreId=s.StoreId)) THROW 51210, N'Every catalog title represented at each initial branch', 1;
PRINT N'PASS: Every catalog title represented at each initial branch';
IF EXISTS (SELECT r.ReturnId FROM dbo.SalesReturns r JOIN dbo.Orders o ON o.OrderId=r.OrderId WHERE r.CreatedAt<o.UpdatedAt OR o.Status<>'COMPLETED') THROW 51210, N'Return occurs after sale', 1;
PRINT N'PASS: Return occurs after sale';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Carts c JOIN dbo.Users u ON u.UserId=c.UserId WHERE u.Username='nam' AND NOT EXISTS(SELECT 1 FROM dbo.CartItems i WHERE i.CartId=c.CartId)) OR EXISTS(SELECT 1 FROM dbo.Orders o JOIN dbo.Users u ON u.UserId=o.CustomerId WHERE u.Username='nam')) THROW 51210, N'Empty cart fixture and empty customer history', 1;
PRINT N'PASS: Empty cart fixture and empty customer history';
IF EXISTS (SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Orders WHERE OrderCode='DEMO-GUEST' AND CustomerId IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.Orders o WHERE o.OrderCode='DEMO-FREE' AND o.TotalAmount=0 AND NOT EXISTS(SELECT 1 FROM dbo.Payments p WHERE p.OrderId=o.OrderId))) THROW 51210, N'Guest and zero amount order fixtures', 1;
PRINT N'PASS: Guest and zero amount order fixtures';
PRINT 'All 85 demo coverage and consistency checks passed.';

COMMIT TRANSACTION;
PRINT 'DEMO v1 committed.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO


-- ============================================================================
-- BƯỚC 4: CHUẨN HÓA USERNAME CÁC TÀI KHOẢN DEMO (ADMIN, MANAGER, STAFF, KHANG...)
-- File gốc: database/008-rename-demo-accounts.sql
-- ============================================================================

SET NOCOUNT ON; SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @m TABLE(OldName nvarchar(50) COLLATE Latin1_General_100_CI_AS,NewName nvarchar(50) COLLATE Latin1_General_100_CI_AS,Email nvarchar(254) COLLATE Latin1_General_100_CI_AS,FullName nvarchar(150),PasswordHash varchar(255));
INSERT @m VALUES
(N'demo.admin',N'admin',N'demo.admin@example.invalid',N'Quản trị viên',N'$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.'),
(N'demo.manager1',N'manager',N'demo.manager1@example.invalid',N'Nguyễn Đức Long',N'$2a$12$h/V9eOyEmJHWg/jK9jmmAuRJl6.RtivUMG/t8Rd3CcWhCF2BcPtoe'),
(N'demo.manager2',N'manager2',N'demo.manager2@example.invalid',N'Trần Quốc Hùng',N'$2a$12$GBN8xQVfueGzURql9Hn4GejEbNMiPKy8qglaHXehCsGGy0GQat95e'),
(N'demo.manager3',N'manager3',N'demo.manager3@example.invalid',N'Lê Thanh Hà',N'$2a$12$Z.pF43Vu0h8LbAIv7WzGqeAnVgHDNwvP1Gjx/cHOFZEp/aYwd3IkG'),
(N'demo.staff1',N'staff',N'demo.staff1@example.invalid',N'Nguyễn Quốc Bảo',N'$2a$12$rJsNblLj8g/F0BlacJjegOBajYuf8l9HfTT2TxmlTVbrclnoq1EsO'),
(N'demo.staff2',N'staff2',N'demo.staff2@example.invalid',N'Trần Ngọc Mai',N'$2a$12$ur8HJ7atr9yRfoKslQZdauGe4COWMQ0CNJVfAZm2FGbg77IOvLy9W'),
(N'demo.staff3',N'staff3',N'demo.staff3@example.invalid',N'Lê Tuấn Anh',N'$2a$12$D5IblYQH.m52BZ9N24NpY.gGSOmf7CIKHjmo1s9bGzjLuM0ywZL7i'),
(N'demo.former',N'staff4',N'demo.former@example.invalid',N'Phạm Minh Đức',N'$2a$12$atr9So0g8TIPqoFzktf6rOl28GCfU6yrSqDJ5oOQvgpKQz5kIKEFK'),
(N'demo.lockedstaff',N'staff5',N'demo.lockedstaff@example.invalid',N'Đỗ Thanh Tâm',N'$2a$12$lB5e8PUkOYTBQUONPq3Z3e8F6gXKMG1rD5rHpwaKuXM/dcEL5b4QO'),
(N'demo.customer1',N'khang',N'demo.customer1@example.invalid',N'Nguyễn Minh Khang',N'$2a$12$q4Q/bX9x8Vx7IKe7Qa8P4O1ad.ZPRwOMqDO7Aplq14a.y0aR4vuli'),
(N'demo.customer2',N'hoang',N'demo.customer2@example.invalid',N'Trần Hoàng',N'$2a$12$1eQpYloy/C2qxgG1aMVL1uekYHqwrKGzhaD7JA.4Xw3H5YI39N6rG'),
(N'demo.customer3',N'van',N'demo.customer3@example.invalid',N'Lê Ngọc Vân',N'$2a$12$6XPhmt6tTWm/2hVM6/l3ceRkpFMjdDcQ/eWhsAaSy/sq3wcCWhpL2'),
(N'demo.locked',N'minh',N'demo.locked@example.invalid',N'Phạm Minh',N'$2a$12$tt6uWQRseJ4YaRDgSHDJqewArJTNR2M107ldJZ.fitMAUL03/IgLi'),
(N'demo.pending',N'linh',N'demo.pending@example.invalid',N'Đỗ Thùy Linh',N'$2a$12$jOsyJ676O.c1fAXy7ji/q.SyEFIWcEXM5X6H/T/V1m2YfD.8OfHIq'),
(N'demo.empty',N'nam',N'demo.empty@example.invalid',N'Nguyễn Hoài Nam',N'$2a$12$F5RkjAybyX/A26doqExmneWfrInAWopF9qRxU7pOjgKnHeBMcS/Li'),
(N'demo.unassigned',N'huy',N'demo.unassigned@example.invalid',N'Trần Quang Huy',N'$2a$12$Yl.z3sbdw93sKF/EgEYLTey244ylprrzy5tpQGgn3RlWEVNgjAvDO');
IF (SELECT COUNT(*) FROM dbo.Users u WITH(UPDLOCK,HOLDLOCK) JOIN @m m ON m.Email=u.Email AND (u.Username=m.OldName OR u.Username=m.NewName))<>16
 THROW 51500,'Expected 16 identifiable demo accounts; no changes made.',1;
IF EXISTS(SELECT 1 FROM dbo.Users u JOIN @m m ON u.Username=m.NewName WHERE u.Email<>m.Email)
 THROW 51501,'A requested username belongs to another account.',1;
UPDATE u SET Username=m.NewName,FullName=m.FullName,PasswordHash=m.PasswordHash,UpdatedAt=SYSUTCDATETIME()
FROM dbo.Users u JOIN @m m ON u.Email=m.Email;
IF @@ROWCOUNT<>16 THROW 51502,'Unexpected updated user count.',1;
COMMIT TRANSACTION;
PRINT 'Updated 16 demo accounts; IDs, statuses, roles and related records preserved.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;

GO


-- ============================================================================
-- BƯỚC 5: BỔ SUNG BẢNG OTP AUTHCHALLENGES VÀ CỘT AUTHVERSION THU HỒI JWT
-- File gốc: database/009-authentication.sql
-- ============================================================================

SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
BEGIN TRY
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Users','AuthVersion') IS NULL
 ALTER TABLE dbo.Users ADD AuthVersion int NOT NULL CONSTRAINT DF_Users_AuthVersion DEFAULT(0);
IF OBJECT_ID('dbo.AuthChallenges','U') IS NULL
BEGIN
 CREATE TABLE dbo.AuthChallenges(
  ChallengeId varchar(36) CONSTRAINT PK_AuthChallenges PRIMARY KEY,
  Purpose varchar(16) NOT NULL,
  Email nvarchar(254) NOT NULL,
  Username nvarchar(50) NULL,
  FullName nvarchar(150) NULL,
  PasswordHash varchar(255) NULL,
  UserId int NULL CONSTRAINT FK_AuthChallenges_Users REFERENCES dbo.Users(UserId),
  CodeHash varchar(64) NOT NULL,
  CreatedAt datetime2(3) NOT NULL,
  ExpiresAt datetime2(3) NOT NULL,
  LastSentAt datetime2(3) NOT NULL,
  VerifiedAt datetime2(3) NULL,
  UsedAt datetime2(3) NULL,
  Attempts int NOT NULL CONSTRAINT DF_AuthChallenges_Attempts DEFAULT(0),
  SendCount int NOT NULL CONSTRAINT DF_AuthChallenges_SendCount DEFAULT(1),
  CONSTRAINT CK_AuthChallenges_Purpose CHECK(Purpose IN ('REGISTER','RESET')),
  CONSTRAINT CK_AuthChallenges_Attempts CHECK(Attempts>=0 AND SendCount>0),
  CONSTRAINT CK_AuthChallenges_Expiry CHECK(ExpiresAt>CreatedAt)
 );
 CREATE INDEX IX_AuthChallenges_EmailCreated ON dbo.AuthChallenges(Email,CreatedAt);
END;
COMMIT;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK;
 THROW;
END CATCH;
GO


-- ============================================================================
-- BƯỚC 6: BỔ SUNG BẢNG ĐÁNH GIÁ SÁCH (BOOKREVIEWS)
-- File gốc: database/010-book-reviews.sql
-- ============================================================================

SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.BookReviews','U') IS NULL
BEGIN
 CREATE TABLE dbo.BookReviews (
  ReviewId bigint IDENTITY PRIMARY KEY,
  BookId int NOT NULL REFERENCES dbo.Books(BookId),
  UserId int NOT NULL REFERENCES dbo.Users(UserId),
  Rating int NOT NULL CHECK(Rating BETWEEN 1 AND 5),
  Comment nvarchar(2000) NULL,
  Status varchar(20) NOT NULL DEFAULT 'PENDING' CHECK(Status IN ('PENDING','APPROVED','HIDDEN')),
  CreatedAt datetime2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_BookReviews_UserBook UNIQUE(UserId,BookId)
 );
 CREATE INDEX IX_BookReviews_BookStatus ON dbo.BookReviews(BookId,Status) INCLUDE(Rating);
END;
COMMIT;
GO


-- ============================================================================
-- BƯỚC 7: BỔ SUNG CỘT ẢNH ĐẠI DIỆN AVATAR VÀ CẬP NHẬT RÀNG BUỘC OTP
-- File gốc: database/011-account-settings.sql
-- ============================================================================

SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Users','AvatarPath') IS NULL
 ALTER TABLE dbo.Users ADD AvatarPath varchar(100) NULL;
IF COL_LENGTH('dbo.AuthChallenges','VersionAtIssue') IS NULL
 ALTER TABLE dbo.AuthChallenges ADD VersionAtIssue int NULL;
IF OBJECT_ID('dbo.CK_AuthChallenges_Purpose','C') IS NOT NULL
 ALTER TABLE dbo.AuthChallenges DROP CONSTRAINT CK_AuthChallenges_Purpose;
ALTER TABLE dbo.AuthChallenges WITH CHECK ADD CONSTRAINT CK_AuthChallenges_Purpose CHECK(Purpose IN ('REGISTER','RESET','EMAIL'));
COMMIT;
GO


-- ============================================================================
-- BƯỚC 8: BỔ SUNG CỘT NGƯỜI DỊCH (TRANSLATOR) CHO SÁCH
-- File gốc: database/012-book-details.sql
-- ============================================================================

SET XACT_ABORT ON;
IF COL_LENGTH('dbo.Books','Translator') IS NULL
 ALTER TABLE dbo.Books ADD Translator nvarchar(250) NULL;
GO


-- ============================================================================
-- BƯỚC 9: SEED ĐÁNH GIÁ SAO VÀ THÔNG BÁO MẪU CHO TẤT CẢ SÁCH
-- File gốc: database/013-seed-reviews-and-notifications.sql
-- ============================================================================

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
GO


-- ============================================================================
-- BƯỚC 10: PHÂN QUYỀN VAI TRÒ ADMIN VÀ STAFF CHO CÁC TÀI KHOẢN KIỂM THỬ
-- File gốc: database/014-seed-staff-admin-roles.sql
-- ============================================================================

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleCode = 'STAFF')
BEGIN
 INSERT INTO dbo.Roles(RoleCode, RoleName)
 VALUES ('STAFF', N'Nhân viên cửa hàng');
END;

DECLARE @AdminRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'ADMIN');
DECLARE @StaffRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'STAFF');
DECLARE @CustomerRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'CUSTOMER');

-- Assign STAFF role to staff and manager accounts
INSERT INTO dbo.UserRoles(UserId, RoleId)
SELECT u.UserId, @StaffRoleId
FROM dbo.Users u
WHERE (u.Username LIKE 'staff%' OR u.Username LIKE 'manager%')
  AND NOT EXISTS (
   SELECT 1 FROM dbo.UserRoles ur WHERE ur.UserId = u.UserId AND ur.RoleId = @StaffRoleId
  );

-- Assign ADMIN role to admin and sang so the active test account has full Admin/Staff access
INSERT INTO dbo.UserRoles(UserId, RoleId)
SELECT u.UserId, @AdminRoleId
FROM dbo.Users u
WHERE u.Username IN ('admin', 'sang')
  AND NOT EXISTS (
   SELECT 1 FROM dbo.UserRoles ur WHERE ur.UserId = u.UserId AND ur.RoleId = @AdminRoleId
  );

COMMIT TRANSACTION;
GO
