package vn.mocsach.catalog;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.JdbcTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import static org.junit.jupiter.api.Assertions.*;

@JdbcTest @Import(CatalogService.class)
class CatalogServiceTest {
 @Autowired JdbcTemplate jdbc; @Autowired CatalogService catalog;
 @BeforeEach void prepare(){
  jdbc.execute("CREATE SCHEMA IF NOT EXISTS dbo");
  for(String sql:new String[]{
   "CREATE TABLE dbo.Categories(CategoryId int,CategoryName nvarchar(100))",
   "CREATE TABLE dbo.Books(BookId int,Title nvarchar(255),CoverImage nvarchar(255),CategoryId int)",
   "CREATE TABLE dbo.Authors(AuthorId int,AuthorName nvarchar(150))",
   "CREATE TABLE dbo.BookAuthors(BookId int,AuthorId int)",
   "CREATE TABLE dbo.BookReviews(BookId int,Rating int,Status varchar(20))",
   "CREATE TABLE dbo.BookCopies(CopyId int,BookId int,Status varchar(20),SalePrice decimal(19,2))",
   "CREATE TABLE dbo.Orders(OrderId int,Status varchar(20))",
   "CREATE TABLE dbo.OrderItems(OrderItemId int,OrderId int,CopyId int)",
   "CREATE TABLE dbo.SalesReturns(ReturnId int,Status varchar(20))",
   "CREATE TABLE dbo.SalesReturnItems(ReturnId int,OrderItemId int,Status varchar(20))"
  })jdbc.execute(sql.replace("CREATE TABLE ","CREATE TABLE IF NOT EXISTS "));
  for(String name:new String[]{"SalesReturnItems","SalesReturns","OrderItems","Orders","BookCopies","BookReviews","BookAuthors","Authors","Books","Categories"})jdbc.update("DELETE FROM dbo."+name);
  jdbc.update("INSERT INTO dbo.Categories VALUES(1,'Văn học')");
  jdbc.update("INSERT INTO dbo.Books VALUES(1,'Sách A','/images/missing.jpg',1),(2,'Sách B',NULL,1)");
  jdbc.update("INSERT INTO dbo.Authors VALUES(1,'Tác giả A'),(2,'Tác giả B')");
  jdbc.update("INSERT INTO dbo.BookAuthors VALUES(1,1),(1,2)");
  jdbc.update("INSERT INTO dbo.BookReviews VALUES(1,5,'APPROVED'),(1,3,'APPROVED'),(1,1,'HIDDEN'),(2,5,'PENDING')");
  jdbc.update("INSERT INTO dbo.BookCopies VALUES(1,1,'SOLD',100),(2,1,'AVAILABLE',80),(3,2,'SOLD',100)");
  jdbc.update("INSERT INTO dbo.Orders VALUES(1,'COMPLETED'),(2,'CANCELLED'),(3,'COMPLETED')");
  jdbc.update("INSERT INTO dbo.OrderItems VALUES(1,1,1),(2,2,2),(3,3,3)");
  jdbc.update("INSERT INTO dbo.SalesReturns VALUES(1,'COMPLETED')");
  jdbc.update("INSERT INTO dbo.SalesReturnItems VALUES(1,3,'ACCEPTED')");
 }
 @Test void aggregatesApprovedReviewsAndCompletedNonReturnedSalesWithoutAuthorDuplication(){
  var books=catalog.books(); var first=books.get(0);
  assertEquals(1,((Number)first.get("id")).intValue());
  assertEquals(4,((Number)first.get("rating")).doubleValue());
  assertEquals(2,((Number)first.get("reviews")).intValue());
  assertEquals(1,((Number)first.get("sales")).intValue());
  assertEquals(0,((Number)books.get(1).get("sales")).intValue());
  assertEquals(0,((Number)books.get(1).get("reviews")).intValue());
  assertEquals("/images/book-placeholder.svg",first.get("cover"));
  assertEquals("Tạm hết hàng",books.get(1).get("priceLabel"));
 }
 @Test void categoryCountsAndMissingCoversRemainUsable(){var categories=catalog.categories(catalog.books());assertEquals(2,categories.get(0).get("count"));assertEquals("/images/book-placeholder.svg",catalog.cover("/images/../secret"));assertEquals("/images/books/1984.jpg",catalog.cover("/images/books/1984.jpg"));}
 @Test void popularityChangesRecommendationOrder(){jdbc.update("INSERT INTO dbo.Orders VALUES(4,'COMPLETED'),(5,'COMPLETED'),(6,'COMPLETED'),(7,'COMPLETED')");jdbc.update("INSERT INTO dbo.OrderItems VALUES(4,4,3),(5,5,3),(6,6,3),(7,7,3)");assertEquals(2,((Number)catalog.books().get(0).get("id")).intValue());}
}
