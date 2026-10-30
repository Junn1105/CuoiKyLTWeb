<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Gửi Yêu Cầu Định Giá Bán Lại Sách Cũ · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .portal-shell { max-width: 960px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .form-group { display: flex; flex-direction: column; gap: 6px; }
  .form-group label { font-size: 13px; font-weight: 600; color: #334155; }
  .form-group input, .form-group select, .form-group textarea { padding: 9px 12px; font-size: 13.5px; border: 1px solid #cbd5e1; border-radius: 8px; background: #fff; }
  .btn-sm { padding: 6px 14px; font-size: 13px; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: 1px solid transparent; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  .item-card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px; margin-bottom: 12px; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="portal-shell">
 <header class="cart-header" style="margin-bottom: 20px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/home" class="btn-sm btn-outline">← Trang chủ</a>
   <a href="${base}/buybacks/my-requests" class="btn-sm btn-outline">Đơn thu mua của tôi</a>
  </div>
 </header>

 <div style="margin-bottom: 20px;">
  <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">DỊCH VỤ THU MUA SÁCH CŨ TẬN NHÀ (C2B BUYBACK)</span>
  <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Gửi Yêu Cầu Định Giá Sách Trực Tuyến</h1>
  <p style="margin:0; color:#64748b; font-size:14px;">Bán lại những cuốn sách bạn đã đọc để lan tỏa tri thức và nhận tiền mặt hoặc điểm tích lũy.</p>
 </div>

 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <form action="${base}/buybacks/new" method="post">
  <div class="panel-box">
   <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">1. Thông tin liên hệ &amp; Chi nhánh nhận</h2>
   <div style="display:grid; grid-template-columns: 1fr 1fr 1.5fr; gap:16px;">
    <div class="form-group">
     <label for="customerName">Họ và tên của bạn *</label>
     <input type="text" id="customerName" name="customerName" placeholder="Nguyễn Văn A" required>
    </div>
    <div class="form-group">
     <label for="customerPhone">Số điện thoại *</label>
     <input type="tel" id="customerPhone" name="customerPhone" placeholder="0901234567" required>
    </div>
    <div class="form-group">
     <label for="targetBranchId">Chi nhánh muốn gửi sách đến *</label>
     <select id="targetBranchId" name="targetBranchId" required>
      <c:forEach items="${branches}" var="b">
       <option value="${b.id}"><c:out value="${b.name}"/> - <c:out value="${b.address}"/></option>
      </c:forEach>
     </select>
    </div>
   </div>
  </div>

  <div class="panel-box">
   <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
    <h2 style="font-size:16px; margin:0; color:#0f172a;">2. Danh sách cuốn sách muốn bán</h2>
    <button type="button" class="btn-sm btn-outline" onclick="addBookItem()">+ Thêm cuốn sách khác</button>
   </div>

   <div id="booksContainer">
    <div class="item-card">
     <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:12px; margin-bottom:10px;">
      <div class="form-group">
       <label>Tựa sách *</label>
       <input type="text" name="customTitle" placeholder="VD: Dế Mèn Phiêu Lưu Ký" required>
      </div>
      <div class="form-group">
       <label>Tác giả</label>
       <input type="text" name="author" placeholder="Tô Hoài">
      </div>
      <div class="form-group">
       <label>Giá bìa gốc (ước tính)</label>
       <input type="number" name="declaredCoverPrice" value="65000" step="5000">
      </div>
     </div>
     <div class="form-group">
      <label>Mô tả tình trạng sách (gáy sách, vết ố, gạch chân...):</label>
      <input type="text" name="customerConditionNote" placeholder="VD: Sách còn nguyên bìa, giấy hơi ngả vàng ở trang đầu...">
     </div>
    </div>
   </div>
  </div>

  <div style="display:flex; justify-content:flex-end; gap:12px;">
   <a href="${base}/home" class="btn-sm btn-outline" style="padding:10px 18px;">Hủy bỏ</a>
   <button type="submit" class="btn-sm btn-primary" style="padding:10px 24px; font-size:14px;">
    ✓ Gửi Yêu Cầu Định Giá
   </button>
  </div>
 </form>
</main>

<script>
 function addBookItem() {
   const container = document.getElementById('booksContainer');
   const div = document.createElement('div');
   div.className = 'item-card';
   div.innerHTML = `
     <div style="display:grid; grid-template-columns: 2fr 1fr 1fr; gap:12px; margin-bottom:10px;">
      <div class="form-group">
       <label>Tựa sách *</label>
       <input type="text" name="customTitle" placeholder="Tựa sách" required>
      </div>
      <div class="form-group">
       <label>Tác giả</label>
       <input type="text" name="author" placeholder="Tác giả">
      </div>
      <div class="form-group">
       <label>Giá bìa gốc</label>
       <input type="number" name="declaredCoverPrice" value="80000" step="5000">
      </div>
     </div>
     <div class="form-group">
      <label>Mô tả tình trạng sách:</label>
      <input type="text" name="customerConditionNote" placeholder="Tình trạng trang sách, gáy...">
     </div>
   `;
   container.appendChild(div);
 }
</script>
</body>
</html>
