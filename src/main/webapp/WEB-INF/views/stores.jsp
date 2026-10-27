<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Hệ thống Chi nhánh Chuỗi Cửa Hàng · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <script defer src="${base}/js/home.js"></script>
 <style>
  .store-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 20px; margin-top: 20px; }
  .store-card { background: #fff; border: 1px solid #e2eaf4; border-radius: 14px; padding: 22px; display: flex; flex-direction: column; justify-content: space-between; box-shadow: 0 4px 12px rgba(20,44,85,0.04); transition: transform .2s, box-shadow .2s; }
  .store-card.selected { border-color: #2563eb; box-shadow: 0 0 0 2px #2563eb; }
  .store-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(20,44,85,0.08); border-color: #cbdcf4; }
  .store-card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
  .store-card-header h2 { font-size: 19px; color: #142c55; margin: 0; line-height: 1.3; }
  .store-tag { font-size: 11.5px; font-weight: 700; padding: 4px 10px; border-radius: 20px; background: #e0f2fe; color: #0369a1; text-transform: uppercase; letter-spacing: 0.5px; }
  .store-meta { font-size: 13.5px; color: #475569; display: grid; gap: 8px; margin: 14px 0 18px; line-height: 1.5; }
  .store-meta div { display: flex; align-items: flex-start; gap: 8px; }
  .store-meta span.icon { flex-shrink: 0; font-size: 16px; }
  .store-inventory-highlight { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px 14px; margin-top: auto; display: flex; justify-content: space-between; align-items: center; gap: 10px; }
  .store-inventory-highlight strong { color: #1158c5; font-size: 18px; }
  .store-inventory-highlight small { color: #64748b; font-size: 12px; display: block; }
  .book-card-item { border: 1px solid #e2e8f0; border-radius: 12px; padding: 14px; display: flex; flex-direction: column; justify-content: space-between; background: #fafcff; transition: box-shadow .15s; }
  .book-card-item:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="cart-shell">
 <header class="cart-header">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div class="header-links">
   <a href="${base}/home">← Khám phá sách</a>
   <a class="cart-link" href="${base}/cart">Giỏ hàng<c:if test="${cartCount > 0}"> (<c:out value="${cartCount}"/>)</c:if></a>
   <shop:notifications/>
   <c:choose>
    <c:when test="${not empty displayName}"><a href="${base}/account"><c:out value="${displayName}"/></a></c:when>
    <c:otherwise><a href="${base}/login">Đăng nhập</a></c:otherwise>
   </c:choose>
  </div>
 </header>

 <div class="cart-heading">
  <span class="eyebrow">MẠNG LƯỚI KHÔNG GIAN SÁCH CŨ</span>
  <h1>Hệ Thống Chi Nhánh Chuỗi Cửa Hàng Mộc Sách</h1>
  <p>Mỗi chi nhánh Mộc Sách lưu giữ hàng nghìn đầu sách cũ tuyển chọn. Quý khách có thể xem danh mục sách đang có sẵn tại từng chi nhánh, ghé thăm trực tiếp hoặc đặt hàng nhận từ chi nhánh gần nhất.</p>
 </div>

 <div class="store-grid">
  <c:forEach items="${stores}" var="s">
   <article class="store-card ${selectedStoreId == s.storeId ? 'selected' : ''}">
    <div>
     <div class="store-card-header">
      <div>
       <span class="store-tag"><c:out value="${s.storeCode}"/></span>
       <h2 style="margin-top:6px;"><c:out value="${s.storeName}"/></h2>
      </div>
      <span class="status-badge ok">Mở cửa</span>
     </div>

     <div class="store-meta">
      <div><span class="icon">📍</span><div><strong>Địa chỉ:</strong> <c:out value="${s.address}"/></div></div>
      <div><span class="icon">📞</span><div><strong>Hotline / Zalo:</strong> <c:out value="${s.phone}"/></div></div>
      <div><span class="icon">📅</span><div><strong>Khai trương:</strong> <c:out value="${s.openedAt}"/></div></div>
      <div><span class="icon">🕒</span><div><strong>Giờ mở cửa:</strong> 08:30 – 21:30 hàng ngày</div></div>
     </div>
    </div>

    <div class="store-inventory-highlight">
     <div>
      <small>Sách sẵn có tại chi nhánh</small>
      <strong><c:out value="${s.availableCopies}"/> bản</strong>
      <small>(<c:out value="${s.distinctBooks}"/> đầu sách tuyển chọn)</small>
     </div>
     <div style="display:flex; flex-direction:column; gap:6px;">
      <a class="outline-button" style="text-align:center; padding:5px 10px; font-size:12px; font-weight:600;" href="${base}/stores?storeId=${s.storeId}#store-books">Xem sách 📚</a>
      <a class="outline-button" style="text-align:center; padding:3px 8px; font-size:11.5px; color:#475569;" href="${base}/home?storeId=${s.storeId}">Lọc tại Home ↗</a>
     </div>
    </div>
   </article>
  </c:forEach>
 </div>

 <c:if test="${not empty selectedStore}">
  <section id="store-books" style="margin-top: 40px; background: #fff; border: 1px solid #e2eaf4; border-radius: 16px; padding: 28px; box-shadow: 0 4px 16px rgba(20,44,85,0.04);">
   <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:16px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; margin-bottom:24px;">
    <div>
     <span class="store-tag" style="background:#e0e7ff; color:#3730a3;">📚 KHO SÁCH CHI NHÁNH</span>
     <h2 style="font-size:22px; color:#142c55; margin:8px 0 4px 0;"><c:out value="${selectedStore.storeName}"/></h2>
     <p style="margin:0; color:#64748b; font-size:14px;">📍 <c:out value="${selectedStore.address}"/> &bull; Hotline: <c:out value="${selectedStore.phone}"/></p>
    </div>
    <div style="display:flex; gap:10px; align-items:center;">
     <a href="${base}/stores" class="outline-button" style="font-size:13px;">✕ Thu gọn</a>
     <a href="${base}/home?storeId=${selectedStore.storeId}" class="outline-button" style="font-size:13px; background:#142c55; color:#fff; border-color:#142c55;">Mở bộ lọc Trang chủ ↗</a>
    </div>
   </div>

   <c:choose>
    <c:when test="${empty storeBooks}">
     <div style="text-align:center; padding:40px 20px; color:#64748b;">
      <p style="font-size:16px; font-weight:600; margin-bottom:6px;">Hiện tại chi nhánh chưa có sách có sẵn trên kệ.</p>
      <p style="font-size:13.5px;">Quý khách vui lòng chọn chi nhánh khác hoặc xem toàn bộ danh mục tại trang chủ.</p>
     </div>
    </c:when>
    <c:otherwise>
     <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(220px, 1fr)); gap:20px;">
      <c:forEach items="${storeBooks}" var="b">
       <article class="book-card-item">
        <div>
         <a href="${base}/books/${b.id}" style="text-decoration:none; color:inherit; display:block;">
          <img src="${base}<c:out value='${b.cover}'/>" alt="<c:out value='${b.title}'/>" style="width:100%; height:200px; object-fit:cover; border-radius:8px; margin-bottom:12px; box-shadow:0 2px 6px rgba(0,0,0,0.06);">
          <span style="display:inline-block; font-size:11px; font-weight:600; background:#e2e8f0; color:#334155; padding:2px 8px; border-radius:12px; margin-bottom:6px;"><c:out value="${b.categoryName}"/></span>
          <h3 style="font-size:15px; font-weight:700; margin:0 0 6px 0; color:#0f172a; line-height:1.4;"><c:out value="${b.title}"/></h3>
          <p style="font-size:12.5px; color:#64748b; margin:0 0 8px 0;"><c:out value="${b.authors}"/></p>
         </a>
        </div>
        <div style="margin-top:12px; padding-top:10px; border-top:1px dashed #cbd5e1; display:flex; justify-content:space-between; align-items:center;">
         <div>
          <span style="font-size:11px; color:#64748b; display:block;">Còn lại trên kệ:</span>
          <b style="color:#0369a1; font-size:14px;"><c:out value="${b.available}"/> cuốn</b>
         </div>
         <a href="${base}/books/${b.id}" class="outline-button" style="padding:4px 10px; font-size:12px;">Xem chi tiết →</a>
        </div>
       </article>
      </c:forEach>
     </div>
    </c:otherwise>
   </c:choose>
  </section>
 </c:if>

 <footer style="margin-top: 40px;">
  <span>Mộc Sách.</span> Hệ thống chuỗi cửa hàng sách cũ trao tay yêu thương. <a href="${base}/home">Về trang chủ</a>
 </footer>
</main>
</body>
</html>
