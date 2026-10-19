<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><c:out value="${book.title}"/> · Mộc Sách</title><link rel="icon" href="${base}/images/moc-sach-mark.svg"><link rel="stylesheet" href="${base}/css/home.css"><link rel="stylesheet" href="${base}/css/book-detail.css"><script defer src="${base}/js/home.js"></script><script defer src="${base}/js/book-detail.js"></script></head>
<body class="detail-page" data-base="${base}"><main class="detail-shell"><header class="detail-header"><a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a><a class="back-home" href="${base}/home">← Khám phá sách</a><div class="header-links"><c:if test="${isStaffOrAdmin}"><a class="cart-link" href="${base}/admin">📊 Quản trị</a></c:if><a class="cart-link" href="${base}/cart">Giỏ hàng<c:if test="${cartCount > 0}"> (<c:out value="${cartCount}"/>)</c:if></a><shop:notifications/><c:choose><c:when test="${not empty displayName}"><a href="${base}/account"><c:out value="${displayName}"/></a></c:when><c:otherwise><a href="${base}/login">Đăng nhập</a></c:otherwise></c:choose></div></header>
<nav class="detail-breadcrumb" aria-label="Đường dẫn"><a href="${base}/home">Trang chủ</a><span>›</span><a href="${base}/home?category=${book.categoryId}"><c:out value="${book.categoryName}"/></a><span>›</span><span><c:out value="${book.title}"/></span></nav>
<c:if test="${not empty success}"><p class="review-message success" role="status"><c:out value="${success}"/></p></c:if><c:if test="${not empty error}"><p class="review-message error" role="alert"><c:out value="${error}"/></p></c:if>
<div class="product-grid"><aside class="product-gallery panel"><div class="main-cover"><img src="${base}<c:out value='${book.cover}'/>" alt="Bìa sách <c:out value='${book.title}'/>" data-cover width="320" height="440"></div><form id="purchase-form" class="purchase-actions" method="post" action="${base}/cart/add"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="bookId" value="${book.id}"><input type="hidden" name="redirect" value="/books/${book.id}"><button class="outline-button" type="submit" name="action" value="cart" ${book.available == 0 ? 'disabled' : ''}><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 3h3l3 12h11l3-9H6M9 20h.01M18 20h.01"/></svg>Thêm vào giỏ hàng</button><button type="submit" name="action" value="buy" ${book.available == 0 ? 'disabled' : ''}>Mua ngay</button></form><div class="gallery-policies"><h3>Chính sách ưu đãi của Mộc Sách</h3><ul><li><strong>Thời gian giao hàng:</strong> Giao nhanh và uy tín từ chi nhánh gần nhất</li><li><strong>Chính sách đổi trả:</strong> Hỗ trợ đổi trả sách đúng mô tả tình trạng</li><li><strong>Sách cũ tuyển chọn:</strong> Kiểm tra kỹ gáy, bìa và trang sách trước khi lên kệ</li></ul></div></aside>
<div class="product-information"><section class="panel product-summary"><span class="eyebrow">MỘC SÁCH · <c:out value="${book.categoryName}"/></span><h1><c:out value="${book.title}"/></h1><dl class="summary-meta"><div><dt>Tác giả:</dt><dd><c:out value="${book.authors}"/></dd></div><div><dt>Nhà xuất bản:</dt><dd><c:out value="${book.publisher}"/></dd></div><div><dt>Danh mục:</dt><dd><c:out value="${book.categoryName}"/></dd></div><div><dt>Năm xuất bản:</dt><dd><c:out value="${book.publishYear}"/></dd></div></dl><div class="metrics-bar"><a class="rating-link" href="#reviews"><span class="star">★★★★★</span> <c:choose><c:when test="${book.reviews > 0}">(<c:out value="${book.ratingLabel}"/>/5 · <c:out value="${book.reviews}"/> đánh giá)</c:when><c:otherwise>(0 đánh giá)</c:otherwise></c:choose></a><span class="metrics-sep">|</span><span class="sold-count">Đã bán <strong><c:out value="${book.sales}"/></strong></span></div><p class="product-price"><c:out value="${book.priceLabel}"/></p><p class="hint">Giá khởi điểm theo các bản sách hiện có; tình trạng từng cuốn có thể khác nhau.</p><div class="stock-note"><c:choose><c:when test="${book.available > 0}">Còn <strong><c:out value="${book.available}"/></strong> cuốn có sẵn tại cửa hàng<c:if test="${inCartCount > 0}"> · Đã có <c:out value="${inCartCount}"/> cuốn trong <a href="${base}/cart">giỏ hàng</a></c:if></c:when><c:otherwise>Sách tạm hết hàng</c:otherwise></c:choose></div><div class="quantity-row"><label for="quantity">Số lượng:</label><div class="quantity-control"><button type="button" data-quantity="-1" aria-label="Giảm số lượng" ${book.available == 0 ? 'disabled' : ''}>−</button><input id="quantity" name="quantity" form="purchase-form" type="number" min="1" max="${book.available > 0 ? book.available : 1}" value="1" step="1" inputmode="numeric" ${book.available == 0 ? 'disabled' : ''}><button type="button" data-quantity="1" aria-label="Tăng số lượng" ${book.available == 0 ? 'disabled' : ''}>+</button></div></div><c:if test="${not empty cartSuccess}"><p class="review-message success" role="status"><c:out value="${cartSuccess}"/> <a href="${base}/cart">Xem giỏ hàng →</a></p></c:if><c:if test="${not empty cartError}"><p class="review-message error" role="alert"><c:out value="${cartError}"/></p></c:if></section>
<c:if test="${isStaffOrAdmin}">
 <section class="panel staff-only-panel" id="staff-inventory">
  <div class="staff-head">
   <div>
    <span class="eyebrow">CHỈ DÀNH CHO STAFF & ADMIN</span>
    <h2>Quản lý Sách, Tình trạng (Như mới, Tốt, Khá), Giá nhập & Giá bán</h2>
   </div>
   <div class="staff-head-actions">
    <a class="staff-btn edit" href="${base}/admin/books/${book.id}/edit">✎ Sửa thông tin sách</a>
    <form method="post" action="${base}/admin/books/${book.id}/delete" class="inline-form">
     <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
     <button type="submit" class="staff-btn delete">🗑 Xóa sách</button>
    </form>
   </div>
  </div>
  <div class="staff-copies-wrap">
   <table class="staff-table">
    <thead>
     <tr>
      <th>Mã bản sách</th>
      <th>Chi nhánh</th>
      <th>Tình trạng</th>
      <th>Giá nhập (CostPrice)</th>
      <th>Giá bán (SalePrice)</th>
      <th>Trạng thái</th>
      <th>Ghi chú tình trạng</th>
      <th>Thao tác</th>
     </tr>
    </thead>
    <tbody>
     <c:forEach items="${staffCopies}" var="cp">
      <tr>
       <td><code><c:out value="${cp.copyCode}"/></code></td>
       <td>
        <select name="storeId" form="copy-form-${cp.copyId}">
         <c:forEach items="${stores}" var="st">
          <option value="${st.id}" ${cp.storeId == st.id ? 'selected' : ''}><c:out value="${st.name}"/></option>
         </c:forEach>
        </select>
       </td>
       <td>
        <select name="conditionId" form="copy-form-${cp.copyId}">
         <c:forEach items="${conditions}" var="cond">
          <option value="${cond.id}" ${cp.conditionId == cond.id ? 'selected' : ''}><c:out value="${cond.name}"/></option>
         </c:forEach>
        </select>
       </td>
       <td><input type="number" name="costPrice" form="copy-form-${cp.copyId}" value="${cp.costPrice}" min="0" step="1000" required></td>
       <td><input type="number" name="salePrice" form="copy-form-${cp.copyId}" value="${cp.salePrice}" min="1000" step="1000" required></td>
       <td>
        <select name="status" form="copy-form-${cp.copyId}">
         <option value="AVAILABLE" ${cp.status == 'AVAILABLE' ? 'selected' : ''}>AVAILABLE (Sẵn có)</option>
         <option value="RESERVED" ${cp.status == 'RESERVED' ? 'selected' : ''}>RESERVED (Đang giữ)</option>
         <option value="SOLD" ${cp.status == 'SOLD' ? 'selected' : ''}>SOLD (Đã bán)</option>
         <option value="DAMAGED" ${cp.status == 'DAMAGED' ? 'selected' : ''}>DAMAGED (Hư hỏng)</option>
        </select>
       </td>
       <td><input type="text" name="conditionNotes" form="copy-form-${cp.copyId}" value="<c:out value='${cp.conditionNotes}'/>" placeholder="Ghi chú bìa, gáy…"></td>
       <td class="staff-row-actions">
        <form id="copy-form-${cp.copyId}" method="post" action="${base}/admin/books/${book.id}/copies/${cp.copyId}/update" class="inline-form">
         <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
         <input type="hidden" name="source" value="detail">
         <button type="submit" class="staff-btn save">Lưu</button>
        </form>
        <form method="post" action="${base}/admin/books/${book.id}/copies/${cp.copyId}/delete" class="inline-form">
         <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
         <input type="hidden" name="source" value="detail">
         <button type="submit" class="staff-btn delete">Xóa</button>
        </form>
       </td>
      </tr>
     </c:forEach>
    </tbody>
   </table>
  </div>
  <form method="post" action="${base}/admin/books/${book.id}/copies/add" class="staff-add-copy-form">
   <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
   <input type="hidden" name="source" value="detail">
   <strong>+ Thêm bản sách mới:</strong>
   <select name="storeId" required>
    <c:forEach items="${stores}" var="st"><option value="${st.id}"><c:out value="${st.name}"/></option></c:forEach>
   </select>
   <select name="conditionId" required>
    <c:forEach items="${conditions}" var="cond"><option value="${cond.id}"><c:out value="${cond.name}"/></option></c:forEach>
   </select>
   <input type="number" name="costPrice" min="0" step="1000" required placeholder="Giá nhập (CostPrice)">
   <input type="number" name="salePrice" min="1000" step="1000" required placeholder="Giá bán (SalePrice)">
   <input type="text" name="conditionNotes" placeholder="Ghi chú tình trạng…">
   <button type="submit" class="staff-btn save">+ Thêm bản sách</button>
  </form>
 </section>
