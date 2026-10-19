package vn.mocsach.auth;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.time.*;
import java.util.*;
@Service
public class AuthService {
 private final UserRepository users; private final ChallengeRepository challenges; private final PasswordEncoder passwords;
 private final OtpMailer mailer; private final JdbcTemplate jdbc; private final Clock clock; private final byte[] secret;
 private final SecureRandom random=new SecureRandom(); private final String dummyHash;
 private final int otpSeconds,resendSeconds,maxAttempts;
 public AuthService(UserRepository users,ChallengeRepository challenges,PasswordEncoder passwords,OtpMailer mailer,JdbcTemplate jdbc,Clock clock,
  @Value("${app.auth.secret}") String secret,@Value("${app.auth.otp-seconds:300}") int otpSeconds,
  @Value("${app.auth.resend-seconds:60}") int resendSeconds,@Value("${app.auth.max-attempts:5}") int maxAttempts) {
  this.users=users;this.challenges=challenges;this.passwords=passwords;this.mailer=mailer;this.jdbc=jdbc;this.clock=clock;
  this.secret=secret.getBytes(StandardCharsets.UTF_8);this.otpSeconds=otpSeconds;this.resendSeconds=resendSeconds;this.maxAttempts=maxAttempts;
  if(this.secret.length<32) throw new IllegalStateException("Configure app.auth.secret (at least 32 random bytes).");
  this.dummyHash=passwords.encode(UUID.randomUUID().toString());
 }
 private LocalDateTime now(){return LocalDateTime.ofInstant(clock.instant(),ZoneOffset.UTC);}
 public UserAccount login(String identifier,String password) {
  identifier=identifier==null?"":identifier.strip(); password=password==null?"":password;
  if(identifier.length()>254 || password.getBytes(StandardCharsets.UTF_8).length>72) throw new AuthProblem("Tên đăng nhập hoặc mật khẩu không đúng.");
  UserAccount user=users.findByUsernameIgnoreCaseOrEmailIgnoreCase(identifier,identifier).orElse(null);
  boolean match=passwords.matches(password,user==null?dummyHash:user.passwordHash);
  if(user==null || !match || !"ACTIVE".equals(user.status)) throw new AuthProblem("Thông tin đăng nhập không đúng hoặc tài khoản chưa được kích hoạt.");
  return user;
 }
 private String email(String value) {
  String s=value==null?"":value.strip().toLowerCase(Locale.ROOT);
  if(s.length()>254 || !s.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) throw new AuthProblem("Vui lòng nhập địa chỉ email hợp lệ.");
  return s;
 }
 public void validatePassword(String password,String confirmation) {
  if(password==null || password.length()<8 || password.getBytes(StandardCharsets.UTF_8).length>72) throw new AuthProblem("Mật khẩu mới cần ít nhất 8 ký tự và tối đa 72 byte.");
  if(!password.equals(confirmation)) throw new AuthProblem("Hai mật khẩu chưa trùng khớp.");
 }
 private void emailLimit(String email) {
  if(challenges.countByEmailAndCreatedAtAfter(email,now().minusHours(1))>=5) throw new AuthProblem("Email này đã nhận nhiều yêu cầu. Vui lòng thử lại sau một giờ.");
  challenges.findFirstByEmailOrderByLastSentAtDesc(email).ifPresent(c->{if(c.lastSentAt.plusSeconds(resendSeconds).isAfter(now())) throw new AuthProblem("Vui lòng chờ 60 giây trước khi yêu cầu mã mới.");});
 }
 @Transactional
 public String register(String fullName,String username,String rawEmail,String password,String confirmation) {
  username=username==null?"":username.strip().toLowerCase(Locale.ROOT); fullName=fullName==null?"":fullName.strip(); String email=email(rawEmail);
  if(!username.matches("[a-z][a-z0-9_.]{2,49}")) throw new AuthProblem("Tên đăng nhập cần 3–50 ký tự không dấu, bắt đầu bằng chữ cái.");
  if(fullName.length()<2 || fullName.length()>150) throw new AuthProblem("Họ tên cần từ 2 đến 150 ký tự.");
  validatePassword(password,confirmation);
  if(users.existsByUsernameIgnoreCase(username)||users.existsByEmailIgnoreCase(email)) throw new AuthProblem("Tên đăng nhập hoặc email đã được sử dụng.");
  emailLimit(email);
  AuthChallenge c=fresh("REGISTER",email); c.username=username;c.fullName=fullName;c.passwordHash=passwords.encode(password);
  issue(c,true); return c.id;
 }
 @Transactional
 public String forgot(String rawEmail) {
  String email=email(rawEmail);emailLimit(email); AuthChallenge c=fresh("RESET",email);
  users.findByEmailIgnoreCase(email).filter(u->"ACTIVE".equals(u.status)).ifPresent(u->{c.userId=u.id;c.versionAtIssue=u.authVersion;});
  issue(c,c.userId!=null);return c.id;
 }
 private AuthChallenge fresh(String purpose,String email) {
  AuthChallenge c=new AuthChallenge();c.id=UUID.randomUUID().toString();c.purpose=purpose;c.email=email;c.createdAt=now();c.attempts=0;c.sendCount=0;return c;
 }
 private void issue(AuthChallenge c,boolean deliver) {
  String code=String.format(Locale.ROOT,"%06d",random.nextInt(1000000));c.codeHash=digest(c.id,code);
  c.lastSentAt=now();c.expiresAt=now().plusSeconds(otpSeconds);c.sendCount++;
  challenges.saveAndFlush(c);
  if(deliver) mailer.send(c.email,code,c.purpose);
 }
 private String digest(String id,String code) {
  try {Mac mac=Mac.getInstance("HmacSHA256");mac.init(new SecretKeySpec(secret,"HmacSHA256"));return HexFormat.of().formatHex(mac.doFinal((id+":"+code).getBytes(StandardCharsets.UTF_8)));}
  catch(GeneralSecurityException ex){throw new IllegalStateException(ex);}
 }
 public AuthChallenge view(String id) {return challenges.findById(id==null?"":id).orElseThrow(()->new AuthProblem("Phiên xác thực đã kết thúc. Vui lòng bắt đầu lại."));}
 private AuthChallenge locked(String id){return challenges.locked(id==null?"":id).orElseThrow(()->new AuthProblem("Phiên xác thực đã kết thúc. Vui lòng bắt đầu lại."));}
 @Transactional
 public void resend(String id) {
  AuthChallenge c=locked(id);
  if("EMAIL".equals(c.purpose)) throw new AuthProblem("Vui lòng xác thực email tại trang tài khoản.");
  resendChallenge(c);
 }
 private void resendChallenge(AuthChallenge c) {
  if(c.usedAt!=null||c.verifiedAt!=null||c.attempts>=maxAttempts||c.sendCount>=5||c.createdAt.plusHours(1).isBefore(now())) throw new AuthProblem("Phiên đã hết hiệu lực. Vui lòng bắt đầu lại.");
  if(c.lastSentAt.plusSeconds(resendSeconds).isAfter(now())) throw new AuthProblem("Vui lòng chờ 60 giây trước khi gửi lại mã.");
  issue(c,!"RESET".equals(c.purpose)||c.userId!=null);
 }
 // Incorrect guesses must commit the attempt count, rather than roll it back with the error.
 @Transactional(noRollbackFor=AuthProblem.class)
 public String verify(String id,String code) {
  AuthChallenge c=locked(id);
  if("EMAIL".equals(c.purpose)) throw new AuthProblem("Vui lòng xác thực email tại trang tài khoản.");
  if(c.usedAt!=null||c.verifiedAt!=null||!c.expiresAt.isAfter(now())||c.attempts>=maxAttempts) throw new AuthProblem("Mã đã hết hạn hoặc không còn hiệu lực. Hãy yêu cầu mã mới.");
  c.attempts++;
  if(code==null || !code.matches("[0-9]{6}") || !MessageDigest.isEqual(c.codeHash.getBytes(StandardCharsets.US_ASCII),digest(c.id,code).getBytes(StandardCharsets.US_ASCII)) || ("RESET".equals(c.purpose)&&c.userId==null))
   throw new AuthProblem("Mã xác thực chưa đúng. Vui lòng kiểm tra lại email.");
  if("REGISTER".equals(c.purpose)) {
   if(users.existsByUsernameIgnoreCase(c.username)||users.existsByEmailIgnoreCase(c.email)) {c.usedAt=now();c.passwordHash=null;throw new AuthProblem("Tên đăng nhập hoặc email đã được sử dụng. Hãy đăng ký lại.");}
   UserAccount u=new UserAccount();u.username=c.username;u.fullName=c.fullName;u.email=c.email;u.passwordHash=c.passwordHash;u.status="ACTIVE";u.createdAt=now();u.updatedAt=now();u=users.saveAndFlush(u);
   int roles=jdbc.update("INSERT INTO dbo.UserRoles(UserId,RoleId,AssignedAt) SELECT ?,RoleId,? FROM dbo.Roles WHERE RoleCode='CUSTOMER'",u.id,now());
   if(roles!=1) throw new IllegalStateException("Customer role is not configured");
   c.userId=u.id;c.usedAt=now();c.passwordHash=null;
  }
  c.verifiedAt=now();c.expiresAt=now().plusMinutes(10);return c.purpose;
 }
 @Transactional
 public void reset(String id,String password,String confirmation) {
  validatePassword(password,confirmation);AuthChallenge c=locked(id);
  if(!"RESET".equals(c.purpose)||c.verifiedAt==null||c.usedAt!=null||!c.expiresAt.isAfter(now())||c.userId==null) throw new AuthProblem("Phiên đặt lại mật khẩu đã hết hiệu lực. Vui lòng bắt đầu lại.");
  UserAccount u=users.locked(c.userId).orElseThrow(()->new AuthProblem("Tài khoản không khả dụng."));
  if(!"ACTIVE".equals(u.status)||!Objects.equals(c.versionAtIssue,u.authVersion)) throw new AuthProblem("Phiên đặt lại mật khẩu không còn hiệu lực.");
  u.passwordHash=passwords.encode(password);u.authVersion++;u.updatedAt=now();c.usedAt=now();
  jdbc.update("UPDATE dbo.RefreshTokens SET RevokedAt=? WHERE UserId=? AND RevokedAt IS NULL",now(),u.id);
  jdbc.update("UPDATE dbo.AuthChallenges SET UsedAt=? WHERE UserId=? AND Purpose='RESET' AND UsedAt IS NULL",now(),u.id);
 }
 private UserAccount active(int id) {
  var u=users.locked(id).orElseThrow(()->new AuthProblem("Tài khoản không khả dụng."));
  if(!"ACTIVE".equals(u.status)) throw new AuthProblem("Tài khoản không khả dụng.");
  return u;
 }
 private void currentPassword(UserAccount u,String password) {
  if(password==null||password.getBytes(StandardCharsets.UTF_8).length>72||!passwords.matches(password,u.passwordHash))
   throw new AuthProblem("Mật khẩu hiện tại không đúng.");
 }
 @Transactional public void updateProfile(int id,String fullName,String phone) {
  fullName=fullName==null?"":fullName.strip();phone=phone==null?"":phone.strip().replaceAll("[ .()-]", "");
  if(fullName.length()<2||fullName.length()>150) throw new AuthProblem("Họ tên cần từ 2 đến 150 ký tự.");
  if(!phone.isEmpty()&&!phone.matches("\\+?[0-9]{9,15}")) throw new AuthProblem("Số điện thoại cần từ 9 đến 15 chữ số, có thể bắt đầu bằng +.");
  var u=active(id);u.fullName=fullName;u.phone=phone.isEmpty()?null:phone;u.updatedAt=now();
 }
 @Transactional public void changePassword(int id,String current,String password,String confirmation) {
  validatePassword(password,confirmation);var u=active(id);currentPassword(u,current);
  if(passwords.matches(password,u.passwordHash)) throw new AuthProblem("Mật khẩu mới cần khác mật khẩu hiện tại.");
  u.passwordHash=passwords.encode(password);u.authVersion++;u.updatedAt=now();
  jdbc.update("UPDATE dbo.RefreshTokens SET RevokedAt=? WHERE UserId=? AND RevokedAt IS NULL",now(),id);
  jdbc.update("UPDATE dbo.AuthChallenges SET UsedAt=? WHERE UserId=? AND Purpose='RESET' AND UsedAt IS NULL",now(),id);
 }
 @Transactional public String beginEmailChange(int id,String rawEmail,String password) {
  var u=active(id);currentPassword(u,password);String target=email(rawEmail);
  if(users.existsByEmailIgnoreCase(target)) throw new AuthProblem("Email này đã được sử dụng.");
  emailLimit(target);
  if(jdbc.queryForObject("SELECT COUNT(*) FROM dbo.AuthChallenges WHERE UserId=? AND Purpose='EMAIL' AND CreatedAt>?",Integer.class,id,now().minusHours(1))>=5) throw new AuthProblem("Vui lòng thử lại sau.");
  // A single outstanding email change per account, including across browser sessions.
  jdbc.update("UPDATE dbo.AuthChallenges SET UsedAt=? WHERE UserId=? AND Purpose='EMAIL' AND UsedAt IS NULL",now(),id);
  var c=fresh("EMAIL",target);c.userId=id;c.versionAtIssue=u.authVersion;issue(c,true);return c.id;
 }
 private AuthChallenge ownedEmail(UserAccount u,String id) {
  var c=locked(id);
  if(!"EMAIL".equals(c.purpose)||!Objects.equals(c.userId,u.id)||!Objects.equals(c.versionAtIssue,u.authVersion))
   throw new AuthProblem("Phiên đổi email không còn hiệu lực. Vui lòng bắt đầu lại.");
  return c;
 }
 @Transactional public void resendEmailChange(int userId,String id) {resendChallenge(ownedEmail(active(userId),id));}
 @Transactional(noRollbackFor=AuthProblem.class) public void verifyEmailChange(int userId,String id,String code) {
  var u=active(userId);var c=ownedEmail(u,id);
  if(c.usedAt!=null||c.verifiedAt!=null||!c.expiresAt.isAfter(now())||c.attempts>=maxAttempts) throw new AuthProblem("Mã đã hết hạn hoặc bị khóa. Vui lòng bắt đầu lại.");
  c.attempts++;
  if(code==null||!code.matches("[0-9]{6}")||!MessageDigest.isEqual(c.codeHash.getBytes(StandardCharsets.US_ASCII),digest(c.id,code).getBytes(StandardCharsets.US_ASCII)))
   throw new AuthProblem("Mã xác thực chưa đúng.");
  if(users.existsByEmailIgnoreCase(c.email)) {c.usedAt=now();throw new AuthProblem("Email này đã được sử dụng. Vui lòng chọn email khác.");}
  u.email=c.email;u.updatedAt=now();u.authVersion++;c.usedAt=now();c.verifiedAt=now();
  jdbc.update("UPDATE dbo.RefreshTokens SET RevokedAt=? WHERE UserId=? AND RevokedAt IS NULL",now(),userId);
  jdbc.update("UPDATE dbo.AuthChallenges SET UsedAt=? WHERE UserId=? AND Purpose='RESET' AND UsedAt IS NULL",now(),userId);
 }
 @Transactional public String updateAvatar(int id,String path) {var u=active(id);String old=u.avatarPath;u.avatarPath=path;u.updatedAt=now();return old;}
}
