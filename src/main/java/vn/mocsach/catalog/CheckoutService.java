package vn.mocsach.catalog;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.scheduling.annotation.Scheduled;
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
 public static final int ORDER_WAITING_MINUTES = 15;
 private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
 private static final DateTimeFormatter DATE_TIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(VN_ZONE);
 private static final DateTimeFormatter DATE_ONLY_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

 private final JdbcTemplate jdbc;
 private final CatalogService catalog;
 private final CartService cart;
 private final NotificationService notifications;

 public CheckoutService(JdbcTemplate jdbc, CatalogService catalog, CartService cart, NotificationService notifications) {
  this.jdbc = jdbc;
  this.catalog = catalog;
  this.cart = cart;
  this.notifications = notifications;
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
   SELECT ci.CartItemId, bc.StoreId, s.StoreName, s.Status AS storeStatus, bc.CopyId, bc.CopyCode,
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
   m.put("storeName", rs.getString("StoreName"));
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

  for (var item : items) {
   if (!"AVAILABLE".equals(item.get("copyStatus")) || !"ACTIVE".equals(item.get("storeStatus")))
    throw new AuthProblem("Bản sách «" + item.get("title") + "» (" + item.get("copyCode") + ") hiện không còn khả dụng. Vui lòng kiểm tra lại giỏ hàng.");
  }

  Map<Integer, List<Map<String, Object>>> itemsByStore = new LinkedHashMap<>();
  for (var item : items) {
   int sId = ((Number) item.get("storeId")).intValue();
   itemsByStore.computeIfAbsent(sId, k -> new ArrayList<>()).add(item);
  }

  String baseCode = "MS-" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE) + "-"
   + String.format("%04d", ThreadLocalRandom.current().nextInt(1000, 10000));
  String note = clean(shipping.get("note"));
  String baseSnapshot = clean(shipping.get("addressLine")) + ", " + clean(shipping.get("administrativeArea"))
   + " | Giao hàng nhanh qua Shopee Express (SPX)"
   + (note.isEmpty() ? "" : " | Ghi chú: " + note);

  boolean isMultiStore = itemsByStore.size() > 1;
  int firstOrderId = 0;
  int storeIndex = 0;
  int totalStores = itemsByStore.size();

  for (var entry : itemsByStore.entrySet()) {
   int sId = entry.getKey();
   var storeItems = entry.getValue();
   String sName = String.valueOf(storeItems.get(0).get("storeName"));

   BigDecimal subtotalForStore = BigDecimal.ZERO;
   for (var item : storeItems) {
    subtotalForStore = subtotalForStore.add((BigDecimal) item.get("salePrice"));
   }
   BigDecimal discountForStore = BigDecimal.ZERO;
   BigDecimal feeForStore = (storeIndex == 0) ? SPX_SHIPPING_FEE : BigDecimal.ZERO;
   BigDecimal totalForStore = subtotalForStore.subtract(discountForStore).add(feeForStore);

   String orderCode = isMultiStore ? (baseCode + "-" + (storeIndex + 1)) : baseCode;
   String snapshot = isMultiStore
    ? (baseSnapshot + " [Kiện " + (storeIndex + 1) + "/" + totalStores + " - CN: " + sName + "]")
    : baseSnapshot;

   final BigDecimal fSub = subtotalForStore;
   final BigDecimal fDisc = discountForStore;
   final BigDecimal fFee = feeForStore;
   final BigDecimal fTot = totalForStore;
   final String fOrderCode = orderCode;
   final String fSnapshot = snapshot;
   final int fStoreId = sId;

   var kh = new GeneratedKeyHolder();
   jdbc.update(con -> {
    PreparedStatement ps = con.prepareStatement("""
     INSERT INTO dbo.Orders(OrderCode, StoreId, CustomerId, CreatedBy, Channel, Status,
      RecipientName, RecipientPhone, ShippingAddressSnapshot, Subtotal, DiscountAmount,
      ShippingFee, TotalAmount, Version, CreatedAt, UpdatedAt)
     VALUES(?, ?, ?, NULL, 'ONLINE', 'PENDING', ?, ?, ?, ?, ?, ?, ?, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
     """, Statement.RETURN_GENERATED_KEYS);
    ps.setString(1, fOrderCode);
    ps.setInt(2, fStoreId);
    ps.setInt(3, userId);
    ps.setString(4, clean(shipping.get("recipientName")));
    ps.setString(5, clean(shipping.get("recipientPhone")));
    ps.setString(6, fSnapshot);
    ps.setBigDecimal(7, fSub);
    ps.setBigDecimal(8, fDisc);
    ps.setBigDecimal(9, fFee);
    ps.setBigDecimal(10, fTot);
    return ps;
   }, kh);

   int subOrderId = extractId(kh, orderCode);
   if (storeIndex == 0) {
    firstOrderId = subOrderId;
   }

   for (var item : storeItems) {
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
     """, subOrderId, copyId, item.get("title"), item.get("conditionName"), unitPrice, unitCost, unitPrice);

    try {
     Timestamp expiresAt = new Timestamp(System.currentTimeMillis() + ORDER_WAITING_MINUTES * 60 * 1000L);
     jdbc.update("""
      INSERT INTO dbo.StockReservations(CopyId, OrderId, Status, ReservedAt, ExpiresAt, ReleasedAt)
      VALUES(?, ?, 'ACTIVE', CURRENT_TIMESTAMP, ?, NULL)
      """, copyId, subOrderId, expiresAt);
    } catch (DataAccessException ignored) {}
   }

   String historyReason = isMultiStore
    ? "Đặt hàng trực tuyến qua Shopee Express (SPX) - Kiện " + (storeIndex + 1) + "/" + totalStores + " (" + sName + ")"
    : "Đặt hàng trực tuyến qua Shopee Express (SPX)";
   jdbc.update("""
    INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
    VALUES(?, NULL, 'PENDING', ?, CURRENT_TIMESTAMP, ?)
    """, subOrderId, userId, historyReason);

   String idemp = "PAY-" + orderCode + "-" + UUID.randomUUID().toString().substring(0, 8);
   jdbc.update("""
    INSERT INTO dbo.Payments(OrderId, Method, Provider, Amount, Currency, Status, ProviderTransactionId, IdempotencyKey, PaidAt, CreatedAt)
    VALUES(?, ?, ?, ?, 'VND', 'PENDING', NULL, ?, NULL, CURRENT_TIMESTAMP)
    """, subOrderId, method, provider, totalForStore, idemp);

   storeIndex++;
  }

  jdbc.update("DELETE FROM dbo.CartItems WHERE CartId IN (SELECT CartId FROM dbo.Carts WHERE UserId=? AND Status='ACTIVE')", userId);
  return firstOrderId;
 }

 public boolean isStaffOrAdmin(int userId) {
  try {
   Integer c = jdbc.queryForObject("""
    SELECT COUNT(*)
    FROM dbo.UserRoles ur
    JOIN dbo.Roles r ON r.RoleId = ur.RoleId
    WHERE ur.UserId = ? AND r.RoleCode IN ('ADMIN', 'MANAGER', 'STAFF')
    """, Integer.class, userId);
   if (c != null && c > 0) return true;
  } catch (DataAccessException ignored) {}
  try {
   Integer s = jdbc.queryForObject("""
    SELECT COUNT(*)
    FROM dbo.StaffStoreAssignments
    WHERE UserId = ? AND Status = 'ACTIVE'
    """, Integer.class, userId);
   return s != null && s > 0;
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

  List<Integer> orderIdsToUpdate = new ArrayList<>();
  orderIdsToUpdate.add(orderId);
  if (Boolean.TRUE.equals(order.get("isMultiStore"))) {
   @SuppressWarnings("unchecked")
   var siblings = (List<Map<String, Object>>) order.get("siblingOrders");
   if (siblings != null) {
    for (var sib : siblings) {
     int sOrdId = ((Number) sib.get("orderId")).intValue();
     if (!orderIdsToUpdate.contains(sOrdId)) orderIdsToUpdate.add(sOrdId);
    }
   }
  }

  for (int oId : orderIdsToUpdate) {
   String txId = "VCB-QR-" + oId + "-" + (System.currentTimeMillis() % 1000000);
   jdbc.update("""
    UPDATE dbo.Payments
    SET Status='SUCCEEDED',
        ProviderTransactionId= COALESCE(ProviderTransactionId, ?),
        PaidAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END
    WHERE OrderId=? AND Status<>'SUCCEEDED'
    """, txId, oId);

   String curSt = jdbc.queryForObject("SELECT Status FROM dbo.Orders WHERE OrderId=?", String.class, oId);
   if ("PENDING".equals(curSt)) {
    jdbc.update("UPDATE dbo.Orders SET Status='CONFIRMED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", oId);
    jdbc.update("""
     INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
     VALUES(?, 'PENDING', 'CONFIRMED', ?, CURRENT_TIMESTAMP, ?)
     """, oId, userId, "Xác nhận đã chuyển khoản QR Vietcombank thành công");
     try {
      jdbc.update("""
       UPDATE dbo.StockReservations
       SET Status='CONSUMED', ReleasedAt=CURRENT_TIMESTAMP
       WHERE OrderId=? AND Status='ACTIVE'
       """, oId);
     } catch (DataAccessException ignored) {}
   }
  }
  return orderDetail(userId, orderId);
 }

 @Scheduled(fixedDelay = 15000)
 @Transactional
 public int cancelExpiredPendingOrders() {
  List<Map<String, Object>> candidateOrders;
  try {
   candidateOrders = jdbc.query("""
    SELECT o.OrderId, o.OrderCode, o.CustomerId, o.CreatedAt,
           (SELECT MAX(p.Method) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentMethod,
           (SELECT MAX(p.Status) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentStatus
    FROM dbo.Orders o
    WHERE o.Status = 'PENDING'
    """, (rs, i) -> {
    var m = new HashMap<String, Object>();
    m.put("orderId", rs.getInt("OrderId"));
    m.put("orderCode", rs.getString("OrderCode"));
    m.put("customerId", rs.getObject("CustomerId"));
    m.put("createdAt", rs.getTimestamp("CreatedAt"));
    m.put("paymentMethod", Objects.toString(rs.getString("paymentMethod"), "CASH"));
    m.put("paymentStatus", Objects.toString(rs.getString("paymentStatus"), "PENDING"));
    return m;
   });
  } catch (DataAccessException ex) {
   return 0;
  }

  long waitMillis = ORDER_WAITING_MINUTES * 60 * 1000L;
  long now = System.currentTimeMillis();
  int cancelledCount = 0;

  for (var cand : candidateOrders) {
   String method = (String) cand.get("paymentMethod");
   String payStatus = (String) cand.get("paymentStatus");
   if (!"BANK_TRANSFER".equalsIgnoreCase(method) || "SUCCEEDED".equalsIgnoreCase(payStatus)) {
    continue;
   }

   Timestamp createdTs = (Timestamp) cand.get("createdAt");
   if (createdTs == null) continue;

   if ((now - createdTs.getTime()) >= waitMillis) {
    int ordId = (Integer) cand.get("orderId");
    String ordCode = (String) cand.get("orderCode");
    Integer custId = cand.get("customerId") instanceof Number n ? n.intValue() : null;
    doCancelExpiredOrder(ordId, ordCode, custId);

    String baseCode = extractBaseCode(ordCode);
    if (baseCode != null && custId != null) {
     try {
      var sibIds = jdbc.queryForList("""
       SELECT OrderId FROM dbo.Orders WHERE OrderCode LIKE ? AND CustomerId = ? AND Status = 'PENDING'
       """, Integer.class, baseCode + "-%", custId);
      for (Integer sId : sibIds) {
       if (sId != null && sId != ordId) {
        doCancelExpiredOrder(sId, ordCode, custId);
       }
      }
     } catch (DataAccessException ignored) {}
    }

    cancelledCount++;
   }
  }
  return cancelledCount;
 }

 @Transactional
 public void doCancelExpiredOrder(int orderId, String orderCode, Integer customerId) {
  try {
   String curStatus = jdbc.query("SELECT Status FROM dbo.Orders WHERE OrderId=?", (rs, i) -> rs.getString(1), orderId)
    .stream().findFirst().orElse(null);
   if (!"PENDING".equals(curStatus)) {
    return;
   }

   jdbc.update("UPDATE dbo.Orders SET Status='CANCELLED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", orderId);
   jdbc.update("UPDATE dbo.Payments SET Status='CANCELLED', PaidAt=NULL WHERE OrderId=?", orderId);
   jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status='AVAILABLE', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
    WHERE CopyId IN (SELECT CopyId FROM dbo.OrderItems WHERE OrderId=?) AND Status='RESERVED'
    """, orderId);

   try {
    jdbc.update("""
     UPDATE dbo.StockReservations
     SET Status='EXPIRED', ReleasedAt=CURRENT_TIMESTAMP
     WHERE OrderId=? AND Status='ACTIVE'
     """, orderId);
   } catch (DataAccessException ignored) {}

   jdbc.update("""
    INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
    VALUES(?, 'PENDING', 'CANCELLED', ?, CURRENT_TIMESTAMP, ?)
    """, orderId, customerId, "Tự động hủy do hết thời gian chờ hoàn tất đơn hàng (" + ORDER_WAITING_MINUTES + " phút)");

   if (customerId != null && notifications != null) {
    try {
     notifications.create(customerId, "ORDER", "Đơn hàng " + orderCode + " đã tự động hủy",
      "Đơn hàng " + orderCode + " đã bị hủy tự động do quá thời gian chờ hoàn tất thanh toán (" + ORDER_WAITING_MINUTES + " phút). Các cuốn sách đã được hoàn lại kệ hàng.",
      "/orders/" + orderId);
    } catch (Exception ignored) {}
   }
  } catch (DataAccessException ignored) {}
 }

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
   try {
    jdbc.update("""
     UPDATE dbo.StockReservations
     SET Status='CANCELLED', ReleasedAt=CURRENT_TIMESTAMP
     WHERE OrderId=? AND Status='ACTIVE'
     """, orderId);
   } catch (DataAccessException ignored) {}
  jdbc.update("""
   INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
   VALUES(?, ?, 'CANCELLED', ?, CURRENT_TIMESTAMP, ?)
   """, orderId, status, userId, "Yêu cầu hủy đơn hàng");

  return orderDetail(userId, orderId);
 }

 @Transactional
 public Map<String, Object> confirmOrderReceived(int userId, int orderId) {
  var order = orderDetail(userId, orderId);
  String status = Objects.toString(order.get("status"), "");
  if (!"SHIPPED".equals(status)) {
   if ("COMPLETED".equals(status)) {
    throw new AuthProblem("Đơn hàng này đã được xác nhận đã giao thành công trước đó.");
   }
   if ("CANCELLED".equals(status)) {
    throw new AuthProblem("Đơn hàng đã bị hủy, không thể xác nhận nhận hàng.");
   }
   throw new AuthProblem("Chỉ có thể xác nhận đã nhận hàng khi đơn hàng đang ở trạng thái đang giao.");
  }

  List<Integer> orderIdsToUpdate = new ArrayList<>();
  orderIdsToUpdate.add(orderId);
  if (Boolean.TRUE.equals(order.get("isMultiStore"))) {
   @SuppressWarnings("unchecked")
   var siblings = (List<Map<String, Object>>) order.get("siblingOrders");
   if (siblings != null) {
    for (var sib : siblings) {
     int sOrdId = ((Number) sib.get("orderId")).intValue();
     if (!orderIdsToUpdate.contains(sOrdId)) orderIdsToUpdate.add(sOrdId);
    }
   }
  }

  for (int oId : orderIdsToUpdate) {
   String oldSt = jdbc.query("SELECT Status FROM dbo.Orders WHERE OrderId=?", (rs, i) -> rs.getString(1), oId)
    .stream().findFirst().orElse("SHIPPED");

   jdbc.update("UPDATE dbo.Orders SET Status='COMPLETED', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderId=?", oId);

   jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status='SOLD', Version=Version+1, UpdatedAt=CURRENT_TIMESTAMP
    WHERE CopyId IN (SELECT CopyId FROM dbo.OrderItems WHERE OrderId=?)
    """, oId);

   jdbc.update("""
    UPDATE dbo.Payments
    SET Status='SUCCEEDED',
        PaidAt=CASE WHEN PaidAt IS NOT NULL THEN PaidAt ELSE CURRENT_TIMESTAMP END
    WHERE OrderId=? AND Status<>'SUCCEEDED'
    """, oId);

   try {
    jdbc.update("UPDATE dbo.StockReservations SET Status='CONSUMED', ReleasedAt=CURRENT_TIMESTAMP WHERE OrderId=? AND Status='ACTIVE'", oId);
   } catch (DataAccessException ignored) {}

   jdbc.update("""
    INSERT INTO dbo.OrderStatusHistory(OrderId, FromStatus, ToStatus, ChangedBy, ChangedAt, Reason)
    VALUES(?, ?, 'COMPLETED', ?, CURRENT_TIMESTAMP, ?)
    """, oId, oldSt, userId, "Khách hàng xác nhận đã nhận hàng thành công");
  }

  String code = String.valueOf(order.get("orderCode"));
  if (notifications != null) {
   try {
    notifications.create(userId, "ORDER", "Đơn hàng " + code + " đã giao thành công",
     "Cảm ơn bạn đã xác nhận đã nhận hàng cho đơn hàng " + code + ". Mộc Sách chúc bạn có những giờ phút đọc sách thật ý nghĩa!",
     "/orders/" + orderId);
   } catch (Exception ignored) {}
  }

  return orderDetail(userId, orderId);
 }

 @Transactional
 public Map<String, Object> checkQrStatus(int userId, int orderId) {
  cancelExpiredPendingOrders();
  boolean staffOrAdmin = isStaffOrAdmin(userId);
  var orders = jdbc.query("""
   SELECT o.OrderId, o.OrderCode, o.CustomerId, o.Status,
    (SELECT MAX(p.Status) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS PaymentStatus,
    (SELECT MAX(p.Method) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS PaymentMethod
   FROM dbo.Orders o
   WHERE o.OrderId = ?
   """, (rs, i) -> {
   var m = new HashMap<String, Object>();
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("customerId", rs.getObject("CustomerId"));
   m.put("status", rs.getString("Status"));
   m.put("paymentStatus", rs.getString("PaymentStatus"));
   m.put("paymentMethod", rs.getString("PaymentMethod"));
   return m;
  }, orderId);

  if (orders.isEmpty()) {
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đơn hàng.");
  }

  var order = orders.get(0);
  Object custObj = order.get("customerId");
  boolean isOwner = (custObj instanceof Number n) && n.intValue() == userId;
  if (!isOwner && !staffOrAdmin) {
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy đơn hàng.");
  }

  String status = Objects.toString(order.get("status"), "PENDING");
  String paymentStatus = Objects.toString(order.get("paymentStatus"), "PENDING");
  String paymentMethod = Objects.toString(order.get("paymentMethod"), "CASH");
  boolean isBank = "BANK_TRANSFER".equalsIgnoreCase(paymentMethod);

  boolean isApproved = List.of("CONFIRMED", "PROCESSING", "SHIPPED", "COMPLETED").contains(status);
  if (isApproved && isBank && !"SUCCEEDED".equalsIgnoreCase(paymentStatus)) {
   jdbc.update("""
    UPDATE dbo.Payments
    SET Status='SUCCEEDED',
        PaidAt=CASE WHEN CreatedAt>CURRENT_TIMESTAMP THEN CreatedAt ELSE CURRENT_TIMESTAMP END
    WHERE OrderId=? AND Status<>'SUCCEEDED' AND Method='BANK_TRANSFER'
    """, orderId);
   paymentStatus = "SUCCEEDED";
  }

  boolean isCancelled = "CANCELLED".equalsIgnoreCase(status);
  boolean isPaid = "SUCCEEDED".equalsIgnoreCase(paymentStatus);
  boolean shouldRedirect = !isCancelled && (isApproved || isPaid);

  var res = new LinkedHashMap<String, Object>();
  res.put("orderId", orderId);
  res.put("orderCode", order.get("orderCode"));
  res.put("status", status);
  res.put("statusLabel", orderStatusLabel(status));
  res.put("paymentStatus", paymentStatus);
  res.put("paymentMethod", paymentMethod);
  res.put("isPaid", isPaid);
  res.put("shouldRedirect", shouldRedirect);
  res.put("isCancelled", isCancelled);
  res.put("redirectUrl", "/orders/" + orderId + "?paid=true");
  return res;
 }

 public Map<String, Object> orderDetail(int userId, int orderId) {
  cancelExpiredPendingOrders();
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
   m.put("canConfirmReceived", "SHIPPED".equals(st));
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
   m.put("createdAtRaw", createdTs);
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

  @SuppressWarnings("unchecked")
  var activePay = (Map<String, Object>) order.get("payment");
  String payMethod = activePay != null ? Objects.toString(activePay.get("method"), "CASH") : "CASH";
  boolean isBank = "BANK_TRANSFER".equalsIgnoreCase(payMethod);
  boolean isPaid = activePay != null && Boolean.TRUE.equals(activePay.get("isPaid"));
  String ordSt = Objects.toString(order.get("status"), "PENDING");

  Timestamp rawCreatedTs = (Timestamp) order.get("createdAtRaw");
  long waitMillis = ORDER_WAITING_MINUTES * 60 * 1000L;
  long elapsedMillis = rawCreatedTs != null ? (System.currentTimeMillis() - rawCreatedTs.getTime()) : 0;
  long remainingMillis = Math.max(0, waitMillis - elapsedMillis);
  long remainingSeconds = remainingMillis / 1000L;
  order.put("waitingMinutes", ORDER_WAITING_MINUTES);
  order.put("remainingSeconds", remainingSeconds);
  order.put("remainingTimeLabel", String.format("%02d:%02d", remainingSeconds / 60, remainingSeconds % 60));
  order.put("hasWaitingTimer", isBank && "PENDING".equals(ordSt) && !isPaid);
  order.put("isExpired", "CANCELLED".equals(ordSt) && elapsedMillis >= waitMillis);

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

  String orderCode = (String) order.get("orderCode");
  String baseCode = extractBaseCode(orderCode);
  if (baseCode != null) {
   var siblings = jdbc.query("""
    SELECT o.OrderId, o.OrderCode, o.StoreId, s.StoreName, o.Status, o.TotalAmount
    FROM dbo.Orders o
    JOIN dbo.Stores s ON s.StoreId = o.StoreId
    WHERE o.OrderCode LIKE ? AND o.CustomerId = ?
    ORDER BY o.OrderId ASC
    """, (rs, i) -> {
    var sm = new LinkedHashMap<String, Object>();
    sm.put("orderId", rs.getInt("OrderId"));
    sm.put("orderCode", rs.getString("OrderCode"));
    sm.put("storeId", rs.getInt("StoreId"));
    sm.put("storeName", rs.getString("StoreName"));
    sm.put("status", rs.getString("Status"));
    sm.put("statusLabel", orderStatusLabel(rs.getString("Status")));
    BigDecimal tot = rs.getBigDecimal("TotalAmount");
    sm.put("totalAmount", tot);
    sm.put("totalAmountLabel", vnd(tot));
    return sm;
   }, baseCode + "-%", custObj);
   if (siblings.size() > 1) {
    order.put("isMultiStore", true);
    order.put("siblingOrders", siblings);
    order.put("baseOrderCode", baseCode);
    BigDecimal groupTotal = siblings.stream()
     .map(s -> (BigDecimal) s.get("totalAmount"))
     .reduce(BigDecimal.ZERO, BigDecimal::add);
    order.put("groupTotalAmount", groupTotal);
    order.put("groupTotalAmountLabel", vnd(groupTotal));
   }
  }

  return order;
 }

 public List<Map<String, Object>> listOrders(int userId) {
  cancelExpiredPendingOrders();
  return jdbc.query("""
   SELECT o.OrderId, o.OrderCode, o.StoreId, s.StoreName, o.Status, o.RecipientName, o.RecipientPhone,
    o.TotalAmount, o.CreatedAt,
    (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.OrderId) AS itemCount,
    (SELECT MAX(Method) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentMethod,
    (SELECT MAX(Status) FROM dbo.Payments p WHERE p.OrderId = o.OrderId) AS paymentStatus
   FROM dbo.Orders o
   JOIN dbo.Stores s ON s.StoreId = o.StoreId
   WHERE o.CustomerId = ?
   ORDER BY o.CreatedAt DESC, o.OrderId DESC
   """, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   String st = Objects.toString(rs.getString("Status"), "PENDING");
   String pm = Objects.toString(rs.getString("paymentMethod"), "CASH");
   String ps = Objects.toString(rs.getString("paymentStatus"), "PENDING");
   BigDecimal total = rs.getBigDecimal("TotalAmount");
   Timestamp createdTs = rs.getTimestamp("CreatedAt");
   m.put("createdAtRaw", createdTs);
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("status", st);
   m.put("statusLabel", orderStatusLabel(st));
   m.put("canCancel", "PENDING".equals(st) || "CONFIRMED".equals(st));
   m.put("canConfirmReceived", "SHIPPED".equals(st));
   m.put("recipientName", rs.getString("RecipientName"));
   m.put("recipientPhone", rs.getString("RecipientPhone"));
   m.put("totalAmount", total);
   m.put("totalAmountLabel", vnd(total));
   m.put("createdAt", formatTime(createdTs));
   m.put("estimatedDelivery", estimatedDelivery(createdTs));
   m.put("itemCount", rs.getInt("itemCount"));
   m.put("paymentMethodLabel", paymentMethodLabel(pm));
   m.put("paymentStatusLabel", paymentStatusLabel(ps));
   boolean isBankTransfer = "BANK_TRANSFER".equalsIgnoreCase(pm);
   boolean isPaid = "SUCCEEDED".equalsIgnoreCase(ps);
   m.put("isBankTransfer", isBankTransfer);
   m.put("isPaid", isPaid);
   long waitMillis = ORDER_WAITING_MINUTES * 60 * 1000L;
   long elapsedMillis = createdTs != null ? (System.currentTimeMillis() - createdTs.getTime()) : 0;
   long remainingMillis = Math.max(0, waitMillis - elapsedMillis);
   long remainingSeconds = remainingMillis / 1000L;
   m.put("remainingSeconds", remainingSeconds);
   m.put("remainingTimeLabel", String.format("%02d:%02d", remainingSeconds / 60, remainingSeconds % 60));
   m.put("hasWaitingTimer", isBankTransfer && "PENDING".equals(st) && !isPaid);
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
   case "PROCESSING" -> "Đang chuẩn bị hàng";
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

 static String extractBaseCode(String orderCode) {
  if (orderCode == null) return null;
  int lastDash = orderCode.lastIndexOf('-');
  if (lastDash > 0) {
   String prefix = orderCode.substring(0, lastDash);
   if (prefix.matches("^MS-\\d{8}-\\d{4}$")) {
    return prefix;
   }
  }
  return null;
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
