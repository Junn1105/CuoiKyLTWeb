<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Tài khoản của tôi · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/account.css"><script defer src="${base}/js/account.js"></script></head>
<body><main class="account-shell">
<header><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" width="30" height="30" alt="">Mộc Sách.</a><a href="${base}/home">← Về trang chủ</a></header>
<div class="heading"><p class="eyebrow">KHÔNG GIAN CỦA BẠN</p><h1>Tài khoản của tôi</h1><p>Quản lý thông tin cá nhân và bảo mật tài khoản.</p></div>
<c:if test="${not empty error}"><div class="message error" role="alert"><c:out value="${error}"/></div></c:if>
<c:if test="${not empty success}"><div class="message success" role="status"><c:out value="${success}"/></div></c:if>
<div class="account-grid"><aside class="card avatar-card"><c:choose><c:when test="${hasAvatar}"><img class="profile-avatar" src="${base}/account/avatar" alt="Ảnh đại diện hiện tại"></c:when><c:otherwise><div class="profile-avatar initial" aria-label="Chưa có ảnh đại diện">M</div></c:otherwise></c:choose><h2><c:out value="${displayName}"/></h2><p class="username">@<c:out value="${username}"/></p>
<form action="${base}/account/avatar?${_csrf.parameterName}=${_csrf.token}" method="post" enctype="multipart/form-data"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><label for="avatar">Thay ảnh đại diện</label><input id="avatar" type="file" name="avatar" accept="image/jpeg,image/png" required aria-describedby="avatar-help"><p class="hint" id="avatar-help">Ảnh JPG hoặc PNG, tối đa 5 MB và 4096 × 4096 pixel. Ảnh sẽ được cắt vuông ở giữa.</p><button type="submit">Lưu ảnh đại diện</button></form>
<nav aria-label="Các mục tài khoản"><a href="#profile">Thông tin cá nhân</a><a href="#email-settings">Địa chỉ email</a><a href="#password-settings">Đổi mật khẩu</a></nav>
</aside><div class="settings">
<section class="card" id="profile"><h2>Thông tin cá nhân</h2><form action="${base}/account/profile" method="post"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><label for="fullName">Họ và tên</label><input id="fullName" name="fullName" value="<c:out value='${displayName}'/>" minlength="2" maxlength="150" autocomplete="name" required><label for="phone">Số điện thoại</label><input id="phone" name="phone" type="tel" value="<c:out value='${phone}'/>" maxlength="25" autocomplete="tel" placeholder="Nhập số điện thoại"><p class="hint">Số điện thoại không cần xác nhận OTP. Bạn có thể để trống.</p><button type="submit">Lưu thông tin</button></form></section>

<section class="card" id="email-settings">
 <h2>Địa chỉ email</h2>
 <p class="current-email">Email hiện tại: <strong><c:out value="${email}"/></strong></p>
 <p class="hint">Nhập địa chỉ email mới và bấm <strong>Nhận mã OTP</strong>, sau đó nhập mã OTP 6 chữ số được gửi về hộp thư để cập nhật email mới.</p>

 <!-- Bước 1: Nhập email mới & Nhận mã -->
 <form action="${base}/account/email" method="post">
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  <label for="email">1. Nhập email mới</label>
  <input id="email" name="email" type="email" maxlength="254" autocomplete="email" placeholder="nhap-email-moi@gmail.com" value="<c:out value='${pendingEmail}'/>" required>
  <button type="submit">Nhận mã OTP</button>
 </form>

 <!-- Bước 2: Nhập mã OTP & Cập nhật email mới (Luôn hiển thị sẵn) -->
 <div class="otp-panel">
  <h3>2. Nhập mã OTP &amp; Cập nhật email mới</h3>
  <c:choose>
   <c:when test="${not empty pendingEmail}">
    <p style="color:#1158c5; font-weight:600;">✓ Mã OTP đã được gửi tới: <strong><c:out value="${pendingEmail}"/></strong>. Vui lòng kiểm tra hộp thư (kể cả mục Spam) và nhập mã vào ô dưới đây:</p>
   </c:when>
   <c:otherwise>
    <p class="hint">Sau khi bấm <strong>Nhận mã OTP</strong> ở trên, hãy nhập mã 6 chữ số nhận được qua email vào ô bên dưới:</p>
   </c:otherwise>
  </c:choose>
  <form action="${base}/account/email/verify" method="post">
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <label for="code">Mã OTP gồm 6 chữ số</label>
   <input id="code" name="code" inputmode="numeric" pattern="[0-9]{6}" minlength="6" maxlength="6" placeholder="000000" autocomplete="one-time-code" required>
   <div style="display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
    <button type="submit">Cập nhật email mới</button>
   </div>
  </form>
  <form action="${base}/account/email/resend" method="post" style="margin-top:6px;">
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <button class="secondary" type="submit">Gửi lại mã OTP</button>
  </form>
  <p class="hint">Mã hết hạn sau 5 phút. Chờ 60 giây giữa hai lần gửi; tối đa 5 lần nhập sai.</p>
 </div>
</section>

<section class="card" id="password-settings"><h2>Đổi mật khẩu</h2><p class="hint">Sau khi đổi mật khẩu thành công, bạn sẽ đăng nhập lại bằng mật khẩu mới.</p><form action="${base}/account/password" method="post"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><label for="currentPassword">Mật khẩu hiện tại</label><div class="password-field"><input id="currentPassword" name="currentPassword" type="password" autocomplete="current-password" required><button type="button" class="toggle" data-password="currentPassword" aria-controls="currentPassword" aria-pressed="false">Hiện</button></div><label for="newPassword">Mật khẩu mới</label><div class="password-field"><input id="newPassword" name="password" type="password" minlength="6" maxlength="72" autocomplete="new-password" required aria-describedby="password-help"><button type="button" class="toggle" data-password="newPassword" aria-controls="newPassword" aria-pressed="false">Hiện</button></div><p class="hint" id="password-help">Ít nhất 6 ký tự, tối đa 72 byte và khác mật khẩu hiện tại.</p><label for="confirmPassword">Nhập lại mật khẩu mới</label><div class="password-field"><input id="confirmPassword" name="confirmPassword" type="password" minlength="6" maxlength="72" autocomplete="new-password" required><button type="button" class="toggle" data-password="confirmPassword" aria-controls="confirmPassword" aria-pressed="false">Hiện</button></div><button type="submit">Đổi mật khẩu</button></form></section>
</div></div></main></body></html>
