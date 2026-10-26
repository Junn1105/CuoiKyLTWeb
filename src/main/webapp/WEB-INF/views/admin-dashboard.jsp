<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Dashboard Quản trị Cửa hàng · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header">
 <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
 <div class="admin-nav-pills">
  <a class="cart-link" href="#stats-section">📊 Thống kê</a>
  <a class="cart-link" href="#orders-section">📦 Quản lý đơn hàng (${stats.totalOrders})</a>
  <a class="cart-link" href="#books-section">📚 Quản lý sách & Giá (${stats.totalBooks})</a>
  <a class="cart-link" href="${base}/admin/stores" style="background:#fef3c7;color:#92400e;border:1px solid #fde68a;font-weight:700;">🏬 Chuỗi Cửa Hàng & Điều Chuyển Kho →</a>
 </div>
 <div class="header-links"><a href="${base}/home">← Về trang khách hàng</a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div>
</header>

<div class="cart-heading">
 <span class="eyebrow">PHÂN HỆ DÀNH RIÊNG CHO STAFF & ADMIN</span>
 <h1>Dashboard Thống kê & Quản trị Chuỗi Cửa Hàng Mộc Sách</h1>
 <p>Quản lý doanh thu, đơn hàng, thêm/sửa/xóa sách, tình trạng sách (Như mới, Tốt, Khá), giá nhập (CostPrice) và giá bán (SalePrice).</p>
</div>

<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

<section id="stats-section" class="admin-section">
 <div class="kpi-grid">
  <article class="panel kpi-card">
   <span class="eyebrow">TỔNG DOANH THU ĐƠN HÀNG</span>
   <strong class="kpi-value red"><c:out value="${stats.totalRevenueLabel}"/></strong>
   <small>Lợi nhuận gộp ước tính: <strong><c:out value="${stats.totalProfitLabel}"/></strong></small>
  </article>
  <article class="panel kpi-card">
   <span class="eyebrow">GIÁ TRỊ KHO THEO GIÁ NHẬP (COSTPRICE)</span>
   <strong class="kpi-value"><c:out value="${stats.inventoryCostLabel}"/></strong>
   <small>Tổng giá bán niêm yết (SalePrice): <strong><c:out value="${stats.inventorySaleLabel}"/></strong></small>
  </article>
  <article class="panel kpi-card">
   <span class="eyebrow">ĐƠN HÀNG TOÀN CHUỖI</span>
   <strong class="kpi-value blue"><c:out value="${stats.totalOrders}"/> đơn</strong>
   <small>Đang xử lý / chờ giao: <strong><c:out value="${stats.pendingOrders}"/> đơn</strong></small>
  </article>
  <article class="panel kpi-card">
   <span class="eyebrow">ĐẦU SÁCH & BẢN SÁCH VẬT LÝ</span>
   <strong class="kpi-value"><c:out value="${stats.totalBooks}"/> đầu sách</strong>
   <small>Còn sẵn trên kệ: <strong><c:out value="${stats.availableCopies}"/> / <c:out value="${stats.totalCopies}"/> bản</strong></small>
  </article>
 </div>

 <div class="admin-two-col">
  <section class="panel">
   <h2>Thống kê theo Chi nhánh cửa hàng</h2>
   <div class="table-scroll">
    <table class="admin-table">
     <thead>
      <tr>
       <th>Chi nhánh</th>
       <th>Tồn khả dụng</th>
       <th>Tổng Giá nhập (CostPrice)</th>
       <th>Tổng Giá bán (SalePrice)</th>
       <th>Đơn hàng</th>
       <th>Doanh thu</th>
      </tr>
     </thead>
     <tbody>
      <c:forEach items="${stats.storeStats}" var="st">
       <tr>
        <td><strong><c:out value="${st.storeName}"/></strong><br><small class="muted"><c:out value="${st.storeCode}"/> · <c:out value="${st.status}"/></small></td>
        <td><strong><c:out value="${st.availableCopies}"/></strong> bản</td>
        <td><c:out value="${st.costValueLabel}"/></td>
        <td><c:out value="${st.saleValueLabel}"/></td>
        <td><c:out value="${st.orderCount}"/></td>
        <td class="price-col"><c:out value="${st.revenueLabel}"/></td>
       </tr>
      </c:forEach>
     </tbody>
    </table>
   </div>
  </section>

  <section class="panel">
   <h2>Thống kê theo Tình trạng sách (Như mới, Tốt, Khá…)</h2>
   <div class="table-scroll">
    <table class="admin-table">
     <thead>
      <tr>
       <th>Tình trạng</th>
       <th>Tổng bản sách</th>
       <th>Sẵn có</th>
       <th>Giá nhập TB (CostPrice)</th>
       <th>Giá bán TB (SalePrice)</th>
      </tr>
     </thead>
     <tbody>
      <c:forEach items="${stats.conditionStats}" var="cs">
       <tr>
        <td><span class="status-badge ok"><c:out value="${cs.conditionName}"/></span></td>
        <td><c:out value="${cs.totalCopies}"/> bản</td>
        <td><strong><c:out value="${cs.availableCopies}"/></strong> bản</td>
        <td><c:out value="${cs.avgCostLabel}"/></td>
        <td class="price-col"><c:out value="${cs.avgSaleLabel}"/></td>
       </tr>
      </c:forEach>
     </tbody>
    </table>
   </div>
  </section>
 </div>
