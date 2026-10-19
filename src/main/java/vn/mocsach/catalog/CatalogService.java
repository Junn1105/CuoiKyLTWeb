package vn.mocsach.catalog;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import java.util.*;
import java.text.NumberFormat;

@Service
public class CatalogService {
 private final JdbcTemplate jdbc;
 public CatalogService(JdbcTemplate jdbc){this.jdbc=jdbc;}
 public List<Map<String,Object>> books(){
  var books=jdbc.queryForList("""
   SELECT b.BookId AS id,b.Title AS title,b.CoverImage AS cover,b.CategoryId AS categoryId,
    c.CategoryName AS categoryName,COALESCE(a.names,N'Đang cập nhật tác giả') AS authors,
    COALESCE(r.rating,0) AS rating,COALESCE(r.reviews,0) AS reviews,
    COALESCE(s.sales,0) AS sales,p.price,COALESCE(p.available,0) AS available
   FROM dbo.Books b JOIN dbo.Categories c ON c.CategoryId=b.CategoryId
   LEFT JOIN (SELECT ba.BookId,STRING_AGG(a.AuthorName,N', ') AS names FROM dbo.BookAuthors ba
     JOIN dbo.Authors a ON a.AuthorId=ba.AuthorId GROUP BY ba.BookId) a ON a.BookId=b.BookId
   LEFT JOIN (SELECT BookId,AVG(CAST(Rating AS decimal(10,2))) AS rating,COUNT(*) AS reviews
     FROM dbo.BookReviews WHERE Status='APPROVED' GROUP BY BookId) r ON r.BookId=b.BookId
   LEFT JOIN (SELECT cp.BookId,COUNT(*) AS sales FROM dbo.OrderItems i
     JOIN dbo.BookCopies cp ON cp.CopyId=i.CopyId JOIN dbo.Orders o ON o.OrderId=i.OrderId
     WHERE o.Status='COMPLETED' AND NOT EXISTS(SELECT 1 FROM dbo.SalesReturnItems ri
       JOIN dbo.SalesReturns sr ON sr.ReturnId=ri.ReturnId
       WHERE ri.OrderItemId=i.OrderItemId AND ri.Status='ACCEPTED' AND sr.Status='COMPLETED')
     GROUP BY cp.BookId) s ON s.BookId=b.BookId
   LEFT JOIN (SELECT BookId,MIN(SalePrice) AS price,COUNT(*) AS available
     FROM dbo.BookCopies WHERE Status='AVAILABLE' GROUP BY BookId) p ON p.BookId=b.BookId
   """);
  NumberFormat money=NumberFormat.getIntegerInstance(Locale.forLanguageTag("vi-VN"));
  for(var b:books){
   b.put("cover",cover(((Number)b.get("id")).intValue(),b.get("cover")));
   b.put("priceLabel",b.get("price")==null?"Tạm hết hàng":"Từ "+money.format(b.get("price"))+" ₫");
   b.put("ratingLabel",String.format(Locale.forLanguageTag("vi-VN"),"%.1f",((Number)b.get("rating")).doubleValue()));
  }
  books.sort(Comparator.<Map<String,Object>>comparingDouble(CatalogService::score).reversed().thenComparingInt(b->((Number)b.get("id")).intValue()));
  return books;
 }
 String cover(int id,Object raw){
  String image=cover(raw);
  String illustrated="/images/books/fallback/"+id+".svg";
  return image.equals("/images/book-placeholder.svg")&&new ClassPathResource("static"+illustrated).exists()?illustrated:image;
 }
 static double score(Map<String,Object> b){
  double count=((Number)b.get("reviews")).doubleValue(),rating=((Number)b.get("rating")).doubleValue(),sales=((Number)b.get("sales")).doubleValue();
  return (rating*count+3.5*5)/(count+5)+Math.log1p(sales)*0.7+Math.log1p(count)*0.15;
 }
 String cover(Object raw){
  String path=raw==null?"":raw.toString();
  return path.startsWith("/images/")&&!path.contains("..")&&new ClassPathResource("static"+path).exists()?path:"/images/book-placeholder.svg";
 }
 public List<Map<String,Object>> categories(List<Map<String,Object>> books){
  var categories=jdbc.queryForList("SELECT CategoryId AS id,CategoryName AS name FROM dbo.Categories ORDER BY CategoryName");
  for(var c:categories){var matches=books.stream().filter(b->((Number)b.get("categoryId")).intValue()==((Number)c.get("id")).intValue()).toList();c.put("count",matches.size());c.put("cover",matches.isEmpty()?"/images/book-placeholder.svg":matches.get(0).get("cover"));}
  return categories;
 }
}
