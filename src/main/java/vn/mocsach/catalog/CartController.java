package vn.mocsach.catalog;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.mocsach.auth.*;
import java.net.URI;
import java.security.Principal;
import java.time.Duration;

@Controller
public class CartController {
 private final CartService cart;
 private final UserRepository users;
 private final RequestLimiter limiter;
 private final NotificationService notifications;
 public CartController(CartService cart,UserRepository users,RequestLimiter limiter,NotificationService notifications){this.cart=cart;this.users=users;this.limiter=limiter;this.notifications=notifications;}

 private UserAccount user(Principal p){
  return users.findByUsernameIgnoreCaseOrEmailIgnoreCase(p.getName(),p.getName()).orElseThrow(()->new AuthProblem("Tài khoản không khả dụng."));
 }

 @GetMapping("/cart")
 public String page(Principal principal,Model model){
  var u=user(principal);
  var detail=cart.detail(u.id);
  model.addAttribute("displayName",u.fullName);
  model.addAttribute("hasAvatar",u.avatarPath!=null);
  model.addAttribute("cart",detail);
  model.addAttribute("cartCount",detail.get("totalCount"));
  model.addAttribute("notifications",notifications.list(u.id,12));
  model.addAttribute("unreadCount",notifications.unreadCount(u.id));
  return "cart";
 }

 @PostMapping("/cart/add")
 public String add(@RequestParam int bookId,@RequestParam(defaultValue="1") int quantity,@RequestParam(defaultValue="cart") String action,@RequestParam(defaultValue="") String redirect,HttpServletRequest req,Principal principal,RedirectAttributes flash){
  var u=user(principal);
  String target=safeTarget(redirect,req,bookId);
  try{
   limiter.check("cart:"+u.id,30,Duration.ofMinutes(10));
   if("buy".equalsIgnoreCase(action)){
    int current=cart.bookCountInCart(u.id,bookId);
    int needed=Math.max(0,quantity-current);
    if(needed>0){
     int added=cart.add(u.id,bookId,needed);
     notifications.create(u.id,"CART","Đã thêm sách vào giỏ hàng","Bạn vừa chọn mua "+added+" cuốn (mã sách MS-"+bookId+").","/checkout/shipping");
    }else if(current==0){
     int added=cart.add(u.id,bookId,1);
     notifications.create(u.id,"CART","Đã thêm sách vào giỏ hàng","Bạn vừa chọn mua "+added+" cuốn (mã sách MS-"+bookId+").","/checkout/shipping");
    }
    return "redirect:/checkout/shipping";
   }
   int added=cart.add(u.id,bookId,quantity);
   notifications.create(u.id,"CART","Đã thêm sách vào giỏ hàng","Bạn vừa thêm "+added+" cuốn (mã sách MS-"+bookId+") vào giỏ hàng của mình.","/cart");
   String msg="Đã thêm "+added+" cuốn vào giỏ hàng.";
   flash.addFlashAttribute("cartSuccess",msg);
   flash.addFlashAttribute("success",msg);
  }catch(AuthProblem ex){
   flash.addFlashAttribute("cartError",ex.getMessage());
   flash.addFlashAttribute("error",ex.getMessage());
  }catch(DataIntegrityViolationException ex){
   String msg="Bản sách vừa được cập nhật trong giỏ hàng. Vui lòng thử lại.";
   flash.addFlashAttribute("cartError",msg);
   flash.addFlashAttribute("error",msg);
  }
  return "redirect:"+target;
 }

 @PostMapping("/cart/items/{id}/remove")
 public String remove(@PathVariable int id,Principal principal,RedirectAttributes flash){
  var u=user(principal);
  try{
   limiter.check("cart:"+u.id,30,Duration.ofMinutes(10));
   cart.removeItem(u.id,id);
   flash.addFlashAttribute("success","Đã xóa sách khỏi giỏ hàng.");
  }catch(AuthProblem ex){
   flash.addFlashAttribute("error",ex.getMessage());
  }
  return "redirect:/cart";
 }

 @PostMapping("/cart/clear")
 public String clear(Principal principal,RedirectAttributes flash){
  var u=user(principal);
  try{
   limiter.check("cart:"+u.id,20,Duration.ofMinutes(10));
   cart.clear(u.id);
   flash.addFlashAttribute("success","Đã làm trống giỏ hàng.");
  }catch(AuthProblem ex){
   flash.addFlashAttribute("error",ex.getMessage());
  }
  return "redirect:/cart";
 }

 static String safeTarget(String redirect,HttpServletRequest req,int bookId){
  String candidate=redirect==null?"":redirect.strip();
  if(isAllowedLocalPath(candidate))return candidate;
  String referer=req.getHeader("Referer");
  if(referer!=null&&!referer.isBlank()){
   try{
    URI uri=URI.create(referer);
    String path=uri.getRawPath()==null?"":uri.getRawPath();
    String ctx=req.getContextPath()==null?"":req.getContextPath();
    if(!ctx.isEmpty()&&path.startsWith(ctx))path=path.substring(ctx.length());
    String full=path+(uri.getRawQuery()==null?"":"?"+uri.getRawQuery());
    if(isAllowedLocalPath(full))return full;
   }catch(IllegalArgumentException ignored){}
  }
  return "/books/"+bookId;
 }

 private static boolean isAllowedLocalPath(String path){
  return !path.isEmpty()&&path.startsWith("/")&&!path.startsWith("//")
   &&(path.equals("/")||path.startsWith("/home")||path.startsWith("/books/")||path.startsWith("/cart"));
 }
}
