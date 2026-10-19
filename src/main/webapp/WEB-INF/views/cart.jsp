<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Giỏ hàng của tôi · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/home">← Tiếp tục khám phá sách</a><div class="header-links"><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="cart-breadcrumb" aria-label="Đường dẫn"><a href="${base}/home">Trang chủ</a><span>›</span><span>Giỏ hàng của tôi</span></nav>
<div class="cart-heading"><span class="eyebrow">GIỎ SÁCH CỦA BẠN</span><h1>Giỏ hàng <small>(<c:out value="${cart.totalCount}"/> cuốn)</small></h1><p>Mỗi mục trong giỏ tương ứng với một bản sách vật lý cụ thể tại chi nhánh.</p></div>
<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>
<c:choose><c:when test="${empty cart.items}">
 <section class="panel empty-cart"><h2>Giỏ hàng của bạn đang trống</h2><p class="hint">Hãy dạo quanh kệ sách cũ và chọn cho mình những cuốn sách ưng ý nhé.</p><a class="primary-link" href="${base}/home">Khám phá sách ngay →</a></section>
</c:when><c:otherwise>
 <div class="cart-grid">
  <section class="panel cart-items-panel">
   <div class="panel-top"><h2>Danh sách bản sách đã chọn</h2><form method="post" action="${base}/cart/clear"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button type="submit" class="outline-button">Làm trống giỏ</button></form></div>
   <div class="cart-list">
    <c:forEach items="${cart.items}" var="item">
     <article class="cart-item ${item.available ? '' : 'unavailable'}">
      <a class="item-cover" href="${base}/books/${item.bookId}"><img src="${base}<c:out value='${item.cover}'/>" alt="Bìa sách <c:out value='${item.title}'/>" width="110" height="154" data-cover></a>
      <div class="item-info">
       <h3><a href="${base}/books/${item.bookId}"><c:out value="${item.title}"/></a></h3>
       <p class="item-author"><c:out value="${item.authors}"/></p>
       <dl class="item-meta">
        <div><dt>Mã bản sách</dt><dd><c:out value="${item.copyCode}"/></dd></div>
        <div><dt>Tình trạng</dt><dd><c:out value="${item.conditionName}"/></dd></div>
        <div><dt>Chi nhánh</dt><dd><c:out value="${item.storeName}"/></dd></div>
        <div><dt>Trạng thái</dt><dd><span class="status-badge ${item.available ? 'ok' : 'warn'}"><c:out value="${item.statusLabel}"/></span></dd></div>
       </dl>
      </div>
      <div class="item-actions">
       <strong class="item-price"><c:out value="${item.priceLabel}"/></strong>
       <form method="post" action="${base}/cart/items/${item.cartItemId}/remove"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button type="submit" class="remove-button" aria-label="Xóa <c:out value='${item.title}'/> khỏi giỏ">Xóa</button></form>
      </div>
     </article>
    </c:forEach>
   </div>
  </section>
  <aside class="panel cart-summary">
   <h2>Tóm tắt giỏ hàng</h2>
   <dl class="summary-rows">
    <div><dt>Tổng số bản sách</dt><dd><c:out value="${cart.totalCount}"/> cuốn</dd></div>
    <div><dt>Bản sách khả dụng</dt><dd><c:out value="${cart.availableCount}"/> cuốn</dd></div>
    <div><dt>Số chi nhánh</dt><dd><c:out value="${cart.storeCount}"/> chi nhánh</dd></div>
    <div class="total-row"><dt>Tạm tính</dt><dd><strong><c:out value="${cart.subtotalLabel}"/></strong></dd></div>
   </dl>
   <c:if test="${cart.unavailableCount > 0}">
    <p class="cart-warning" role="alert">Có <c:out value="${cart.unavailableCount}"/> bản sách trong giỏ hiện không còn khả dụng. Vui lòng xóa khỏi giỏ trước khi đặt hàng.</p>
   </c:if>
   <p class="hint">Thêm sách vào giỏ chưa giữ chỗ tồn kho. Hệ thống sẽ kiểm tra lại tình trạng cuốn sách tại thời điểm đặt hàng.</p>
   <form method="get" action="${base}/checkout/shipping"><button type="submit" class="checkout-button" ${cart.availableCount == 0 or cart.unavailableCount > 0 ? 'disabled' : ''}>Tiến hành đặt hàng →</button></form>
  </aside>
 </div>
</c:otherwise></c:choose>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
