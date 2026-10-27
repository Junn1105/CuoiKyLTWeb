<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}" />
<!doctype html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Mộc Sách · Cửa hàng bán sách cũ</title><link rel="icon" type="image/svg+xml" href="${base}/images/moc-sach-mark.svg">
<link rel="stylesheet" href="${base}/webjars/bootstrap/5.3.8/css/bootstrap.min.css"><link rel="stylesheet" href="${base}/css/auth.css">
<script src="${base}/js/auth.js" defer></script></head>
<body><main class="auth-shell">
 <aside class="story-panel" aria-label="Mộc Sách — những câu chuyện tiếp nối">
  <div class="story-top"><span class="tiny-brand">MỘC SÁCH</span><span class="story-edition">ĐỌC · GIỮ · SẺ CHIA</span></div>
  <img class="book-art" src="${base}/images/books-scene.svg" alt="Những cuốn sách xanh và kem xếp trên bục, với một cuốn sách đang mở" width="600" height="590">
  <div class="story-copy"><span class="eyebrow">MỖI CUỐN SÁCH, MỘT HÀNH TRÌNH</span><h2>Sách cũ.<br>Câu chuyện chưa cũ.</h2><p>Trao một cuốn sách.<br>Gặp một thế giới mới.</p><div class="story-note"><span class="note-star">✧</span> Những trang sách luôn có một nơi để về.</div></div>
 </aside>
 <section class="form-panel">
  <nav class="switch-link" aria-label="Chuyển trang tài khoản"><c:choose><c:when test="${mode == 'login'}">Chưa có tài khoản? <a href="${base}/register">Đăng ký ngay <span aria-hidden="true">↗</span></a></c:when><c:otherwise>Đã có tài khoản? <a href="${base}/login">Đăng nhập <span aria-hidden="true">↗</span></a></c:otherwise></c:choose></nav>
  <div class="form-content ${mode == 'register' ? 'registration-content' : ''}">
   <a class="brand" href="${base}/login" aria-label="Mộc Sách — Trang đăng nhập"><img src="${base}/images/moc-sach-mark.svg" width="40" height="40" alt=""><span>Mộc Sách<span class="brand-dot">.</span></span></a>
   <c:choose>
    <c:when test="${mode == 'login'}"><h1>Cửa hàng<br>bán sách cũ</h1><p class="intro">Chào mừng trở lại. Một câu chuyện mới đang đợi bạn.</p></c:when>
    <c:when test="${mode == 'register'}"><h1>Chào bạn mới!</h1><p class="intro">Tạo tài khoản để bắt đầu hành trình cùng Mộc Sách.</p></c:when>
    <c:when test="${mode == 'forgot'}"><h1>Quên mật khẩu?</h1><p class="intro">Không sao cả. Nhập email đã đăng ký, chúng tôi sẽ giúp bạn lấy lại tài khoản.</p></c:when>
    <c:when test="${mode == 'verify'}"><h1>Kiểm tra email nhé.</h1><p class="intro"><c:choose><c:when test="${purpose == 'RESET'}">Nếu email thuộc tài khoản đang hoạt động, mã xác thực đã được gửi đến </c:when><c:otherwise>Chúng tôi đã gửi mã xác thực đến </c:otherwise></c:choose><strong><c:out value="${maskedEmail}"/></strong>.</p></c:when>
    <c:otherwise><h1>Mật khẩu mới,<br>khởi đầu mới.</h1><p class="intro">Đặt mật khẩu mới để tiếp tục khám phá những trang sách yêu thích.</p></c:otherwise>
   </c:choose>
   <c:if test="${not empty error}"><div class="message error-message" role="alert"><span aria-hidden="true">!</span><div><c:out value="${error}"/></div></div></c:if>
   <c:if test="${not empty success}"><div class="message success-message" role="status"><c:out value="${success}"/></div></c:if>
   <c:if test="${param.registered != null}"><div class="message success-message" role="status">Email đã được xác thực. Bạn có thể đăng nhập ngay!</div></c:if>
   <c:if test="${param.reset != null}"><div class="message success-message" role="status">Đã đổi mật khẩu. Hãy đăng nhập với mật khẩu mới.</div></c:if>
   <c:if test="${param.logout != null}"><div class="message success-message" role="status">Bạn đã đăng xuất. Hẹn gặp lại!</div></c:if>
   <c:if test="${param.expired != null}"><div class="message error-message" role="alert">Phiên xác thực đã hết hiệu lực. Vui lòng bắt đầu lại.</div></c:if>
   <c:choose>
    <c:when test="${mode == 'login'}">
     <form method="post" action="${base}/auth/login" id="login-form" class="auth-form">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <label for="identifier">Tên đăng nhập hoặc email</label><div class="input-wrap"><input id="identifier" name="identifier" autocomplete="username" placeholder="Nhập tên đăng nhập hoặc email" maxlength="254" value="<c:out value='${identifier}'/>" required><span class="input-icon" aria-hidden="true">@</span></div>
      <label for="password">Mật khẩu</label><div class="input-wrap"><input id="password" type="password" name="password" autocomplete="current-password" placeholder="Nhập mật khẩu của bạn" maxlength="72" required><button class="password-toggle" type="button" data-for="password" aria-label="Hiện mật khẩu" aria-pressed="false"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/><path class="eye-slash" d="m4 4 16 16"/></svg></button></div>
      <div class="form-options"><label class="remember"><input type="checkbox" id="remember-username"><span>Ghi nhớ tên đăng nhập</span></label><a href="${base}/forgot-password">Quên mật khẩu?</a></div>
      <button class="primary-button" type="submit"><span>Đăng nhập</span><span aria-hidden="true">→</span></button>
     </form><p class="form-footnote"><span class="small-lock" aria-hidden="true">◇</span> Một tài khoản, thật nhiều câu chuyện.</p>
    </c:when>
    <c:when test="${mode == 'register'}">
     <form method="post" action="${base}/register" class="auth-form" data-confirm-password="true">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <div class="registration-grid"><div><label for="fullName">Họ và tên</label><div class="input-wrap"><input id="fullName" name="fullName" autocomplete="name" placeholder="Nguyễn Minh Khang" minlength="2" maxlength="150" value="<c:out value='${fullName}'/>" required></div></div><div><label for="username">Tên đăng nhập</label><div class="input-wrap"><input id="username" name="username" autocomplete="username" placeholder="minhkhang" pattern="[a-zA-Z][a-zA-Z0-9_.]{2,49}" title="3–50 ký tự không dấu, bắt đầu bằng chữ cái" value="<c:out value='${username}'/>" required></div></div></div>
      <label for="email">Email của bạn</label><div class="input-wrap"><input id="email" name="email" type="email" autocomplete="email" placeholder="ban@gmail.com" maxlength="254" value="<c:out value='${email}'/>" required><span class="input-icon" aria-hidden="true">@</span></div>
      <label for="password">Mật khẩu</label><div class="input-wrap"><input id="password" name="password" type="password" autocomplete="new-password" placeholder="Ít nhất 6 ký tự" minlength="6" maxlength="72" required><button class="password-toggle" type="button" data-for="password" aria-label="Hiện mật khẩu" aria-pressed="false">Hiện</button></div>
      <label for="confirmPassword">Nhập lại mật khẩu</label><div class="input-wrap"><input id="confirmPassword" name="confirmPassword" type="password" autocomplete="new-password" placeholder="Nhập lại mật khẩu" minlength="6" maxlength="72" required><button class="password-toggle" type="button" data-for="confirmPassword" aria-label="Hiện mật khẩu nhập lại" aria-pressed="false">Hiện</button></div>
      <p class="input-hint">Một mã xác thực sẽ được gửi đến email của bạn.</p><button class="primary-button" type="submit"><span>Đăng ký &amp; nhận mã</span><span aria-hidden="true">→</span></button>
     </form>
    </c:when>
    <c:when test="${mode == 'forgot'}">
     <form method="post" action="${base}/forgot-password" class="auth-form"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <label for="email">Email đã đăng ký</label><div class="input-wrap"><input id="email" type="email" name="email" autocomplete="email" placeholder="ban@gmail.com" maxlength="254" value="<c:out value='${email}'/>" required><span class="input-icon" aria-hidden="true">@</span></div>
      <button class="primary-button" type="submit"><span>Gửi mã xác thực</span><span aria-hidden="true">→</span></button></form><a class="back-link" href="${base}/login">← Quay lại đăng nhập</a>
    </c:when>
    <c:when test="${mode == 'verify'}">
     <form method="post" action="${base}/verify-otp" class="auth-form"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <label for="code">Mã xác thực 6 chữ số</label><input class="otp-input" id="code" name="code" inputmode="numeric" pattern="[0-9]{6}" maxlength="6" minlength="6" autocomplete="one-time-code" placeholder="000000" required aria-describedby="otp-hint"><p id="otp-hint" class="input-hint">Mã có hiệu lực 5 phút. Bạn nhớ kiểm tra cả thư mục Spam nhé.</p>
      <button class="primary-button" type="submit"><span>Xác thực email</span><span aria-hidden="true">→</span></button></form>
     <form method="post" action="${base}/resend-otp" class="resend-form"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><span>Chưa nhận được mã?</span> <button type="submit" class="text-button" data-resend-seconds="${resendWait}">Gửi lại mã</button><span class="countdown" aria-live="polite"></span></form>
     <a class="back-link" href="${base}/${purpose == 'REGISTER' ? 'register' : 'forgot-password'}">← Thay đổi thông tin</a>
    </c:when>
    <c:otherwise>
     <form method="post" action="${base}/reset-password" class="auth-form" data-confirm-password="true"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <label for="password">Mật khẩu mới</label><div class="input-wrap"><input id="password" name="password" type="password" autocomplete="new-password" placeholder="Ít nhất 6 ký tự" minlength="6" maxlength="72" required><button class="password-toggle" type="button" data-for="password" aria-label="Hiện mật khẩu" aria-pressed="false">Hiện</button></div>
      <label for="confirmPassword">Nhập lại mật khẩu mới</label><div class="input-wrap"><input id="confirmPassword" name="confirmPassword" type="password" autocomplete="new-password" placeholder="Nhập lại mật khẩu" minlength="6" maxlength="72" required><button class="password-toggle" type="button" data-for="confirmPassword" aria-label="Hiện mật khẩu nhập lại" aria-pressed="false">Hiện</button></div>
      <button class="primary-button" type="submit"><span>Lưu mật khẩu mới</span><span aria-hidden="true">→</span></button></form>
    </c:otherwise>
   </c:choose>
  </div><div class="bottom-note">Sách được yêu thêm một lần.</div>
 </section>
</main></body></html>
