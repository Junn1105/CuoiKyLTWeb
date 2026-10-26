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
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

import static org.springframework.http.HttpStatus.NOT_FOUND;

@Service
public class StoreService {
 private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
 private static final DateTimeFormatter DATE_TIME_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm").withZone(VN_ZONE);

 private final JdbcTemplate jdbc;
 private final NotificationService notifications;
 private final org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

 public record UserStoreContext(
  int userId,
  String username,
  String fullName,
  boolean isAdmin,
  boolean isManager,
  boolean isStaff,
  Integer storeId,
  String storeCode,
  String storeName,
  String storeRole
 ) {
  public boolean canManageStore(int checkStoreId) {
   if (isAdmin) return true;
   return storeId != null && storeId.intValue() == checkStoreId;
  }
  public boolean isStaffOrAdmin() {
   return isAdmin || isManager || isStaff;
  }
 }

 public StoreService(JdbcTemplate jdbc, NotificationService notifications) {
  this(jdbc, notifications, new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder(12));
 }

 @org.springframework.beans.factory.annotation.Autowired
 public StoreService(JdbcTemplate jdbc, NotificationService notifications, org.springframework.security.crypto.password.PasswordEncoder passwordEncoder) {
  this.jdbc = jdbc;
  this.notifications = notifications;
  this.passwordEncoder = passwordEncoder;
 }

 static String formatTime(Timestamp ts) {
  return ts == null ? "—" : DATE_TIME_FMT.format(ts.toInstant());
 }

 static int extractGeneratedId(GeneratedKeyHolder keyHolder, String idColumn) {
  try {
   if (keyHolder.getKeys() != null && !keyHolder.getKeys().isEmpty()) {
    for (var entry : keyHolder.getKeys().entrySet()) {
     if (entry.getKey().equalsIgnoreCase(idColumn) && entry.getValue() instanceof Number n) {
      return n.intValue();
     }
    }
    for (var val : keyHolder.getKeys().values()) {
     if (val instanceof Number n) {
      return n.intValue();
     }
    }
   }
   Number k = keyHolder.getKey();
   return k == null ? 0 : k.intValue();
  } catch (Exception ex) {
   return 0;
  }
 }


