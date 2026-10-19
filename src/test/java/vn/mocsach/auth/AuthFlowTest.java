package vn.mocsach.auth;
import com.icegreen.greenmail.util.GreenMail;
import com.icegreen.greenmail.util.ServerSetup;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.context.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.mock.web.MockHttpSession;
import java.time.*;
import java.util.regex.Pattern;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest @AutoConfigureMockMvc @ActiveProfiles("test") @Import(AuthFlowTest.TestClock.class)
class AuthFlowTest {
 @org.junit.jupiter.api.io.TempDir static java.nio.file.Path avatarDirectory;
 static final GreenMail smtp=new GreenMail(new ServerSetup(0,"127.0.0.1","smtp"));
 static {smtp.start();smtp.setUser("sender@example.test","sender","secret");}
 @DynamicPropertySource static void mail(DynamicPropertyRegistry r){r.add("app.avatar.directory",()->avatarDirectory.toString());r.add("spring.mail.host",()->"127.0.0.1");r.add("spring.mail.port",()->smtp.getSmtp().getPort());r.add("spring.mail.username",()->"sender");r.add("spring.mail.password",()->"secret");}
 static class MutableClock extends Clock {
  Instant value=Instant.now();public ZoneId getZone(){return ZoneOffset.UTC;}public Clock withZone(ZoneId z){return this;}public Instant instant(){return value;}void advance(long seconds){value=value.plusSeconds(seconds);}
 }
 @TestConfiguration static class TestClock {@Bean @Primary MutableClock mutableClock(){return new MutableClock();}}
 @Autowired AuthService auth;@Autowired UserRepository users;@Autowired ChallengeRepository challenges;@Autowired JdbcTemplate jdbc;
 @Autowired PasswordEncoder passwords;@Autowired MockMvc mvc;@Autowired JwtTokens tokens;@Autowired MutableClock clock;
 @BeforeEach void prepare()throws Exception {
  clock.value=Instant.now();smtp.purgeEmailFromAllMailboxes();challenges.deleteAll();
  jdbc.execute("CREATE TABLE IF NOT EXISTS dbo.Roles(RoleId int PRIMARY KEY,RoleCode varchar(30))");
  jdbc.execute("CREATE TABLE IF NOT EXISTS dbo.UserRoles(UserId int,RoleId int,AssignedAt timestamp)");
  jdbc.execute("CREATE TABLE IF NOT EXISTS dbo.RefreshTokens(UserId int,RevokedAt timestamp)");
  jdbc.update("DELETE FROM dbo.UserRoles");jdbc.update("DELETE FROM dbo.RefreshTokens");jdbc.update("DELETE FROM dbo.Roles");users.deleteAll();
  jdbc.update("INSERT INTO dbo.Roles VALUES(1,'CUSTOMER')");
 }
 @AfterAll static void stop(){smtp.stop();}
 String code()throws Exception {var messages=smtp.getReceivedMessages();assertTrue(messages.length>0);var matcher=Pattern.compile("\\b[0-9]{6}\\b").matcher(messages[messages.length-1].getSubject());assertTrue(matcher.find());return matcher.group();}
 UserAccount user(String name,String status){UserAccount u=new UserAccount();u.username=name;u.email=name+"@example.test";u.fullName="Nguyễn Khang";u.passwordHash=passwords.encode("123456");u.status=status;u.createdAt=LocalDateTime.now(ZoneOffset.UTC);u.updatedAt=u.createdAt;return users.saveAndFlush(u);}
 String signup(){return auth.register("Nguyễn Khang","newreader","newreader@example.test","Reader123!","Reader123!");}
 @Test void registrationSendsRealSmtpAndCreatesOnlyAfterOtp()throws Exception {
  String id=signup();assertFalse(users.existsByUsernameIgnoreCase("newreader"));String otp=code();assertNotEquals(otp,challenges.findById(id).orElseThrow().codeHash);
  assertEquals("newreader@example.test",smtp.getReceivedMessages()[0].getAllRecipients()[0].toString());
  assertEquals("REGISTER",auth.verify(id,otp));var u=users.findByEmailIgnoreCase("newreader@example.test").orElseThrow();assertEquals("ACTIVE",u.status);assertTrue(passwords.matches("Reader123!",u.passwordHash));
  assertEquals(1,jdbc.queryForObject("SELECT COUNT(*) FROM dbo.UserRoles WHERE UserId=?",Integer.class,u.id));assertThrows(AuthProblem.class,()->auth.verify(id,otp));assertNull(challenges.findById(id).orElseThrow().passwordHash);
 }
 @Test void fiveWrongCodesLockChallengeAndPersistAttempts()throws Exception {String id=signup();String real=code();String wrong=real.equals("000000")?"111111":"000000";for(int i=0;i<5;i++)assertThrows(AuthProblem.class,()->auth.verify(id,wrong));assertEquals(5,challenges.findById(id).orElseThrow().attempts);assertThrows(AuthProblem.class,()->auth.verify(id,real));assertThrows(AuthProblem.class,()->auth.resend(id));}
 @Test void expiredOtpRejected()throws Exception {String id=signup(),code=code();clock.advance(301);assertThrows(AuthProblem.class,()->auth.verify(id,code));assertFalse(users.existsByUsernameIgnoreCase("newreader"));}
 @Test void resendHasCooldownAndInvalidatesOldCode()throws Exception {String id=signup(),old=code();assertThrows(AuthProblem.class,()->auth.resend(id));clock.advance(61);auth.resend(id);String fresh=code();if(!old.equals(fresh))assertThrows(AuthProblem.class,()->auth.verify(id,old));assertEquals("REGISTER",auth.verify(id,fresh));assertEquals(2,challenges.findById(id).orElseThrow().sendCount);}
 @Test void duplicateAndInvalidRegistrationRejected(){user("newreader","ACTIVE");assertThrows(AuthProblem.class,this::signup);assertThrows(AuthProblem.class,()->auth.register("A","!!","invalid","123","123"));}
 @Test void resetRequiresOtpAndRevokesPreviousJwt()throws Exception {
  var u=user("khang","ACTIVE");String jwt=tokens.issue(u);jdbc.update("INSERT INTO dbo.RefreshTokens VALUES(?,NULL)",u.id);
  String id=auth.forgot(u.email);assertThrows(AuthProblem.class,()->auth.reset(id,"NewPassword123!","NewPassword123!"));auth.verify(id,code());
  auth.reset(id,"NewPassword123!","NewPassword123!");assertThrows(AuthProblem.class,()->auth.login("khang","123456"));assertNotNull(auth.login("khang","NewPassword123!"));
  assertEquals(1,users.findById(u.id).orElseThrow().authVersion);assertNotNull(jdbc.queryForObject("SELECT RevokedAt FROM dbo.RefreshTokens WHERE UserId=?",java.sql.Timestamp.class,u.id));
  mvc.perform(get("/account").cookie(new Cookie("mocsach_auth",jwt))).andExpect(status().is3xxRedirection()).andExpect(redirectedUrlPattern("**/login"));
  assertThrows(AuthProblem.class,()->auth.reset(id,"Another123!","Another123!"));
 }
 @Test void unknownOrLockedEmailDoesNotSendResetCode(){user("blocked","LOCKED");String unknown=auth.forgot("unknown@example.test"),blocked=auth.forgot("blocked@example.test");assertEquals(0,smtp.getReceivedMessages().length);assertThrows(AuthProblem.class,()->auth.verify(unknown,"123456"));assertThrows(AuthProblem.class,()->auth.verify(blocked,"123456"));}
 @Test void lockedAndPendingCannotLogin(){user("locked","LOCKED");user("pending","PENDING");assertThrows(AuthProblem.class,()->auth.login("locked","123456"));assertThrows(AuthProblem.class,()->auth.login("pending","123456"));}
 @Test void loginCookieProtectedPageLogoutAndCsrf()throws Exception {
  user("admin","ACTIVE");mvc.perform(post("/auth/login").param("identifier","admin").param("password","123456")).andExpect(status().isForbidden());
  var result=mvc.perform(post("/auth/login").with(csrf()).param("identifier","admin").param("password","123456")).andExpect(status().is3xxRedirection()).andExpect(redirectedUrl("/home")).andReturn();
  String header=result.getResponse().getHeader("Set-Cookie");assertNotNull(header);assertTrue(header.contains("HttpOnly"));assertTrue(header.contains("SameSite=Lax"));
  String jwt=header.substring(header.indexOf('=')+1,header.indexOf(';'));
  mvc.perform(get("/account").cookie(new Cookie("mocsach_auth",jwt))).andExpect(status().isOk()).andExpect(model().attribute("username","admin"));
  mvc.perform(post("/logout").with(csrf()).cookie(new Cookie("mocsach_auth",jwt))).andExpect(status().is3xxRedirection()).andExpect(header().string("Set-Cookie",org.hamcrest.Matchers.containsString("Max-Age=0")));
  mvc.perform(get("/account").cookie(new Cookie("mocsach_auth",jwt+"bad"))).andExpect(status().is3xxRedirection());
 }
 @Test void resetPagesRequireSessionGrant()throws Exception {mvc.perform(get("/reset-password")).andExpect(redirectedUrl("/forgot-password"));mvc.perform(get("/verify-otp")).andExpect(redirectedUrl("/login?expired"));}
 @Test void registrationHttpJourney()throws Exception {
  var start=mvc.perform(post("/register").with(csrf()).param("fullName","Nguyễn Khang").param("username","httpreader").param("email","httpreader@example.test").param("password","Hello123!").param("confirmPassword","Hello123!")).andExpect(redirectedUrl("/verify-otp")).andReturn();
  var session=(MockHttpSession)start.getRequest().getSession();mvc.perform(post("/verify-otp").session(session).with(csrf()).param("code",code())).andExpect(redirectedUrl("/login?registered"));
 }
 @Test void resetHttpJourney()throws Exception {
  user("reader","ACTIVE");var start=mvc.perform(post("/forgot-password").with(csrf()).param("email","reader@example.test")).andExpect(redirectedUrl("/verify-otp")).andReturn();var session=(MockHttpSession)start.getRequest().getSession();
  mvc.perform(post("/verify-otp").with(csrf()).session(session).param("code",code())).andExpect(redirectedUrl("/reset-password"));
  mvc.perform(post("/reset-password").with(csrf()).session(session).param("password","NewPassword123!").param("confirmPassword","NewPassword123!")).andExpect(redirectedUrl("/login?reset"));
  assertNotNull(auth.login("reader","NewPassword123!"));
 }
 @Test void verifiedResetGrantExpires()throws Exception {user("expiry","ACTIVE");String id=auth.forgot("expiry@example.test");auth.verify(id,code());clock.advance(601);assertThrows(AuthProblem.class,()->auth.reset(id,"Password123!","Password123!"));}
 @Test void memoryRateLimiterBlocksAndRecovers(){var limiter=new RequestLimiter(clock);limiter.check("key",2,Duration.ofMinutes(1));limiter.check("key",2,Duration.ofMinutes(1));assertThrows(AuthProblem.class,()->limiter.check("key",2,Duration.ofMinutes(1)));clock.advance(61);assertDoesNotThrow(()->limiter.check("key",2,Duration.ofMinutes(1)));}
 @Test void profileUpdateValidatesNameAndPhoneWithoutOtp() {
  var u=user("profile","ACTIVE");auth.updateProfile(u.id,"Hoàng Văn Khang","090 123 4567");
  var updated=users.findById(u.id).orElseThrow();assertEquals("Hoàng Văn Khang",updated.fullName);assertEquals("0901234567",updated.phone);assertEquals(0,smtp.getReceivedMessages().length);
  assertThrows(AuthProblem.class,()->auth.updateProfile(u.id,"A","abc"));assertEquals("0901234567",users.findById(u.id).orElseThrow().phone);
 }
 @Test void emailChangeRequiresOwnerPasswordAndOtpThenRevokesOldJwt()throws Exception {
  var u=user("emailowner","ACTIVE");var other=user("other","ACTIVE");String jwt=tokens.issue(u);
  assertThrows(AuthProblem.class,()->auth.beginEmailChange(u.id,"new@example.test","bad"));
  String id=auth.beginEmailChange(u.id,"new@example.test","123456"),otp=code();
  assertEquals("emailowner@example.test",users.findById(u.id).orElseThrow().email);
  assertEquals("new@example.test",smtp.getReceivedMessages()[0].getAllRecipients()[0].toString());
  assertThrows(AuthProblem.class,()->auth.verify(id,otp));assertThrows(AuthProblem.class,()->auth.resend(id));
  assertThrows(AuthProblem.class,()->auth.verifyEmailChange(other.id,id,otp));
  auth.verifyEmailChange(u.id,id,otp);assertEquals("new@example.test",users.findById(u.id).orElseThrow().email);
  assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,id,otp));
  mvc.perform(get("/account").cookie(new Cookie("mocsach_auth",jwt))).andExpect(status().is3xxRedirection());
 }
 @Test void emailOtpExpiryCooldownAndWrongAttemptLock()throws Exception {
  var u=user("emailguards","ACTIVE");String id=auth.beginEmailChange(u.id,"guard@example.test","123456"),old=code();
  assertThrows(AuthProblem.class,()->auth.resendEmailChange(u.id,id));clock.advance(61);auth.resendEmailChange(u.id,id);String fresh=code();
  if(!old.equals(fresh))assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,id,old));
  clock.advance(301);assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,id,fresh));
  String next=auth.beginEmailChange(u.id,"another@example.test","123456"),real=code(),wrong=real.equals("000000")?"111111":"000000";
  for(int i=0;i<5;i++)assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,next,wrong));
  assertEquals(5,challenges.findById(next).orElseThrow().attempts);assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,next,real));
 }
 @Test void emailDuplicateAndSupersededChallengeCannotChangeAddress()throws Exception {
  var u=user("duplicate","ACTIVE");var taken=user("taken","ACTIVE");
  assertThrows(AuthProblem.class,()->auth.beginEmailChange(u.id,taken.email,"123456"));
  String old=auth.beginEmailChange(u.id,"first@example.test","123456"),oldCode=code();
  String latest=auth.beginEmailChange(u.id,"second@example.test","123456"),latestCode=code();
  assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,old,oldCode));
  taken.email="second@example.test";users.saveAndFlush(taken);
  assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,latest,latestCode));assertEquals("duplicate@example.test",users.findById(u.id).orElseThrow().email);
 }
 @Test void passwordChangeRequiresCurrentPasswordAndCancelsPendingEmail()throws Exception {
  var u=user("passwordchange","ACTIVE");String id=auth.beginEmailChange(u.id,"pending@example.test","123456"),otp=code();
  assertThrows(AuthProblem.class,()->auth.changePassword(u.id,"wrong","NewPassword123!","NewPassword123!"));
  assertThrows(AuthProblem.class,()->auth.changePassword(u.id,"123456","short","short"));
  auth.changePassword(u.id,"123456","NewPassword123!","NewPassword123!");
  assertThrows(AuthProblem.class,()->auth.login(u.username,"123456"));assertNotNull(auth.login(u.username,"NewPassword123!"));
  assertThrows(AuthProblem.class,()->auth.verifyEmailChange(u.id,id,otp));
 }
 @Test void accountHttpRoutesRequireCsrfAndEmailConfirmationRenewsCookie()throws Exception {
  var u=user("settingshttp","ACTIVE");Cookie cookie=new Cookie("mocsach_auth",tokens.issue(u));var session=new MockHttpSession();
  mvc.perform(post("/account/profile").cookie(cookie).param("fullName","Hoàng Khang")).andExpect(status().isForbidden());
  mvc.perform(post("/account/profile").cookie(cookie).with(csrf()).param("fullName","Hoàng Khang").param("phone","0901234567")).andExpect(redirectedUrl("/account"));
  mvc.perform(post("/account/email").session(session).cookie(cookie).with(csrf()).param("email","httpnew@example.test").param("currentPassword","123456")).andExpect(redirectedUrl("/account#email-settings"));
  mvc.perform(post("/account/email/verify").session(session).cookie(cookie).with(csrf()).param("code",code())).andExpect(redirectedUrl("/account")).andExpect(header().string("Set-Cookie",org.hamcrest.Matchers.containsString("HttpOnly")));
 }
 @Test void changingEmailCancelsRecoverySentToOldEmail()throws Exception {
  var u=user("oldrecovery","ACTIVE");String reset=auth.forgot(u.email),resetCode=code();auth.verify(reset,resetCode);
  String change=auth.beginEmailChange(u.id,"replacement@example.test","123456");auth.verifyEmailChange(u.id,change,code());
  assertThrows(AuthProblem.class,()->auth.reset(reset,"Changed123!","Changed123!"));
 }
 @Autowired org.springframework.mail.javamail.JavaMailSender mailSender;
 @Test void smtpFailureRollsBackEmailChangeRequest()throws Exception {
  var u=user("smtpfailed","ACTIVE");var sender=(org.springframework.mail.javamail.JavaMailSenderImpl)mailSender;int previous=sender.getPort();
  try {
   sender.setPort(1);
   assertThrows(org.springframework.mail.MailException.class,()->auth.beginEmailChange(u.id,"delivery@example.test","123456"));
   assertEquals(0,challenges.count());assertEquals(u.email,users.findById(u.id).orElseThrow().email);
  } finally {sender.setPort(previous);}
 }
 @Test void avatarHttpUploadPersistsImageAndIsPrivateToOwner()throws Exception {
  var owner=user("avatarowner","ACTIVE");var other=user("avatarother","ACTIVE");var cookie=new Cookie("mocsach_auth",tokens.issue(owner));
  var bytes=new java.io.ByteArrayOutputStream();javax.imageio.ImageIO.write(new java.awt.image.BufferedImage(640,480,java.awt.image.BufferedImage.TYPE_INT_RGB),"png",bytes);
  var image=new org.springframework.mock.web.MockMultipartFile("avatar","picture.png","image/png",bytes.toByteArray());
  mvc.perform(multipart("/account/avatar").file(image).cookie(cookie)).andExpect(status().isForbidden());
  mvc.perform(multipart("/account/avatar").file(image).cookie(cookie).with(csrf())).andExpect(redirectedUrl("/account")).andExpect(flash().attributeExists("success"));
  String saved=users.findById(owner.id).orElseThrow().avatarPath;assertNotNull(saved);
  var response=mvc.perform(get("/account/avatar").cookie(cookie)).andExpect(status().isOk()).andExpect(content().contentType("image/png")).andReturn();
  assertEquals(384,javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(response.getResponse().getContentAsByteArray())).getWidth());
  mvc.perform(get("/account/avatar").cookie(new Cookie("mocsach_auth",tokens.issue(other)))).andExpect(status().isNotFound());
  mvc.perform(get("/account/avatar")).andExpect(status().is3xxRedirection());
  var bad=new org.springframework.mock.web.MockMultipartFile("avatar","bad.svg","image/svg+xml","<svg/>".getBytes());
  mvc.perform(multipart("/account/avatar").file(bad).cookie(cookie).with(csrf())).andExpect(redirectedUrl("/account")).andExpect(flash().attributeExists("error"));
  assertEquals(saved,users.findById(owner.id).orElseThrow().avatarPath);
 }
 @Test void passwordHttpChangeClearsCookieAndRejectsOldLogin()throws Exception {
  var u=user("passwordhttp","ACTIVE");var cookie=new Cookie("mocsach_auth",tokens.issue(u));
  mvc.perform(post("/account/password").cookie(cookie).with(csrf()).param("currentPassword","wrong").param("password","BrandNew123!").param("confirmPassword","BrandNew123!")).andExpect(redirectedUrl("/account")).andExpect(flash().attributeExists("error"));
  mvc.perform(post("/account/password").cookie(cookie).with(csrf()).param("currentPassword","123456").param("password","BrandNew123!").param("confirmPassword","BrandNew123!")).andExpect(redirectedUrl("/login?reset")).andExpect(header().string("Set-Cookie",org.hamcrest.Matchers.containsString("Max-Age=0")));
  mvc.perform(get("/account").cookie(cookie)).andExpect(status().is3xxRedirection());
  assertThrows(AuthProblem.class,()->auth.login(u.username,"123456"));assertNotNull(auth.login(u.username,"BrandNew123!"));
 }
 @Test void profileHttpOnlyUpdatesAuthenticatedAccount()throws Exception {
  var owner=user("profileowner","ACTIVE");var other=user("profileother","ACTIVE");
  mvc.perform(post("/account/profile").with(csrf()).cookie(new Cookie("mocsach_auth",tokens.issue(owner))).param("userId",other.id.toString()).param("fullName","Hoàng Văn").param("phone","+84901234567")).andExpect(redirectedUrl("/account"));
  assertEquals("Hoàng Văn",users.findById(owner.id).orElseThrow().fullName);assertEquals("+84901234567",users.findById(owner.id).orElseThrow().phone);assertEquals("Nguyễn Khang",users.findById(other.id).orElseThrow().fullName);
 }
}
