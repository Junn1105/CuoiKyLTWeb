package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class StoreAdminController {
 private final StoreService storeService;
 private final UserRepository users;
 private final CartService cart;
 private final NotificationService notifications;
 private final AdminService adminService;

 public StoreAdminController(
  StoreService storeService,
  UserRepository users,
  CartService cart,
  NotificationService notifications, AdminService adminService
 ) {
  this.storeService = storeService;
  this.users = users;
  this.cart = cart;
  this.notifications = notifications;
  this.adminService = adminService;
 }

 private UserAccount user(Principal p) {
  return users.findByUsernameIgnoreCaseOrEmailIgnoreCase(p.getName(), p.getName())
   .orElseThrow(() -> new AuthProblem("Tài khoản không khả dụng."));
 }

 private void populateHeader(UserAccount u, Model model) {
  model.addAttribute("displayName", u.fullName);
  model.addAttribute("hasAvatar", u.avatarPath != null);
  model.addAttribute("isStaffOrAdmin", true);
  model.addAttribute("cartCount", cart.count(u.id));
  model.addAttribute("notifications", notifications.list(u.id, 12));
  model.addAttribute("unreadCount", notifications.unreadCount(u.id));
 }

 // ================= STAFF & MANAGER MY-STORE WORKSPACE =================
 @GetMapping("/my-store")
 public String myStore(
  @RequestParam(defaultValue = "0") int storeId,
  @RequestParam(defaultValue = "") String q,
  @RequestParam(defaultValue = "ALL") String orderStatus,
  Principal principal,
  Model model,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  populateHeader(u, model);
  var ctx = storeService.getUserStoreContext(u.id);
  model.addAttribute("userContext", ctx);

  int targetStoreId = storeId > 0 ? storeId : (ctx.storeId() != null ? ctx.storeId() : 0);
  if (targetStoreId == 0) {
   if (ctx.isAdmin()) {
    var actives = storeService.activeStores();
    if (!actives.isEmpty()) {
     targetStoreId = (Integer) actives.get(0).get("id");
    }
   }
  }

  if (targetStoreId == 0) {
   flash.addFlashAttribute("error", "Bạn chưa được phân công quản lý chi nhánh nào. Vui lòng liên hệ Quản trị viên.");
   return "redirect:/admin";
  }

  if (!ctx.isAdmin() && (ctx.storeId() == null || ctx.storeId().intValue() != targetStoreId)) {
   flash.addFlashAttribute("error", "Bạn chỉ có quyền truy cập chi nhánh được phân công của mình.");
   return "redirect:/admin/my-store?storeId=" + ctx.storeId();
  }

  var store = storeService.getStore(targetStoreId);
  model.addAttribute("store", store);
  model.addAttribute("storeCopies", storeService.listCopiesForStore(targetStoreId, q));
  model.addAttribute("storeOrders", storeService.listOrdersForStore(targetStoreId, orderStatus));
  model.addAttribute("storeTransfers", storeService.listStockTransfersForStore(targetStoreId));
  model.addAttribute("activeStores", storeService.activeStores());
  model.addAttribute("categories", adminService.categories());
  model.addAttribute("conditions", adminService.conditions());
  model.addAttribute("allBooks", adminService.listBooksForAdmin("", 0));
  model.addAttribute("q", q);
  model.addAttribute("orderStatus", orderStatus);

  return "my-store";
 }

 // ================= MULTI-STORE CHAIN ADMINISTRATION =================
 @GetMapping({"/stores", "/stores/"})
 public String index(
  @RequestParam(defaultValue = "") String tab,
  @RequestParam(defaultValue = "0") int transferId,
  @RequestParam(defaultValue = "0") int fromStore,
  @RequestParam(defaultValue = "") String userSearch,
  @RequestParam(defaultValue = "ALL") String roleFilter,
  @RequestParam(defaultValue = "ALL") String userStatusFilter,
  Principal principal,
  Model model
 ) {
  var u = user(principal);
  populateHeader(u, model);
  var ctx = storeService.getUserStoreContext(u.id);
  model.addAttribute("userContext", ctx);

  // Tab routing based on role
  String activeTab = tab;
  if (activeTab.isEmpty()) {
   activeTab = ctx.isAdmin() ? "stores" : (ctx.isManager() ? "staff" : "transfers");
  }

  // Non-admins cannot see stores or users tabs
  if (!ctx.isAdmin()) {
   if ("stores".equals(activeTab) || "users".equals(activeTab)) {
    activeTab = ctx.isManager() ? "staff" : "transfers";
   }
  }
  // Staff cannot see staff tab
  if (!ctx.isAdmin() && !ctx.isManager() && "staff".equals(activeTab)) {
   activeTab = "transfers";
  }

  model.addAttribute("tab", activeTab);
  model.addAttribute("stores", storeService.listStoresWithStats());
  model.addAttribute("activeStores", storeService.activeStores());
  model.addAttribute("categories", adminService.categories());
  model.addAttribute("conditions", adminService.conditions());
  model.addAttribute("allBooks", adminService.listBooksForAdmin("", 0));

  // Staff assignments tab based on role
  if (ctx.isAdmin()) {
   model.addAttribute("staffAssignments", storeService.listStaffAssignments(null));
   model.addAttribute("eligibleUsers", storeService.getEligibleStaffUsers());
  } else if (ctx.isManager() && ctx.storeId() != null) {
   model.addAttribute("staffAssignments", storeService.listStaffAssignments(ctx.storeId()));
   model.addAttribute("eligibleUsers", storeService.getEligibleStaffUsers());
  } else {
   model.addAttribute("staffAssignments", List.of());
   model.addAttribute("eligibleUsers", List.of());
  }

  // Transfers tab based on role
  if (ctx.isAdmin()) {
   model.addAttribute("transfers", storeService.listStockTransfers());
  } else if (ctx.storeId() != null) {
   model.addAttribute("transfers", storeService.listStockTransfersForStore(ctx.storeId()));
  } else {
   model.addAttribute("transfers", List.of());
  }

  // User management tab (Admin only)
  if (ctx.isAdmin()) {
   model.addAttribute("allUsers", storeService.listAllUsers(userSearch, roleFilter, userStatusFilter));
   model.addAttribute("userSearch", userSearch);
   model.addAttribute("roleFilter", roleFilter);
   model.addAttribute("userStatusFilter", userStatusFilter);
  }

  if (transferId > 0) {
   try {
    model.addAttribute("selectedTransfer", storeService.getTransferDetail(transferId));
   } catch (Exception ignored) {}
  }

  if (fromStore > 0) {
   model.addAttribute("selectedFromStore", fromStore);
   model.addAttribute("availableCopies", storeService.getAvailableCopiesForStore(fromStore));
  }

  return "admin-stores";
 }

 @GetMapping("/stores/api/copies")
 @ResponseBody
 public List<Map<String, Object>> apiCopies(@RequestParam int storeId) {
  return storeService.getAvailableCopiesForStore(storeId);
 }

 @PostMapping("/stores/create")
 public String createStore(
  @RequestParam String storeCode,
  @RequestParam String storeName,
  @RequestParam String address,
  @RequestParam(defaultValue = "") String phone,
  @RequestParam(defaultValue = "ACTIVE") String status,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên hệ thống (Admin) mới có quyền mở thêm chi nhánh mới.");
   return "redirect:/admin/stores?tab=transfers";
  }
  try {
   int id = storeService.createStore(storeCode, storeName, address, phone, status);
   flash.addFlashAttribute("success", "Đã mở thêm chi nhánh mới: " + storeName + " (Mã: " + storeCode.toUpperCase() + ")");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=stores#stores-section";
 }

 @PostMapping("/stores/{id}/update")
 public String updateStore(
  @PathVariable int id,
  @RequestParam String storeName,
  @RequestParam String address,
  @RequestParam(defaultValue = "") String phone,
  @RequestParam String status,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên hệ thống (Admin) mới có quyền cập nhật thông tin chi nhánh.");
   return "redirect:/admin/stores?tab=transfers";
  }
  try {
   storeService.updateStore(id, storeName, address, phone, status);
   flash.addFlashAttribute("success", "Đã cập nhật thông tin chi nhánh thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=stores#stores-section";
 }

 @PostMapping("/stores/staff/assign")
 public String assignStaff(
  @RequestParam int userId,
  @RequestParam int storeId,
  @RequestParam String storeRole,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  try {
   Integer managerStoreId = ctx.isAdmin() ? null : ctx.storeId();
   storeService.assignStaff(userId, storeId, storeRole, managerStoreId);
   flash.addFlashAttribute("success", "Đã phân công nhân sự vào chi nhánh thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=staff#staff-section";
 }

 @PostMapping("/stores/staff/{id}/end")
 public String endStaffAssignment(
  @PathVariable int id,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  try {
   Integer managerStoreId = ctx.isAdmin() ? null : ctx.storeId();
   storeService.endStaffAssignment(id, managerStoreId);
   flash.addFlashAttribute("success", "Đã kết thúc phân công nhân viên tại chi nhánh.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=staff#staff-section";
 }

 @PostMapping("/stores/transfers/create")
 public String createTransfer(
  @RequestParam int fromStoreId,
  @RequestParam int toStoreId,
  @RequestParam(name = "copyIds", required = false) List<Integer> copyIds,
  @RequestParam(defaultValue = "") String note,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   int transferId = storeService.createStockTransfer(fromStoreId, toStoreId, copyIds, u.id, note);
   flash.addFlashAttribute("success", "Đã lập phiếu điều chuyển sách nội bộ thành công (ID=" + transferId + "). Trạng thái hiện tại: DRAFT (Chờ duyệt).");
   if ("my-store".equalsIgnoreCase(source)) {
    return "redirect:/admin/my-store#transfers-section";
   }
   return "redirect:/admin/stores?tab=transfers&transferId=" + transferId + "#transfers-section";
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
   if ("my-store".equalsIgnoreCase(source)) {
    return "redirect:/admin/my-store#transfers-section";
   }
   return "redirect:/admin/stores?tab=transfers&fromStore=" + fromStoreId + "#create-transfer-box";
  }
 }

 @PostMapping("/stores/transfers/{id}/approve")
 public String approveTransfer(
  @PathVariable int id,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên hệ thống (Admin) mới có quyền phê duyệt phiếu điều chuyển kho.");
   return "redirect:/admin/stores?tab=transfers&transferId=" + id + "#transfers-section";
  }
  try {
   storeService.approveStockTransfer(id, u.id);
   flash.addFlashAttribute("success", "Đã phê duyệt phiếu điều chuyển ID=" + id + ". Trạng thái: APPROVED.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=transfers&transferId=" + id + "#transfers-section";
 }

 @PostMapping("/stores/transfers/{id}/ship")
 public String shipTransfer(
  @PathVariable int id,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   storeService.shipStockTransfer(id, u.id);
   flash.addFlashAttribute("success", "Đã xuất kho điều chuyển. Sách đã chuyển sang trạng thái ĐANG VẬN CHUYỂN (IN_TRANSIT) và được khóa tại chi nhánh gửi.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store#transfers-section";
  }
  return "redirect:/admin/stores?tab=transfers&transferId=" + id + "#transfers-section";
 }

 @PostMapping("/stores/transfers/{id}/receive")
 public String receiveTransfer(
  @PathVariable int id,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   storeService.receiveStockTransfer(id, u.id);
   flash.addFlashAttribute("success", "Chi nhánh đích đã nhận hàng thành công! Tất cả sách đã được tự động chuyển sang chi nhánh mới và cập nhật trạng thái SẴN SÀNG (AVAILABLE).");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store#transfers-section";
  }
  return "redirect:/admin/stores?tab=transfers&transferId=" + id + "#transfers-section";
 }

 @PostMapping("/stores/transfers/{id}/cancel")
 public String cancelTransfer(
  @PathVariable int id,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   storeService.cancelStockTransfer(id, u.id);
   flash.addFlashAttribute("success", "Đã hủy phiếu điều chuyển. Sách đã được mở khóa về chi nhánh gửi ban đầu.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store#transfers-section";
  }
  return "redirect:/admin/stores?tab=transfers&transferId=" + id + "#transfers-section";
 }

 // ================= ADMIN USER & ROLE MANAGEMENT =================
 @PostMapping("/stores/users/create")
 public String createUser(
  @RequestParam String fullName,
  @RequestParam String username,
  @RequestParam String email,
  @RequestParam String password,
  @RequestParam(defaultValue = "") String phone,
  @RequestParam(defaultValue = "STAFF") String roleCode,
  @RequestParam(required = false) Integer storeId,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   storeService.createStaffUser(fullName, username, email, password, phone, roleCode, storeId, u.id);
   flash.addFlashAttribute("success", "Đã tạo tài khoản nhân sự mới: " + username + " (" + roleCode + ")");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=users#users-section";
 }

 @PostMapping("/stores/users/{id}/toggle-status")
 public String toggleUserStatus(@PathVariable int id, Principal principal, RedirectAttributes flash) {
  var u = user(principal);
  try {
   storeService.toggleUserStatus(id, u.id);
   flash.addFlashAttribute("success", "Đã cập nhật trạng thái tài khoản thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=users#users-section";
 }

 @PostMapping("/stores/users/{id}/role")
 public String changeUserRole(@PathVariable int id, @RequestParam String role, Principal principal, RedirectAttributes flash) {
  var u = user(principal);
  try {
   storeService.changeUserRole(id, role, u.id);
   flash.addFlashAttribute("success", "Đã cập nhật vai trò tài khoản thành: " + role);
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=users#users-section";
 }

 @PostMapping("/stores/users/{id}/reset-password")
 public String resetUserPassword(@PathVariable int id, @RequestParam String newPassword, Principal principal, RedirectAttributes flash) {
  var u = user(principal);
  try {
   storeService.adminResetPassword(id, newPassword, u.id);
   flash.addFlashAttribute("success", "Đã đặt lại mật khẩu mới cho tài khoản ID=" + id);
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/stores?tab=users#users-section";
 }
}
