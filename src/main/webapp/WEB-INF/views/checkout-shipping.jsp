<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Giao hàng & Địa chỉ · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a href="${base}/cart">← Quay lại giỏ hàng</a><div class="header-links"><a class="cart-link" href="${base}/cart">Giỏ hàng (<c:out value="${cartCount}"/>)</a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div></header>
<nav class="checkout-steps" aria-label="Tiến trình đặt hàng">
 <div class="step active"><span class="step-num">1</span><span>Giao hàng & Địa chỉ</span></div>
 <span class="step-line"></span>
 <div class="step"><span class="step-num">2</span><span>Phương thức thanh toán</span></div>
 <span class="step-line"></span>
 <div class="step"><span class="step-num">3</span><span>Xác nhận & Hoàn tất</span></div>
</nav>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>
<div class="cart-grid">
 <section class="panel checkout-main">
  <form id="shipping-form" method="post" action="${base}/checkout/shipping" class="checkout-form">
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <h2>1. Chọn phương thức giao hàng</h2>
   <label class="carrier-card selected">
    <input type="radio" name="shippingMethod" value="SPX_EXPRESS" checked>
    <div class="carrier-body">
     <div class="carrier-top">
      <span class="spx-badge">Shopee Express</span>
      <strong>Giao hàng nhanh qua Shopee Express (SPX)</strong>
      <span class="carrier-fee"><c:out value="${summary.shippingFeeLabel}"/></span>
     </div>
     <p>Dự kiến giao hàng tới: <strong><c:out value="${summary.estimatedDelivery}"/></strong> · Bọc chống sốc 2 lớp · Đồng kiểm sách khi nhận hàng.</p>
    </div>
   </label>

   <h2 class="section-gap">2. Thông tin người nhận & Địa chỉ giao hàng</h2>
   <div class="form-row-2">
    <div class="field-group">
     <label for="recipientName">Họ và tên người nhận <span>*</span></label>
     <input id="recipientName" name="recipientName" type="text" required minlength="2" maxlength="150" placeholder="Ví dụ: Nguyễn Phước Sang" value="<c:out value='${shipping.recipientName}'/>">
    </div>
    <div class="field-group">
     <label for="recipientPhone">Số điện thoại nhận hàng <span>*</span></label>
     <input id="recipientPhone" name="recipientPhone" type="tel" required minlength="9" maxlength="15" inputmode="tel" placeholder="Ví dụ: 0901234567" value="<c:out value='${shipping.recipientPhone}'/>">
    </div>
   </div>
   <div class="field-group">
    <label for="administrativeArea">Tỉnh / Thành phố, Quận / Huyện, Phường / Xã <span>*</span></label>
    <input id="administrativeArea" name="administrativeArea" type="text" required minlength="3" maxlength="250" placeholder="Ví dụ: Phường Võ Thị Sáu, Quận 3, TP. Hồ Chí Minh" value="<c:out value='${shipping.administrativeArea}'/>">
   </div>
   <div class="field-group">
    <label for="addressLine">Địa chỉ cụ thể (Số nhà, ngõ/hẻm, tên đường, tòa nhà) <span>*</span></label>
    <input id="addressLine" name="addressLine" type="text" required minlength="4" maxlength="500" placeholder="Ví dụ: Số 120 đường Kỳ Đồng" value="<c:out value='${shipping.addressLine}'/>">
   </div>
   <div class="field-group">
    <label for="note">Ghi chú cho bưu tá Shopee Express (Tùy chọn)</label>
    <input id="note" name="note" type="text" maxlength="300" placeholder="Ví dụ: Giao trong giờ hành chính, gọi điện trước khi giao…" value="<c:out value='${shipping.note}'/>">
   </div>
   <div class="checkout-actions">
    <a class="outline-button" href="${base}/cart">← Giỏ hàng</a>
    <button type="submit" class="checkout-button">Tiếp theo: Phương thức thanh toán →</button>
   </div>
  </form>
 </section>

 <aside class="panel cart-summary">
  <h2>Đơn sách của bạn (<c:out value="${summary.totalCount}"/> cuốn)</h2>
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
   <div><dt>Phí giao nhanh (Shopee Express)</dt><dd><c:out value="${summary.shippingFeeLabel}"/></dd></div>
   <div><dt>Dự kiến giao hàng tới</dt><dd><c:out value="${summary.estimatedDelivery}"/></dd></div>
   <div class="total-row"><dt>Tổng thanh toán</dt><dd><strong><c:out value="${summary.totalAmountLabel}"/></strong></dd></div>
  </dl>
  <button type="submit" form="shipping-form" class="checkout-button">Tiếp theo →</button>
 </aside>
</div>
<footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
