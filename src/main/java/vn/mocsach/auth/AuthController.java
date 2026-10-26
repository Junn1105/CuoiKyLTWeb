package vn.mocsach.auth;
import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.*;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.mocsach.catalog.StoreService;
import java.security.Principal;
import java.time.*;
@Controller
public class AuthController {
 private final AuthService service;private final JwtTokens tokens;private final RequestLimiter limiter;private final UserRepository users;private final StoreService storeService;private final boolean secure;
 public AuthController(AuthService service,JwtTokens tokens,RequestLimiter limiter,UserRepository users,StoreService storeService,@Value("${app.auth.secure-cookie:false}") boolean secure){this.service=service;this.tokens=tokens;this.limiter=limiter;this.users=users;this.storeService=storeService;this.secure=secure;}
 private String page(String mode,Model m){m.addAttribute("mode",mode);return "auth";}
 private void cookie(HttpServletRequest req,HttpServletResponse res,String value,int seconds){res.addHeader(HttpHeaders.SET_COOKIE,ResponseCookie.from("mocsach_auth",value).httpOnly(true).secure(secure).sameSite("Lax").path(req.getContextPath().isBlank()?"/":req.getContextPath()).maxAge(seconds).build().toString());}
 private void limit(HttpServletRequest r,String action,int count){limiter.check(action+":"+r.getRemoteAddr(),count,Duration.ofMinutes(10));}
 
 @GetMapping("/login") public String login(Model m,Principal p){return p==null?page("login",m):"redirect:/home";}
 @GetMapping("/register") public String register(Model m){return page("register",m);}
 @GetMapping("/forgot-password") public String forgot(Model m){return page("forgot",m);}
 @PostMapping("/auth/login") public String loginPost(@RequestParam(defaultValue="") String identifier,@RequestParam(defaultValue="") String password,HttpServletRequest r,HttpServletResponse response,Model m){
  try {limit(r,"login",20);limiter.check("login-user:"+identifier.strip().toLowerCase(),12,Duration.ofMinutes(10));var user=service.login(identifier,password);r.getSession();r.changeSessionId();cookie(r,response,tokens.issue(user),7200);var ctx=storeService.getUserStoreContext(user.id);if(ctx.isAdmin()){return "redirect:/admin";}if(ctx.isStaff()||ctx.isManager()){return ctx.storeId()!=null?"redirect:/admin/my-store":"redirect:/admin";}return "redirect:/home";}
  catch(AuthProblem e){m.addAttribute("error",e.getMessage());m.addAttribute("identifier",identifier);return page("login",m);}
 }
 @PostMapping("/register") public String registerPost(@RequestParam(defaultValue="") String fullName,@RequestParam(defaultValue="") String username,@RequestParam(defaultValue="") String email,@RequestParam(defaultValue="") String password,@RequestParam(defaultValue="") String confirmPassword,HttpServletRequest r,Model m){
  try {limit(r,"otp",10);String id=service.register(fullName,username,email,password,confirmPassword);r.getSession().setAttribute("pendingAuth",id);r.getSession().removeAttribute("resetGrant");return "redirect:/verify-otp";}
  catch(AuthProblem e){m.addAttribute("error",e.getMessage());}
  catch(MailException e){m.addAttribute("error","Chưa gửi được email. Vui lòng thử lại sau.");}
  m.addAttribute("fullName",fullName);m.addAttribute("username",username);m.addAttribute("email",email);return page("register",m);
 }
 @PostMapping("/forgot-password") public String forgotPost(@RequestParam(defaultValue="") String email,HttpServletRequest r,Model m){
  try {limit(r,"otp",10);String id=service.forgot(email);r.getSession().setAttribute("pendingAuth",id);r.getSession().removeAttribute("resetGrant");return "redirect:/verify-otp";}
  catch(AuthProblem e){m.addAttribute("error",e.getMessage());}
  catch(MailException e){m.addAttribute("error","Chưa gửi được email. Vui lòng thử lại sau.");}
  m.addAttribute("email",email);return page("forgot",m);
 }
 private String sessionValue(HttpServletRequest r,String key){return r.getSession(false)==null?null:(String)r.getSession(false).getAttribute(key);}
 private String otpPage(HttpServletRequest r,Model m){
  try {var c=service.view(sessionValue(r,"pendingAuth"));if(c.usedAt!=null)return "redirect:/login";
   if(c.verifiedAt!=null)return "redirect:/reset-password";
   String[] parts=c.email.split("@",2);m.addAttribute("maskedEmail",parts[0].substring(0,1)+"***@"+parts[1]);m.addAttribute("purpose",c.purpose);
   long wait=Duration.between(LocalDateTime.now(ZoneOffset.UTC),c.lastSentAt.plusSeconds(60)).getSeconds();m.addAttribute("resendWait",Math.max(0,wait));return page("verify",m);
  }catch(AuthProblem e){return "redirect:/login?expired";}
 }
 @GetMapping("/verify-otp") public String otp(HttpServletRequest r,Model m){return otpPage(r,m);}
 @PostMapping("/verify-otp") public String verify(@RequestParam(defaultValue="") String code,HttpServletRequest r,Model m){
  try {limit(r,"verify",30);String id=sessionValue(r,"pendingAuth");String purpose=service.verify(id,code);r.changeSessionId();
   if("RESET".equals(purpose)){r.getSession().setAttribute("resetGrant",id);return "redirect:/reset-password";}
   r.getSession().removeAttribute("pendingAuth");return "redirect:/login?registered";
  }catch(AuthProblem e){m.addAttribute("error",e.getMessage());}
  catch(DataIntegrityViolationException e){m.addAttribute("error","Tên đăng nhập hoặc email vừa được sử dụng. Vui lòng đăng ký lại.");}
  return otpPage(r,m);
 }
 @PostMapping("/resend-otp") public String resend(HttpServletRequest r,Model m){
  try {limit(r,"otp",10);service.resend(sessionValue(r,"pendingAuth"));m.addAttribute("success","Đã xử lý yêu cầu gửi lại mã. Hãy kiểm tra hộp thư của bạn.");}
  catch(AuthProblem e){m.addAttribute("error",e.getMessage());}
  catch(MailException e){m.addAttribute("error","Chưa gửi được email. Vui lòng thử lại sau.");}
  return otpPage(r,m);
 }
 @GetMapping("/reset-password") public String reset(HttpServletRequest r,Model m){
  String id=sessionValue(r,"resetGrant");if(id==null)return "redirect:/forgot-password";
  try {var c=service.view(id);if(c.usedAt!=null||c.verifiedAt==null||!c.expiresAt.isAfter(LocalDateTime.now(ZoneOffset.UTC)))return "redirect:/forgot-password";return page("reset",m);}
  catch(AuthProblem e){return "redirect:/forgot-password";}
 }
 @PostMapping("/reset-password") public String resetPost(@RequestParam(defaultValue="") String password,@RequestParam(defaultValue="") String confirmPassword,HttpServletRequest r,HttpServletResponse response,Model m){
  try {limit(r,"reset",10);service.reset(sessionValue(r,"resetGrant"),password,confirmPassword);cookie(r,response,"",0);r.getSession().invalidate();return "redirect:/login?reset";}
  catch(AuthProblem e){m.addAttribute("error",e.getMessage());return reset(r,m);}
 }
 @PostMapping("/logout") public String logout(HttpServletRequest r,HttpServletResponse response){cookie(r,response,"",0);if(r.getSession(false)!=null)r.getSession().invalidate();return "redirect:/login?logout";}
}
