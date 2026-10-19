package vn.mocsach.catalog;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;

import java.security.Principal;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.Map;

@Controller
public class CheckoutController {
 private static final String SESSION_SHIPPING = "checkoutShipping";

 private final CheckoutService checkout;
 private final CartService cart;
 private final UserRepository users;
 private final NotificationService notifications;
 private final RequestLimiter limiter;

 public CheckoutController(CheckoutService checkout, CartService cart, UserRepository users, NotificationService notifications, RequestLimiter limiter) {
  this.checkout = checkout;
  this.cart = cart;
  this.users = users;
  this.notifications = notifications;
  this.limiter = limiter;
 }

 private UserAccount user(Principal p) {
  return users.findByUsernameIgnoreCaseOrEmailIgnoreCase(p.getName(), p.getName())
   .orElseThrow(() -> new AuthProblem("Tài khoản không khả dụng."));
 }

 private void populateHeader(UserAccount u, Model model) {
  model.addAttribute("displayName", u.fullName);
  model.addAttribute("hasAvatar", u.avatarPath != null);
  model.addAttribute("cartCount", cart.count(u.id));
  model.addAttribute("notifications", notifications.list(u.id, 12));
  model.addAttribute("unreadCount", notifications.unreadCount(u.id));
  model.addAttribute("isStaffOrAdmin", checkout.isStaffOrAdmin(u.id));
 }

 @SuppressWarnings("unchecked")
 private Map<String, String> resolveShipping(UserAccount u, HttpSession session) {
  Object raw = session.getAttribute(SESSION_SHIPPING);
  if (raw instanceof Map<?, ?> m && m.get("recipientName") != null) {
   var copy = new LinkedHashMap<String, String>();
   m.forEach((k, v) -> copy.put(String.valueOf(k), v == null ? "" : String.valueOf(v)));
   return copy;
  }
  return checkout.defaultShippingInfo(u.id);
 }

 @GetMapping("/checkout/shipping")
 public String shippingPage(Principal principal, HttpSession session, Model model, RedirectAttributes flash) {
  var u = user(principal);
  var summary = checkout.checkoutSummary(u.id);
  int available = ((Number) summary.get("availableCount")).intValue();
  int unavailable = ((Number) summary.get("unavailableCount")).intValue();
  if (available == 0 || unavailable > 0) {
   flash.addFlashAttribute("error", unavailable > 0
    ? "Vui lòng xóa bản sách đã hết hàng khỏi giỏ trước khi thanh toán."
    : "Giỏ hàng của bạn đang trống. Hãy chọn sách trước khi thanh toán.");
   return "redirect:/cart";
  }
  populateHeader(u, model);
  model.addAttribute("summary", summary);
  if (!model.containsAttribute("shipping")) {
   model.addAttribute("shipping", resolveShipping(u, session));
  }
  return "checkout-shipping";
 }

 @PostMapping("/checkout/shipping")
 public String submitShipping(
  @RequestParam String recipientName,
  @RequestParam String recipientPhone,
  @RequestParam String administrativeArea,
  @RequestParam String addressLine,
  @RequestParam(defaultValue = "") String note,
  Principal principal,
  HttpSession session,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  try {
   var saved = checkout.validateAndSaveShipping(u.id, recipientName, recipientPhone, administrativeArea, addressLine, note);
   session.setAttribute(SESSION_SHIPPING, saved);
   return "redirect:/checkout/payment";
  } catch (AuthProblem ex) {
   var draft = new LinkedHashMap<String, String>();
   draft.put("recipientName", recipientName);
   draft.put("recipientPhone", recipientPhone);
   draft.put("administrativeArea", administrativeArea);
   draft.put("addressLine", addressLine);
   draft.put("note", note);
   flash.addFlashAttribute("shipping", draft);
   flash.addFlashAttribute("error", ex.getMessage());
   return "redirect:/checkout/shipping";
  }
 }

 @GetMapping("/checkout/payment")
 public String paymentPage(Principal principal, HttpSession session, Model model, RedirectAttributes flash) {
  var u = user(principal);
  var summary = checkout.checkoutSummary(u.id);
  int available = ((Number) summary.get("availableCount")).intValue();
  int unavailable = ((Number) summary.get("unavailableCount")).intValue();
  if (available == 0 || unavailable > 0) {
   return "redirect:/cart";
  }
  var shipping = resolveShipping(u, session);
  if (shipping.getOrDefault("addressLine", "").isBlank() || shipping.getOrDefault("recipientPhone", "").isBlank()) {
   flash.addFlashAttribute("error", "Vui lòng nhập địa chỉ và số điện thoại giao hàng trước.");
   return "redirect:/checkout/shipping";
  }
  populateHeader(u, model);
  model.addAttribute("summary", summary);
  model.addAttribute("shipping", shipping);
  return "checkout-payment";
 }

