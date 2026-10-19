package vn.mocsach.catalog;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.mocsach.auth.UserRepository;
import java.security.Principal;
import java.util.*;

@Controller
public class HomeController {
 private final CatalogService catalog;
 private final UserRepository users;
 private final CartService cart;
 private final NotificationService notifications;
 private final AdminService admin;
 public HomeController(CatalogService catalog,UserRepository users,CartService cart,NotificationService notifications,AdminService admin){this.catalog=catalog;this.users=users;this.cart=cart;this.notifications=notifications;this.admin=admin;}
 @GetMapping({"/", "/home"})
 public String home(@RequestParam(defaultValue="") String q,@RequestParam(defaultValue="0") int category,Model model,Principal principal){
  String search=q.strip().substring(0,Math.min(100,q.strip().length()));
  var books=catalog.books();
  var filtered=books.stream().filter(b->category==0||((Number)b.get("categoryId")).intValue()==category)
   .filter(b->(b.get("title")+" "+b.get("authors")).toLowerCase(Locale.ROOT).contains(search.toLowerCase(Locale.ROOT))).toList();
  model.addAttribute("books",filtered.stream().limit(24).toList());
  model.addAttribute("recommended",books.stream().limit(4).toList());
  model.addAttribute("bestsellers",books.stream().filter(b->((Number)b.get("sales")).intValue()>0)
   .sorted(Comparator.<Map<String,Object>>comparingInt(b->((Number)b.get("sales")).intValue()).reversed().thenComparing(b->b.get("title").toString())).limit(4).toList());
  model.addAttribute("categories",catalog.categories(books));model.addAttribute("bookCount",books.size());
  model.addAttribute("q",search);model.addAttribute("category",category);model.addAttribute("resultCount",filtered.size());
  model.addAttribute("searching",!search.isEmpty()||category!=0);
  if(principal!=null)users.findByUsernameIgnoreCaseOrEmailIgnoreCase(principal.getName(),principal.getName()).ifPresent(u->{
   model.addAttribute("displayName",u.fullName);model.addAttribute("hasAvatar",u.avatarPath!=null);
   model.addAttribute("cartCount",cart.count(u.id));
   model.addAttribute("notifications",notifications.list(u.id,12));
   model.addAttribute("unreadCount",notifications.unreadCount(u.id));
   model.addAttribute("isStaffOrAdmin",admin.isStaffOrAdmin(u.id));
  });
  return "home";
 }
}
