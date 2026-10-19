package vn.mocsach.catalog;

import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.mocsach.auth.AuthProblem;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.*;

@Service
public class CartService {
 private final JdbcTemplate jdbc;
 private final CatalogService catalog;
 public CartService(JdbcTemplate jdbc,CatalogService catalog){this.jdbc=jdbc;this.catalog=catalog;}

 public int count(int userId){
  Integer c=jdbc.queryForObject("SELECT COUNT(*) FROM dbo.CartItems ci JOIN dbo.Carts c ON c.CartId=ci.CartId WHERE c.UserId=? AND c.Status='ACTIVE'",Integer.class,userId);
  return c==null?0:c;
 }

 public int bookCountInCart(int userId,int bookId){
  Integer c=jdbc.queryForObject("SELECT COUNT(*) FROM dbo.CartItems ci JOIN dbo.Carts c ON c.CartId=ci.CartId JOIN dbo.BookCopies bc ON bc.CopyId=ci.CopyId WHERE c.UserId=? AND c.Status='ACTIVE' AND bc.BookId=?",Integer.class,userId,bookId);
  return c==null?0:c;
 }

 @Transactional
 public int add(int userId,int bookId,int quantity){
  if(quantity<1||quantity>50)throw new AuthProblem("Vui lòng chọn số lượng hợp lệ.");
  if(jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Books WHERE BookId=?",Integer.class,bookId)==0)throw new ResponseStatusException(HttpStatus.NOT_FOUND,"Không tìm thấy sách");
  if(jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Users WHERE UserId=? AND Status='ACTIVE'",Integer.class,userId)==0)throw new AuthProblem("Tài khoản không khả dụng.");
  var candidates=jdbc.queryForList("""
   SELECT bc.CopyId AS copyId,bc.StoreId AS storeId
   FROM dbo.BookCopies bc
   JOIN dbo.Stores s ON s.StoreId=bc.StoreId
   WHERE bc.BookId=? AND bc.Status='AVAILABLE' AND s.Status='ACTIVE'
    AND NOT EXISTS(SELECT 1 FROM dbo.CartItems ci JOIN dbo.Carts c ON c.CartId=ci.CartId
     WHERE c.UserId=? AND c.Status='ACTIVE' AND ci.CopyId=bc.CopyId)
   ORDER BY bc.SalePrice ASC,bc.CopyId ASC
   """,bookId,userId);
  if(candidates.isEmpty()){
   if(bookCountInCart(userId,bookId)>0)throw new AuthProblem("Tất cả các bản có sẵn của sách này đã nằm trong giỏ hàng của bạn.");
   throw new AuthProblem("Sách hiện tạm hết bản có sẵn tại các chi nhánh đang hoạt động.");
  }
  if(candidates.size()<quantity)throw new AuthProblem("Chỉ còn "+candidates.size()+" bản sách có sẵn có thể thêm vào giỏ hàng.");
  for(int i=0;i<quantity;i++){
   var copy=candidates.get(i);
   int copyId=((Number)copy.get("copyId")).intValue(),storeId=((Number)copy.get("storeId")).intValue();
   var cartIds=jdbc.queryForList("SELECT CartId FROM dbo.Carts WHERE UserId=? AND StoreId=? AND Status='ACTIVE'",Integer.class,userId,storeId);
   int cartId;
   if(cartIds.isEmpty()){
    jdbc.update("INSERT INTO dbo.Carts(UserId,StoreId,Status,CreatedAt,UpdatedAt) VALUES(?,?,'ACTIVE',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)",userId,storeId);
    cartId=jdbc.queryForObject("SELECT CartId FROM dbo.Carts WHERE UserId=? AND StoreId=? AND Status='ACTIVE'",Integer.class,userId,storeId);
   }else{
    cartId=cartIds.get(0);
    jdbc.update("UPDATE dbo.Carts SET UpdatedAt=CURRENT_TIMESTAMP WHERE CartId=?",cartId);
   }
   jdbc.update("INSERT INTO dbo.CartItems(CartId,CopyId,AddedAt) VALUES(?,?,CURRENT_TIMESTAMP)",cartId,copyId);
  }
  return quantity;
 }

 @Transactional
 public void removeItem(int userId,int cartItemId){
  var cartIds=jdbc.queryForList("SELECT c.CartId FROM dbo.CartItems ci JOIN dbo.Carts c ON c.CartId=ci.CartId WHERE ci.CartItemId=? AND c.UserId=? AND c.Status='ACTIVE'",Integer.class,cartItemId,userId);
  if(cartIds.isEmpty())throw new AuthProblem("Mục giỏ hàng không tồn tại hoặc đã được xóa.");
  jdbc.update("DELETE FROM dbo.CartItems WHERE CartItemId=?",cartItemId);
  jdbc.update("UPDATE dbo.Carts SET UpdatedAt=CURRENT_TIMESTAMP WHERE CartId=?",cartIds.get(0));
 }

 @Transactional
 public void clear(int userId){
  jdbc.update("DELETE FROM dbo.CartItems WHERE CartId IN (SELECT CartId FROM dbo.Carts WHERE UserId=? AND Status='ACTIVE')",userId);
  jdbc.update("UPDATE dbo.Carts SET UpdatedAt=CURRENT_TIMESTAMP WHERE UserId=? AND Status='ACTIVE'",userId);
 }

 public Map<String,Object> detail(int userId){
  var items=jdbc.queryForList("""
   SELECT ci.CartItemId AS cartItemId,c.CartId AS cartId,bc.CopyId AS copyId,bc.CopyCode AS copyCode,
    b.BookId AS bookId,b.Title AS title,b.CoverImage AS cover,
    COALESCE(a.names,N'Đang cập nhật tác giả') AS authors,
    cond.ConditionName AS conditionName,bc.ConditionNotes AS conditionNotes,
    s.StoreId AS storeId,s.StoreName AS storeName,s.Status AS storeStatus,
    bc.Status AS copyStatus,bc.SalePrice AS price,ci.AddedAt AS addedAt
   FROM dbo.CartItems ci
   JOIN dbo.Carts c ON c.CartId=ci.CartId
   JOIN dbo.BookCopies bc ON bc.CopyId=ci.CopyId
   JOIN dbo.Books b ON b.BookId=bc.BookId
   JOIN dbo.BookConditions cond ON cond.ConditionId=bc.ConditionId
   JOIN dbo.Stores s ON s.StoreId=c.StoreId
   LEFT JOIN (SELECT ba.BookId,STRING_AGG(a.AuthorName,N', ') AS names FROM dbo.BookAuthors ba
     JOIN dbo.Authors a ON a.AuthorId=ba.AuthorId GROUP BY ba.BookId) a ON a.BookId=b.BookId
   WHERE c.UserId=? AND c.Status='ACTIVE'
   ORDER BY ci.AddedAt DESC,ci.CartItemId DESC
   """,userId);
  NumberFormat money=NumberFormat.getIntegerInstance(Locale.forLanguageTag("vi-VN"));
  BigDecimal subtotal=BigDecimal.ZERO;
  int availableCount=0;
  Set<Integer> activeStores=new HashSet<>();
  for(var item:items){
   int bookId=((Number)item.get("bookId")).intValue();
   item.put("cover",catalog.cover(bookId,item.get("cover")));
   boolean copyOk="AVAILABLE".equals(item.get("copyStatus")),storeOk="ACTIVE".equals(item.get("storeStatus")),available=copyOk&&storeOk;
   item.put("available",available);
   item.put("statusLabel",available?"Còn hàng":(!storeOk?"Chi nhánh tạm ngưng":"Đã bán / Hết hàng"));
   BigDecimal price=item.get("price") instanceof BigDecimal bd?bd:BigDecimal.valueOf(((Number)item.get("price")).doubleValue());
   item.put("priceLabel",money.format(price)+" ₫");
   if(available){
    availableCount++;
    subtotal=subtotal.add(price);
    activeStores.add(((Number)item.get("storeId")).intValue());
   }
  }
  return Map.of(
   "items",items,
   "totalCount",items.size(),
   "availableCount",availableCount,
   "unavailableCount",items.size()-availableCount,
   "storeCount",activeStores.size(),
   "subtotal",subtotal,
   "subtotalLabel",money.format(subtotal)+" ₫"
  );
 }
}
