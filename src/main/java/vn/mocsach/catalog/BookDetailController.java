package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.dao.DataIntegrityViolationException;
import vn.mocsach.auth.*;
import java.security.Principal;
import java.time.Duration;

@Controller
public class BookDetailController {
 private final BookDetailService service;
 private final UserRepository users;
 private final RequestLimiter limiter;
 private final CartService cart;
 private final NotificationService notifications;
 private final AdminService admin;
 private final StoreService storeService;

 public BookDetailController(
  BookDetailService service,
  UserRepository users,
  RequestLimiter limiter,
  CartService cart,
  NotificationService notifications,
  AdminService admin,
  StoreService storeService
 ) {
  this.service = service;
  this.users = users;
  this.limiter = limiter;
  this.cart = cart;
  this.notifications = notifications;
  this.admin = admin;
  this.storeService = storeService;
 }

 @GetMapping("/books/{id}")
 public String page(@PathVariable int id, Principal principal, Model model) {
  model.addAttribute("book", service.detail(id));
  model.addAttribute("reviews", service.reviews(id));
  model.addAttribute("histogram", service.histogram(id));
  model.addAttribute("storeAvailability", storeService.storeAvailability(id));

  if (principal != null) {
   var u = users.findByUsernameIgnoreCaseOrEmailIgnoreCase(principal.getName(), principal.getName()).orElseThrow();
   boolean staffOrAdmin = admin.isStaffOrAdmin(u.id);
   model.addAttribute("displayName", u.fullName);
   model.addAttribute("ownReview", service.ownReview(id, u.id));
   model.addAttribute("cartCount", cart.count(u.id));
   model.addAttribute("inCartCount", cart.bookCountInCart(u.id, id));
   model.addAttribute("notifications", notifications.list(u.id, 12));
   model.addAttribute("unreadCount", notifications.unreadCount(u.id));
   model.addAttribute("isStaffOrAdmin", staffOrAdmin);
   if (staffOrAdmin) {
    model.addAttribute("staffCopies", admin.bookCopiesForStaff(id));
    model.addAttribute("stores", admin.activeStores());
    model.addAttribute("conditions", admin.conditions());
   }
  }
  return "book-detail";
 }

 @PostMapping("/books/{id}/reviews")
 public String review(@PathVariable int id, @RequestParam(defaultValue = "0") int rating, @RequestParam(defaultValue = "") String comment, Principal principal, RedirectAttributes flash) {
  var u = users.findByUsernameIgnoreCaseOrEmailIgnoreCase(principal.getName(), principal.getName()).orElseThrow();
  try {
   limiter.check("review:" + u.id, 10, Duration.ofHours(1));
   service.review(id, u.id, rating, comment);
   notifications.create(u.id, "REVIEW", "Đã đăng đánh giá sách", "Đánh giá " + rating + " sao của bạn cho mã sách MS-" + id + " đã được hiển thị công khai.", "/books/" + id + "#reviews");
   flash.addFlashAttribute("success", "Đã lưu đánh giá và bình luận của bạn.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  } catch (DataIntegrityViolationException ex) {
   flash.addFlashAttribute("error", "Đánh giá vừa được cập nhật. Hãy tải lại trang và thử lại.");
  }
  return "redirect:/books/" + id + "#reviews";
 }
}
