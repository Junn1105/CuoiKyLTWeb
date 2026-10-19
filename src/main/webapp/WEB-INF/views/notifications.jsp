<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Thông báo · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/home">← Về trang chủ</a><div class="header-links"><a class="cart-link" href="${base}/cart">Giỏ hàng<c:if test="${cartCount > 0}"> (<c:out value="${cartCount}"/>)</c:if></a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="cart-breadcrumb" aria-label="Đường dẫn"><a href="${base}/home">Trang chủ</a><span>›</span><span>Thông báo</span></nav>
<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<section class="panel notif-page-card">
 <div class="notif-page-head">
  <div><h1>Thông báo</h1><p class="hint">Bạn có <strong><c:out value="${unreadCount}"/></strong> thông báo chưa đọc.</p></div>
  <c:if test="${unreadCount > 0}">
   <form method="post" action="${base}/notifications/read-all"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="redirect" value="/notifications"><button type="submit" class="outline-button">Đánh dấu tất cả đã đọc</button></form>
  </c:if>
 </div>
 <div class="notif-tabs">
  <a class="notif-tab ${filter == 'all' ? 'active' : ''}" href="${base}/notifications?filter=all">Tất cả</a>
  <a class="notif-tab ${filter == 'unread' ? 'active' : ''}" href="${base}/notifications?filter=unread">Chưa đọc (${unreadCount})</a>
 </div>
 <div class="notif-page-list">
  <c:choose>
   <c:when test="${empty pageNotifications}">
    <p class="notif-empty">Không có thông báo nào trong mục này.</p>
   </c:when>
   <c:otherwise>
    <c:forEach items="${pageNotifications}" var="n">
     <form method="post" action="${base}/notifications/${n.id}/open" class="notif-item-form">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
      <button type="submit" class="notif-item ${n.unread ? 'is-unread' : ''}">
       <span class="notif-avatar" aria-hidden="true"><c:out value="${n.icon}"/></span>
       <span class="notif-content">
        <span class="notif-text"><strong><c:out value="${n.title}"/></strong> — <c:out value="${n.content}"/></span>
        <span class="notif-time ${n.unread ? 'unread' : ''}"><c:out value="${n.timeLabel}"/></span>
       </span>
       <c:if test="${n.unread}"><span class="notif-dot" aria-label="Chưa đọc"></span></c:if>
      </button>
     </form>
    </c:forEach>
   </c:otherwise>
  </c:choose>
 </div>
</section>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