 public List<Map<String, Object>> listStoresWithStats() {
  String sql = """
   SELECT s.StoreId, s.StoreCode, s.StoreName, s.Address, s.Phone, s.Status, s.OpenedAt,
     (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId) AS totalCopies,
     (SELECT COUNT(*) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status = 'AVAILABLE') AS availableCopies,
     (SELECT COUNT(DISTINCT bc.BookId) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status = 'AVAILABLE') AS distinctBooks,
     (SELECT COALESCE(SUM(bc.CostPrice), 0) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status = 'AVAILABLE') AS inventoryCost,
     (SELECT COALESCE(SUM(bc.SalePrice), 0) FROM dbo.BookCopies bc WHERE bc.StoreId = s.StoreId AND bc.Status = 'AVAILABLE') AS inventorySale,
     (SELECT COUNT(*) FROM dbo.StaffStoreAssignments sa WHERE sa.StoreId = s.StoreId AND sa.Status = 'ACTIVE') AS activeStaffCount,
     (SELECT COUNT(*) FROM dbo.Orders o WHERE o.StoreId = s.StoreId) AS orderCount,
     (SELECT COALESCE(SUM(o.TotalAmount), 0) FROM dbo.Orders o WHERE o.StoreId = s.StoreId AND o.Status = 'COMPLETED') AS totalRevenue
   FROM dbo.Stores s
   ORDER BY s.StoreId ASC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   int id = rs.getInt("StoreId");
   String status = rs.getString("Status");
   BigDecimal cost = rs.getBigDecimal("inventoryCost");
   BigDecimal sale = rs.getBigDecimal("inventorySale");
   BigDecimal revenue = rs.getBigDecimal("totalRevenue");

   m.put("storeId", id);
   m.put("storeCode", rs.getString("StoreCode"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("address", rs.getString("Address"));
   m.put("phone", rs.getString("Phone") == null ? "Chưa cập nhật" : rs.getString("Phone"));
   m.put("status", status);
   m.put("statusLabel", storeStatusLabel(status));
   m.put("openedAt", rs.getDate("OpenedAt") == null ? "—" : rs.getDate("OpenedAt").toString());
   m.put("totalCopies", rs.getInt("totalCopies"));
   m.put("availableCopies", rs.getInt("availableCopies"));
   m.put("distinctBooks", rs.getInt("distinctBooks"));
   m.put("inventoryCost", cost);
   m.put("inventoryCostLabel", CheckoutService.vnd(cost));
   m.put("inventorySale", sale);
   m.put("inventorySaleLabel", CheckoutService.vnd(sale));
   m.put("activeStaffCount", rs.getInt("activeStaffCount"));
   m.put("orderCount", rs.getInt("orderCount"));
   m.put("revenue", revenue);
   m.put("revenueLabel", CheckoutService.vnd(revenue));
   return (Map<String, Object>) m;
  });
 }

 public List<Map<String, Object>> activeStores() {
  return jdbc.query("SELECT StoreId, StoreCode, StoreName, Address, Phone FROM dbo.Stores WHERE Status = 'ACTIVE' ORDER BY StoreId", (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("id", rs.getInt("StoreId"));
   m.put("code", rs.getString("StoreCode"));
   m.put("name", rs.getString("StoreName"));
   m.put("address", rs.getString("Address"));
   m.put("phone", rs.getString("Phone"));
   return (Map<String, Object>) m;
  });
 }

 public Map<String, Object> getStore(int storeId) {
  var list = listStoresWithStats().stream()
   .filter(s -> ((Number) s.get("storeId")).intValue() == storeId)
   .findFirst();
  return list.orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Không tìm thấy chi nhánh ID=" + storeId));
 }

 @Transactional
 public int createStore(String storeCode, String storeName, String address, String phone, String status) {
  String code = storeCode == null ? "" : storeCode.trim().toUpperCase(Locale.ROOT);
  String name = storeName == null ? "" : storeName.trim();
  String addr = address == null ? "" : address.trim();
  String tel = phone == null ? "" : phone.trim();
  String st = status == null || status.isBlank() ? "ACTIVE" : status.trim().toUpperCase(Locale.ROOT);

  if (code.length() < 2 || code.length() > 30) {
   throw new AuthProblem("Mã chi nhánh phải từ 2 đến 30 ký tự.");
  }
  if (name.length() < 2 || name.length() > 150) {
   throw new AuthProblem("Tên chi nhánh phải từ 2 đến 150 ký tự.");
  }
  if (addr.length() < 5 || addr.length() > 500) {
   throw new AuthProblem("Địa chỉ chi nhánh phải từ 5 đến 500 ký tự.");
  }
  if (!Set.of("ACTIVE", "TEMPORARILY_CLOSED", "CLOSED").contains(st)) {
   throw new AuthProblem("Trạng thái chi nhánh không hợp lệ.");
  }

  Integer count = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Stores WHERE UPPER(StoreCode) = ?", Integer.class, code);
  if (count != null && count > 0) {
   throw new AuthProblem("Mã chi nhánh " + code + " đã tồn tại trong hệ thống.");
  }

  var keyHolder = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement(
    "INSERT INTO dbo.Stores(StoreCode, StoreName, Address, Phone, Status, OpenedAt, CreatedAt, UpdatedAt) VALUES(?,?,?,?,?,CAST(CURRENT_TIMESTAMP AS date),CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)",
    Statement.RETURN_GENERATED_KEYS
   );
   ps.setString(1, code);
   ps.setString(2, name);
   ps.setString(3, addr);
   ps.setString(4, tel.isBlank() ? null : tel);
   ps.setString(5, st);
   return ps;
  }, keyHolder);

  return extractGeneratedId(keyHolder, "StoreId");
 }

 @Transactional
 public void updateStore(int storeId, String storeName, String address, String phone, String status) {
  String name = storeName == null ? "" : storeName.trim();
  String addr = address == null ? "" : address.trim();
  String tel = phone == null ? "" : phone.trim();
  String st = status == null ? "ACTIVE" : status.trim().toUpperCase(Locale.ROOT);

  if (name.length() < 2 || name.length() > 150) {
   throw new AuthProblem("Tên chi nhánh phải từ 2 đến 150 ký tự.");
  }
  if (addr.length() < 5 || addr.length() > 500) {
   throw new AuthProblem("Địa chỉ chi nhánh phải từ 5 đến 500 ký tự.");
  }
  if (!Set.of("ACTIVE", "TEMPORARILY_CLOSED", "CLOSED").contains(st)) {
   throw new AuthProblem("Trạng thái chi nhánh không hợp lệ.");
  }

  int rows = jdbc.update(
   "UPDATE dbo.Stores SET StoreName=?, Address=?, Phone=?, Status=?, UpdatedAt=CURRENT_TIMESTAMP WHERE StoreId=?",
   name, addr, tel.isBlank() ? null : tel, st, storeId
  );
  if (rows == 0) {
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy chi nhánh ID=" + storeId);
  }
 }

 // ================= USER CONTEXT & PERMISSIONS =================

 public UserStoreContext getUserStoreContext(int userId) {
  var users = jdbc.query("SELECT UserId, Username, FullName FROM dbo.Users WHERE UserId = ?", (rs, i) -> {
   var m = new HashMap<String, String>();
   m.put("username", rs.getString("Username"));
   m.put("fullName", rs.getString("FullName"));
   return m;
  }, userId);
  if (users.isEmpty()) {
   throw new AuthProblem("Tài khoản không tồn tại.");
  }
  String username = users.get(0).get("username");
  String fullName = users.get(0).get("fullName");

  List<String> roles = jdbc.queryForList(
   "SELECT r.RoleCode FROM dbo.Roles r JOIN dbo.UserRoles ur ON ur.RoleId = r.RoleId WHERE ur.UserId = ?",
   String.class, userId
  );
  boolean isAdmin = roles.contains("ADMIN");
  boolean hasStaffRole = roles.contains("STAFF") || roles.contains("MANAGER");

  String assignSql = """
   SELECT a.StoreId, s.StoreCode, s.StoreName, a.StoreRole
   FROM dbo.StaffStoreAssignments a
   JOIN dbo.Stores s ON s.StoreId = a.StoreId
   WHERE a.UserId = ? AND a.Status = 'ACTIVE'
   ORDER BY CASE WHEN a.StoreRole = 'MANAGER' THEN 0 ELSE 1 END, a.AssignmentId DESC
   """;
  var assignments = jdbc.query(assignSql, (rs, i) -> {
   var m = new HashMap<String, Object>();
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeCode", rs.getString("StoreCode"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("storeRole", rs.getString("StoreRole"));
   return m;
  }, userId);

  Integer storeId = null;
  String storeCode = null;
  String storeName = null;
  String storeRole = null;
  boolean isManager = false;

  if (!assignments.isEmpty()) {
   var first = assignments.get(0);
   storeId = (Integer) first.get("storeId");
   storeCode = (String) first.get("storeCode");
   storeName = (String) first.get("storeName");
   storeRole = (String) first.get("storeRole");
   isManager = "MANAGER".equalsIgnoreCase(storeRole);
  }

  boolean isStaff = hasStaffRole || !assignments.isEmpty();

  return new UserStoreContext(userId, username, fullName, isAdmin, isManager, isStaff, storeId, storeCode, storeName, storeRole);
 }

 // ================= STAFF ASSIGNMENTS =================

 public List<Map<String, Object>> listStaffAssignments() {
  return listStaffAssignments(null);
 }

 public List<Map<String, Object>> listStaffAssignments(Integer filterStoreId) {
  String sql = """
   SELECT a.AssignmentId, a.UserId, u.Username, u.FullName, u.Email, u.Phone,
          s.StoreId, s.StoreCode, s.StoreName, a.StoreRole, a.StartAt, a.EndAt, a.Status
   FROM dbo.StaffStoreAssignments a
   JOIN dbo.Users u ON u.UserId = a.UserId
   JOIN dbo.Stores s ON s.StoreId = a.StoreId
   WHERE (? IS NULL OR a.StoreId = ?)
   ORDER BY CASE WHEN a.Status = 'ACTIVE' THEN 0 ELSE 1 END, a.StartAt DESC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("assignmentId", rs.getInt("AssignmentId"));
   m.put("userId", rs.getInt("UserId"));
   m.put("username", rs.getString("Username"));
   m.put("fullName", rs.getString("FullName"));
   m.put("email", rs.getString("Email"));
   m.put("phone", rs.getString("Phone") == null ? "—" : rs.getString("Phone"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeCode", rs.getString("StoreCode"));
   m.put("storeName", rs.getString("StoreName"));
   String role = rs.getString("StoreRole");
   m.put("storeRole", role);
   m.put("storeRoleLabel", "MANAGER".equalsIgnoreCase(role) ? "Quản lý chi nhánh (Manager)" : "Nhân viên bán hàng (Staff)");
   m.put("status", rs.getString("Status"));
   m.put("statusLabel", "ACTIVE".equalsIgnoreCase(rs.getString("Status")) ? "Đang công tác" : "Đã kết thúc");
   m.put("startAt", formatTime(rs.getTimestamp("StartAt")));
   m.put("endAt", formatTime(rs.getTimestamp("EndAt")));
   return (Map<String, Object>) m;
  }, filterStoreId, filterStoreId);
 }

