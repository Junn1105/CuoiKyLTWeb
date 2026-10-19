<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Đơn hàng của tôi · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/home">← Tiếp tục khám phá sách</a><div class="header-links"><a class="cart-link" href="${base}/cart">Giỏ hàng<c:if test="${cartCount > 0}"> (<c:out value="${cartCount}"/>)</c:if></a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="cart-breadcrumb" aria-label="Đường dẫn"><a href="${base}/home">Trang chủ</a><span>›</span><span>Đơn hàng của tôi</span></nav>
<div class="cart-heading"><span class="eyebrow">THEO DÕI ĐƠN SÁCH</span><h1>Đơn hàng của tôi <small>(<c:out value="${orders.size()}"/> đơn)</small></h1><p>Quản lý đơn hàng, in hóa đơn hoặc hủy đơn khi chưa xuất kho.</p></div>

<c:choose>
 <c:when test="${empty orders}">
  <section class="panel empty-cart"><h2>Bạn chưa có đơn hàng nào</h2><p class="hint">Hãy chọn một cuốn sách yêu thích và bấm Mua ngay để trải nghiệm giao nhanh qua Shopee Express nhé.</p><a class="primary-link" href="${base}/home">Khám phá sách ngay →</a></section>
 </c:when>
 <c:otherwise>
  <div class="orders-list">
   <c:forEach items="${orders}" var="o">
    <article class="panel order-card">
     <div class="order-card-head">
      <div>
       <strong>Mã đơn: <a href="${base}/orders/${o.orderId}"><c:out value="${o.orderCode}"/></a></strong>
       <span class="order-date">Đặt lúc <c:out value="${o.createdAt}"/> · <c:out value="${o.itemCount}"/> cuốn</span>
      </div>
      <span class="status-badge ${o.status == 'CANCELLED' ? 'warn' : 'ok'}"><c:out value="${o.statusLabel}"/></span>
     </div>
     <div class="order-card-body">
      <div>
       <p><strong>Người nhận:</strong> <c:out value="${o.recipientName}"/> (<c:out value="${o.recipientPhone}"/>)</p>
       <p><strong>Thanh toán:</strong> <c:out value="${o.paymentMethodLabel}"/> · <em><c:out value="${o.paymentStatusLabel}"/></em></p>
       <p><strong>Dự kiến giao hàng tới:</strong> <c:out value="${o.estimatedDelivery}"/> (Shopee Express)</p>
      </div>
      <div class="order-card-total">
       <span>Tổng thanh toán</span>
       <strong><c:out value="${o.totalAmountLabel}"/></strong>
      </div>
     </div>
     <div class="post-payment-actions">
      <a class="action-btn primary" href="${base}/orders/${o.orderId}">📄 Xem thông tin đơn hàng</a>
      <a class="action-btn secondary" href="${base}/orders/${o.orderId}/invoice" target="_blank" rel="noopener">🖨 In hóa đơn</a>
      <c:if test="${o.canCancel}">
       <form method="post" action="${base}/orders/${o.orderId}/cancel" class="inline-form" data-confirm-cancel>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit" class="action-btn danger">✕ Hủy đơn hàng</button>
       </form>
      </c:if>
     </div>
    </article>
   </c:forEach>
  </div>
 </c:otherwise>
</c:choose>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
