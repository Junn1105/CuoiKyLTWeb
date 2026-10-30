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

<section class="panel qr-checkout-panel" data-order-id="${order.orderId}" data-order-status="${order.status}">
 <div class="qr-card-frame ${order.status == 'CANCELLED' ? 'cancelled' : ''}">
  <img src="${base}/images/vietcombank-qr.png" alt="Mã QR Vietcombank NGUYEN PHUOC SANG 1050241186" class="qr-image" width="320" height="480">
  <c:if test="${order.status == 'CANCELLED'}">
   <div class="qr-cancelled-overlay">ĐÃ HỦY ĐƠN HÀNG</div>
  </c:if>
 </div>
 <div class="qr-details">
  <span class="eyebrow">CHUYỂN KHOẢN VIETQR NAPAS 247</span>
  <h1>Thanh toán đơn hàng <c:out value="${order.orderCode}"/></h1>
   <c:choose>
   <c:when test="${order.status == 'CANCELLED'}">
    <p class="hint" style="color:#b91c1c;">Đơn hàng này đã bị hủy. Mã QR không còn hiệu lực thanh toán.</p>
   </c:when>
   <c:otherwise>
    <p class="hint">Mở ứng dụng ngân hàng hoặc ví điện tử bất kỳ để quét mã QR bên trái với thông tin chuyển khoản bên dưới:</p>
   </c:otherwise>
  </c:choose>

  <dl class="bank-transfer-box">
   <div><dt>Ngân hàng thụ hưởng</dt><dd><strong>Vietcombank · CN Kỳ Đồng</strong></dd></div>
   <div><dt>Chủ tài khoản</dt><dd><strong>NGUYEN PHUOC SANG</strong></dd></div>
   <div><dt>Số tài khoản</dt><dd><strong>1050241186</strong></dd></div>
   <div><dt>Số tiền thanh toán</dt><dd class="amount-highlight"><c:out value="${order.isMultiStore ? order.groupTotalAmountLabel : order.totalAmountLabel}"/></dd></div>
   <div><dt>Nội dung chuyển khoản</dt><dd><code class="transfer-code"><c:out value="${order.isMultiStore ? order.baseOrderCode : order.orderCode}"/></code></dd></div>
   <div><dt>Dự kiến giao hàng tới</dt><dd><strong><c:out value="${order.estimatedDelivery}"/></strong> (Shopee Express)</dd></div>
   <div><dt>Trạng thái đơn hàng</dt><dd><span class="status-badge ${order.status == 'CANCELLED' ? 'warn' : 'ok'}"><c:out value="${order.statusLabel}"/></span></dd></div>
   <div><dt>Trạng thái thanh toán</dt><dd><span class="status-badge ${order.payment.isPaid ? 'ok' : 'warn'}"><c:out value="${order.payment.statusLabel}"/></span></dd></div>
  </dl>

  <c:if test="${order.isMultiStore}">
   <div style="margin-bottom:16px; padding:12px 16px; background:#f0f9ff; border:1px solid #bae6fd; border-radius:8px;">
    <strong style="font-size:13px; color:#0369a1;">📦 Đơn hàng gồm <c:out value="${order.siblingOrders.size()}"/> kiện hàng từ các chi nhánh:</strong>
    <ul style="margin:6px 0 0; padding-left:18px; font-size:12.5px; color:#0c4a6e;">
     <c:forEach items="${order.siblingOrders}" var="sib">
      <li style="margin-bottom:3px;">
       <strong><c:out value="${sib.storeName}"/></strong> (<c:out value="${sib.orderCode}"/>): <c:out value="${sib.totalAmountLabel}"/> &bull; <em><c:out value="${sib.statusLabel}"/></em>
      </li>
     </c:forEach>
    </ul>
    <p style="margin:6px 0 0; font-size:12px; color:#0284c7;">Quý khách chỉ cần quét mã QR 1 lần cho toàn bộ đơn hàng tổng. Hệ thống sẽ tự động xác nhận và thông báo cho từng chi nhánh.</p>
   </div>
  </c:if>

  <c:choose>
   <c:when test="${order.status == 'CANCELLED'}">
    <div class="expired-banner" role="alert">
     <strong>✕ Đơn hàng đã bị hủy</strong>
     <p>Đơn hàng <c:out value="${order.orderCode}"/> đã bị hủy do quá thời gian chờ hoàn tất thanh toán (15 phút) hoặc theo yêu cầu. Các cuốn sách đã được hoàn lại kệ hàng. Nếu vẫn muốn mua sách, bạn vui lòng tạo đơn hàng mới.</p>
    </div>
   </c:when>
   <c:when test="${order.payment.isPaid or order.status == 'CONFIRMED' or order.status == 'PROCESSING' or order.status == 'SHIPPED' or order.status == 'COMPLETED'}">
    <div class="paid-banner">
     <strong>✓ Đơn hàng đã được xác nhận!</strong>
     <p>Đơn hàng <c:out value="${order.orderCode}"/> đang được chuẩn bị để bàn giao cho <strong>Shopee Express (SPX)</strong>.</p>
    </div>
   </c:when>
   <c:otherwise>
    <div class="order-countdown-box" id="qr-countdown-box" data-remaining="${order.remainingSeconds}">
     <div class="countdown-badge">
      <span class="countdown-icon">⏳</span>
      <div class="countdown-info">
       <div class="countdown-title">Thời gian chờ hoàn tất đơn hàng: <strong id="countdown-timer" class="countdown-timer"><c:out value="${order.remainingTimeLabel}"/></strong></div>
       <p class="countdown-desc">Vui lòng quét mã VietQR và chuyển khoản đúng số tiền <strong><c:out value="${order.isMultiStore ? order.groupTotalAmountLabel : order.totalAmountLabel}"/></strong> trước khi hết thời gian chờ. Hệ thống sẽ tự động hủy đơn hàng và hoàn sách lại kho nếu không hoàn tất thanh toán.</p>
      </div>
     </div>
    </div>
    <div class="bank-instruction-note" style="margin: 10px 0 16px; font-size: 13px; color: #475569; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px;">
     ℹ️ Sau khi bạn chuyển khoản với nội dung <code><c:out value="${order.isMultiStore ? order.baseOrderCode : order.orderCode}"/></code>, nhân viên Mộc Sách sẽ kiểm tra và xác nhận đơn hàng cho bạn.
    </div>
    <div class="qr-auto-check-notice" id="qr-auto-check-notice">
     <span class="pulse-dot"></span>
     <span>Hệ thống đang tự động kiểm tra trạng thái thanh toán mỗi 5 giây. Khi nhân viên xác nhận hoặc chuẩn bị hàng, hệ thống sẽ tự động chuyển sang trang chi tiết đơn hàng.</span>
    </div>
   </c:otherwise>
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