 @PostMapping("/checkout/payment")
 public String submitPayment(
  @RequestParam(defaultValue = "CASH") String paymentMethod,
  Principal principal,
  HttpSession session,
  RedirectAttributes flash
 ) {
  var u = user(principal);
  var shipping = resolveShipping(u, session);
  try {
   limiter.check("checkout:" + u.id, 15, Duration.ofMinutes(10));
   int orderId = checkout.placeOrder(u.id, shipping, paymentMethod);
   var detail = checkout.orderDetail(u.id, orderId);
   String code = String.valueOf(detail.get("orderCode"));
   if ("BANK_TRANSFER".equalsIgnoreCase(paymentMethod)) {
    notifications.create(u.id, "ORDER", "Đơn hàng " + code + " đang chờ chuyển khoản",
     "Vui lòng quét mã VietQR Vietcombank và bấm xác nhận thanh toán cho đơn hàng " + code + ".",
     "/checkout/qr/" + orderId);
    return "redirect:/checkout/qr/" + orderId;
   }
   notifications.create(u.id, "ORDER", "Đặt hàng thành công (" + code + ")",
    "Đơn hàng " + code + " thanh toán tiền mặt (COD) sẽ được giao nhanh qua Shopee Express.",
    "/orders/" + orderId);
   flash.addFlashAttribute("success", "Đặt hàng thành công! Đơn hàng " + code + " đang được chuẩn bị để bàn giao cho Shopee Express.");
   return "redirect:/orders/" + orderId;
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
   return "redirect:/checkout/payment";
  }
 }

 @GetMapping("/checkout/qr/{id}")
 public String qrPage(@PathVariable int id, Principal principal, Model model) {
  var u = user(principal);
  var order = checkout.orderDetail(u.id, id);
  populateHeader(u, model);
  model.addAttribute("order", order);
  return "checkout-qr";
 }

 @PostMapping("/checkout/qr/{id}/confirm")
 public String confirmQr(@PathVariable int id, Principal principal, RedirectAttributes flash) {
  var u = user(principal);
  try {
   var order = checkout.confirmQrPayment(u.id, id);
   String code = String.valueOf(order.get("orderCode"));
   notifications.create(u.id, "ORDER", "Thanh toán thành công (" + code + ")",
    "Cảm ơn bạn! Mộc Sách đã ghi nhận thanh toán chuyển khoản cho đơn hàng " + code + ".",
    "/orders/" + id);
   flash.addFlashAttribute("success", "Xác nhận thanh toán chuyển khoản thành công! Bạn có thể xem chi tiết, in hóa đơn hoặc quản lý đơn hàng bên dưới.");
   return "redirect:/checkout/qr/" + id + "?confirmed=1";
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
   return "redirect:/checkout/qr/" + id;
  }
 }

 @GetMapping("/orders")
 public String ordersPage(Principal principal, Model model) {
  var u = user(principal);
  populateHeader(u, model);
  model.addAttribute("orders", checkout.listOrders(u.id));
  return "orders";
 }

 @GetMapping("/orders/{id}")
 public String orderDetailPage(@PathVariable int id, Principal principal, Model model) {
  var u = user(principal);
  var order = checkout.orderDetail(u.id, id);
  populateHeader(u, model);
  model.addAttribute("order", order);
  return "order-detail";
 }

 @GetMapping("/orders/{id}/invoice")
 public String invoicePage(@PathVariable int id, Principal principal, Model model) {
  var u = user(principal);
  var order = checkout.orderDetail(u.id, id);
  model.addAttribute("displayName", u.fullName);
  model.addAttribute("isStaffOrAdmin", checkout.isStaffOrAdmin(u.id));
  model.addAttribute("order", order);
  return "order-invoice";
 }

 @PostMapping("/orders/{id}/cancel")
 public String cancelOrder(@PathVariable int id, Principal principal, RedirectAttributes flash) {
  var u = user(principal);
  try {
   var order = checkout.cancelOrder(u.id, id);
   String code = String.valueOf(order.get("orderCode"));
   notifications.create(u.id, "ORDER", "Đã hủy đơn hàng " + code,
    "Đơn hàng " + code + " đã được hủy theo yêu cầu của bạn.",
    "/orders/" + id);
   flash.addFlashAttribute("success", "Đã hủy đơn hàng " + code + " thành công. Các bản sách đã được hoàn lại kệ.");
  } catch (AuthProblem ex) {
   flash.addFlashAttribute("error", ex.getMessage());
  }
  return "redirect:/orders/" + id;
 }
}
