package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class AdminController {
 private final AdminService admin;
 private final UserRepository users;
 private final CartService cart;
 private final NotificationService notifications;
 private final StoreService storeService;

 public AdminController(AdminService admin, UserRepository users, CartService cart, NotificationService notifications, StoreService storeService) {
  this.admin = admin;
  this.users = users;
  this.cart = cart;
  this.notifications = notifications;
  this.storeService = storeService;
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

 @GetMapping({"", "/"})
 public String dashboard(
  @RequestParam(defaultValue = "") String q,
  @RequestParam(defaultValue = "0") int category,
  @RequestParam(defaultValue = "ALL") String orderStatus,
  Principal principal,
  Model model
 ) {
  var u = user(principal);
  populateHeader(u, model);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   return "redirect:/admin/my-store";
  }
  model.addAttribute("stats", admin.dashboardStats());
  model.addAttribute("books", admin.listBooksForAdmin(q, category));
  model.addAttribute("orders", admin.listAllOrders(orderStatus));
  model.addAttribute("categories", admin.categories());
  model.addAttribute("stores", admin.activeStores());
  model.addAttribute("conditions", admin.conditions());
  model.addAttribute("q", q);
  model.addAttribute("category", category);
  model.addAttribute("orderStatus", orderStatus);
  return "admin-dashboard";
 }

 @GetMapping("/books/{id}/edit")
 @SuppressWarnings("unchecked")
 public String editBookPage(@PathVariable int id, Principal principal, Model model, RedirectAttributes flash) {
  var u = user(principal);
  populateHeader(u, model);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin() && !ctx.isManager()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên (Admin) hoặc Quản lý chi nhánh (Manager) mới có quyền chỉnh sửa sách.");
   return "redirect:/admin/my-store";
  }
  model.addAttribute("userContext", ctx);
  var book = admin.bookForEdit(id);
  var stores = admin.activeStores();
  if (!ctx.isAdmin() && ctx.storeId() != null) {
   int myStoreId = ctx.storeId();
   var allCopies = (List<Map<String, Object>>) book.get("copies");
   if (allCopies != null) {
    book.put("copies", allCopies.stream()
     .filter(cp -> ((Number) cp.get("storeId")).intValue() == myStoreId)
     .toList());
   }
   stores = stores.stream()
    .filter(st -> ((Number) st.get("id")).intValue() == myStoreId)
    .toList();
  }
  model.addAttribute("book", book);
  model.addAttribute("categories", admin.categories());
  model.addAttribute("stores", stores);
  model.addAttribute("conditions", admin.conditions());
  return "admin-book-edit";
 }

 @PostMapping("/books/create")
 public String createBook(
  @RequestParam String title,
  @RequestParam int categoryId,
  @RequestParam(defaultValue = "Nhiều tác giả") String authorName,
  @RequestParam(defaultValue = "NXB Văn Học") String publisherName,
  @RequestParam(required = false) Integer publishYear,
  @RequestParam(defaultValue = "") String translator,
  @RequestParam(defaultValue = "") String isbn,
  @RequestParam(defaultValue = "") String coverImage,
  @RequestParam(defaultValue = "") String description,
  @RequestParam int storeId,
  @RequestParam int conditionId,
  @RequestParam BigDecimal costPrice,
  @RequestParam BigDecimal salePrice,
  @RequestParam(defaultValue = "1") int copyQuantity,
  @RequestParam(defaultValue = "Kệ A1") String shelfLocation,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin() && !ctx.isManager()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên (Admin) hoặc Quản lý chi nhánh (Manager) mới có quyền thêm sách mới.");
   return "redirect:/admin/my-store";
  }
  int effectiveStoreId = ctx.isAdmin() ? storeId : (ctx.storeId() != null ? ctx.storeId() : storeId);
  try {
   int bookId = admin.createBook(title, categoryId, authorName, publisherName, publishYear, translator, isbn, coverImage, description, effectiveStoreId, conditionId, costPrice, salePrice, copyQuantity, shelfLocation);
   flash.addFlashAttribute("success", "Đã thêm đầu sách mới (MS-" + bookId + ") kèm " + copyQuantity + " bản sách vật lý vào kho chi nhánh.");
   if ("my-store".equalsIgnoreCase(source) || !ctx.isAdmin()) {
    return "redirect:/admin/my-store?storeId=" + effectiveStoreId + "#inventory-section";
   }
   return "redirect:/admin/books/" + bookId + "/edit";
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
   return ("my-store".equalsIgnoreCase(source) || !ctx.isAdmin()) ? "redirect:/admin/my-store#inventory-section" : "redirect:/admin#books-section";
  }
 }

 @PostMapping("/books/{id}/update")
 public String updateBook(
  @PathVariable int id,
  @RequestParam String title,
  @RequestParam int categoryId,
  @RequestParam(defaultValue = "Nhiều tác giả") String authorName,
  @RequestParam(defaultValue = "NXB Văn Học") String publisherName,
  @RequestParam(required = false) Integer publishYear,
  @RequestParam(defaultValue = "") String translator,
  @RequestParam(defaultValue = "") String isbn,
  @RequestParam(defaultValue = "") String coverImage,
  @RequestParam(defaultValue = "") String description,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin() && !ctx.isManager()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên (Admin) hoặc Quản lý chi nhánh (Manager) mới có quyền sửa thông tin sách.");
   return "redirect:/admin/my-store";
  }
  try {
   admin.updateBook(id, title, categoryId, authorName, publisherName, publishYear, translator, isbn, coverImage, description);
   flash.addFlashAttribute("success", "Đã cập nhật thông tin đầu sách MS-" + id + " thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/books/" + id + "/edit";
 }

 @PostMapping("/books/{id}/delete")
 public String deleteBook(
  @PathVariable int id,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin() && !ctx.isManager()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên (Admin) hoặc Quản lý chi nhánh (Manager) mới có quyền xóa sách.");
   return "redirect:/admin/my-store";
  }
  if (ctx.isAdmin()) {
   admin.deleteBook(id);
   flash.addFlashAttribute("success", "Đã xóa đầu sách MS-" + id + " khỏi hệ thống.");
   return "my-store".equalsIgnoreCase(source) ? "redirect:/admin/my-store#inventory-section" : "redirect:/admin#books-section";
  } else {
   if (ctx.storeId() == null) {
    flash.addFlashAttribute("error", "Bạn chưa được phân công chi nhánh để thực hiện xóa sách.");
    return "redirect:/admin/my-store";
   }
   admin.deleteBookFromStore(id, ctx.storeId());
   flash.addFlashAttribute("success", "Đã xóa sách MS-" + id + " khỏi kho chi nhánh " + (ctx.storeName() != null ? ctx.storeName() : "") + " thành công.");
   return "redirect:/admin/my-store?storeId=" + ctx.storeId() + "#inventory-section";
  }
 }

 @PostMapping("/books/copies/add-to-store")
 public String addCopyToStore(
  @RequestParam int bookId,
  @RequestParam int storeId,
  @RequestParam int conditionId,
  @RequestParam BigDecimal costPrice,
  @RequestParam BigDecimal salePrice,
  @RequestParam(defaultValue = "") String conditionNotes,
  @RequestParam(defaultValue = "Kệ A1") String shelfLocation,
  Principal principal,
  RedirectAttributes flash
 ) {
  return addCopy(bookId, storeId, conditionId, costPrice, salePrice, conditionNotes, shelfLocation, "my-store", principal, flash);
 }

 @PostMapping("/books/{id}/copies/add")
 public String addCopy(
  @PathVariable int id,
  @RequestParam int storeId,
  @RequestParam int conditionId,
  @RequestParam BigDecimal costPrice,
  @RequestParam BigDecimal salePrice,
  @RequestParam(defaultValue = "") String conditionNotes,
  @RequestParam(defaultValue = "Kệ A1") String shelfLocation,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin() && !ctx.isManager()) {
   flash.addFlashAttribute("error", "Chỉ Quản trị viên (Admin) hoặc Quản lý chi nhánh (Manager) mới có quyền thêm bản sách vào chi nhánh.");
   return "redirect:/admin/my-store#inventory-section";
  }
  int effectiveStoreId = ctx.isAdmin() ? storeId : (ctx.storeId() != null ? ctx.storeId() : storeId);
  try {
   admin.addCopy(id, effectiveStoreId, conditionId, costPrice, salePrice, conditionNotes, shelfLocation);
   flash.addFlashAttribute("success", "Đã thêm bản sách vật lý mới (MS-" + id + ") vào kho chi nhánh.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store?storeId=" + effectiveStoreId + "#inventory-section";
  }
  return "detail".equalsIgnoreCase(source) ? "redirect:/books/" + id + "#staff-inventory" : "redirect:/admin/books/" + id + "/edit#copies-section";
 }

 @PostMapping("/books/{bookId}/copies/{copyId}/update")
 public String updateCopy(
  @PathVariable int bookId,
  @PathVariable int copyId,
  @RequestParam int storeId,
  @RequestParam int conditionId,
  @RequestParam BigDecimal costPrice,
  @RequestParam BigDecimal salePrice,
  @RequestParam(defaultValue = "AVAILABLE") String status,
  @RequestParam(defaultValue = "") String conditionNotes,
  @RequestParam(required = false) String shelfLocation,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  int effectiveStoreId = storeId;
  if (!ctx.isAdmin()) {
   if (!ctx.isManager()) {
    flash.addFlashAttribute("error", "Chỉ Quản lý chi nhánh (Manager) hoặc Admin mới có quyền chỉnh sửa bản sách.");
    return "redirect:/admin/my-store#inventory-section";
   }
   Integer copyStoreId = admin.getCopyStoreId(copyId);
   if (copyStoreId == null || ctx.storeId() == null || copyStoreId.intValue() != ctx.storeId().intValue()) {
    flash.addFlashAttribute("error", "Bạn chỉ có quyền chỉnh sửa sách thuộc chi nhánh mình đang quản lý.");
    return "redirect:/admin/my-store#inventory-section";
   }
   effectiveStoreId = ctx.storeId();
  }
  try {
   admin.updateCopy(copyId, effectiveStoreId, conditionId, costPrice, salePrice, status, conditionNotes, shelfLocation);
   flash.addFlashAttribute("success", "Đã cập nhật thông tin bản sách #" + copyId + " thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store?storeId=" + effectiveStoreId + "#inventory-section";
  }
  return "detail".equalsIgnoreCase(source) ? "redirect:/books/" + bookId + "#staff-inventory" : "redirect:/admin/books/" + bookId + "/edit#copies-section";
 }

 @PostMapping("/books/{bookId}/copies/{copyId}/delete")
 public String deleteCopy(
  @PathVariable int bookId,
  @PathVariable int copyId,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   if (!ctx.isManager()) {
    flash.addFlashAttribute("error", "Chỉ Quản lý chi nhánh (Manager) hoặc Admin mới có quyền xóa bản sách.");
    return "redirect:/admin/my-store#inventory-section";
   }
   Integer copyStoreId = admin.getCopyStoreId(copyId);
   if (copyStoreId == null || ctx.storeId() == null || copyStoreId.intValue() != ctx.storeId().intValue()) {
    flash.addFlashAttribute("error", "Bạn chỉ có quyền xóa sách thuộc chi nhánh mình đang quản lý.");
    return "redirect:/admin/my-store#inventory-section";
   }
  }
  admin.deleteCopy(copyId);
  flash.addFlashAttribute("success", "Đã xóa bản sách vật lý khỏi kho chi nhánh.");
  if ("my-store".equalsIgnoreCase(source)) {
   return "redirect:/admin/my-store" + (ctx.storeId() != null ? "?storeId=" + ctx.storeId() : "") + "#inventory-section";
  }
  return "detail".equalsIgnoreCase(source) ? "redirect:/books/" + bookId + "#staff-inventory" : "redirect:/admin/books/" + idOrBook(bookId) + "/edit#copies-section";
 }

 private static int idOrBook(int bookId) {
  return bookId;
 }

 @PostMapping("/orders/{id}/status")
 public String updateOrderStatus(
  @PathVariable int id,
  @RequestParam String status,
  @RequestParam(defaultValue = "") String source,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var ctx = storeService.getUserStoreContext(u.id);
  if (!ctx.isAdmin()) {
   Integer orderStoreId = admin.getOrderStoreId(id);
   if (orderStoreId != null && (ctx.storeId() == null || ctx.storeId().intValue() != orderStoreId.intValue())) {
    flash.addFlashAttribute("error", "Bạn chỉ được phép duyệt đơn hàng phát sinh tại chi nhánh của mình.");
    return "my-store".equalsIgnoreCase(source) ? "redirect:/admin/my-store#orders-section" : "redirect:/admin#orders-section";
   }
  }
  try {
   admin.updateOrderStatus(u.id, id, status);
   flash.addFlashAttribute("success", "Đã cập nhật trạng thái đơn hàng thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "my-store".equalsIgnoreCase(source) ? "redirect:/admin/my-store#orders-section" : "redirect:/admin#orders-section";
 }
}
