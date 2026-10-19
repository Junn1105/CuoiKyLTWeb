package vn.mocsach.catalog;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;
import java.security.Principal;

@Controller
public class NotificationController {
 private final NotificationService notifications;
 private final CartService cart;
 private final UserRepository users;
 public NotificationController(NotificationService notifications,CartService cart,UserRepository users){
  this.notifications=notifications;this.cart=cart;this.users=users;
 }

 private UserAccount user(Principal p){
  return users.findByUsernameIgnoreCaseOrEmailIgnoreCase(p.getName(),p.getName()).orElseThrow(()->new AuthProblem("Tài khoản không khả dụng."));
 }

 @GetMapping("/notifications")
 public String page(@RequestParam(defaultValue="all") String filter,Principal principal,Model model){
  var u=user(principal);
  var all=notifications.list(u.id,50);
  var filtered="unread".equalsIgnoreCase(filter)?all.stream().filter(n->Boolean.TRUE.equals(n.get("unread"))).toList():all;
  model.addAttribute("displayName",u.fullName);
  model.addAttribute("hasAvatar",u.avatarPath!=null);
  model.addAttribute("cartCount",cart.count(u.id));
  model.addAttribute("notifications",all);
  model.addAttribute("pageNotifications",filtered);
  model.addAttribute("unreadCount",notifications.unreadCount(u.id));
  model.addAttribute("filter","unread".equalsIgnoreCase(filter)?"unread":"all");
  return "notifications";
 }

 @PostMapping("/notifications/{id}/open")
 public String open(@PathVariable long id,Principal principal){
  var u=user(principal);
  String target=notifications.openAndMarkRead(u.id,id);
  return "redirect:"+target;
 }

 @PostMapping("/notifications/read-all")
 public String readAll(@RequestParam(defaultValue="") String redirect,HttpServletRequest req,Principal principal,RedirectAttributes flash){
  var u=user(principal);
  notifications.markAllRead(u.id);
  flash.addFlashAttribute("success","Đã đánh dấu tất cả thông báo là đã đọc.");
  String target=CartController.safeTarget(redirect,req,1);
  if(redirect!=null&&redirect.startsWith("/notifications"))target="/notifications";
  else if(target.equals("/books/1")&&(redirect==null||!redirect.equals("/books/1")))target="/notifications";
  return "redirect:"+target;
 }
}
