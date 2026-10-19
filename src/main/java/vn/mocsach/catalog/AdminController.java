package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;

import java.math.BigDecimal;
import java.security.Principal;

@Controller
@RequestMapping("/admin")
public class AdminController {
 private final AdminService admin;
 private final UserRepository users;
 private final CartService cart;
 private final NotificationService notifications;

 public AdminController(AdminService admin, UserRepository users, CartService cart, NotificationService notifications) {
  this.admin = admin;
  this.users = users;
  this.cart = cart;
  this.notifications = notifications;
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
 public String editBookPage(@PathVariable int id, Principal principal, Model model) {
  var u = user(principal);
  populateHeader(u, model);
  model.addAttribute("book", admin.bookForEdit(id));
  model.addAttribute("categories", admin.categories());
  model.addAttribute("stores", admin.activeStores());
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
  RedirectAttributes flash
 ) {
  try {
   int bookId = admin.createBook(title, categoryId, authorName, publisherName, publishYear, translator, isbn, coverImage, description, storeId, conditionId, costPrice, salePrice, copyQuantity);
   flash.addFlashAttribute("success", "Đã thêm đầu sách mới (MS-" + bookId + ") kèm " + copyQuantity + " bản sách vật lý vào kho.");
   return "redirect:/admin/books/" + bookId + "/edit";
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
   return "redirect:/admin#books-section";
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
  RedirectAttributes flash
 ) {
  try {
   admin.updateBook(id, title, categoryId, authorName, publisherName, publishYear, translator, isbn, coverImage, description);
   flash.addFlashAttribute("success", "Đã cập nhật thông tin đầu sách MS-" + id + " thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin/books/" + id + "/edit";
 }

 @PostMapping("/books/{id}/delete")
 public String deleteBook(@PathVariable int id, RedirectAttributes flash) {
  admin.deleteBook(id);
  flash.addFlashAttribute("success", "Đã xóa đầu sách MS-" + id + " khỏi hệ thống.");
  return "redirect:/admin#books-section";
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
  RedirectAttributes flash
 ) {
  try {
   admin.addCopy(id, storeId, conditionId, costPrice, salePrice, conditionNotes, shelfLocation);
   flash.addFlashAttribute("success", "Đã thêm bản sách vật lý mới vào kho.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
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
  @RequestParam(defaultValue = "") String source,
  RedirectAttributes flash
 ) {
  try {
   admin.updateCopy(copyId, storeId, conditionId, costPrice, salePrice, status, conditionNotes);
   flash.addFlashAttribute("success", "Đã cập nhật tình trạng, giá nhập (CostPrice) và giá bán (SalePrice) của bản sách.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "detail".equalsIgnoreCase(source) ? "redirect:/books/" + bookId + "#staff-inventory" : "redirect:/admin/books/" + bookId + "/edit#copies-section";
 }

 @PostMapping("/books/{bookId}/copies/{copyId}/delete")
 public String deleteCopy(
  @PathVariable int bookId,
  @PathVariable int copyId,
  @RequestParam(defaultValue = "") String source,
  RedirectAttributes flash
 ) {
  admin.deleteCopy(copyId);
  flash.addFlashAttribute("success", "Đã xóa bản sách vật lý khỏi kho.");
  return "detail".equalsIgnoreCase(source) ? "redirect:/books/" + bookId + "#staff-inventory" : "redirect:/admin/books/" + bookId + "/edit#copies-section";
 }

 @PostMapping("/orders/{id}/status")
 public String updateOrderStatus(
  @PathVariable int id,
  @RequestParam String status,
  Principal principal,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   admin.updateOrderStatus(u.id, id, status);
   flash.addFlashAttribute("success", "Đã cập nhật trạng thái đơn hàng thành công.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/admin#orders-section";
 }
}
