<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Phương thức thanh toán · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/checkout/shipping">← Quay lại bước giao hàng</a><div class="header-links"><a class="cart-link" href="${base}/cart">Giỏ hàng (<c:out value="${cartCount}"/>)</a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="checkout-steps" aria-label="Tiến trình đặt hàng">
 <a class="step done" href="${base}/checkout/shipping"><span class="step-num">✓</span><span>Giao hàng & Địa chỉ</span></a>
 <span class="step-line active"></span>
 <div class="step active"><span class="step-num">2</span><span>Phương thức thanh toán</span></div>
 <span class="step-line"></span>
 <div class="step"><span class="step-num">3</span><span>Xác nhận & Hoàn tất</span></div>
</nav>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>
<div class="cart-grid">
 <section class="panel checkout-main">
  <div class="shipping-recap">
   <div>
    <span class="eyebrow">THÔNG TIN NHẬN HÀNG (SHOPEE EXPRESS · DỰ KIẾN GIAO TỚI: <c:out value="${summary.estimatedDelivery}"/>)</span>
    <strong><c:out value="${shipping.recipientName}"/> · <c:out value="${shipping.recipientPhone}"/></strong>
    <p><c:out value="${shipping.addressLine}"/>, <c:out value="${shipping.administrativeArea}"/><c:if test="${not empty shipping.note}"> · Ghi chú: <c:out value="${shipping.note}"/></c:if></p>
   </div>
   <a class="outline-button" href="${base}/checkout/shipping">Thay đổi</a>
  </div>

  <form id="payment-form" method="post" action="${base}/checkout/payment" class="checkout-form">
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <h2>Chọn phương thức thanh toán</h2>
   <div class="payment-options">
    <label class="payment-card selected" data-payment-card>
     <input type="radio" name="paymentMethod" value="BANK_TRANSFER" checked>
     <span class="payment-icon">🏦</span>
     <div class="payment-body">
      <strong>Chuyển khoản ngân hàng (Mã QR Vietcombank)</strong>
      <p>Quét mã VietQR Napas 247 Vietcombank chính thức ở bước tiếp theo để thanh toán nhanh chóng, chính xác.</p>
     </div>
    </label>
    <label class="payment-card" data-payment-card>
     <input type="radio" name="paymentMethod" value="CASH">
     <span class="payment-icon">💵</span>
     <div class="payment-body">
      <strong>Tiền mặt khi nhận hàng (COD)</strong>
      <p>Thanh toán trực tiếp bằng tiền mặt cho bưu tá Shopee Express sau khi nhận và kiểm tra sách.</p>
     </div>
    </label>
   </div>
   <div class="checkout-actions">
    <a class="outline-button" href="${base}/checkout/shipping">← Quay lại</a>
    <button type="submit" class="checkout-button">Tiếp theo →</button>
   </div>
  </form>
 </section>

 <aside class="panel cart-summary">
  <h2>Tóm tắt thanh toán</h2>
  <div class="mini-item-list">
   <c:forEach items="${summary.items}" var="item">
    <div class="mini-item">
     <img src="${base}<c:out value='${item.cover}'/>" alt="" width="44" height="60" data-cover>
     <div>
      <strong><c:out value="${item.title}"/></strong>
      <small>Mã: <c:out value="${item.copyCode}"/> · <c:out value="${item.conditionName}"/></small>
     </div>
     <span><c:out value="${item.priceLabel}"/></span>
    </div>
   </c:forEach>
  </div>
  <dl class="summary-rows">
   <div><dt>Tạm tính (<c:out value="${summary.totalCount}"/> cuốn)</dt><dd><c:out value="${summary.subtotalLabel}"/></dd></div>
   <div><dt>Giao nhanh Shopee Express</dt><dd><c:out value="${summary.shippingFeeLabel}"/></dd></div>
   <div><dt>Dự kiến giao hàng tới</dt><dd><c:out value="${summary.estimatedDelivery}"/></dd></div>
   <div class="total-row"><dt>Tổng thanh toán</dt><dd><strong><c:out value="${summary.totalAmountLabel}"/></strong></dd></div>
  </dl>
  <button type="submit" form="payment-form" class="checkout-button">Tiếp theo →</button>
 </aside>
</div>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
