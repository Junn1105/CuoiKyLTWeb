package vn.mocsach.auth;

import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.*;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.security.Principal;
import java.time.Duration;
import java.io.IOException;

@Controller
@RequestMapping("/account")
public class AccountController {
 private final UserRepository users;private final AuthService auth;private final AvatarStorage avatars;private final RequestLimiter limiter;private final JwtTokens tokens;private final boolean secure;
 public AccountController(UserRepository users,AuthService auth,AvatarStorage avatars,RequestLimiter limiter,JwtTokens tokens,@Value("${app.auth.secure-cookie:false}") boolean secure){this.users=users;this.auth=auth;this.avatars=avatars;this.limiter=limiter;this.tokens=tokens;this.secure=secure;}
 private UserAccount user(Principal p){return users.findByUsernameIgnoreCaseOrEmailIgnoreCase(p.getName(),p.getName()).orElseThrow(()->new AuthProblem("Tài khoản không khả dụng."));}
 private void limit(int id,String action){limiter.check("account:"+action+":"+id,5,Duration.ofMinutes(10));}
 private String pending(HttpServletRequest r){return (String)r.getSession().getAttribute("pendingEmail");}
 private void success(RedirectAttributes flash,String message){flash.addFlashAttribute("success",message);}
 @GetMapping public String page(Principal p,Model model,HttpServletRequest r){
  var u=user(p);model.addAttribute("username",u.username);model.addAttribute("displayName",u.fullName);model.addAttribute("email",u.email);model.addAttribute("phone",u.phone);model.addAttribute("hasAvatar",u.avatarPath!=null);
  String id=pending(r);if(id!=null)try{var c=auth.view(id);if("EMAIL".equals(c.purpose)&&u.id.equals(c.userId)&&c.usedAt==null&&Integer.valueOf(u.authVersion).equals(c.versionAtIssue))model.addAttribute("pendingEmail",c.email);else r.getSession().removeAttribute("pendingEmail");}catch(AuthProblem ignored){r.getSession().removeAttribute("pendingEmail");}
  return "account";
 }
 @PostMapping("/profile") public String profile(Principal p,@RequestParam String fullName,@RequestParam(defaultValue="") String phone,RedirectAttributes flash){auth.updateProfile(user(p).id,fullName,phone);success(flash,"Đã cập nhật họ tên và số điện thoại.");return "redirect:/account";}
 @PostMapping("/avatar") public String avatar(Principal p,@RequestParam MultipartFile avatar,RedirectAttributes flash){
  var u=user(p);limit(u.id,"avatar");String path=avatars.save(avatar);
  try{String old=auth.updateAvatar(u.id,path);avatars.delete(old);}catch(RuntimeException ex){avatars.delete(path);throw ex;}
  success(flash,"Đã thay ảnh đại diện.");return "redirect:/account";
 }
 @GetMapping("/avatar") @ResponseBody public ResponseEntity<byte[]> avatarImage(Principal p)throws IOException {
  byte[] image=avatars.read(user(p).avatarPath);
  if(image==null)return ResponseEntity.notFound().build();
  return ResponseEntity.ok().cacheControl(CacheControl.noStore()).contentType(MediaType.IMAGE_PNG).body(image);
 }
 @PostMapping("/password") public String password(Principal p,@RequestParam String currentPassword,@RequestParam String password,@RequestParam String confirmPassword,HttpServletRequest r,HttpServletResponse res){
  var u=user(p);limit(u.id,"sensitive");auth.changePassword(u.id,currentPassword,password,confirmPassword);r.getSession().invalidate();setCookie(r,res,"",0);return "redirect:/login?reset";
 }
 @PostMapping("/email") public String email(Principal p,@RequestParam String email,@RequestParam String currentPassword,HttpServletRequest r,RedirectAttributes flash){
  var u=user(p);limit(u.id,"sensitive");String id=auth.beginEmailChange(u.id,email,currentPassword);r.getSession().setAttribute("pendingEmail",id);success(flash,"Đã gửi mã OTP đến email mới. Mã có hiệu lực trong 5 phút.");return "redirect:/account#email-settings";
 }
 @PostMapping("/email/resend") public String resend(Principal p,HttpServletRequest r,RedirectAttributes flash){var u=user(p);limit(u.id,"send");auth.resendEmailChange(u.id,pending(r));success(flash,"Đã gửi lại mã. Mã cũ không còn hiệu lực.");return "redirect:/account#email-settings";}
 @PostMapping("/email/verify") public String verify(Principal p,@RequestParam String code,HttpServletRequest r,HttpServletResponse res,RedirectAttributes flash){
  var u=user(p);limiter.check("account:verify:"+u.id,30,Duration.ofMinutes(10));auth.verifyEmailChange(u.id,pending(r),code);r.getSession().removeAttribute("pendingEmail");r.changeSessionId();setCookie(r,res,tokens.issue(users.findById(u.id).orElseThrow()),7200);success(flash,"Đã xác nhận và cập nhật email mới.");return "redirect:/account";
 }
 private void setCookie(HttpServletRequest r,HttpServletResponse res,String token,int seconds){res.addHeader(HttpHeaders.SET_COOKIE,ResponseCookie.from("mocsach_auth",token).httpOnly(true).secure(secure).sameSite("Lax").path(r.getContextPath().isBlank()?"/":r.getContextPath()).maxAge(seconds).build().toString());}
 @ExceptionHandler(AuthProblem.class) public String problem(AuthProblem ex,RedirectAttributes flash){flash.addFlashAttribute("error",ex.getMessage());return "redirect:/account";}
 @ExceptionHandler(MailException.class) public String mailFailure(RedirectAttributes flash){flash.addFlashAttribute("error","Chưa gửi được email. Hãy kiểm tra cấu hình Gmail SMTP hoặc thử lại sau. Email hiện tại chưa thay đổi.");return "redirect:/account";}
 @ExceptionHandler(DataIntegrityViolationException.class) public String duplicate(RedirectAttributes flash){flash.addFlashAttribute("error","Email đã được tài khoản khác sử dụng. Vui lòng chọn email khác.");return "redirect:/account";}
 @ExceptionHandler(MaxUploadSizeExceededException.class) public String tooLarge(RedirectAttributes flash){flash.addFlashAttribute("error","Ảnh quá lớn. Vui lòng chọn ảnh tối đa 5 MB.");return "redirect:/account";}
}
