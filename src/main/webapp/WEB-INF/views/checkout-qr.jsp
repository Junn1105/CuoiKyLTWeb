<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Thanh toán mã QR · <c:out value="${order.orderCode}"/> · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/orders/${order.orderId}">← Chi tiết đơn hàng</a><div class="header-links"><a class="cart-link" href="${base}/orders">Đơn hàng của tôi</a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="checkout-steps" aria-label="Tiến trình đặt hàng">
 <div class="step done"><span class="step-num">✓</span><span>Giao hàng & Địa chỉ</span></div>
 <span class="step-line active"></span>
 <div class="step done"><span class="step-num">✓</span><span>Phương thức thanh toán</span></div>
 <span class="step-line active"></span>
 <div class="step active"><span class="step-num">3</span><span>Quét mã QR & Hoàn tất</span></div>
</nav>
<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

<section class="panel qr-checkout-panel">
 <div class="qr-card-frame">
  <img src="${base}/images/vietcombank-qr.png" alt="Mã QR Vietcombank NGUYEN PHUOC SANG 1050241186" class="qr-image" width="320" height="480">
 </div>
 <div class="qr-details">
  <span class="eyebrow">CHUYỂN KHOẢN VIETQR NAPAS 247</span>
  <h1>Thanh toán đơn hàng <c:out value="${order.orderCode}"/></h1>
  <p class="hint">Mở ứng dụng ngân hàng hoặc ví điện tử bất kỳ để quét mã QR bên trái với thông tin chuyển khoản bên dưới:</p>

  <dl class="bank-transfer-box">
   <div><dt>Ngân hàng thụ hưởng</dt><dd><strong>Vietcombank · CN Kỳ Đồng</strong></dd></div>
   <div><dt>Chủ tài khoản</dt><dd><strong>NGUYEN PHUOC SANG</strong></dd></div>
   <div><dt>Số tài khoản</dt><dd><strong>1050241186</strong></dd></div>
   <div><dt>Số tiền thanh toán</dt><dd class="amount-highlight"><c:out value="${order.totalAmountLabel}"/></dd></div>
   <div><dt>Nội dung chuyển khoản</dt><dd><code class="transfer-code"><c:out value="${order.orderCode}"/></code></dd></div>
   <div><dt>Dự kiến giao hàng tới</dt><dd><strong><c:out value="${order.estimatedDelivery}"/></strong> (Shopee Express)</dd></div>
   <div><dt>Trạng thái thanh toán</dt><dd><span class="status-badge ${order.payment.isPaid ? 'ok' : 'warn'}"><c:out value="${order.payment.statusLabel}"/></span></dd></div>
  </dl>

  <c:choose>
   <c:when test="${not order.payment.isPaid and order.status != 'CANCELLED'}">
    <form method="post" action="${base}/checkout/qr/${order.orderId}/confirm" class="qr-confirm-form">
     <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
     <button type="submit" class="confirm-paid-btn">✓ Xác nhận thanh toán thành công</button>
    </form>
    <p class="hint">Sau khi chuyển khoản xong, bấm nút <strong>Xác nhận thanh toán thành công</strong> để hệ thống ghi nhận đơn hàng.</p>
   </c:when>
   <c:when test="${order.payment.isPaid}">
    <div class="paid-banner">
     <strong>✓ Đã xác nhận thanh toán thành công!</strong>
     <p>Đơn hàng <c:out value="${order.orderCode}"/> đang được đóng gói để bàn giao cho <strong>Shopee Express (SPX)</strong>.</p>
    </div>
   </c:when>
  </c:choose>

  <div class="post-payment-actions">
   <a class="action-btn primary" href="${base}/orders/${order.orderId}">📄 Xem thông tin đơn hàng</a>
   <a class="action-btn secondary" href="${base}/orders/${order.orderId}/invoice" target="_blank" rel="noopener">🖨 In hóa đơn</a>
   <c:if test="${order.canCancel}">
    <form method="post" action="${base}/orders/${order.orderId}/cancel" class="inline-form" data-confirm-cancel>
     <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
     <button type="submit" class="action-btn danger">✕ Hủy đơn hàng</button>
    </form>
   </c:if>
  </div>
 </div>
</section>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
