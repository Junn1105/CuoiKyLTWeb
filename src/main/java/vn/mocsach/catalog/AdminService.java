package vn.mocsach.catalog;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import vn.mocsach.auth.AuthProblem;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class AdminService {
 private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
 private static final DateTimeFormatter DATE_TIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(VN_ZONE);

 private final JdbcTemplate jdbc;
 private final CatalogService catalog;
 private final NotificationService notifications;

 public AdminService(JdbcTemplate jdbc, CatalogService catalog, NotificationService notifications) {
  this.jdbc = jdbc;
  this.catalog = catalog;
  this.notifications = notifications;
 }

 public boolean isStaffOrAdmin(int userId) {
  try {
   Integer c = jdbc.queryForObject("""
    SELECT COUNT(*)
    FROM dbo.UserRoles ur
    JOIN dbo.Roles r ON r.RoleId = ur.RoleId
    WHERE ur.UserId = ? AND r.RoleCode IN ('ADMIN', 'STAFF')
    """, Integer.class, userId);
   return c != null && c > 0;
  } catch (DataAccessException ex) {
   return false;
  }
 }

 public Map<String, Object> dashboardStats() {
  var stats = new LinkedHashMap<String, Object>();
  int totalBooks = intVal("SELECT COUNT(*) FROM dbo.Books");
  int totalCopies = intVal("SELECT COUNT(*) FROM dbo.BookCopies");
  int availableCopies = intVal("SELECT COUNT(*) FROM dbo.BookCopies WHERE Status='AVAILABLE'");
  BigDecimal invCost = decVal("SELECT COALESCE(SUM(CostPrice),0) FROM dbo.BookCopies WHERE Status IN ('AVAILABLE','RESERVED')");
  BigDecimal invSale = decVal("SELECT COALESCE(SUM(SalePrice),0) FROM dbo.BookCopies WHERE Status IN ('AVAILABLE','RESERVED')");
  int totalOrders = intVal("SELECT COUNT(*) FROM dbo.Orders");
  int pendingOrders = intVal("SELECT COUNT(*) FROM dbo.Orders WHERE Status IN ('PENDING','CONFIRMED','PROCESSING','SHIPPED')");
  BigDecimal totalRevenue = decVal("SELECT COALESCE(SUM(TotalAmount),0) FROM dbo.Orders WHERE Status<>'CANCELLED'");
  BigDecimal totalProfit = decVal("""
   SELECT COALESCE(SUM(oi.LineTotal - oi.UnitCostSnapshot),0)
   FROM dbo.OrderItems oi
   JOIN dbo.Orders o ON o.OrderId = oi.OrderId
   WHERE o.Status <> 'CANCELLED'
   """);

  stats.put("totalBooks", totalBooks);
  stats.put("totalCopies", totalCopies);
  stats.put("availableCopies", availableCopies);
  stats.put("inventoryCostLabel", CheckoutService.vnd(invCost));
  stats.put("inventorySaleLabel", CheckoutService.vnd(invSale));
  stats.put("totalOrders", totalOrders);
  stats.put("pendingOrders", pendingOrders);
  stats.put("totalRevenueLabel", CheckoutService.vnd(totalRevenue));
  stats.put("totalProfitLabel", CheckoutService.vnd(totalProfit));

  var storeStats = jdbc.query("""
   SELECT s.StoreId, s.StoreCode, s.StoreName, s.Status,
    (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status = 'AVAILABLE') AS availableCopies,
    (SELECT COALESCE(SUM(bc.CostPrice),0) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status IN ('AVAILABLE','RESERVED')) AS costValue,
    (SELECT COALESCE(SUM(bc.SalePrice),0) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status IN ('AVAILABLE','RESERVED')) AS saleValue,
    (SELECT COUNT(*) FROM dbo.Orders o WHERE o.StoreId = s.StoreId AND o.Status <> 'CANCELLED') AS orderCount,
    (SELECT COALESCE(SUM(o.TotalAmount),0) FROM dbo.Orders o WHERE o.StoreId = s.StoreId AND o.Status <> 'CANCELLED') AS revenue
   FROM dbo.Stores s
   ORDER BY s.StoreId ASC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeCode", rs.getString("StoreCode"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("status", rs.getString("Status"));
   m.put("availableCopies", rs.getInt("availableCopies"));
   m.put("costValueLabel", CheckoutService.vnd(rs.getBigDecimal("costValue")));
   m.put("saleValueLabel", CheckoutService.vnd(rs.getBigDecimal("saleValue")));
   m.put("orderCount", rs.getInt("orderCount"));
   m.put("revenueLabel", CheckoutService.vnd(rs.getBigDecimal("revenue")));
   return (Map<String, Object>) m;
  });
  stats.put("storeStats", storeStats);

  var conditionStats = jdbc.query("""
   SELECT c.ConditionId, c.ConditionCode, c.ConditionName,
    (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.ConditionId = c.ConditionId) AS totalCopies,
    (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.ConditionId = c.ConditionId AND bc.Status = 'AVAILABLE') AS availableCopies,
    (SELECT COALESCE(AVG(bc.CostPrice),0) FROM dbo.BookCopies bc WHERE bc.ConditionId = c.ConditionId) AS avgCost,
    (SELECT COALESCE(AVG(bc.SalePrice),0) FROM dbo.BookCopies bc WHERE bc.ConditionId = c.ConditionId) AS avgSale
   FROM dbo.BookConditions c
   ORDER BY c.SortOrder ASC, c.ConditionId ASC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("conditionId", rs.getInt("ConditionId"));
   m.put("conditionCode", rs.getString("ConditionCode"));
   m.put("conditionName", rs.getString("ConditionName"));
   m.put("totalCopies", rs.getInt("totalCopies"));
   m.put("availableCopies", rs.getInt("availableCopies"));
   m.put("avgCostLabel", CheckoutService.vnd(rs.getBigDecimal("avgCost")));
   m.put("avgSaleLabel", CheckoutService.vnd(rs.getBigDecimal("avgSale")));
   return (Map<String, Object>) m;
  });
  stats.put("conditionStats", conditionStats);
  return stats;
 }

 public List<Map<String, Object>> categories() {
  return jdbc.query("SELECT CategoryId, CategoryName FROM dbo.Categories ORDER BY CategoryName", (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("id", rs.getInt("CategoryId"));
   m.put("name", rs.getString("CategoryName"));
   return (Map<String, Object>) m;
  });
 }

 public List<Map<String, Object>> activeStores() {
  return jdbc.query("SELECT StoreId, StoreName, Status FROM dbo.Stores ORDER BY StoreId", (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("id", rs.getInt("StoreId"));
   m.put("name", rs.getString("StoreName"));
   m.put("status", rs.getString("Status"));
   return (Map<String, Object>) m;
  });
 }

 public List<Map<String, Object>> conditions() {
  return jdbc.query("SELECT ConditionId, ConditionCode, ConditionName FROM dbo.BookConditions ORDER BY SortOrder ASC, ConditionId ASC", (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("id", rs.getInt("ConditionId"));
   m.put("code", rs.getString("ConditionCode"));
   m.put("name", rs.getString("ConditionName"));
   return (Map<String, Object>) m;
  });
 }

 public List<Map<String, Object>> listBooksForAdmin(String q, int categoryId) {
  String search = clean(q).toLowerCase(Locale.ROOT);
  var rows = jdbc.query("""
   SELECT b.BookId, b.Title, b.ISBN, b.PublishYear, b.CoverImage, b.CategoryId,
    c.CategoryName, p.PublisherName,
    (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.BookId = b.BookId) AS totalCopies,
    (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.BookId = b.BookId AND bc.Status = 'AVAILABLE') AS availableCopies,
    (SELECT MIN(bc.CostPrice) FROM dbo.BookCopies bc WHERE bc.BookId = b.BookId) AS minCost,
    (SELECT MIN(bc.SalePrice) FROM dbo.BookCopies bc WHERE bc.BookId = b.BookId) AS minSale
   FROM dbo.Books b
   JOIN dbo.Categories c ON c.CategoryId = b.CategoryId
   LEFT JOIN dbo.Publishers p ON p.PublisherId = b.PublisherId
   ORDER BY b.BookId DESC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   int id = rs.getInt("BookId");
   m.put("id", id);
   m.put("title", rs.getString("Title"));
   m.put("isbn", Objects.toString(rs.getString("ISBN"), "—"));
   m.put("publishYear", rs.getObject("PublishYear") != null ? rs.getInt("PublishYear") : "—");
   m.put("categoryId", rs.getInt("CategoryId"));
   m.put("categoryName", rs.getString("CategoryName"));
   m.put("publisherName", Objects.toString(rs.getString("PublisherName"), "Đang cập nhật"));
   m.put("cover", catalog.cover(id, rs.getString("CoverImage")));
   m.put("totalCopies", rs.getInt("totalCopies"));
   m.put("availableCopies", rs.getInt("availableCopies"));
   BigDecimal minCost = rs.getBigDecimal("minCost");
   BigDecimal minSale = rs.getBigDecimal("minSale");
   m.put("minCostLabel", minCost != null ? CheckoutService.vnd(minCost) : "—");
   m.put("minSaleLabel", minSale != null ? CheckoutService.vnd(minSale) : "—");
   return (Map<String, Object>) m;
  });

  return rows.stream()
   .filter(b -> categoryId == 0 || ((Number) b.get("categoryId")).intValue() == categoryId)
   .filter(b -> search.isEmpty() || (b.get("title") + " " + b.get("isbn") + " MS-" + b.get("id")).toLowerCase(Locale.ROOT).contains(search))
   .toList();
 }

 public List<Map<String, Object>> bookCopiesForStaff(int bookId) {
  return jdbc.query("""
   SELECT bc.CopyId, bc.CopyCode, bc.BookId, bc.StoreId, s.StoreName,
    bc.ConditionId, cond.ConditionName, bc.CostPrice, bc.SalePrice,
    bc.Status, bc.ConditionNotes, bc.ShelfLocation
   FROM dbo.BookCopies bc
   JOIN dbo.Stores s ON s.StoreId = bc.StoreId
   JOIN dbo.BookConditions cond ON cond.ConditionId = bc.ConditionId
   WHERE bc.BookId = ?
   ORDER BY bc.CopyId ASC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   BigDecimal cost = rs.getBigDecimal("CostPrice");
   BigDecimal sale = rs.getBigDecimal("SalePrice");
   m.put("copyId", rs.getInt("CopyId"));
   m.put("copyCode", rs.getString("CopyCode"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("conditionId", rs.getInt("ConditionId"));
   m.put("conditionName", rs.getString("ConditionName"));
   m.put("costPrice", cost);
   m.put("costPriceLabel", CheckoutService.vnd(cost));
   m.put("salePrice", sale);
   m.put("salePriceLabel", CheckoutService.vnd(sale));
   m.put("status", rs.getString("Status"));
   m.put("conditionNotes", Objects.toString(rs.getString("ConditionNotes"), ""));
   m.put("shelfLocation", Objects.toString(rs.getString("ShelfLocation"), ""));
   return (Map<String, Object>) m;
  }, bookId);
 }

 public Map<String, Object> bookForEdit(int bookId) {
  var rows = jdbc.query("""
   SELECT b.BookId, b.Title, b.ISBN, b.CategoryId, b.PublisherId, p.PublisherName,
    b.PublishYear, b.Translator, b.CoverImage, b.Description
   FROM dbo.Books b
   LEFT JOIN dbo.Publishers p ON p.PublisherId = b.PublisherId
   WHERE b.BookId = ?
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   int id = rs.getInt("BookId");
   m.put("id", id);
   m.put("title", rs.getString("Title"));
   m.put("isbn", Objects.toString(rs.getString("ISBN"), ""));
   m.put("categoryId", rs.getInt("CategoryId"));
   m.put("publisherName", Objects.toString(rs.getString("PublisherName"), ""));
   m.put("publishYear", rs.getObject("PublishYear") != null ? rs.getInt("PublishYear") : "");
   m.put("translator", Objects.toString(rs.getString("Translator"), ""));
   m.put("coverImage", Objects.toString(rs.getString("CoverImage"), ""));
   m.put("cover", catalog.cover(id, rs.getString("CoverImage")));
   m.put("description", Objects.toString(rs.getString("Description"), ""));
   return m;
  }, bookId);
  if (rows.isEmpty()) throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đầu sách.");
  var book = rows.get(0);
  var authors = jdbc.query("SELECT a.AuthorName FROM dbo.BookAuthors ba JOIN dbo.Authors a ON a.AuthorId=ba.AuthorId WHERE ba.BookId=? ORDER BY a.AuthorId",
   (rs, i) -> rs.getString(1), bookId);
  book.put("authors", String.join(", ", authors));
  book.put("copies", bookCopiesForStaff(bookId));
  return book;
 }

 @Transactional
 public int createBook(
  String title, int categoryId, String authorName, String publisherName,
  Integer publishYear, String translator, String isbn, String coverImage, String description,
  int storeId, int conditionId, BigDecimal costPrice, BigDecimal salePrice, int copyQuantity
 ) {
  String cleanTitle = clean(title);
  if (cleanTitle.length() < 2 || cleanTitle.length() > 255)
   throw new AuthProblem("Tên sách cần từ 2 đến 255 ký tự.");
  if (costPrice == null || costPrice.compareTo(BigDecimal.ZERO) < 0)
   throw new AuthProblem("Giá nhập (CostPrice) phải lớn hơn hoặc bằng 0.");
  if (salePrice == null || salePrice.compareTo(BigDecimal.ZERO) <= 0)
   throw new AuthProblem("Giá bán (SalePrice) phải lớn hơn 0.");

  int publisherId = resolveOrCreatePublisher(publisherName);
  String cleanIsbn = clean(isbn);
  String cleanTranslator = clean(translator);
  String cleanCover = clean(coverImage);
  String cleanDesc = description == null ? "" : description.strip();

  var kh = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement("""
    INSERT INTO dbo.Books(ISBN, Title, CategoryId, PublisherId, PublishYear, CoverImage, Description, Translator)
    VALUES(?, ?, ?, ?, ?, ?, ?, ?)
    """, Statement.RETURN_GENERATED_KEYS);
   if (cleanIsbn.isEmpty()) ps.setNull(1, Types.VARCHAR); else ps.setString(1, cleanIsbn);
   ps.setString(2, cleanTitle);
   ps.setInt(3, categoryId);
   ps.setInt(4, publisherId);
   if (publishYear == null || publishYear <= 0) ps.setNull(5, Types.INTEGER); else ps.setInt(5, publishYear);
   if (cleanCover.isEmpty()) ps.setNull(6, Types.NVARCHAR); else ps.setString(6, cleanCover);
   if (cleanDesc.isEmpty()) ps.setNull(7, Types.NVARCHAR); else ps.setString(7, cleanDesc);
   if (cleanTranslator.isEmpty()) ps.setNull(8, Types.NVARCHAR); else ps.setString(8, cleanTranslator);
   return ps;
  }, kh);

  int bookId = extractId(kh, "SELECT MAX(BookId) FROM dbo.Books");
  syncBookAuthors(bookId, authorName);

  int qty = Math.max(1, Math.min(20, copyQuantity));
  for (int i = 0; i < qty; i++) {
   addCopy(bookId, storeId, conditionId, costPrice, salePrice, "Bản sách tuyển chọn", "Kệ A1");
  }
  return bookId;
 }

 @Transactional
 public void updateBook(
  int bookId, String title, int categoryId, String authorName, String publisherName,
  Integer publishYear, String translator, String isbn, String coverImage, String description
 ) {
  String cleanTitle = clean(title);
  if (cleanTitle.length() < 2 || cleanTitle.length() > 255)
   throw new AuthProblem("Tên sách cần từ 2 đến 255 ký tự.");
  int publisherId = resolveOrCreatePublisher(publisherName);
  String cleanIsbn = clean(isbn);
  String cleanTranslator = clean(translator);
  String cleanCover = clean(coverImage);
  String cleanDesc = description == null ? "" : description.strip();

  int updated = jdbc.update("""
   UPDATE dbo.Books
   SET ISBN=?, Title=?, CategoryId=?, PublisherId=?, PublishYear=?, CoverImage=?, Description=?, Translator=?
   WHERE BookId=?
   """,
   cleanIsbn.isEmpty() ? null : cleanIsbn,
   cleanTitle,
   categoryId,
   publisherId,
   (publishYear == null || publishYear <= 0) ? null : publishYear,
   cleanCover.isEmpty() ? null : cleanCover,
   cleanDesc.isEmpty() ? null : cleanDesc,
   cleanTranslator.isEmpty() ? null : cleanTranslator,
   bookId
  );
  if (updated == 0) throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đầu sách.");
  syncBookAuthors(bookId, authorName);
 }

 @Transactional
 public void deleteBook(int bookId) {
  jdbc.update("DELETE FROM dbo.CartItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId);
  try { jdbc.update("DELETE FROM dbo.MediaAssets WHERE BookId=? OR CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId, bookId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.StockTransferItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.StocktakeItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.InventoryMovements WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.StockReservations WHERE OrderItemId IN (SELECT OrderItemId FROM dbo.OrderItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?))", bookId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.SalesReturnItems WHERE OrderItemId IN (SELECT OrderItemId FROM dbo.OrderItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?))", bookId); } catch (DataAccessException ignored) {}
  jdbc.update("DELETE FROM dbo.OrderItems WHERE CopyId IN (SELECT CopyId FROM dbo.BookCopies WHERE BookId=?)", bookId);
  jdbc.update("UPDATE dbo.BookCopies SET PurchaseReceiptItemId=NULL WHERE BookId=?", bookId);
  try { jdbc.update("DELETE FROM dbo.PurchaseReceiptItems WHERE BookId=?", bookId); } catch (DataAccessException ignored) {}
  jdbc.update("DELETE FROM dbo.BookCopies WHERE BookId=?", bookId);
  jdbc.update("DELETE FROM dbo.BookReviews WHERE BookId=?", bookId);
  jdbc.update("DELETE FROM dbo.BookAuthors WHERE BookId=?", bookId);
  jdbc.update("DELETE FROM dbo.Books WHERE BookId=?", bookId);
 }

 @Transactional
 public void addCopy(int bookId, int storeId, int conditionId, BigDecimal costPrice, BigDecimal salePrice, String conditionNotes, String shelfLocation) {
  if (costPrice == null || costPrice.compareTo(BigDecimal.ZERO) < 0)
   throw new AuthProblem("Giá nhập (CostPrice) phải lớn hơn hoặc bằng 0.");
  if (salePrice == null || salePrice.compareTo(BigDecimal.ZERO) <= 0)
   throw new AuthProblem("Giá bán (SalePrice) phải lớn hơn 0.");

  String copyCode = "MS-" + bookId + "-" + (System.currentTimeMillis() % 100000) + "-" + ThreadLocalRandom.current().nextInt(10, 99);
  jdbc.update("""
   INSERT INTO dbo.BookCopies(CopyCode, BookId, StoreId, ConditionId, PurchaseReceiptItemId,
    CostPrice, SalePrice, ConditionNotes, ShelfLocation, Status, Version, CreatedAt, UpdatedAt)
   VALUES(?, ?, ?, ?, NULL, ?, ?, ?, ?, 'AVAILABLE', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
   """, copyCode, bookId, storeId, conditionId, costPrice, salePrice,
   clean(conditionNotes).isEmpty() ? null : clean(conditionNotes),
   clean(shelfLocation).isEmpty() ? "Kệ A" : clean(shelfLocation));
 }

 @Transactional
 public void updateCopy(int copyId, int storeId, int conditionId, BigDecimal costPrice, BigDecimal salePrice, String status, String conditionNotes) {
  if (costPrice == null || costPrice.compareTo(BigDecimal.ZERO) < 0)
   throw new AuthProblem("Giá nhập (CostPrice) phải lớn hơn hoặc bằng 0.");
  if (salePrice == null || salePrice.compareTo(BigDecimal.ZERO) <= 0)
   throw new AuthProblem("Giá bán (SalePrice) phải lớn hơn 0.");
  String validStatus = switch (clean(status).toUpperCase(Locale.ROOT)) {
   case "AVAILABLE", "RESERVED", "SOLD", "DAMAGED", "LOST", "IN_TRANSIT" -> clean(status).toUpperCase(Locale.ROOT);
   default -> "AVAILABLE";
  };
  jdbc.update("""
   UPDATE dbo.BookCopies
   SET StoreId=?, ConditionId=?, CostPrice=?, SalePrice=?, Status=?, ConditionNotes=?, Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
   WHERE CopyId=?
   """, storeId, conditionId, costPrice, salePrice, validStatus,
   clean(conditionNotes).isEmpty() ? null : clean(conditionNotes), copyId);
 }

 @Transactional
 public void deleteCopy(int copyId) {
  jdbc.update("DELETE FROM dbo.CartItems WHERE CopyId=?", copyId);
  try { jdbc.update("DELETE FROM dbo.MediaAssets WHERE CopyId=?", copyId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.StockTransferItems WHERE CopyId=?", copyId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.StocktakeItems WHERE CopyId=?", copyId); } catch (DataAccessException ignored) {}
  try { jdbc.update("DELETE FROM dbo.InventoryMovements WHERE CopyId=?", copyId); } catch (DataAccessException ignored) {}
  jdbc.update("DELETE FROM dbo.OrderItems WHERE CopyId=?", copyId);
  jdbc.update("DELETE FROM dbo.BookCopies WHERE CopyId=?", copyId);
 }

 public List<Map<String, Object>> listAllOrders(String statusFilter) {
  String filter = clean(statusFilter).toUpperCase(Locale.ROOT);
  var rows = jdbc.query("""
   SELECT o.OrderId, o.OrderCode, o.CustomerId, o.StoreId, s.StoreName,
    o.Status, o.RecipientName, o.RecipientPhone, o.ShippingAddressSnapshot,
    o.Subtotal, o.ShippingFee, o.TotalAmount, o.CreatedAt,
    (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.OrderId) AS itemCount,
    (SELECT COALESCE(SUM(oi.UnitCostSnapshot),0) FROM dbo.OrderItems oi WHERE oi.OrderId = o.OrderId) AS totalCost,
    (SELECT MAX(p.Method) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentMethod,
    (SELECT MAX(p.Status) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentStatus
   FROM dbo.Orders o
   JOIN dbo.Stores s ON s.StoreId = o.StoreId
   ORDER BY o.CreatedAt DESC, o.OrderId DESC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   String st = Objects.toString(rs.getString("Status"), "PENDING");
   String pm = Objects.toString(rs.getString("paymentMethod"), "CASH");
   String ps = Objects.toString(rs.getString("paymentStatus"), "PENDING");
   Timestamp createdTs = rs.getTimestamp("CreatedAt");
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("customerId", rs.getObject("CustomerId"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("status", st);
   m.put("statusLabel", CheckoutService.orderStatusLabel(st));
   m.put("recipientName", Objects.toString(rs.getString("RecipientName"), "Khách tại quầy"));
   m.put("recipientPhone", Objects.toString(rs.getString("RecipientPhone"), "—"));
   m.put("shippingAddress", Objects.toString(rs.getString("ShippingAddressSnapshot"), "Mua trực tiếp tại cửa hàng"));
   m.put("totalCostLabel", CheckoutService.vnd(rs.getBigDecimal("totalCost")));
   m.put("totalAmountLabel", CheckoutService.vnd(rs.getBigDecimal("TotalAmount")));
   m.put("createdAt", createdTs != null ? DATE_TIME_FMT.format(createdTs.toInstant()) : "");
   m.put("estimatedDelivery", CheckoutService.estimatedDelivery(createdTs));
   m.put("itemCount", rs.getInt("itemCount"));
   m.put("paymentMethodLabel", CheckoutService.paymentMethodLabel(pm));
   m.put("paymentStatusLabel", CheckoutService.paymentStatusLabel(ps));
   return (Map<String, Object>) m;
  });
  if (filter.isEmpty() || "ALL".equals(filter)) return rows;
  return rows.stream().filter(r -> filter.equals(r.get("status"))).toList();
 }

 @Transactional
 public void updateOrderStatus(int staffUserId, int orderId, String targetStatus) {
  String newStatus = clean(targetStatus).toUpperCase(Locale.ROOT);
  if (!List.of("PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "COMPLETED", "CANCELLED").contains(newStatus))
   throw new AuthProblem("Trạng thái đơn hàng không hợp lệ.");

  var orders = jdbc.query("SELECT OrderId, OrderCode, CustomerId, Status FROM dbo.Orders WHERE OrderId=?", (rs, i) -> {
   var m = new HashMap<String, Object>();
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("customerId", rs.getObject("CustomerId"));
   m.put("status", rs.getString("Status"));
   return m;
  }, orderId);
  if (orders.isEmpty()) throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đơn hàng.");

  var order = orders.get(0);
  String oldStatus = Objects.toString(order.get("status"), "PENDING");
  if (oldStatus.equals(newStatus)) return;

  jdbc.update("UPDATE dbo.Orders SET Status=?, Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", newStatus, orderId);
  jdbc.update("""
   INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
   VALUES(?, ?, ?, ?, CURRENT_TIMESTAMP, ?)
   """, orderId, oldStatus, newStatus, staffUserId, "Cập nhật trạng thái bởi nhân viên/quản trị viên");

  if ("COMPLETED".equals(newStatus)) {
   jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status='SOLD', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
    WHERE CopyId IN (SELECT CopyId FROM dbo.OrderItems WHERE OrderId=?)
    """, orderId);
   jdbc.update("""
    UPDATE dbo.Payments
    SET Status='SUCCEEDED',
        PaidAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END
    WHERE OrderId=? AND Status<>'SUCCEEDED'
    """, orderId);
  } else if ("CANCELLED".equals(newStatus)) {
   jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status='AVAILABLE', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
    WHERE CopyId IN (SELECT CopyId FROM dbo.OrderItems WHERE OrderId=?) AND Status IN ('RESERVED','SOLD')
    """, orderId);
   jdbc.update("UPDATE dbo.Payments SET Status='CANCELLED', PaidAt=NULL WHERE OrderId=?", orderId);
  }

  if (order.get("customerId") instanceof Number custId) {
   String code = String.valueOf(order.get("orderCode"));
   notifications.create(custId.intValue(), "ORDER",
    "Cập nhật đơn hàng " + code,
    "Đơn hàng " + code + " của bạn đã chuyển sang trạng thái: " + CheckoutService.orderStatusLabel(newStatus) + ".",
    "/orders/" + orderId);
  }
 }

 private int resolveOrCreatePublisher(String publisherName) {
  String name = clean(publisherName);
  if (name.isEmpty()) name = "NXB Văn Học";
  var existing = jdbc.query("SELECT PublisherId FROM dbo.Publishers WHERE LOWER(PublisherName)=LOWER(?)",
   (rs, i) -> rs.getInt(1), name);
  if (!existing.isEmpty()) return existing.get(0);
  final String finalName = name;
  var kh = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement("INSERT INTO dbo.Publishers(PublisherName) VALUES(?)", Statement.RETURN_GENERATED_KEYS);
   ps.setString(1, finalName);
   return ps;
  }, kh);
  return extractId(kh, "SELECT MAX(PublisherId) FROM dbo.Publishers");
 }

 private void syncBookAuthors(int bookId, String authorNames) {
  jdbc.update("DELETE FROM dbo.BookAuthors WHERE BookId=?", bookId);
  String raw = clean(authorNames);
  if (raw.isEmpty()) raw = "Nhiều tác giả";
  for (String part : raw.split(",")) {
   String aName = clean(part);
   if (aName.isEmpty()) continue;
   var existing = jdbc.query("SELECT AuthorId FROM dbo.Authors WHERE LOWER(AuthorName)=LOWER(?)",
    (rs, i) -> rs.getInt(1), aName);
   int authorId;
   if (!existing.isEmpty()) {
    authorId = existing.get(0);
   } else {
    var kh = new GeneratedKeyHolder();
    jdbc.update(con -> {
     PreparedStatement ps = con.prepareStatement("INSERT INTO dbo.Authors(AuthorName) VALUES(?)", Statement.RETURN_GENERATED_KEYS);
     ps.setString(1, aName);
     return ps;
    }, kh);
    authorId = extractId(kh, "SELECT MAX(AuthorId) FROM dbo.Authors");
   }
   jdbc.update("INSERT INTO dbo.BookAuthors(BookId, AuthorId) VALUES(?, ?)", bookId, authorId);
  }
 }

 private int intVal(String sql) {
  Integer v = jdbc.queryForObject(sql, Integer.class);
  return v == null ? 0 : v;
 }

 private BigDecimal decVal(String sql) {
  BigDecimal v = jdbc.queryForObject(sql, BigDecimal.class);
  return v == null ? BigDecimal.ZERO : v;
 }

 private int extractId(GeneratedKeyHolder kh, String fallbackSql) {
  Number key = kh.getKey();
  if (key != null) return key.intValue();
  var keys = kh.getKeys();
  if (keys != null && !keys.isEmpty()) {
   Object first = keys.values().iterator().next();
   if (first instanceof Number n) return n.intValue();
  }
  Integer id = jdbc.queryForObject(fallbackSql, Integer.class);
  return id == null ? 0 : id;
 }

 private static String clean(String value) {
  return value == null ? "" : value.strip().replaceAll("\\s+", " ");
 }
}
