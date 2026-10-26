package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.mocsach.auth.UserAccount;
import vn.mocsach.auth.UserRepository;

import java.security.Principal;

@Controller
public class StoreController {
 private final StoreService storeService;
 private final CartService cart;
 private final NotificationService notifications;
 private final AdminService admin;
 private final UserRepository users;

 public StoreController(
  StoreService storeService,
  CartService cart,
  NotificationService notifications,
  AdminService admin,
  UserRepository users
 ) {
  this.storeService = storeService;
  this.cart = cart;
  this.notifications = notifications;
  this.admin = admin;
  this.users = users;
 }

 @GetMapping("/stores")
 public String listStores(
  @RequestParam(defaultValue = "0") int storeId,
  Principal principal,
  Model model
 ) {
  var activeStores = storeService.listStoresWithStats().stream()
   .filter(s -> "ACTIVE".equalsIgnoreCase((String) s.get("status")))
   .toList();

  model.addAttribute("stores", activeStores);
  model.addAttribute("selectedStoreId", storeId);

  if (storeId > 0) {
   var selectedStore = activeStores.stream()
    .filter(s -> ((Number) s.get("storeId")).intValue() == storeId)
    .findFirst()
    .orElse(null);
   if (selectedStore != null) {
    model.addAttribute("selectedStore", selectedStore);
    model.addAttribute("storeBooks", storeService.getBooksAvailableAtStore(storeId));
   }
  }

  if (principal != null) {
   var u = users.findByUsernameIgnoreCaseOrEmailIgnoreCase(principal.getName(), principal.getName()).orElse(null);
   if (u != null) {
    model.addAttribute("displayName", u.fullName);
    model.addAttribute("hasAvatar", u.avatarPath != null);
    model.addAttribute("cartCount", cart.count(u.id));
    model.addAttribute("notifications", notifications.list(u.id, 12));
    model.addAttribute("unreadCount", notifications.unreadCount(u.id));
    model.addAttribute("isStaffOrAdmin", admin.isStaffOrAdmin(u.id));
   }
  }

  return "stores";
 }
}