</c:if>
<section class="panel"><h2>Thông tin chi tiết</h2><dl class="specifications"><div><dt>Mã hàng</dt><dd>MS-<c:out value="${book.id}"/></dd></div><div><dt>ISBN</dt><dd><c:out value="${book.isbn}"/></dd></div><div><dt>Tác giả</dt><dd><c:out value="${book.authors}"/></dd></div><div><dt>Người dịch</dt><dd><c:out value="${book.translator}"/></dd></div><div><dt>NXB</dt><dd><c:out value="${book.publisher}"/></dd></div><div><dt>Năm xuất bản</dt><dd><c:out value="${book.publishYear}"/></dd></div><div><dt>Thể loại</dt><dd><c:out value="${book.categoryName}"/></dd></div></dl></section>
<section class="panel"><h2>Mô tả sản phẩm</h2><div class="product-description"><c:out value="${book.description}"/></div></section></div></div>
<section class="panel reviews-panel" id="reviews"><h2>Đánh giá và bình luận</h2><div class="review-overview"><div class="rating-total"><strong><c:choose><c:when test="${book.reviews > 0}"><c:out value="${book.ratingLabel}"/></c:when><c:otherwise>0</c:otherwise></c:choose></strong><span>/5</span><p>(<c:out value="${book.reviews}"/> đánh giá)</p></div><div class="rating-bars"><c:forEach items="${histogram}" var="row"><div><span>${row.stars} sao</span><progress value="${row.percent}" max="100" aria-label="${row.stars} sao: ${row.count} đánh giá"></progress><span>${row.percent}%</span></div></c:forEach></div></div>
<c:choose><c:when test="${not empty displayName}"><div class="review-compose"><h3>Chia sẻ cảm nhận của bạn</h3><c:if test="${not empty ownReview}"><p class="hint">Đánh giá của bạn: <c:choose><c:when test="${ownReview.status == 'APPROVED'}">Đã hiển thị</c:when><c:when test="${ownReview.status == 'HIDDEN'}">Đã bị ẩn</c:when><c:otherwise>Đang chờ duyệt</c:otherwise></c:choose>.</p></c:if><c:if test="${ownReview.status != 'HIDDEN'}"><form method="post" action="${base}/books/${book.id}/reviews"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><fieldset><legend>Bạn đánh giá cuốn sách này thế nào?</legend><div class="star-choices"><c:forEach begin="1" end="5" var="star"><label><input type="radio" name="rating" value="${star}" ${ownReview.rating == star ? 'checked' : ''} required><span>${star} ★</span></label></c:forEach></div></fieldset><label for="comment">Bình luận của bạn</label><textarea id="comment" name="comment" rows="3" minlength="3" maxlength="2000" required placeholder="Chia sẻ điều bạn thích về cuốn sách…"><c:out value="${ownReview.comment}"/></textarea><p class="hint">Mỗi tài khoản có một đánh giá cho mỗi sách. Bạn có thể cập nhật cảm nhận của mình sau khi gửi.</p><button type="submit">${empty ownReview ? 'Gửi đánh giá' : 'Cập nhật đánh giá'}</button></form></c:if></div></c:when><c:otherwise><p class="signin-review">Bạn cần <a href="${base}/login">đăng nhập</a> hoặc <a href="${base}/register">đăng ký</a> để viết đánh giá.</p></c:otherwise></c:choose>
<div class="review-list"><c:choose><c:when test="${empty reviews}"><p class="empty-review">Chưa có bình luận công khai. Hãy chia sẻ cảm nhận đầu tiên của bạn.</p></c:when><c:otherwise><h3>Bình luận mới nhất</h3><p class="hint">Hiển thị tối đa 20 đánh giá đã duyệt gần nhất.</p><c:forEach items="${reviews}" var="review"><article class="reader-review"><header><strong><c:out value="${review.fullName}"/></strong><span class="star">${review.rating}/5 ★</span></header><p class="review-date"><c:out value="${review.createdAt}"/></p><p class="product-description"><c:out value="${review.comment}"/></p></article></c:forEach></c:otherwise></c:choose></div></section>
<section class="panel related-section"><h2>Khám phá sách cùng tác giả</h2><p class="hint">Đọc tiếp những câu chuyện từ <c:out value="${book.authors}"/>.</p><c:choose><c:when test="${empty book.related}"><p>Hiện chưa có sách khác cùng tác giả trong cửa hàng.</p></c:when><c:otherwise><div class="book-grid"><c:forEach items="${book.related}" var="related"><shop:book book="${related}"/></c:forEach></div></c:otherwise></c:choose></section><footer><span>Mộc Sách.</span>Sách được yêu thêm một lần.<a href="${base}/home">Về trang chủ</a></footer></main><div id="toast" role="status" aria-live="polite" ${empty cartSuccess and empty cartError ? 'hidden' : ''}><span><c:out value="${not empty cartSuccess ? cartSuccess : cartError}"/></span><button type="button" aria-label="Đóng thông báo">×</button></div></body></html>
