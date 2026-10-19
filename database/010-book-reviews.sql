USE [WebsiteQuanLyCuaHangSachCu];
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
