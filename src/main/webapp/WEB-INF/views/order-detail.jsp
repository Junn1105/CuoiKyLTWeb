<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Đơn hàng <c:out value="${order.orderCode}"/> · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/orders">← Danh sách đơn hàng</a><div class="header-links"><a class="cart-link" href="${base}/cart">Giỏ hàng<c:if test="${cartCount > 0}"> (<c:out value="${cartCount}"/>)</c:if></a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="cart-breadcrumb" aria-label="Đường dẫn"><a href="${base}/home">Trang chủ</a><span>›</span><a href="${base}/orders">Đơn hàng của tôi</a><span>›</span><span><c:out value="${order.orderCode}"/></span></nav>
<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

<section class="panel order-hero-bar">
 <div>
  <span class="eyebrow">CHI TIẾT ĐƠN HÀNG · SHOPEE EXPRESS</span>
  <h1>Mã đơn: <c:out value="${order.orderCode}"/> <span class="status-badge ${order.status == 'CANCELLED' ? 'warn' : 'ok'}"><c:out value="${order.statusLabel}"/></span></h1>
  <p class="hint">Ngày đặt: <c:out value="${order.createdAt}"/> · Phương thức thanh toán: <strong><c:out value="${order.payment.methodLabel}"/></strong> (<c:out value="${order.payment.statusLabel}"/>)</p>
 </div>
 <div class="post-payment-actions">
  <a class="action-btn primary" href="#order-items-section">📄 Xem thông tin đơn hàng</a>
  <a class="action-btn secondary" href="${base}/orders/${order.orderId}/invoice" target="_blank" rel="noopener">🖨 In hóa đơn</a>
  <c:if test="${order.payment.isBankTransfer and not order.payment.isPaid and order.canCancel}">
   <a class="action-btn outline" href="${base}/checkout/qr/${order.orderId}">🏦 Quét mã QR thanh toán</a>
  </c:if>
  <c:if test="${order.canCancel}">
   <form method="post" action="${base}/orders/${order.orderId}/cancel" class="inline-form" data-confirm-cancel>
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <button type="submit" class="action-btn danger">✕ Hủy đơn hàng</button>
   </form>
  </c:if>
 </div>
</section>

<div class="cart-grid" id="order-items-section">
 <section class="panel cart-items-panel">
  <div class="panel-top">
   <h2>Sách trong đơn hàng (<c:out value="${order.itemCount}"/> cuốn)</h2>
   <span class="spx-badge">Giao nhanh Shopee Express</span>
  </div>
  <div class="cart-list">
   <c:forEach items="${order.items}" var="item">
    <article class="cart-item">
     <a class="item-cover" href="${base}/books/${item.bookId}"><img src="${base}<c:out value='${item.cover}'/>" alt="" width="96" height="136" data-cover></a>
     <div class="item-info">
      <h3><a href="${base}/books/${item.bookId}"><c:out value="${item.title}"/></a></h3>
      <dl class="item-meta">
       <div><dt>Mã bản sách</dt><dd><c:out value="${item.copyCode}"/></dd></div>
       <div><dt>Tình trạng</dt><dd><c:out value="${item.conditionName}"/></dd></div>
       <div><dt>Chi nhánh xuất kho</dt><dd><c:out value="${item.storeName}"/></dd></div>
      </dl>
     </div>
     <div class="item-actions">
      <strong class="item-price"><c:out value="${item.priceLabel}"/></strong>
     </div>
    </article>
   </c:forEach>
  </div>
 </section>

 <aside class="panel cart-summary">
  <h2>Thông tin giao nhận</h2>
  <dl class="summary-rows">
   <div><dt>Người nhận</dt><dd><c:out value="${order.recipientName}"/></dd></div>
   <div><dt>Số điện thoại</dt><dd><c:out value="${order.recipientPhone}"/></dd></div>
   <div><dt>Đơn vị vận chuyển</dt><dd>Shopee Express (SPX)</dd></div>
   <div><dt>Dự kiến giao hàng tới</dt><dd><strong><c:out value="${order.estimatedDelivery}"/></strong></dd></div>
  </dl>
  <p class="address-box"><c:out value="${order.shippingAddress}"/></p>

  <h2 class="section-gap">Chi tiết thanh toán</h2>
  <dl class="summary-rows">
   <div><dt>Tạm tính (<c:out value="${order.itemCount}"/> cuốn)</dt><dd><c:out value="${order.subtotalLabel}"/></dd></div>
   <div><dt>Phí giao hàng SPX</dt><dd><c:out value="${order.shippingFeeLabel}"/></dd></div>
   <div class="total-row"><dt>Tổng cộng</dt><dd><strong><c:out value="${order.totalAmountLabel}"/></strong></dd></div>
  </dl>
 </aside>
</div>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
