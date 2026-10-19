<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hóa đơn <c:out value="${order.orderCode}"/> · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/checkout.js"></script></head>
<body class="invoice-page" data-base="${base}">
<div class="invoice-toolbar no-print">
 <div class="order-inline-actions">
  <a class="outline-button" href="${base}/orders/${order.orderId}">← Chi tiết đơn hàng</a>
  <c:if test="${isStaffOrAdmin}">
   <a class="outline-button" href="${base}/admin#orders-section">← Quản trị đơn hàng</a>
  </c:if>
 </div>
 <button type="button" class="checkout-button" data-print-invoice>🖨 In hóa đơn ngay</button>
</div>
<main class="invoice-sheet">
 <header class="invoice-header">
  <div class="invoice-brand">
   <img src="${base}/images/moc-sach-mark.svg" alt="" width="36" height="36">
   <div>
    <strong>MỘC SÁCH · CHUỖI CỬA HÀNG SÁCH CŨ</strong>
    <p>Chi nhánh: <c:out value="${order.storeName}"/> · <c:out value="${order.storeAddress}"/></p>
    <p>Hotline: <c:out value="${order.storePhone}"/> · Vận chuyển: Shopee Express (SPX)</p>
   </div>
  </div>
  <div class="invoice-meta">
   <h1>HÓA ĐƠN BÁN HÀNG</h1>
   <p>Mã đơn: <strong><c:out value="${order.orderCode}"/></strong></p>
   <p>Ngày lập: <c:out value="${order.createdAt}"/></p>
   <p>Trạng thái: <strong><c:out value="${order.statusLabel}"/></strong></p>
  </div>
 </header>

 <section class="invoice-customer">
  <div>
   <h3>Thông tin người nhận</h3>
   <p><strong>Họ và tên:</strong> <c:out value="${order.recipientName}"/></p>
   <p><strong>Số điện thoại:</strong> <c:out value="${order.recipientPhone}"/></p>
   <p><strong>Địa chỉ nhận hàng:</strong> <c:out value="${order.shippingAddress}"/></p>
   <p><strong>Dự kiến giao hàng tới:</strong> <c:out value="${order.estimatedDelivery}"/></p>
  </div>
  <div>
   <h3>Thông tin thanh toán</h3>
   <p><strong>Phương thức:</strong> <c:out value="${order.payment.methodLabel}"/></p>
   <p><strong>Trạng thái TT:</strong> <c:out value="${order.payment.statusLabel}"/></p>
   <c:if test="${not empty order.payment.transactionId}">
    <p><strong>Mã giao dịch:</strong> <c:out value="${order.payment.transactionId}"/></p>
   </c:if>
  </div>
 </section>

 <table class="invoice-table">
  <thead>
   <tr>
    <th>STT</th>
    <th>Mã bản sách</th>
    <th>Tên sách</th>
    <th>Tình trạng</th>
    <th>Chi nhánh</th>
    <th>Đơn giá</th>
   </tr>
  </thead>
  <tbody>
   <c:forEach items="${order.items}" var="item" varStatus="st">
    <tr>
     <td>${st.index + 1}</td>
     <td><code><c:out value="${item.copyCode}"/></code></td>
     <td><strong><c:out value="${item.title}"/></strong></td>
     <td><c:out value="${item.conditionName}"/></td>
     <td><c:out value="${item.storeName}"/></td>
     <td class="num"><c:out value="${item.priceLabel}"/></td>
    </tr>
   </c:forEach>
  </tbody>
  <tfoot>
   <tr><td colspan="5">Tạm tính (<c:out value="${order.itemCount}"/> cuốn)</td><td class="num"><c:out value="${order.subtotalLabel}"/></td></tr>
   <tr><td colspan="5">Phí giao hàng nhanh (Shopee Express - SPX)</td><td class="num"><c:out value="${order.shippingFeeLabel}"/></td></tr>
   <tr class="grand-total"><td colspan="5">TỔNG THANH TOÁN</td><td class="num"><c:out value="${order.totalAmountLabel}"/></td></tr>
  </tfoot>
 </table>

 <footer class="invoice-footer">
  <div>
   <strong>Người mua hàng</strong>
   <p>(Ký, ghi rõ họ tên)</p>
   <span class="sig-name"><c:out value="${order.recipientName}"/></span>
  </div>
  <div>
   <strong>Đại diện Mộc Sách</strong>
   <p>(Ký, đóng dấu xác nhận)</p>
   <span class="sig-name">Mộc Sách Bookstore</span>
  </div>
 </footer>
 <p class="invoice-thanks">Cảm ơn bạn đã đồng hành cùng Mộc Sách — Mỗi cuốn sách cũ đều xứng đáng được yêu thêm một lần!</p>
</main>
</body></html>
