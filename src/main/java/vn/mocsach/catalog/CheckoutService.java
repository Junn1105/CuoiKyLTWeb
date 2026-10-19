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
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class CheckoutService {
 public static final BigDecimal SPX_SHIPPING_FEE = new BigDecimal("25000");
 private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
 private static final DateTimeFormatter DATE_TIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(VN_ZONE);
 private static final DateTimeFormatter DATE_ONLY_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

 private final JdbcTemplate jdbc;
 private final CatalogService catalog;
 private final CartService cart;

 public CheckoutService(JdbcTemplate jdbc, CatalogService catalog, CartService cart) {
  this.jdbc = jdbc;
  this.catalog = catalog;
  this.cart = cart;
 }

 public Map<String, String> defaultShippingInfo(int userId) {
  var info = new LinkedHashMap<String, String>();
  info.put("recipientName", "");
  info.put("recipientPhone", "");
  info.put("administrativeArea", "");
  info.put("addressLine", "");
  info.put("note", "");
  info.put("shippingMethod", "SPX_EXPRESS");

  try {
   var users = jdbc.query("SELECT FullName, Phone FROM dbo.Users WHERE UserId=?", (rs, i) -> {
    var m = new HashMap<String, String>();
    m.put("name", Objects.toString(rs.getString("FullName"), ""));
    m.put("phone", Objects.toString(rs.getString("Phone"), ""));
    return m;
   }, userId);
   if (!users.isEmpty()) {
    info.put("recipientName", users.get(0).get("name"));
    info.put("recipientPhone", users.get(0).get("phone"));
   }
  } catch (DataAccessException ignored) {}

  try {
   var addrs = jdbc.query("""
    SELECT RecipientName, Phone, AdministrativeArea, AddressLine
    FROM dbo.CustomerAddresses
    WHERE UserId=?
    ORDER BY IsDefault DESC, UpdatedAt DESC, AddressId DESC
    """, (rs, i) -> {
    var m = new HashMap<String, String>();
    m.put("recipientName", Objects.toString(rs.getString("RecipientName"), ""));
    m.put("recipientPhone", Objects.toString(rs.getString("Phone"), ""));
    m.put("administrativeArea", Objects.toString(rs.getString("AdministrativeArea"), ""));
    m.put("addressLine", Objects.toString(rs.getString("AddressLine"), ""));
    return m;
   }, userId);
   if (!addrs.isEmpty()) {
    var a = addrs.get(0);
    if (!a.get("recipientName").isBlank()) info.put("recipientName", a.get("recipientName"));
    if (!a.get("recipientPhone").isBlank()) info.put("recipientPhone", a.get("recipientPhone"));
    info.put("administrativeArea", a.get("administrativeArea"));
    info.put("addressLine", a.get("addressLine"));
   }
  } catch (DataAccessException ignored) {}

  return info;
 }

 @Transactional
 public Map<String, String> validateAndSaveShipping(int userId, String recipientName, String recipientPhone, String administrativeArea, String addressLine, String note) {
  String name = clean(recipientName);
  String phone = clean(recipientPhone);
  String area = clean(administrativeArea);
  String line = clean(addressLine);
  String cleanNote = clean(note);

  if (name.length() < 2 || name.length() > 150)
   throw new AuthProblem("Vui lòng nhập họ và tên người nhận (từ 2 đến 150 ký tự).");
  String digits = phone.replaceAll("[^0-9]", "");
  if (digits.length() < 9 || digits.length() > 15)
   throw new AuthProblem("Số điện thoại nhận hàng không hợp lệ (cần từ 9 đến 15 chữ số).");
  if (area.length() < 3 || area.length() > 250)
   throw new AuthProblem("Vui lòng nhập Tỉnh/Thành phố, Quận/Huyện, Phường/Xã.");
  if (line.length() < 4 || line.length() > 500)
   throw new AuthProblem("Vui lòng nhập địa chỉ cụ thể (số nhà, tên đường).");
  if (cleanNote.length() > 300)
   cleanNote = cleanNote.substring(0, 300);

  try {
   var existing = jdbc.query("SELECT AddressId FROM dbo.CustomerAddresses WHERE UserId=? ORDER BY IsDefault DESC, AddressId DESC",
    (rs, i) -> rs.getInt("AddressId"), userId);
   if (existing.isEmpty()) {
    jdbc.update("""
     INSERT INTO dbo.CustomerAddresses(UserId, RecipientName, Phone, AddressLine, AdministrativeArea, CountryCode, IsDefault, CreatedAt, UpdatedAt)
     VALUES(?, ?, ?, ?, ?, 'VN', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
     """, userId, name, digits, line, area);
   } else {
    jdbc.update("""
     UPDATE dbo.CustomerAddresses
     SET RecipientName=?, Phone=?, AddressLine=?, AdministrativeArea=?, IsDefault=1, UpdatedAt=CURRENT_TIMESTAMP
     WHERE AddressId=? AND UserId=?
     """, name, digits, line, area, existing.get(0), userId);
   }
  } catch (DataAccessException ignored) {}

  var result = new LinkedHashMap<String, String>();
  result.put("recipientName", name);
  result.put("recipientPhone", digits);
  result.put("administrativeArea", area);
  result.put("addressLine", line);
  result.put("note", cleanNote);
  result.put("shippingMethod", "SPX_EXPRESS");
  result.put("shippingMethodLabel", "Giao hàng nhanh qua Shopee Express (SPX Express)");
  result.put("fullAddress", line + ", " + area);
  return result;
 }

 public Map<String, Object> checkoutSummary(int userId) {
  var detail = new LinkedHashMap<>(cart.detail(userId));
  BigDecimal subtotal = (BigDecimal) detail.getOrDefault("subtotal", BigDecimal.ZERO);
  BigDecimal shippingFee = SPX_SHIPPING_FEE;
  BigDecimal total = subtotal.add(shippingFee);
  detail.put("shippingFee", shippingFee);
  detail.put("shippingFeeLabel", vnd(shippingFee));
  detail.put("totalAmount", total);
  detail.put("totalAmountLabel", vnd(total));
  detail.put("carrierName", "Giao hàng nhanh qua Shopee Express (SPX Express)");
  detail.put("estimatedDelivery", estimatedDelivery(null));
  return detail;
 }

 @Transactional
 public int placeOrder(int userId, Map<String, String> shipping, String paymentMethod) {
  String userStatus = jdbc.query("SELECT Status FROM dbo.Users WHERE UserId=?", (rs, i) -> rs.getString(1), userId)
   .stream().findFirst().orElse(null);
  if (!"ACTIVE".equals(userStatus))
   throw new AuthProblem("Tài khoản của bạn hiện không thể đặt hàng.");

  if (shipping == null || clean(shipping.get("recipientName")).isEmpty() || clean(shipping.get("recipientPhone")).isEmpty() || clean(shipping.get("addressLine")).isEmpty())
   throw new AuthProblem("Vui lòng nhập đầy đủ địa chỉ và số điện thoại giao hàng trước khi thanh toán.");

  String method = "BANK_TRANSFER".equalsIgnoreCase(paymentMethod) ? "BANK_TRANSFER" : "CASH";
  String provider = "BANK_TRANSFER".equals(method) ? "VIETCOMBANK_VIETQR" : "SPX_COD";

  var items = jdbc.query("""
   SELECT ci.CartItemId, c.StoreId, s.Status AS storeStatus, bc.CopyId, bc.CopyCode,
    bc.Status AS copyStatus, bc.SalePrice, bc.CostPrice, b.Title, cond.ConditionName
   FROM dbo.Carts c
   JOIN dbo.CartItems ci ON ci.CartId = c.CartId
   JOIN dbo.BookCopies bc ON bc.CopyId = ci.CopyId
   JOIN dbo.Books b ON b.BookId = bc.BookId
   JOIN dbo.BookConditions cond ON cond.ConditionId = bc.ConditionId
   JOIN dbo.Stores s ON s.StoreId = bc.StoreId
   WHERE c.UserId = ? AND c.Status = 'ACTIVE'
   ORDER BY ci.AddedAt ASC, ci.CartItemId ASC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("cartItemId", rs.getInt("CartItemId"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeStatus", rs.getString("storeStatus"));
   m.put("copyId", rs.getInt("CopyId"));
   m.put("copyCode", rs.getString("CopyCode"));
   m.put("copyStatus", rs.getString("copyStatus"));
   m.put("salePrice", rs.getBigDecimal("SalePrice"));
   m.put("costPrice", rs.getBigDecimal("CostPrice") != null ? rs.getBigDecimal("CostPrice") : BigDecimal.ZERO);
   m.put("title", rs.getString("Title"));
   m.put("conditionName", rs.getString("ConditionName"));
   return m;
  }, userId);

  if (items.isEmpty())
   throw new AuthProblem("Giỏ hàng của bạn đang trống. Vui lòng chọn sách trước khi thanh toán.");

  BigDecimal subtotal = BigDecimal.ZERO;
  for (var item : items) {
   if (!"AVAILABLE".equals(item.get("copyStatus")) || !"ACTIVE".equals(item.get("storeStatus")))
    throw new AuthProblem("Bản sách «" + item.get("title") + "» (" + item.get("copyCode") + ") hiện không còn khả dụng. Vui lòng kiểm tra lại giỏ hàng.");
   subtotal = subtotal.add((BigDecimal) item.get("salePrice"));
  }

  int primaryStoreId = ((Number) items.get(0).get("storeId")).intValue();
  final BigDecimal finalSubtotal = subtotal;
  BigDecimal discount = BigDecimal.ZERO;
  BigDecimal shippingFee = SPX_SHIPPING_FEE;
  BigDecimal total = finalSubtotal.subtract(discount).add(shippingFee);

  String orderCode = "MS-" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + "-"
   + String.format("%04d", ThreadLocalRandom.current().nextInt(1000, 10000));
  String note = clean(shipping.get("note"));
  String snapshot = clean(shipping.get("addressLine")) + ", " + clean(shipping.get("administrativeArea"))
   + " | Giao hàng nhanh qua Shopee Express (SPX)"
   + (note.isEmpty() ? "" : " | Ghi chú: " + note);

  var kh = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement("""
    INSERT INTO dbo.Orders(OrderCode, StoreId, CustomerId, CreatedBy, Channel, Status,
     RecipientName, RecipientPhone, ShippingAddressSnapshot, Subtotal, DiscountAmount,
     ShippingFee, TotalAmount, Version, CreatedAt, UpdatedAt)
    VALUES(?, ?, ?, NULL, 'ONLINE', 'PENDING', ?, ?, ?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    """, Statement.RETURN_GENERATED_KEYS);
   ps.setString(1, orderCode);
   ps.setInt(2, primaryStoreId);
   ps.setInt(3, userId);
   ps.setString(4, clean(shipping.get("recipientName")));
   ps.setString(5, clean(shipping.get("recipientPhone")));
   ps.setString(6, snapshot);
   ps.setBigDecimal(7, finalSubtotal);
   ps.setBigDecimal(8, discount);
   ps.setBigDecimal(9, shippingFee);
   ps.setBigDecimal(10, total);
   return ps;
  }, kh);

  int orderId = extractId(kh, orderCode);

  for (var item : items) {
   int copyId = ((Number) item.get("copyId")).intValue();
   int updated = jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status='RESERVED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
    WHERE CopyId=? AND Status='AVAILABLE'
    """, copyId);
   if (updated == 0)
    throw new AuthProblem("Bản sách «" + item.get("title") + "» vừa được khách khác đặt mua. Vui lòng thử lại.");

   BigDecimal unitPrice = (BigDecimal) item.get("salePrice");
   BigDecimal unitCost = (BigDecimal) item.get("costPrice");
   jdbc.update("""
    INSERT INTO dbo.OrderItems(OrderId, CopyId, BookTitleSnapshot, ConditionSnapshot, UnitPrice, UnitCostSnapshot, DiscountAmount, LineTotal)
    VALUES(?, ?, ?, ?, ?, ?, 0, ?)
    """, orderId, copyId, item.get("title"), item.get("conditionName"), unitPrice, unitCost, unitPrice);
  }

  jdbc.update("""
   INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
   VALUES(?, NULL, 'PENDING', ?, CURRENT_TIMESTAMP, N'Đặt hàng trực tuyến qua Shopee Express (SPX)')
   """, orderId, userId);

  String idemp = "PAY-" + orderCode + "-" + UUID.randomUUID().toString().substring(0, 8);
  jdbc.update("""
   INSERT INTO dbo.Payments(OrderId, Method, Provider, Amount, Currency, Status, ProviderTransactionId, IdempotencyKey, PaidAt, CreatedAt)
   VALUES(?, ?, ?, ?, 'VND', 'PENDING', NULL, ?, NULL, CURRENT_TIMESTAMP)
   """, orderId, method, provider, total, idemp);

  jdbc.update("DELETE FROM dbo.CartItems WHERE CartId IN (SELECT CartId FROM dbo.Carts WHERE UserId=? AND Status='ACTIVE')", userId);
  return orderId;
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

 @Transactional
 public Map<String, Object> confirmQrPayment(int userId, int orderId) {
  var order = orderDetail(userId, orderId);
  String status = Objects.toString(order.get("status"), "");
  if ("CANCELLED".equals(status))
   throw new AuthProblem("Đơn hàng đã bị hủy, không thể xác nhận thanh toán.");

  String txId = "VCB-QR-" + orderId + "-" + (System.currentTimeMillis() % 1000000);
  jdbc.update("""
   UPDATE dbo.Payments
   SET Status='SUCCEEDED',
       ProviderTransactionId= COALESCE(ProviderTransactionId, ?),
       PaidAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END
   WHERE OrderId=? AND Status<>'SUCCEEDED'
   """, txId, orderId);

  if ("PENDING".equals(status)) {
   jdbc.update("UPDATE dbo.Orders SET Status='CONFIRMED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", orderId);
   jdbc.update("""
    INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
    VALUES(?, 'PENDING', 'CONFIRMED', ?, CURRENT_TIMESTAMP, ?)
    """, orderId, userId, "Xác nhận đã chuyển khoản QR Vietcombank thành công");
  }
  return orderDetail(userId, orderId);
 }

 @Transactional
 public Map<String, Object> cancelOrder(int userId, int orderId) {
  var order = orderDetail(userId, orderId);
  String status = Objects.toString(order.get("status"), "");
  if ("CANCELLED".equals(status))
   throw new AuthProblem("Đơn hàng này đã được hủy trước đó.");
  if (!"PENDING".equals(status) && !"CONFIRMED".equals(status))
   throw new AuthProblem("Đơn hàng đang được vận chuyển hoặc đã hoàn tất nên không thể hủy trực tuyến.");

  jdbc.update("UPDATE dbo.Orders SET Status='CANCELLED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", orderId);
  jdbc.update("UPDATE dbo.Payments SET Status='CANCELLED', PaidAt=NULL WHERE OrderId=?", orderId);
  jdbc.update("""
   UPDATE dbo.BookCopies
   SET Status='AVAILABLE', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
   WHERE CopyId IN (SELECT CopyId FROM dbo.OrderItems WHERE OrderId=?) AND Status='RESERVED'
   """, orderId);
  jdbc.update("""
   INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
   VALUES(?, ?, 'CANCELLED', ?, CURRENT_TIMESTAMP, ?)
   """, orderId, status, userId, "Yêu cầu hủy đơn hàng");

  return orderDetail(userId, orderId);
 }

 public Map<String, Object> orderDetail(int userId, int orderId) {
  boolean staffOrAdmin = isStaffOrAdmin(userId);
  var orders = jdbc.query("""
   SELECT o.OrderId, o.OrderCode, o.StoreId, o.CustomerId, s.StoreName, s.Address AS storeAddress, s.Phone AS storePhone,
    o.Status, o.RecipientName, o.RecipientPhone, o.ShippingAddressSnapshot,
    o.Subtotal, o.DiscountAmount, o.ShippingFee, o.TotalAmount, o.CreatedAt, o.UpdatedAt
   FROM dbo.Orders o
   JOIN dbo.Stores s ON s.StoreId = o.StoreId
   WHERE o.OrderId = ?
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("customerId", rs.getObject("CustomerId"));
   String storeName = Objects.toString(rs.getString("StoreName"), "Mộc Sách");
   m.put("storeName", storeName);
   m.put("storeAddress", Objects.toString(rs.getString("storeAddress"), "TP. Hồ Chí Minh"));
   m.put("storePhone", Objects.toString(rs.getString("storePhone"), "1900 6868"));
   String st = Objects.toString(rs.getString("Status"), "PENDING");
   m.put("status", st);
   m.put("statusLabel", orderStatusLabel(st));
   m.put("canCancel", "PENDING".equals(st) || "CONFIRMED".equals(st));
   String recName = clean(rs.getString("RecipientName"));
   String recPhone = clean(rs.getString("RecipientPhone"));
   String shipAddr = clean(rs.getString("ShippingAddressSnapshot"));
   m.put("recipientName", recName.isEmpty() ? "Khách mua tại quầy" : recName);
   m.put("recipientPhone", recPhone.isEmpty() ? "—" : recPhone);
   m.put("shippingAddress", shipAddr.isEmpty() ? "Mua trực tiếp tại cửa hàng (" + storeName + ")" : shipAddr);
   BigDecimal sub = rs.getBigDecimal("Subtotal") != null ? rs.getBigDecimal("Subtotal") : BigDecimal.ZERO;
   BigDecimal disc = rs.getBigDecimal("DiscountAmount") != null ? rs.getBigDecimal("DiscountAmount") : BigDecimal.ZERO;
   BigDecimal ship = rs.getBigDecimal("ShippingFee") != null ? rs.getBigDecimal("ShippingFee") : BigDecimal.ZERO;
   BigDecimal tot = rs.getBigDecimal("TotalAmount") != null ? rs.getBigDecimal("TotalAmount") : BigDecimal.ZERO;
   m.put("subtotal", sub);
   m.put("subtotalLabel", vnd(sub));
   m.put("discountAmount", disc);
   m.put("discountLabel", vnd(disc));
   m.put("shippingFee", ship);
   m.put("shippingFeeLabel", vnd(ship));
   m.put("totalAmount", tot);
   m.put("totalAmountLabel", vnd(tot));
   Timestamp createdTs = rs.getTimestamp("CreatedAt");
   m.put("createdAt", formatTime(createdTs));
   m.put("estimatedDelivery", estimatedDelivery(createdTs));
   return m;
  }, orderId);

  if (orders.isEmpty())
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đơn hàng.");

  var order = orders.get(0);
  Object custObj = order.get("customerId");
  boolean isOwner = (custObj instanceof Number n) && n.intValue() == userId;
  if (!isOwner && !staffOrAdmin)
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đơn hàng.");

  if (("Khách mua tại quầy".equals(order.get("recipientName")) || "—".equals(order.get("recipientPhone")))
      && custObj instanceof Number custNum) {
   try {
    jdbc.query("SELECT FullName, Phone FROM dbo.Users WHERE UserId=?", rs -> {
     String fn = clean(rs.getString("FullName"));
     String ph = clean(rs.getString("Phone"));
     if (!fn.isEmpty() && "Khách mua tại quầy".equals(order.get("recipientName"))) order.put("recipientName", fn);
     if (!ph.isEmpty() && "—".equals(order.get("recipientPhone"))) order.put("recipientPhone", ph);
    }, custNum.intValue());
   } catch (DataAccessException ignored) {}
  }

  var payments = jdbc.query("""
   SELECT PaymentId, Method, Provider, Amount, Status, ProviderTransactionId, PaidAt
   FROM dbo.Payments
   WHERE OrderId = ?
   ORDER BY PaymentId DESC
   """, (rs, i) -> {
   var p = new LinkedHashMap<String, Object>();
   String method = Objects.toString(rs.getString("Method"), "CASH");
   String pStatus = Objects.toString(rs.getString("Status"), "PENDING");
   p.put("paymentId", rs.getInt("PaymentId"));
   p.put("method", method);
   p.put("methodLabel", paymentMethodLabel(method));
   p.put("provider", rs.getString("Provider"));
   p.put("status", pStatus);
   p.put("statusLabel", paymentStatusLabel(pStatus));
   p.put("transactionId", rs.getString("ProviderTransactionId"));
   p.put("paidAt", rs.getTimestamp("PaidAt") != null ? formatTime(rs.getTimestamp("PaidAt")) : null);
   p.put("isBankTransfer", "BANK_TRANSFER".equals(method));
   p.put("isPaid", "SUCCEEDED".equals(pStatus));
   return p;
  }, orderId);

  if (!payments.isEmpty()) {
   order.put("payment", payments.get(0));
  } else {
   order.put("payment", Map.of(
    "method", "CASH",
    "methodLabel", paymentMethodLabel("CASH"),
    "status", "PENDING",
    "statusLabel", paymentStatusLabel("PENDING"),
    "isBankTransfer", false,
    "isPaid", false
   ));
  }

  var items = jdbc.query("""
   SELECT oi.OrderItemId, oi.CopyId, oi.BookTitleSnapshot, oi.ConditionSnapshot,
    oi.UnitPrice, oi.LineTotal, bc.CopyCode, bc.BookId, b.CoverImage, s.StoreName
   FROM dbo.OrderItems oi
   JOIN dbo.BookCopies bc ON bc.CopyId = oi.CopyId
   JOIN dbo.Books b ON b.BookId = bc.BookId
   JOIN dbo.Stores s ON s.StoreId = bc.StoreId
   WHERE oi.OrderId = ?
   ORDER BY oi.OrderItemId ASC
   """, (rs, i) -> {
   var item = new LinkedHashMap<String, Object>();
   int bookId = rs.getInt("BookId");
   item.put("orderItemId", rs.getInt("OrderItemId"));
   item.put("copyId", rs.getInt("CopyId"));
   item.put("copyCode", rs.getString("CopyCode"));
   item.put("bookId", bookId);
   item.put("title", rs.getString("BookTitleSnapshot"));
   item.put("conditionName", rs.getString("ConditionSnapshot"));
   item.put("storeName", rs.getString("StoreName"));
   item.put("cover", catalog.cover(bookId, rs.getString("CoverImage")));
   BigDecimal price = rs.getBigDecimal("LineTotal");
   item.put("price", price);
   item.put("priceLabel", vnd(price));
   return (Map<String, Object>) item;
  }, orderId);

  order.put("items", items);
  order.put("itemCount", items.size());
  return order;
 }

 public List<Map<String, Object>> listOrders(int userId) {
  return jdbc.query("""
   SELECT o.OrderId, o.OrderCode, o.Status, o.RecipientName, o.RecipientPhone,
    o.TotalAmount, o.CreatedAt,
    (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.OrderId) AS itemCount,
    (SELECT MAX(Method) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentMethod,
    (SELECT MAX(Status) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentStatus
   FROM dbo.Orders o
   WHERE o.CustomerId = ?
   ORDER BY o.CreatedAt DESC, o.OrderId DESC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   String st = Objects.toString(rs.getString("Status"), "PENDING");
   String pm = Objects.toString(rs.getString("paymentMethod"), "CASH");
   String ps = Objects.toString(rs.getString("paymentStatus"), "PENDING");
   BigDecimal total = rs.getBigDecimal("TotalAmount");
   Timestamp createdTs = rs.getTimestamp("CreatedAt");
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("status", st);
   m.put("statusLabel", orderStatusLabel(st));
   m.put("canCancel", "PENDING".equals(st) || "CONFIRMED".equals(st));
   m.put("recipientName", rs.getString("RecipientName"));
   m.put("recipientPhone", rs.getString("RecipientPhone"));
   m.put("totalAmount", total);
   m.put("totalAmountLabel", vnd(total));
   m.put("createdAt", formatTime(createdTs));
   m.put("estimatedDelivery", estimatedDelivery(createdTs));
   m.put("itemCount", rs.getInt("itemCount"));
   m.put("paymentMethodLabel", paymentMethodLabel(pm));
   m.put("paymentStatusLabel", paymentStatusLabel(ps));
   return (Map<String, Object>) m;
  }, userId);
 }

 static String estimatedDelivery(Timestamp createdAt) {
  LocalDate baseDate = createdAt == null
   ? LocalDate.now(VN_ZONE)
   : createdAt.toInstant().atZone(VN_ZONE).toLocalDate();
  LocalDate from = baseDate.plusDays(2);
  LocalDate to = baseDate.plusDays(3);
  return DATE_ONLY_FMT.format(from) + " – " + DATE_ONLY_FMT.format(to);
 }

 static String vnd(BigDecimal amount) {
  BigDecimal safe = amount == null ? BigDecimal.ZERO : amount;
  return java.text.NumberFormat.getIntegerInstance(Locale.forLanguageTag("vi-VN")).format(safe) + " ₫";
 }

 static String orderStatusLabel(String status) {
  return switch (status.toUpperCase(Locale.ROOT)) {
   case "PENDING" -> "Chờ xác nhận";
   case "CONFIRMED" -> "Đã xác nhận";
   case "PROCESSING" -> "Đang đóng gói";
   case "SHIPPED" -> "Đang giao (SPX Express)";
   case "COMPLETED" -> "Đã giao thành công";
   case "CANCELLED" -> "Đã hủy";
   default -> status;
  };
 }

 static String paymentMethodLabel(String method) {
  return switch (method.toUpperCase(Locale.ROOT)) {
   case "BANK_TRANSFER" -> "Chuyển khoản QR Vietcombank";
   case "CASH", "COD" -> "Tiền mặt khi nhận hàng (COD)";
   default -> method;
  };
 }

 static String paymentStatusLabel(String status) {
  return switch (status.toUpperCase(Locale.ROOT)) {
   case "SUCCEEDED" -> "Đã thanh toán";
   case "PENDING" -> "Chờ thanh toán";
   case "CANCELLED" -> "Đã hủy";
   case "FAILED" -> "Thanh toán thất bại";
   default -> status;
  };
 }

 private static String formatTime(Timestamp ts) {
  if (ts == null) return "";
  return DATE_TIME_FMT.format(ts.toInstant());
 }

 private int extractId(GeneratedKeyHolder kh, String orderCode) {
  Number key = kh.getKey();
  if (key != null) return key.intValue();
  var keys = kh.getKeys();
  if (keys != null && !keys.isEmpty()) {
   Object first = keys.values().iterator().next();
   if (first instanceof Number n) return n.intValue();
  }
  Integer id = jdbc.queryForObject("SELECT OrderId FROM dbo.Orders WHERE OrderCode=?", Integer.class, orderCode);
  return id == null ? 0 : id;
 }

 private static String clean(String value) {
  return value == null ? "" : value.strip().replaceAll("\\s+", " ");
 }
}
