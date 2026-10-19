package vn.mocsach.catalog;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import vn.mocsach.auth.AuthProblem;
import java.util.*;

@Service
public class BookDetailService {
 private final JdbcTemplate jdbc;private final CatalogService catalog;
 public BookDetailService(JdbcTemplate jdbc,CatalogService catalog){this.jdbc=jdbc;this.catalog=catalog;}
 public Map<String,Object> detail(int id){
  var all=catalog.books();
  var book=all.stream().filter(b->((Number)b.get("id")).intValue()==id).findFirst().orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Không tìm thấy sách"));
  var extra=jdbc.queryForMap("SELECT b.ISBN AS isbn,b.PublishYear AS publishYear,b.Description AS description,b.Translator AS translator,p.PublisherName AS publisher FROM dbo.Books b LEFT JOIN dbo.Publishers p ON p.PublisherId=b.PublisherId WHERE b.BookId=?",id);
  for(var field:List.of("isbn","publishYear","translator","publisher")){Object value=extra.get(field);extra.put(field,value==null||value.toString().isBlank()?"Đang cập nhật":value);}
  Object description=extra.get("description");extra.put("description",description==null||description.toString().isBlank()?"Mô tả nội dung cuốn sách đang được cập nhật.":description);
  book.putAll(extra);
  var relatedIds=new HashSet<>(jdbc.queryForList("SELECT DISTINCT other.BookId FROM dbo.BookAuthors other JOIN dbo.BookAuthors own ON own.AuthorId=other.AuthorId WHERE own.BookId=? AND other.BookId<>?",Integer.class,id,id));
  book.put("related",all.stream().filter(b->relatedIds.contains(((Number)b.get("id")).intValue())).limit(8).toList());
  return book;
 }
 public List<Map<String,Object>> reviews(int id){return jdbc.queryForList("SELECT TOP 20 r.Rating AS rating,r.Comment AS comment,r.CreatedAt AS createdAt,u.FullName AS fullName FROM dbo.BookReviews r JOIN dbo.Users u ON u.UserId=r.UserId WHERE r.BookId=? AND r.Status='APPROVED' ORDER BY r.CreatedAt DESC,r.ReviewId DESC",id);}
 public List<Map<String,Object>> histogram(int id){
  var counts=jdbc.queryForList("SELECT Rating AS stars,COUNT(*) AS total FROM dbo.BookReviews WHERE BookId=? AND Status='APPROVED' GROUP BY Rating",id);
  long sum=counts.stream().mapToLong(r->((Number)r.get("total")).longValue()).sum();var result=new ArrayList<Map<String,Object>>();
  for(int stars=5;stars>=1;stars--){int target=stars;long n=counts.stream().filter(r->((Number)r.get("stars")).intValue()==target).mapToLong(r->((Number)r.get("total")).longValue()).sum();result.add(Map.of("stars",stars,"count",n,"percent",sum==0?0:Math.round(n*100.0/sum)));}
  return result;
 }
 public Map<String,Object> ownReview(int id,int userId){var rows=jdbc.queryForList("SELECT Rating AS rating,Comment AS comment,Status AS status FROM dbo.BookReviews WHERE BookId=? AND UserId=?",id,userId);return rows.isEmpty()?null:rows.get(0);}
 @Transactional public void review(int id,int userId,int rating,String comment){
  if(rating<1||rating>5)throw new AuthProblem("Vui lòng chọn từ 1 đến 5 sao.");
  comment=comment==null?"":comment.strip();if(comment.length()<3||comment.length()>2000)throw new AuthProblem("Bình luận cần từ 3 đến 2000 ký tự.");
  if(jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Books WHERE BookId=?",Integer.class,id)==0)throw new ResponseStatusException(HttpStatus.NOT_FOUND);
  if(jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Users WHERE UserId=? AND Status='ACTIVE'",Integer.class,userId)==0)throw new AuthProblem("Tài khoản không khả dụng.");
  var own=ownReview(id,userId);
  if(own!=null&&"HIDDEN".equals(own.get("status")))throw new AuthProblem("Đánh giá này đã bị ẩn. Bạn không thể chỉnh sửa lúc này.");
  if(own==null)jdbc.update("INSERT INTO dbo.BookReviews(BookId,UserId,Rating,Comment,Status,CreatedAt) VALUES(?,?,?,?,'APPROVED',CURRENT_TIMESTAMP)",id,userId,rating,comment);
  else jdbc.update("UPDATE dbo.BookReviews SET Rating=?,Comment=?,Status='APPROVED',CreatedAt=CURRENT_TIMESTAMP WHERE BookId=? AND UserId=? AND Status<>'HIDDEN'",rating,comment,id,userId);
 }
}