 public List<Map<String, Object>> getEligibleStaffUsers() {
  String sql = """
   SELECT DISTINCT u.UserId, u.Username, u.FullName, u.Email
   FROM dbo.Users u
   JOIN dbo.UserRoles ur ON ur.UserId = u.UserId
   JOIN dbo.Roles r ON r.RoleId = ur.RoleId
   WHERE r.RoleCode IN ('ADMIN', 'STAFF', 'MANAGER') AND u.Status = 'ACTIVE'
   ORDER BY u.FullName
   """;
  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("userId", rs.getInt("UserId"));
   m.put("username", rs.getString("Username"));
   m.put("fullName", rs.getString("FullName"));
   m.put("email", rs.getString("Email"));
   return (Map<String, Object>) m;
  });
 }

 @Transactional
 public void assignStaff(int userId, int storeId, String storeRole, Integer managerStoreId) {
  if (managerStoreId != null && managerStoreId.intValue() != storeId) {
   throw new AuthProblem("Quản lý chi nhánh chỉ được quyền phân công nhân sự tại chi nhánh của mình.");
  }
  assignStaff(userId, storeId, storeRole);
 }

 @Transactional
 public void assignStaff(int userId, int storeId, String storeRole) {
  String role = storeRole == null ? "STAFF" : storeRole.trim().toUpperCase(Locale.ROOT);
  if (!Set.of("MANAGER", "STAFF").contains(role)) {
   throw new AuthProblem("Vai trò chi nhánh chỉ có thể là MANAGER hoặc STAFF.");
  }

  Integer userOk = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Users WHERE UserId = ? AND Status = 'ACTIVE'", Integer.class, userId);
  if (userOk == null || userOk == 0) {
   throw new AuthProblem("Nhân viên không tồn tại hoặc đã bị khóa.");
  }

  Integer storeOk = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Stores WHERE StoreId = ? AND Status = 'ACTIVE'", Integer.class, storeId);
  if (storeOk == null || storeOk == 0) {
   throw new AuthProblem("Chi nhánh không tồn tại hoặc không ở trạng thái hoạt động.");
  }

  Integer active = jdbc.queryForObject(
   "SELECT COUNT(*) FROM dbo.StaffStoreAssignments WHERE UserId = ? AND StoreId = ? AND Status = 'ACTIVE'",
   Integer.class, userId, storeId
  );
  if (active != null && active > 0) {
   throw new AuthProblem("Nhân viên này đã được phân công tại chi nhánh được chọn.");
  }

  jdbc.update(
   "INSERT INTO dbo.StaffStoreAssignments(UserId, StoreId, StoreRole, StartAt, Status) VALUES(?,?,?,CURRENT_TIMESTAMP,'ACTIVE')",
   userId, storeId, role
  );
 }

 @Transactional
 public void endStaffAssignment(int assignmentId, Integer managerStoreId) {
  if (managerStoreId != null) {
   var sIdList = jdbc.queryForList("SELECT StoreId FROM dbo.StaffStoreAssignments WHERE AssignmentId = ?", Integer.class, assignmentId);
   if (sIdList.isEmpty() || sIdList.get(0).intValue() != managerStoreId.intValue()) {
    throw new AuthProblem("Bạn không có quyền kết thúc nhiệm kỳ nhân viên ở chi nhánh khác.");
   }
  }
  endStaffAssignment(assignmentId);
 }

 @Transactional
 public void endStaffAssignment(int assignmentId) {
  int rows = jdbc.update(
   "UPDATE dbo.StaffStoreAssignments SET Status = 'ENDED', EndAt = CURRENT_TIMESTAMP WHERE AssignmentId = ? AND Status = 'ACTIVE'",
   assignmentId
  );
  if (rows == 0) {
   throw new AuthProblem("Không tìm thấy phân công đang hoạt động cần kết thúc.");
  }
 }

 // ================= STOCK TRANSFERS =================

 public List<Map<String, Object>> listStockTransfers() {
  String sql = """
   SELECT t.TransferId, t.TransferCode, t.FromStoreId, fs.StoreName AS fromStoreName, fs.StoreCode AS fromStoreCode,
          t.ToStoreId, ts.StoreName AS toStoreName, ts.StoreCode AS toStoreCode, t.Status,
          t.RequestedBy, ru.FullName AS requesterName,
          t.ApprovedBy, au.FullName AS approverName,
          t.ShippedAt, t.ReceivedAt, t.CreatedAt,
          (SELECT COUNT(*) FROM dbo.StockTransferItems ti WHERE ti.TransferId = t.TransferId) AS itemCount,
          (SELECT COALESCE(SUM(bc.SalePrice), 0) FROM dbo.StockTransferItems ti JOIN dbo.BookCopies bc ON bc.CopyId = ti.CopyId WHERE ti.TransferId = t.TransferId) AS totalValue
   FROM dbo.StockTransfers t
   JOIN dbo.Stores fs ON fs.StoreId = t.FromStoreId
   JOIN dbo.Stores ts ON ts.StoreId = t.ToStoreId
   JOIN dbo.Users ru ON ru.UserId = t.RequestedBy
   LEFT JOIN dbo.Users au ON au.UserId = t.ApprovedBy
   ORDER BY t.TransferId DESC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   int id = rs.getInt("TransferId");
   String st = rs.getString("Status");
   BigDecimal totalValue = rs.getBigDecimal("totalValue");

   m.put("transferId", id);
   m.put("transferCode", rs.getString("TransferCode"));
   m.put("fromStoreId", rs.getInt("FromStoreId"));
   m.put("fromStoreName", rs.getString("fromStoreName"));
   m.put("fromStoreCode", rs.getString("fromStoreCode"));
   m.put("toStoreId", rs.getInt("ToStoreId"));
   m.put("toStoreName", rs.getString("toStoreName"));
   m.put("toStoreCode", rs.getString("toStoreCode"));
   m.put("status", st);
   m.put("statusLabel", transferStatusLabel(st));
   m.put("requesterName", rs.getString("requesterName"));
   m.put("approverName", rs.getString("approverName") == null ? "Chưa duyệt" : rs.getString("approverName"));
   m.put("itemCount", rs.getInt("itemCount"));
   m.put("totalValue", totalValue);
   m.put("totalValueLabel", CheckoutService.vnd(totalValue));
   m.put("createdAt", formatTime(rs.getTimestamp("CreatedAt")));
   m.put("shippedAt", formatTime(rs.getTimestamp("ShippedAt")));
   m.put("receivedAt", formatTime(rs.getTimestamp("ReceivedAt")));
   return (Map<String, Object>) m;
  });
 }

 public Map<String, Object> getTransferDetail(int transferId) {
  var transfers = listStockTransfers();
  var header = transfers.stream()
   .filter(t -> ((Number) t.get("transferId")).intValue() == transferId)
   .findFirst()
   .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Không tìm thấy phiếu điều chuyển ID=" + transferId));

  String itemSql = """
   SELECT ti.TransferItemId, ti.CopyId, bc.CopyCode, b.BookId, b.Title AS bookTitle,
          b.CoverImage AS cover,
          sc.ConditionName AS sentConditionName,
          rc.ConditionName AS receivedConditionName,
          ti.ReceiptStatus, ti.Note, bc.CostPrice, bc.SalePrice
   FROM dbo.StockTransferItems ti
   JOIN dbo.BookCopies bc ON bc.CopyId = ti.CopyId
   JOIN dbo.Books b ON b.BookId = bc.BookId
   JOIN dbo.BookConditions sc ON sc.ConditionId = ti.SentConditionId
   LEFT JOIN dbo.BookConditions rc ON rc.ConditionId = ti.ReceivedConditionId
   WHERE ti.TransferId = ?
   ORDER BY ti.TransferItemId ASC
   """;

  List<Map<String, Object>> items = jdbc.query(itemSql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("itemId", rs.getInt("TransferItemId"));
   m.put("copyId", rs.getInt("CopyId"));
   m.put("copyCode", rs.getString("CopyCode"));
   m.put("bookId", rs.getInt("BookId"));
   m.put("bookTitle", rs.getString("bookTitle"));
   m.put("cover", rs.getString("cover") == null ? "/images/book-placeholder.svg" : rs.getString("cover"));
   m.put("sentCondition", rs.getString("sentConditionName"));
   m.put("receivedCondition", rs.getString("receivedConditionName") == null ? "—" : rs.getString("receivedConditionName"));
   m.put("receiptStatus", rs.getString("ReceiptStatus"));
   m.put("note", rs.getString("Note") == null ? "" : rs.getString("Note"));
   m.put("costPriceLabel", CheckoutService.vnd(rs.getBigDecimal("CostPrice")));
   m.put("salePriceLabel", CheckoutService.vnd(rs.getBigDecimal("SalePrice")));
   return (Map<String, Object>) m;
  }, transferId);

  var detail = new LinkedHashMap<>(header);
  detail.put("items", items);
  return detail;
 }

 public List<Map<String, Object>> getAvailableCopiesForStore(int storeId) {
  String sql = """
   SELECT bc.CopyId, bc.CopyCode, b.BookId, b.Title AS bookTitle,
          cond.ConditionId, cond.ConditionName, bc.SalePrice, bc.CostPrice, bc.ShelfLocation
   FROM dbo.BookCopies bc
   JOIN dbo.Books b ON b.BookId = bc.BookId
   JOIN dbo.BookConditions cond ON cond.ConditionId = bc.ConditionId
   WHERE bc.StoreId = ? AND bc.Status = 'AVAILABLE'
   ORDER BY b.Title ASC, bc.CopyCode ASC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("copyId", rs.getInt("CopyId"));
   m.put("copyCode", rs.getString("CopyCode"));
   m.put("bookId", rs.getInt("BookId"));
   m.put("bookTitle", rs.getString("bookTitle"));
   m.put("conditionId", rs.getInt("ConditionId"));
   m.put("conditionName", rs.getString("ConditionName"));
   m.put("shelfLocation", rs.getString("ShelfLocation") == null ? "Chưa xếp kệ" : rs.getString("ShelfLocation"));
   m.put("salePriceLabel", CheckoutService.vnd(rs.getBigDecimal("SalePrice")));
   m.put("costPriceLabel", CheckoutService.vnd(rs.getBigDecimal("CostPrice")));
   return (Map<String, Object>) m;
  }, storeId);
 }

 @Transactional
 public int createStockTransfer(int fromStoreId, int toStoreId, List<Integer> copyIds, int requestedByUserId, String note) {
  if (fromStoreId == toStoreId) {
   throw new AuthProblem("Chi nhánh gửi và chi nhánh nhận phải khác nhau.");
  }
  if (copyIds == null || copyIds.isEmpty()) {
   throw new AuthProblem("Vui lòng chọn ít nhất 1 cuốn sách để tạo phiếu điều chuyển.");
  }

  // Validate stores
  Integer fromExists = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Stores WHERE StoreId = ?", Integer.class, fromStoreId);
  Integer toExists = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Stores WHERE StoreId = ?", Integer.class, toStoreId);
  if (fromExists == null || fromExists == 0 || toExists == null || toExists == 0) {
   throw new AuthProblem("Chi nhánh gửi hoặc chi nhánh nhận không tồn tại.");
  }

  // Validate copies
  for (Integer copyId : copyIds) {
   var rows = jdbc.queryForList("SELECT StoreId, Status, ConditionId FROM dbo.BookCopies WHERE CopyId = ?", copyId);
   if (rows.isEmpty()) {
    throw new AuthProblem("Không tìm thấy bản sách ID=" + copyId);
   }
   var row = rows.get(0);
   int currentStore = ((Number) row.get("StoreId")).intValue();
   String currentStatus = (String) row.get("Status");
   if (currentStore != fromStoreId) {
    throw new AuthProblem("Bản sách ID=" + copyId + " không thuộc chi nhánh gửi đã chọn.");
   }
   if (!"AVAILABLE".equalsIgnoreCase(currentStatus)) {
    throw new AuthProblem("Bản sách ID=" + copyId + " đang không ở trạng thái sẵn sàng (AVAILABLE).");
   }
  }

  // Generate transfer code
  String transferCode = "TRF-" + System.currentTimeMillis() % 10000000 + "-" + (ThreadLocalRandom.current().nextInt(900) + 100);

  var keyHolder = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement(
    "INSERT INTO dbo.StockTransfers(TransferCode, FromStoreId, ToStoreId, Status, RequestedBy, CreatedAt, UpdatedAt) VALUES(?,?,?,'DRAFT',?,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)",
    Statement.RETURN_GENERATED_KEYS
   );
   ps.setString(1, transferCode);
   ps.setInt(2, fromStoreId);
   ps.setInt(3, toStoreId);
   ps.setInt(4, requestedByUserId);
   return ps;
  }, keyHolder);

  int transferId = extractGeneratedId(keyHolder, "TransferId");

  for (Integer copyId : copyIds) {
   Integer conditionId = jdbc.queryForObject("SELECT ConditionId FROM dbo.BookCopies WHERE CopyId = ?", Integer.class, copyId);
   jdbc.update(
    "INSERT INTO dbo.StockTransferItems(TransferId, CopyId, SentConditionId, ReceiptStatus, Note) VALUES(?,?,?,'PENDING',?)",
    transferId, copyId, conditionId, note
   );
  }

  notifications.create(
   requestedByUserId,
   "TRANSFER",
   "Đã tạo phiếu điều chuyển sách nội bộ",
   "Phiếu điều chuyển " + transferCode + " (" + copyIds.size() + " cuốn) đã được tạo và đang ở trạng thái DRAFT.",
   "/admin/stores#transfers-section"
  );

  return transferId;
 }

 @Transactional
 public void approveStockTransfer(int transferId, int approvedByUserId) {
  Integer adminCount = jdbc.queryForObject(
   "SELECT COUNT(*) FROM dbo.UserRoles ur JOIN dbo.Roles r ON r.RoleId = ur.RoleId WHERE ur.UserId = ? AND r.RoleCode = 'ADMIN'",
   Integer.class, approvedByUserId
  );
  if (adminCount == null || adminCount == 0) {
   throw new AuthProblem("Chỉ Quản trị viên hệ thống (Admin) mới có quyền phê duyệt phiếu điều chuyển kho.");
  }

  var row = getTransferHeader(transferId);
  String status = (String) row.get("Status");
  if (!"DRAFT".equalsIgnoreCase(status)) {
   throw new AuthProblem("Chỉ có thể duyệt phiếu đang ở trạng thái DRAFT.");
  }

  jdbc.update(
   "UPDATE dbo.StockTransfers SET Status = 'APPROVED', ApprovedBy = ?, UpdatedAt = CURRENT_TIMESTAMP WHERE TransferId = ?",
   approvedByUserId, transferId
  );

  int requestedBy = ((Number) row.get("RequestedBy")).intValue();
  notifications.create(
   requestedBy,
   "TRANSFER",
   "Phiếu điều chuyển đã được phê duyệt",
   "Phiếu " + row.get("TransferCode") + " đã được quản trị viên duyệt. Vui lòng xuất kho vận chuyển.",
   "/admin/stores#transfers-section"
  );
 }

  public void shipStockTransfer(int transferId) {
  shipStockTransfer(transferId, null);
 }

 @Transactional
 public void shipStockTransfer(int transferId, Integer actorUserId) {
  var row = getTransferHeader(transferId);
  String status = (String) row.get("Status");
  if (!"APPROVED".equalsIgnoreCase(status)) {
   throw new AuthProblem("Chỉ có thể xuất kho phiếu đã được Quản trị viên (Admin) phê duyệt (APPROVED).");
  }

  int fromStoreId = ((Number) row.get("FromStoreId")).intValue();
  if (actorUserId != null) {
   var ctx = getUserStoreContext(actorUserId);
   if (!ctx.isAdmin() && (ctx.storeId() == null || ctx.storeId() != fromStoreId)) {
    throw new AuthProblem("Chỉ nhân sự tại chi nhánh gửi (hoặc Quản trị viên) mới có quyền thực hiện xuất kho phiếu này.");
   }
  }

  // Update transfer status
  jdbc.update(
   "UPDATE dbo.StockTransfers SET Status = 'IN_TRANSIT', ShippedAt = CURRENT_TIMESTAMP, UpdatedAt = CURRENT_TIMESTAMP WHERE TransferId = ?",
   transferId
  );

  // Lock copies to IN_TRANSIT
  jdbc.update("""
   UPDATE dbo.BookCopies
   SET Status = 'IN_TRANSIT', UpdatedAt = CURRENT_TIMESTAMP
   WHERE CopyId IN (SELECT CopyId FROM dbo.StockTransferItems WHERE TransferId = ?)
   """, transferId);
 }

  public void receiveStockTransfer(int transferId) {
  receiveStockTransfer(transferId, null);
 }

 @Transactional
 public void receiveStockTransfer(int transferId, Integer actorUserId) {
  var row = getTransferHeader(transferId);
  String status = (String) row.get("Status");
  if (!"IN_TRANSIT".equalsIgnoreCase(status)) {
   throw new AuthProblem("Chỉ có thể xác nhận nhận hàng với phiếu đang vận chuyển (IN_TRANSIT).");
  }

  int toStoreId = ((Number) row.get("ToStoreId")).intValue();
  if (actorUserId != null) {
   var ctx = getUserStoreContext(actorUserId);
   if (!ctx.isAdmin() && (ctx.storeId() == null || ctx.storeId() != toStoreId)) {
    throw new AuthProblem("Chỉ nhân sự tại chi nhánh nhận (hoặc Quản trị viên) mới có quyền xác nhận nhập kho phiếu này.");
   }
  }

  // Move copies to destination store and mark AVAILABLE
  jdbc.update("""
   UPDATE dbo.BookCopies
   SET StoreId = ?, Status = 'AVAILABLE', UpdatedAt = CURRENT_TIMESTAMP
   WHERE CopyId IN (SELECT CopyId FROM dbo.StockTransferItems WHERE TransferId = ?)
   """, toStoreId, transferId);

  // Mark all items as RECEIVED
  jdbc.update("""
   UPDATE dbo.StockTransferItems
   SET ReceiptStatus = 'RECEIVED', ReceivedConditionId = SentConditionId
   WHERE TransferId = ?
   """, transferId);

  // Update transfer header
  jdbc.update(
   "UPDATE dbo.StockTransfers SET Status = 'RECEIVED', ReceivedAt = CURRENT_TIMESTAMP, UpdatedAt = CURRENT_TIMESTAMP WHERE TransferId = ?",
   transferId
  );

  int requestedBy = ((Number) row.get("RequestedBy")).intValue();
  notifications.create(
   requestedBy,
   "TRANSFER",
   "Hoàn tất điều chuyển sách",
   "Phiếu " + row.get("TransferCode") + " đã được chi nhánh đích nhận hàng thành công và nhập kho sẵn sàng bán.",
   "/admin/stores#transfers-section"
  );
 }

  public void cancelStockTransfer(int transferId) {
  cancelStockTransfer(transferId, null);
 }

 @Transactional
 public void cancelStockTransfer(int transferId, Integer actorUserId) {
  var row = getTransferHeader(transferId);
  String status = (String) row.get("Status");
  if ("RECEIVED".equalsIgnoreCase(status) || "CANCELLED".equalsIgnoreCase(status)) {
   throw new AuthProblem("Phiếu điều chuyển đã hoàn tất hoặc đã bị hủy trước đó.");
  }

  int fromStoreId = ((Number) row.get("FromStoreId")).intValue();
  int requestedBy = ((Number) row.get("RequestedBy")).intValue();

  if (actorUserId != null) {
   var ctx = getUserStoreContext(actorUserId);
   if (!ctx.isAdmin()) {
    if (!"DRAFT".equalsIgnoreCase(status)) {
     throw new AuthProblem("Chỉ Quản trị viên (Admin) mới có quyền hủy phiếu điều chuyển đã được phê duyệt hoặc đang vận chuyển.");
    }
    boolean isRequester = (actorUserId.intValue() == requestedBy);
    boolean isFromStoreManager = ctx.isManager() && ctx.storeId() != null && ctx.storeId().intValue() == fromStoreId;
    if (!isRequester && !isFromStoreManager) {
     throw new AuthProblem("Bạn không có quyền hủy phiếu điều chuyển này.");
    }
   }
  }

  if ("IN_TRANSIT".equalsIgnoreCase(status)) {
   // Restore copies to AVAILABLE at fromStore
   jdbc.update("""
    UPDATE dbo.BookCopies
    SET Status = 'AVAILABLE', UpdatedAt = CURRENT_TIMESTAMP
    WHERE CopyId IN (SELECT CopyId FROM dbo.StockTransferItems WHERE TransferId = ?)
    """, transferId);
  }

  jdbc.update(
   "UPDATE dbo.StockTransfers SET Status = 'CANCELLED', UpdatedAt = CURRENT_TIMESTAMP WHERE TransferId = ?",
   transferId
  );
 }

 private Map<String, Object> getTransferHeader(int transferId) {
  var rows = jdbc.queryForList("SELECT TransferId, TransferCode, FromStoreId, ToStoreId, Status, RequestedBy FROM dbo.StockTransfers WHERE TransferId = ?", transferId);
  if (rows.isEmpty()) {
   throw new ResponseStatusException(NOT_FOUND, "Không tìm thấy phiếu điều chuyển ID=" + transferId);
  }
  return rows.get(0);
 }

 // ================= STOREFRONT HELPER =================

 public List<Map<String, Object>> storeAvailability(int bookId) {
  String sql = """
   SELECT s.StoreId AS storeId, s.StoreCode AS storeCode, s.StoreName AS storeName, s.Address AS address, s.Phone AS phone,
          COUNT(bc.CopyId) AS availableCopies,
          MIN(bc.SalePrice) AS minPrice
   FROM dbo.BookCopies bc
   JOIN dbo.Stores s ON s.StoreId = bc.StoreId
   WHERE bc.BookId = ? AND bc.Status = 'AVAILABLE' AND s.Status = 'ACTIVE'
   GROUP BY s.StoreId, s.StoreCode, s.StoreName, s.Address, s.Phone
   ORDER BY s.StoreName ASC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("storeId", rs.getInt("storeId"));
   m.put("storeCode", rs.getString("storeCode"));
   m.put("storeName", rs.getString("storeName"));
   m.put("address", rs.getString("address"));
   m.put("phone", rs.getString("phone") == null ? "Hotline" : rs.getString("phone"));
   m.put("availableCopies", rs.getInt("availableCopies"));
   m.put("minPriceLabel", CheckoutService.vnd(rs.getBigDecimal("minPrice")));
   return (Map<String, Object>) m;
  }, bookId);
 }

  // ================= STORE BRANCH WORKSPACE (FOR STAFF & MANAGER) =================

 public List<Map<String, Object>> listStockTransfersForStore(int storeId) {
  return listStockTransfers().stream()
   .filter(t -> ((Number) t.get("fromStoreId")).intValue() == storeId || ((Number) t.get("toStoreId")).intValue() == storeId)
   .toList();
 }

 public List<Map<String, Object>> listCopiesForStore(int storeId, String q) {
  String search = q == null ? "" : q.strip().toLowerCase(Locale.ROOT);
  String sql = """
   SELECT bc.CopyId, bc.CopyCode, b.BookId, b.Title AS bookTitle, b.CoverImage AS cover,
          cond.ConditionId, cond.ConditionName, bc.CostPrice, bc.SalePrice,
          bc.ShelfLocation, bc.Status, bc.UpdatedAt
   FROM dbo.BookCopies bc
   JOIN dbo.Books b ON b.BookId = bc.BookId
   JOIN dbo.BookConditions cond ON cond.ConditionId = bc.ConditionId
   WHERE bc.StoreId = ?
   ORDER BY bc.CopyId DESC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("copyId", rs.getInt("CopyId"));
   m.put("copyCode", rs.getString("CopyCode"));
   m.put("bookId", rs.getInt("BookId"));
   m.put("bookTitle", rs.getString("bookTitle"));
   m.put("cover", rs.getString("cover") == null ? "/images/book-placeholder.svg" : rs.getString("cover"));
   m.put("conditionId", rs.getInt("ConditionId"));
   m.put("conditionName", rs.getString("ConditionName"));
   BigDecimal cost = rs.getBigDecimal("CostPrice");
   BigDecimal sale = rs.getBigDecimal("SalePrice");
   m.put("costPrice", cost);
   m.put("costPriceLabel", CheckoutService.vnd(cost));
   m.put("salePrice", sale);
   m.put("salePriceLabel", CheckoutService.vnd(sale));
   m.put("shelfLocation", rs.getString("ShelfLocation") == null ? "Chưa xếp kệ" : rs.getString("ShelfLocation"));
   m.put("status", rs.getString("Status"));
   m.put("updatedAt", formatTime(rs.getTimestamp("UpdatedAt")));
   return (Map<String, Object>) m;
  }, storeId).stream()
   .filter(c -> search.isEmpty()
    || ((String) c.get("bookTitle")).toLowerCase(Locale.ROOT).contains(search)
    || ((String) c.get("copyCode")).toLowerCase(Locale.ROOT).contains(search)
    || ((String) c.get("shelfLocation")).toLowerCase(Locale.ROOT).contains(search))
   .toList();
 }

 public List<Map<String, Object>> listOrdersForStore(int storeId, String statusFilter) {
  String st = statusFilter == null || statusFilter.isBlank() ? "ALL" : statusFilter.toUpperCase(Locale.ROOT);
  String sql = """
   SELECT o.OrderId, o.OrderCode, o.StoreId, s.StoreName, o.CustomerId, u.FullName AS customerName,
          o.RecipientName, o.RecipientPhone, o.ShippingAddressSnapshot AS shippingAddress,
          o.TotalAmount, o.Status, o.CreatedAt,
          (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.OrderId) AS itemCount
   FROM dbo.Orders o
   LEFT JOIN dbo.Stores s ON s.StoreId = o.StoreId
   LEFT JOIN dbo.Users u ON u.UserId = o.CustomerId
   WHERE o.StoreId = ?
     AND (? = 'ALL' OR o.Status = ?)
   ORDER BY o.OrderId DESC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("orderId", rs.getInt("OrderId"));
   m.put("orderCode", rs.getString("OrderCode"));
   m.put("storeId", rs.getInt("StoreId"));
   m.put("storeName", rs.getString("StoreName"));
   m.put("customerId", rs.getObject("CustomerId"));
   m.put("customerName", rs.getString("customerName") == null ? "Khách vãng lai" : rs.getString("customerName"));
   m.put("recipientName", rs.getString("RecipientName"));
   m.put("recipientPhone", rs.getString("RecipientPhone"));
   m.put("shippingAddress", rs.getString("shippingAddress"));
   BigDecimal total = rs.getBigDecimal("TotalAmount");
   m.put("totalAmount", total);
   m.put("totalAmountLabel", CheckoutService.vnd(total));
   String ordStatus = rs.getString("Status");
   m.put("status", ordStatus);
   m.put("itemCount", rs.getInt("itemCount"));
   m.put("createdAt", formatTime(rs.getTimestamp("CreatedAt")));
   return (Map<String, Object>) m;
  }, storeId, st, st);
 }

 public List<Map<String, Object>> getBooksAvailableAtStore(int storeId) {
  String sql = """
   SELECT b.BookId AS id, b.Title AS title, b.CoverImage AS cover, b.CategoryId AS categoryId,
          c.CategoryName AS categoryName, pub.PublisherName AS publisher, b.PublishYear AS publishYear,
          COALESCE(a.names, N'Nhiều tác giả') AS authors,
          p.price, p.available
   FROM dbo.Books b
   JOIN dbo.Categories c ON c.CategoryId = b.CategoryId
   LEFT JOIN dbo.Publishers pub ON pub.PublisherId = b.PublisherId
   JOIN (
     SELECT BookId, MIN(SalePrice) AS price, COUNT(*) AS available
     FROM dbo.BookCopies
     WHERE Status = 'AVAILABLE' AND StoreId = ?
     GROUP BY BookId
   ) p ON p.BookId = b.BookId
   LEFT JOIN (
     SELECT ba.BookId, STRING_AGG(auth.AuthorName, N', ') AS names
     FROM dbo.BookAuthors ba
     JOIN dbo.Authors auth ON auth.AuthorId = ba.AuthorId
     GROUP BY ba.BookId
   ) a ON a.BookId = b.BookId
   ORDER BY b.Title ASC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("id", rs.getInt("id"));
   m.put("title", rs.getString("title"));
   String cover = rs.getString("cover");
   m.put("cover", cover == null || cover.isBlank() ? "/images/book-placeholder.svg" : cover);
   m.put("categoryId", rs.getInt("categoryId"));
   m.put("categoryName", rs.getString("categoryName"));
   m.put("publisher", rs.getString("publisher"));
   m.put("publishYear", rs.getObject("publishYear"));
   m.put("authors", rs.getString("authors"));
   BigDecimal price = rs.getBigDecimal("price");
   m.put("price", price);
   m.put("priceLabel", price == null ? "Tạm hết hàng" : CheckoutService.vnd(price));
   m.put("available", rs.getInt("available"));
   return (Map<String, Object>) m;
  }, storeId);
 }

 // ================= ADMIN USER MANAGEMENT =================

 public List<Map<String, Object>> listAllUsers(String search, String roleFilter, String statusFilter) {
  String q = search == null ? "" : search.strip().toLowerCase(Locale.ROOT);
  String sql = """
   SELECT u.UserId, u.Username, u.FullName, u.Email, u.Phone, u.Status, u.CreatedAt,
          (SELECT STRING_AGG(r.RoleCode, ', ') FROM dbo.UserRoles ur JOIN dbo.Roles r ON r.RoleId = ur.RoleId WHERE ur.UserId = u.UserId) AS roles,
          sa.StoreId, s.StoreCode, s.StoreName, sa.StoreRole
   FROM dbo.Users u
   LEFT JOIN dbo.StaffStoreAssignments sa ON sa.UserId = u.UserId AND sa.Status = 'ACTIVE'
   LEFT JOIN dbo.Stores s ON s.StoreId = sa.StoreId
   ORDER BY u.UserId DESC
   """;

  return jdbc.query(sql, (rs, i) -> {
   var m = new LinkedHashMap<String, Object>();
   m.put("userId", rs.getInt("UserId"));
   m.put("username", rs.getString("Username"));
   m.put("fullName", rs.getString("FullName"));
   m.put("email", rs.getString("Email"));
   m.put("phone", rs.getString("Phone") == null ? "—" : rs.getString("Phone"));
   m.put("status", rs.getString("Status"));
   m.put("roles", rs.getString("roles") == null ? "CUSTOMER" : rs.getString("roles"));
   m.put("storeId", rs.getObject("StoreId"));
   m.put("storeCode", rs.getString("StoreCode"));
   m.put("storeName", rs.getString("StoreName") == null ? "Chưa phân công" : rs.getString("StoreName"));
   m.put("storeRole", rs.getString("StoreRole") == null ? "—" : rs.getString("StoreRole"));
   m.put("createdAt", formatTime(rs.getTimestamp("CreatedAt")));
   return (Map<String, Object>) m;
  }).stream()
   .filter(u -> q.isEmpty()
    || ((String) u.get("username")).toLowerCase(Locale.ROOT).contains(q)
    || ((String) u.get("fullName")).toLowerCase(Locale.ROOT).contains(q)
    || ((String) u.get("email")).toLowerCase(Locale.ROOT).contains(q)
    || ((String) u.get("phone")).contains(q))
   .filter(u -> roleFilter == null || roleFilter.isBlank() || "ALL".equalsIgnoreCase(roleFilter)
    || ((String) u.get("roles")).toUpperCase(Locale.ROOT).contains(roleFilter.toUpperCase(Locale.ROOT)))
   .filter(u -> statusFilter == null || statusFilter.isBlank() || "ALL".equalsIgnoreCase(statusFilter)
    || ((String) u.get("status")).equalsIgnoreCase(statusFilter))
   .toList();
 }

 @Transactional
 public int createStaffUser(String fullName, String username, String email, String password, String phone, String roleCode, Integer storeId, int adminUserId) {
  Integer isAdmin = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.UserRoles ur JOIN dbo.Roles r ON r.RoleId=ur.RoleId WHERE ur.UserId=? AND r.RoleCode='ADMIN'", Integer.class, adminUserId);
  if (isAdmin == null || isAdmin == 0) {
   throw new AuthProblem("Chỉ Quản trị viên hệ thống (Admin) mới có quyền tạo nhân sự mới.");
  }

  String uName = username == null ? "" : username.strip().toLowerCase(Locale.ROOT);
  String mail = email == null ? "" : email.strip().toLowerCase(Locale.ROOT);
  String fName = fullName == null ? "" : fullName.strip();
  String rawPass = password == null ? "" : password.strip();

  if (uName.length() < 3) throw new AuthProblem("Tên đăng nhập phải có ít nhất 3 ký tự.");
  if (mail.length() < 5 || !mail.contains("@")) throw new AuthProblem("Email không hợp lệ.");
  if (fName.length() < 2) throw new AuthProblem("Họ và tên không hợp lệ.");
  if (rawPass.length() < 6) throw new AuthProblem("Mật khẩu khởi tạo phải có ít nhất 6 ký tự.");

  Integer uExists = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Users WHERE LOWER(Username) = ?", Integer.class, uName);
  if (uExists != null && uExists > 0) throw new AuthProblem("Tên đăng nhập '" + uName + "' đã được sử dụng.");

  Integer mailExists = jdbc.queryForObject("SELECT COUNT(*) FROM dbo.Users WHERE LOWER(Email) = ?", Integer.class, mail);
  if (mailExists != null && mailExists > 0) throw new AuthProblem("Email '" + mail + "' đã được sử dụng.");

  String hash = passwordEncoder.encode(rawPass);

  var keyHolder = new GeneratedKeyHolder();
  jdbc.update(con -> {
   PreparedStatement ps = con.prepareStatement(
    "INSERT INTO dbo.Users(Username, Email, PasswordHash, FullName, Phone, Status, CreatedAt, UpdatedAt, AuthVersion) VALUES(?,?,?,?,?,'ACTIVE',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,0)",
    Statement.RETURN_GENERATED_KEYS
   );
   ps.setString(1, uName);
   ps.setString(2, mail);
   ps.setString(3, hash);
   ps.setString(4, fName);
   ps.setString(5, phone == null || phone.isBlank() ? null : phone.strip());
   return ps;
  }, keyHolder);

  int newUserId = extractGeneratedId(keyHolder, "UserId");

  String rCode = roleCode == null ? "STAFF" : roleCode.trim().toUpperCase(Locale.ROOT);
  Integer roleId = jdbc.queryForObject("SELECT RoleId FROM dbo.Roles WHERE RoleCode = ?", Integer.class, "MANAGER".equals(rCode) ? "STAFF" : rCode);
  if (roleId != null) {
   jdbc.update("INSERT INTO dbo.UserRoles(UserId, RoleId) VALUES(?, ?)", newUserId, roleId);
  }

  if (storeId != null && storeId > 0) {
   String storeRole = "MANAGER".equals(rCode) ? "MANAGER" : "STAFF";
   jdbc.update(
    "INSERT INTO dbo.StaffStoreAssignments(UserId, StoreId, StoreRole, StartAt, Status) VALUES(?,?,?,CURRENT_TIMESTAMP,'ACTIVE')",
    newUserId, storeId, storeRole
   );
  }

  return newUserId;
 }

 @Transactional
 public void toggleUserStatus(int targetUserId, int adminUserId) {
  if (targetUserId == adminUserId) {
   throw new AuthProblem("Bạn không thể tự khóa tài khoản của chính mình.");
  }
  var status = jdbc.queryForObject("SELECT Status FROM dbo.Users WHERE UserId = ?", String.class, targetUserId);
  String newStatus = "ACTIVE".equalsIgnoreCase(status) ? "LOCKED" : "ACTIVE";
  jdbc.update(
   "UPDATE dbo.Users SET Status = ?, AuthVersion = AuthVersion + 1, UpdatedAt = CURRENT_TIMESTAMP WHERE UserId = ?",
   newStatus, targetUserId
  );
 }

 @Transactional
 public void changeUserRole(int targetUserId, String newRole, int adminUserId) {
  if (targetUserId == adminUserId) {
   throw new AuthProblem("Bạn không thể tự thay đổi vai trò của chính mình.");
  }
  String r = newRole == null ? "STAFF" : newRole.trim().toUpperCase(Locale.ROOT);
  Integer roleId = jdbc.queryForObject("SELECT RoleId FROM dbo.Roles WHERE RoleCode = ?", Integer.class, "MANAGER".equals(r) ? "STAFF" : r);
  if (roleId == null) {
   throw new AuthProblem("Vai trò không hợp lệ.");
  }

  jdbc.update("DELETE FROM dbo.UserRoles WHERE UserId = ?", targetUserId);
  jdbc.update("INSERT INTO dbo.UserRoles(UserId, RoleId) VALUES(?, ?)", targetUserId, roleId);

  if ("CUSTOMER".equals(r)) {
   jdbc.update("UPDATE dbo.StaffStoreAssignments SET Status = 'ENDED', EndAt = CURRENT_TIMESTAMP WHERE UserId = ? AND Status = 'ACTIVE'", targetUserId);
  } else if ("MANAGER".equals(r)) {
   jdbc.update("UPDATE dbo.StaffStoreAssignments SET StoreRole = 'MANAGER' WHERE UserId = ? AND Status = 'ACTIVE'", targetUserId);
  }

  jdbc.update("UPDATE dbo.Users SET AuthVersion = AuthVersion + 1, UpdatedAt = CURRENT_TIMESTAMP WHERE UserId = ?", targetUserId);
 }

 @Transactional
 public void adminResetPassword(int targetUserId, String newPassword, int adminUserId) {
  if (newPassword == null || newPassword.strip().length() < 6) {
   throw new AuthProblem("Mật khẩu mới phải có ít nhất 6 ký tự.");
  }
  String hash = passwordEncoder.encode(newPassword.strip());
  jdbc.update(
   "UPDATE dbo.Users SET PasswordHash = ?, AuthVersion = AuthVersion + 1, UpdatedAt = CURRENT_TIMESTAMP WHERE UserId = ?",
   hash, targetUserId
  );
 }

 static String storeStatusLabel(String status) {
  if (status == null) return "Không xác định";
  return switch (status.toUpperCase(Locale.ROOT)) {
   case "ACTIVE" -> "Đang hoạt động";
   case "TEMPORARILY_CLOSED" -> "Tạm nghỉ sửa chữa";
   case "CLOSED" -> "Đã đóng cửa";
   default -> status;
  };
 }

 static String transferStatusLabel(String status) {
  if (status == null) return "Không xác định";
  return switch (status.toUpperCase(Locale.ROOT)) {
   case "DRAFT" -> "Chờ duyệt (DRAFT)";
   case "APPROVED" -> "Đã duyệt (APPROVED)";
   case "IN_TRANSIT" -> "Đang vận chuyển (IN_TRANSIT)";
   case "RECEIVED" -> "Đã nhận hàng (RECEIVED)";
   case "CANCELLED" -> "Đã hủy (CANCELLED)";
   default -> status;
  };
 }
}