</section>

<section id="orders-section" class="panel admin-section">
 <div class="panel-top">
  <div>
   <span class="eyebrow">VẬN HÀNH ĐƠN HÀNG SHOPEE EXPRESS</span>
   <h2>Quản lý Đơn hàng toàn chuỗi (<c:out value="${orders.size()}"/> đơn)</h2>
  </div>
  <form method="get" action="${base}/admin#orders-section" class="filter-bar">
   <select name="orderStatus">
    <option value="ALL" ${orderStatus == 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
    <option value="PENDING" ${orderStatus == 'PENDING' ? 'selected' : ''}>Chờ xác nhận (PENDING)</option>
    <option value="CONFIRMED" ${orderStatus == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận (CONFIRMED)</option>
    <option value="PROCESSING" ${orderStatus == 'PROCESSING' ? 'selected' : ''}>Đang đóng gói (PROCESSING)</option>
    <option value="SHIPPED" ${orderStatus == 'SHIPPED' ? 'selected' : ''}>Đang giao SPX (SHIPPED)</option>
    <option value="COMPLETED" ${orderStatus == 'COMPLETED' ? 'selected' : ''}>Đã giao thành công (COMPLETED)</option>
    <option value="CANCELLED" ${orderStatus == 'CANCELLED' ? 'selected' : ''}>Đã hủy (CANCELLED)</option>
   </select>
   <button type="submit">Lọc đơn</button>
  </form>
 </div>
 <div class="table-scroll">
  <table class="admin-table">
   <thead>
    <tr>
     <th>Mã đơn / Ngày đặt</th>
     <th>Khách nhận & Địa chỉ</th>
     <th>Dự kiến giao tới</th>
     <th>Giá vốn (CostPrice)</th>
     <th>Tổng thu</th>
     <th>Thanh toán</th>
     <th>Trạng thái & Cập nhật</th>
     <th>Hóa đơn</th>
    </tr>
   </thead>
   <tbody>
    <c:choose>
     <c:when test="${empty orders}">
      <tr><td colspan="8" class="empty-cell">Chưa có đơn hàng nào khớp bộ lọc.</td></tr>
     </c:when>
     <c:otherwise>
      <c:forEach items="${orders}" var="o">
       <tr>
        <td>
         <strong><c:out value="${o.orderCode}"/></strong><br>
         <small class="muted"><c:out value="${o.createdAt}"/> · <c:out value="${o.itemCount}"/> cuốn</small>
        </td>
        <td>
         <strong><c:out value="${o.recipientName}"/></strong> (<c:out value="${o.recipientPhone}"/>)<br>
         <small class="muted"><c:out value="${o.shippingAddress}"/></small>
        </td>
        <td><strong><c:out value="${o.estimatedDelivery}"/></strong></td>
        <td><c:out value="${o.totalCostLabel}"/></td>
        <td class="price-col"><c:out value="${o.totalAmountLabel}"/></td>
        <td>
         <c:out value="${o.paymentMethodLabel}"/><br>
         <span class="status-badge ${o.paymentStatusLabel == 'Đã thanh toán' ? 'ok' : 'warn'}"><c:out value="${o.paymentStatusLabel}"/></span>
        </td>
        <td>
         <form method="post" action="${base}/admin/orders/${o.orderId}/status" class="status-inline-form">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
          <select name="status">
           <option value="PENDING" ${o.status == 'PENDING' ? 'selected' : ''}>Chờ xác nhận</option>
           <option value="CONFIRMED" ${o.status == 'CONFIRMED' ? 'selected' : ''}>Đã xác nhận</option>
           <option value="PROCESSING" ${o.status == 'PROCESSING' ? 'selected' : ''}>Đang đóng gói</option>
           <option value="SHIPPED" ${o.status == 'SHIPPED' ? 'selected' : ''}>Đang giao SPX</option>
           <option value="COMPLETED" ${o.status == 'COMPLETED' ? 'selected' : ''}>Hoàn tất</option>
           <option value="CANCELLED" ${o.status == 'CANCELLED' ? 'selected' : ''}>Hủy đơn</option>
          </select>
          <button type="submit">Lưu</button>
         </form>
        </td>
        <td>
         <a class="outline-button" href="${base}/orders/${o.orderId}/invoice" target="_blank" rel="noopener">🖨 In</a>
        </td>
       </tr>
      </c:forEach>
     </c:otherwise>
    </c:choose>
   </tbody>
  </table>
 </div>
</section>

<section id="books-section" class="panel admin-section">
 <div class="panel-top">
  <div>
   <span class="eyebrow">QUẢN LÝ ĐẦU SÁCH & BẢN SÁCH VẬT LÝ</span>
   <h2>Thêm sách mới (Kèm Tình trạng, Giá nhập CostPrice & Giá bán SalePrice)</h2>
  </div>
 </div>
 <form method="post" action="${base}/admin/books/create" class="admin-book-form">
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  <div class="form-row-4">
   <div class="field-group">
    <label>Tên đầu sách <span>*</span></label>
    <input type="text" name="title" required minlength="2" maxlength="255" placeholder="Nhập tên sách…">
   </div>
   <div class="field-group">
    <label>Danh mục <span>*</span></label>
    <select name="categoryId" required>
     <c:forEach items="${categories}" var="cat"><option value="${cat.id}"><c:out value="${cat.name}"/></option></c:forEach>
    </select>
   </div>
   <div class="field-group">
    <label>Tác giả <span>*</span></label>
    <input type="text" name="authorName" required placeholder="Ví dụ: Nguyễn Nhật Ánh">
   </div>
   <div class="field-group">
    <label>Nhà xuất bản</label>
    <input type="text" name="publisherName" value="NXB Trẻ" placeholder="Ví dụ: NXB Trẻ">
   </div>
  </div>
  <div class="form-row-4">
   <div class="field-group">
    <label>Chi nhánh nhập kho <span>*</span></label>
    <select name="storeId" required>
     <c:forEach items="${stores}" var="st"><option value="${st.id}"><c:out value="${st.name}"/></option></c:forEach>
    </select>
   </div>
   <div class="field-group">
    <label>Tình trạng (Như mới, Tốt, Khá) <span>*</span></label>
    <select name="conditionId" required>
     <c:forEach items="${conditions}" var="cond"><option value="${cond.id}"><c:out value="${cond.name}"/></option></c:forEach>
    </select>
   </div>
   <div class="field-group">
    <label>Giá nhập (CostPrice - ₫) <span>*</span></label>
    <input type="number" name="costPrice" min="0" step="1000" value="35000" required>
   </div>
   <div class="field-group">
    <label>Giá bán (SalePrice - ₫) <span>*</span></label>
    <input type="number" name="salePrice" min="1000" step="1000" value="65000" required>
   </div>
  </div>
  <div class="form-row-4">
   <div class="field-group">
    <label>Năm xuất bản</label>
    <input type="number" name="publishYear" min="1900" max="2030" value="2022">
   </div>
   <div class="field-group">
    <label>ISBN</label>
    <input type="text" name="isbn" placeholder="978-604-...">
   </div>
   <div class="field-group">
    <label>Số lượng bản nhập</label>
    <input type="number" name="copyQuantity" min="1" max="20" value="2">
   </div>
   <div class="field-group">
    <label>Mô tả ngắn</label>
    <input type="text" name="description" placeholder="Giới thiệu nội dung và tình trạng sách…">
   </div>
  </div>
  <button type="submit" class="checkout-button admin-submit-btn">+ Thêm đầu sách & Nhập kho ngay</button>
 </form>

 <hr class="admin-divider">

 <div class="panel-top">
  <h2>Danh sách đầu sách hiện có (<c:out value="${books.size()}"/> đầu sách)</h2>
  <form method="get" action="${base}/admin#books-section" class="filter-bar">
   <select name="category">
    <option value="0">Tất cả danh mục</option>
    <c:forEach items="${categories}" var="cat"><option value="${cat.id}" ${category == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option></c:forEach>
   </select>
   <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm mã sách, tên sách, ISBN…">
   <button type="submit">Tìm sách</button>
  </form>
 </div>

 <div class="table-scroll">
  <table class="admin-table">
   <thead>
    <tr>
     <th>Mã</th>
     <th>Bìa</th>
     <th>Tên sách & Danh mục</th>
     <th>NXB / Năm</th>
     <th>Tồn kho</th>
     <th>Giá nhập từ (CostPrice)</th>
     <th>Giá bán từ (SalePrice)</th>
     <th>Thao tác (Staff / Admin)</th>
    </tr>
   </thead>
   <tbody>
    <c:forEach items="${books}" var="b">
     <tr>
      <td><code>MS-<c:out value="${b.id}"/></code></td>
      <td><img src="${base}<c:out value='${b.cover}'/>" alt="" width="38" height="52" data-cover></td>
      <td>
       <strong><a href="${base}/books/${b.id}"><c:out value="${b.title}"/></a></strong><br>
       <small class="muted"><c:out value="${b.categoryName}"/> · ISBN: <c:out value="${b.isbn}"/></small>
      </td>
      <td><c:out value="${b.publisherName}"/><br><small class="muted">Năm: <c:out value="${b.publishYear}"/></small></td>
      <td><strong><c:out value="${b.availableCopies}"/></strong> / <c:out value="${b.totalCopies}"/> bản</td>
      <td><strong><c:out value="${b.minCostLabel}"/></strong></td>
      <td class="price-col"><c:out value="${b.minSaleLabel}"/></td>
      <td class="staff-row-actions">
       <a class="outline-button" href="${base}/admin/books/${b.id}/edit">✎ Sửa / Quản lý Giá & Tình trạng</a>
       <form method="post" action="${base}/admin/books/${b.id}/delete" class="inline-form" data-confirm-cancel>
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit" class="remove-button">🗑 Xóa</button>
       </form>
      </td>
     </tr>
    </c:forEach>
   </tbody>
  </table>
 </div>
</section>
<footer><span>Mộc Sách.</span>Hệ thống quản trị chuỗi cửa hàng sách cũ.<a href="${base}/home">Về trang chủ</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
