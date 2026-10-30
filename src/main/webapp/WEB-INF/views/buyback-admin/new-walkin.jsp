<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Lập Phiếu Thu Mua Tại Quầy (Walk-in Buyback) · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1180px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .calc-box { background: #f0fdf4; border: 1.5px solid #86efac; border-radius: 12px; padding: 18px; margin-bottom: 24px; }
  .calc-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; align-items: end; }
  .form-group { display: flex; flex-direction: column; gap: 6px; }
  .form-group label { font-size: 13px; font-weight: 600; color: #334155; }
  .form-group input, .form-group select, .form-group textarea { padding: 9px 12px; font-size: 13.5px; border: 1px solid #cbd5e1; border-radius: 8px; background: #fff; }
  .item-row { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px; margin-bottom: 12px; display: grid; grid-template-columns: 2fr 1.5fr 1fr 1fr 1fr 1fr auto; gap: 10px; align-items: center; }
  .btn-sm { padding: 6px 14px; font-size: 13px; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: 1px solid transparent; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-success { background: #059669; color: #fff; }
  .btn-danger { background: #dc2626; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  .price-highlight { font-size: 16px; font-weight: 700; color: #059669; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="admin-shell">
 <header class="cart-header" style="margin-bottom: 20px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/admin/buybacks" class="btn-sm btn-outline">← Danh sách Thu mua</a>
   <a href="${base}/admin/my-store" class="btn-sm btn-outline">🏪 Chi nhánh của tôi</a>
  </div>
 </header>

 <div style="margin-bottom: 20px;">
  <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">QUY TRÌNH THU MUA TRỰC TIẾP TẠI QUẦY (WALK-IN INTAKE)</span>
  <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Lập Phiếu Thu Mua Sách Cũ &amp; Tự Động Nhập Kho</h1>
  <p style="margin:0; color:#64748b; font-size:14px;">Nhập thông tin khách hàng, kiểm định tình trạng sách và áp dụng thuật toán định giá tự động trước khi sinh mã vạch BookItem.</p>
 </div>

 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <!-- CÔNG CỤ TÍNH GIÁ NHANH (LIVE PRICING ENGINE CALCULATOR) -->
 <div class="calc-box">
  <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
   <strong style="color:#166534; font-size:15px;">⚡ Công cụ Định Giá Tự Động (Pricing Engine Calculator)</strong>
   <small style="color:#15803d;">Áp dụng hệ số tồn kho chuỗi (K_stock) &amp; hạn mức điều chỉnh ±15% của nhân viên</small>
  </div>
  <div class="calc-grid">
   <div class="form-group">
    <label for="calcCover">Giá bìa niêm yết (đ):</label>
    <input type="number" id="calcCover" value="100000" step="5000" min="0">
   </div>
   <div class="form-group">
    <label for="calcGrade">Tình trạng sách:</label>
    <select id="calcGrade">
     <option value="S">Hạng S - Như mới (95-99%) [Mua 45% / Bán 75%]</option>
     <option value="A">Hạng A - Rất tốt (80-90%) [Mua 35% / Bán 60%]</option>
     <option value="B" selected>Hạng B - Khá tốt (65-75%) [Mua 20% / Bán 45%]</option>
     <option value="C">Hạng C - Đọc được (&lt;65%) [Mua 8% / Bán 25%]</option>
    </select>
   </div>
   <div class="form-group">
    <label for="calcRarity">Hệ số độ hiếm (Mặc định 1.0):</label>
    <input type="number" id="calcRarity" value="1.0" step="0.1" min="0.5" max="3.0">
   </div>
   <button type="button" class="btn-sm btn-success" onclick="calculatePrice()" style="padding:10px;">
    🔍 Tính Giá Đề Xuất
   </button>
  </div>
  <div id="calcResult" style="margin-top:14px; padding-top:12px; border-top:1px dashed #86efac; display:none;">
   <div style="display:flex; gap:20px; flex-wrap:wrap; align-items:center;">
    <div>Giá thu mua đề xuất: <span id="resBuy" class="price-highlight">0 đ</span></div>
    <div>Giá bán niêm yết dự kiến: <strong id="resSell" style="color:#2563eb;">0 đ</strong></div>
    <div>Hạn mức nhân viên điều chỉnh (±15%): <span id="resRange" style="color:#b45309; font-weight:600;">0 - 0 đ</span></div>
    <div>Hệ số tồn kho: <code id="resKStock">1.0</code></div>
   </div>
  </div>
 </div>

 <!-- FORM THU MUA CHÍNH -->
 <form action="${base}/admin/buybacks/new-walkin" method="post" id="buybackForm">
  <div class="panel-box">
   <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">1. Thông tin Khách Hàng Bán Sách</h2>
   <div style="display:grid; grid-template-columns: 1fr 1fr 1.5fr; gap:16px;">
    <div class="form-group">
     <label for="customerName">Họ và tên khách hàng *</label>
     <input type="text" id="customerName" name="customerName" placeholder="Nguyễn Văn A" required>
    </div>
    <div class="form-group">
     <label for="customerPhone">Số điện thoại liên hệ *</label>
     <input type="tel" id="customerPhone" name="customerPhone" placeholder="0901234567" required>
    </div>
    <div class="form-group">
     <label for="staffNote">Ghi chú tiếp nhận:</label>
     <input type="text" id="staffNote" name="staffNote" placeholder="Khách mang trực tiếp tại quầy...">
    </div>
   </div>
  </div>

  <div class="panel-box">
   <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
    <h2 style="font-size:16px; margin:0; color:#0f172a;">2. Danh mục Sách Thu Mua &amp; Phẩm Cấp</h2>
    <button type="button" class="btn-sm btn-outline" onclick="addItemRow()">+ Thêm cuốn sách khác</button>
   </div>

   <div id="itemsContainer">
    <!-- DÒNG SÁCH 1 -->
    <div class="item-row">
     <div class="form-group">
      <label>Tên sách *</label>
      <input type="text" name="title" placeholder="VD: Nhà Giả Kim" required>
     </div>
     <div class="form-group">
      <label>Tác giả</label>
      <input type="text" name="author" placeholder="Paulo Coelho">
     </div>
     <div class="form-group">
      <label>Giá bìa (đ) *</label>
      <input type="number" name="coverPrice" value="80000" step="1000" required>
     </div>
     <div class="form-group">
      <label>Phẩm cấp *</label>
      <select name="grade" required>
       <option value="S">Hạng S (Như mới)</option>
       <option value="A">Hạng A (Rất tốt)</option>
       <option value="B" selected>Hạng B (Khá tốt)</option>
       <option value="C">Hạng C (Đọc được)</option>
      </select>
     </div>
     <div class="form-group">
      <label>Giá thu mua (đ)</label>
      <input type="number" name="offeredPrice" placeholder="Tự động tính" step="1000">
     </div>
     <div class="form-group">
      <label>Mã ISBN</label>
      <input type="text" name="isbn" placeholder="Tùy chọn">
     </div>
     <div>
      <button type="button" class="btn-sm btn-danger" onclick="removeItemRow(this)" title="Xóa">✕</button>
     </div>
    </div>
   </div>
  </div>

  <div style="display:flex; justify-content:flex-end; gap:12px;">
   <a href="${base}/admin/buybacks" class="btn-sm btn-outline" style="padding:10px 18px;">Hủy bỏ</a>
   <button type="submit" class="btn-sm btn-primary" style="padding:10px 24px; font-size:14px;">
    ✓ Hoàn Tất Thu Mua &amp; Nhập Kho Tự Động
   </button>
  </div>
 </form>
</main>

<script>
 const base = document.body.dataset.base || '';

 function calculatePrice() {
   const cover = document.getElementById('calcCover').value;
   const grade = document.getElementById('calcGrade').value;
   const rarity = document.getElementById('calcRarity').value;

   fetch(base + '/api/pricing/estimate?coverPrice=' + cover + '&grade=' + grade + '&rarityFactor=' + rarity)
     .then(res => res.json())
     .then(data => {
       if (data.success) {
         document.getElementById('resBuy').innerText = Number(data.recommendedBuybackPrice).toLocaleString('vi-VN') + ' đ';
         document.getElementById('resSell').innerText = Number(data.recommendedSellingPrice).toLocaleString('vi-VN') + ' đ';
         document.getElementById('resRange').innerText = Number(data.minStaffBuybackPrice).toLocaleString('vi-VN') + ' đ - ' + Number(data.maxStaffBuybackPrice).toLocaleString('vi-VN') + ' đ';
         document.getElementById('resKStock').innerText = data.kStock;
         document.getElementById('calcResult').style.display = 'block';
       }
     })
     .catch(err => console.error(err));
 }

 function addItemRow() {
   const container = document.getElementById('itemsContainer');
   const div = document.createElement('div');
   div.className = 'item-row';
   div.innerHTML = `
     <div class="form-group">
      <label>Tên sách *</label>
      <input type="text" name="title" placeholder="VD: Mắt Biếc" required>
     </div>
     <div class="form-group">
      <label>Tác giả</label>
      <input type="text" name="author" placeholder="Nguyễn Nhật Ánh">
     </div>
     <div class="form-group">
      <label>Giá bìa (đ) *</label>
      <input type="number" name="coverPrice" value="100000" step="1000" required>
     </div>
     <div class="form-group">
      <label>Phẩm cấp *</label>
      <select name="grade" required>
       <option value="S">Hạng S (Như mới)</option>
       <option value="A">Hạng A (Rất tốt)</option>
       <option value="B" selected>Hạng B (Khá tốt)</option>
       <option value="C">Hạng C (Đọc được)</option>
      </select>
     </div>
     <div class="form-group">
      <label>Giá thu mua (đ)</label>
      <input type="number" name="offeredPrice" placeholder="Tự động tính" step="1000">
     </div>
     <div class="form-group">
      <label>Mã ISBN</label>
      <input type="text" name="isbn" placeholder="Tùy chọn">
     </div>
     <div>
      <button type="button" class="btn-sm btn-danger" onclick="removeItemRow(this)" title="Xóa">✕</button>
     </div>
   `;
   container.appendChild(div);
 }

 function removeItemRow(btn) {
   const rows = document.querySelectorAll('.item-row');
   if (rows.length > 1) {
     btn.closest('.item-row').remove();
   } else {
     alert('Phiếu thu mua phải có ít nhất một cuốn sách.');
   }
 }
</script>
</body>
</html>
