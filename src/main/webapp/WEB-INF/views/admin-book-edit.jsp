<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Chỉnh sửa sách MS-<c:out value="${book.id}"/> · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/cart.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/checkout.js"></script></head>
<body class="cart-page" data-base="${base}"><main class="cart-shell">
<header class="cart-header">
 <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
 <a href="${base}/admin#books-section">← Quay lại Dashboard Quản trị</a>
 <div class="header-links"><a class="cart-link" href="${base}/books/${book.id}">Xem trang khách hàng ↗</a><shop:notifications/><a href="${base}/account"><c:out value="${displayName}"/></a></div>
</header>

<c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
<c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

<section class="panel admin-section">
 <div class="panel-top">
  <div>
   <span class="eyebrow">CHỈNH SỬA ĐẦU SÁCH · MS-<c:out value="${book.id}"/></span>
   <h1><c:out value="${book.title}"/></h1>
  </div>
  <form method="post" action="${base}/admin/books/${book.id}/delete" class="inline-form" data-confirm-cancel>
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <button type="submit" class="remove-button">🗑 Xóa đầu sách này</button>
  </form>
 </div>

 <form method="post" action="${base}/admin/books/${book.id}/update" class="admin-book-form">
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  <div class="form-row-4">
   <div class="field-group">
    <label>Tên sách <span>*</span></label>
    <input type="text" name="title" required value="<c:out value='${book.title}'/>">
   </div>
   <div class="field-group">
    <label>Danh mục <span>*</span></label>
    <select name="categoryId" required>
     <c:forEach items="${categories}" var="cat">
      <option value="${cat.id}" ${book.categoryId == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option>
     </c:forEach>
    </select>
   </div>
   <div class="field-group">
    <label>Tác giả (cách nhau dấu phẩy)</label>
    <input type="text" name="authorName" value="<c:out value='${book.authors}'/>">
   </div>
   <div class="field-group">
    <label>Nhà xuất bản</label>
    <input type="text" name="publisherName" value="<c:out value='${book.publisherName}'/>">
   </div>
  </div>
  <div class="form-row-4">
   <div class="field-group">
    <label>Năm xuất bản</label>
    <input type="number" name="publishYear" value="<c:out value='${book.publishYear}'/>">
   </div>
   <div class="field-group">
    <label>Người dịch</label>
    <input type="text" name="translator" value="<c:out value='${book.translator}'/>">
   </div>
   <div class="field-group">
    <label>ISBN</label>
    <input type="text" name="isbn" value="<c:out value='${book.isbn}'/>">
   </div>
   <div class="field-group">
    <label>Đường dẫn ảnh bìa</label>
    <input type="text" name="coverImage" value="<c:out value='${book.coverImage}'/>">
   </div>
  </div>
  <div class="field-group">
   <label>Mô tả chi tiết sách</label>
   <textarea name="description" rows="4" class="admin-textarea"><c:out value="${book.description}"/></textarea>
  </div>
  <button type="submit" class="checkout-button admin-submit-btn">Lưu thông tin đầu sách</button>
 </form>
</section>

<section id="copies-section" class="panel admin-section">
 <div class="panel-top">
  <div>
   <span class="eyebrow">CHỈ HIỂN THỊ & QUẢN LÝ BỞI STAFF / ADMIN</span>
   <h2>Quản lý Bản sách vật lý: Tình trạng (Như mới, Tốt, Khá), Giá nhập (CostPrice) & Giá bán (SalePrice)</h2>
  </div>
 </div>

 <div class="table-scroll">
  <table class="admin-table">
   <thead>
    <tr>
     <th>Mã bản sách</th>
     <th>Chi nhánh</th>
     <th>Tình trạng (Như mới, Tốt, Khá)</th>
     <th>Giá nhập (CostPrice - ₫)</th>
     <th>Giá bán (SalePrice - ₫)</th>
     <th>Trạng thái</th>
     <th>Ghi chú tình trạng</th>
     <th>Lưu / Xóa</th>
    </tr>
   </thead>
   <tbody>
    <c:forEach items="${book.copies}" var="cp">
     <tr>
      <td><code><c:out value="${cp.copyCode}"/></code></td>
      <td>
       <select name="storeId" form="edit-copy-${cp.copyId}">
        <c:forEach items="${stores}" var="st">
         <option value="${st.id}" ${cp.storeId == st.id ? 'selected' : ''}><c:out value="${st.name}"/></option>
        </c:forEach>
       </select>
      </td>
      <td>
       <select name="conditionId" form="edit-copy-${cp.copyId}">
        <c:forEach items="${conditions}" var="cond">
         <option value="${cond.id}" ${cp.conditionId == cond.id ? 'selected' : ''}><c:out value="${cond.name}"/></option>
        </c:forEach>
       </select>
      </td>
      <td><input type="number" name="costPrice" form="edit-copy-${cp.copyId}" value="${cp.costPrice}" min="0" step="1000" required></td>
      <td><input type="number" name="salePrice" form="edit-copy-${cp.copyId}" value="${cp.salePrice}" min="1000" step="1000" required></td>
      <td>
       <select name="status" form="edit-copy-${cp.copyId}">
        <option value="AVAILABLE" ${cp.status == 'AVAILABLE' ? 'selected' : ''}>AVAILABLE (Sẵn có)</option>
        <option value="RESERVED" ${cp.status == 'RESERVED' ? 'selected' : ''}>RESERVED (Đang giữ)</option>
        <option value="SOLD" ${cp.status == 'SOLD' ? 'selected' : ''}>SOLD (Đã bán)</option>
        <option value="DAMAGED" ${cp.status == 'DAMAGED' ? 'selected' : ''}>DAMAGED (Hư hỏng)</option>
       </select>
      </td>
      <td><input type="text" name="conditionNotes" form="edit-copy-${cp.copyId}" value="<c:out value='${cp.conditionNotes}'/>"></td>
      <td class="staff-row-actions">
       <form id="edit-copy-${cp.copyId}" method="post" action="${base}/admin/books/${book.id}/copies/${cp.copyId}/update" class="inline-form">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit">Lưu</button>
       </form>
       <form method="post" action="${base}/admin/books/${book.id}/copies/${cp.copyId}/delete" class="inline-form">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <button type="submit" class="remove-button">Xóa</button>
       </form>
      </td>
     </tr>
    </c:forEach>
   </tbody>
  </table>
 </div>

 <form method="post" action="${base}/admin/books/${book.id}/copies/add" class="staff-add-copy-form">
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  <strong>+ Thêm bản sách vật lý mới:</strong>
  <select name="storeId" required>
   <c:forEach items="${stores}" var="st"><option value="${st.id}"><c:out value="${st.name}"/></option></c:forEach>
  </select>
  <select name="conditionId" required>
   <c:forEach items="${conditions}" var="cond"><option value="${cond.id}"><c:out value="${cond.name}"/></option></c:forEach>
  </select>
  <input type="number" name="costPrice" min="0" step="1000" required placeholder="Giá nhập (CostPrice)">
  <input type="number" name="salePrice" min="1000" step="1000" required placeholder="Giá bán (SalePrice)">
  <input type="text" name="conditionNotes" placeholder="Ghi chú tình trạng…">
  <button type="submit">+ Thêm bản sách</button>
 </form>
</section>
<footer><span>Mộc Sách.</span>Hệ thống quản trị chuỗi cửa hàng sách cũ.<a href="${base}/admin">Về Dashboard</a></footer>
</main><div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
