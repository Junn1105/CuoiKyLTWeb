<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Lập Phiếu Điều Chuyển Kho Mới · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1180px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .form-group { display: flex; flex-direction: column; gap: 6px; }
  .form-group label { font-size: 13px; font-weight: 600; color: #334155; }
  .form-group input, .form-group select, .form-group textarea { padding: 9px 12px; font-size: 13.5px; border: 1px solid #cbd5e1; border-radius: 8px; background: #fff; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13px; }
  .data-table th { background: #f8fafc; padding: 10px 12px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; position: sticky; top: 0; }
  .data-table td { padding: 8px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .table-box { max-height: 380px; overflow-y: auto; border: 1px solid #cbd5e1; border-radius: 8px; margin-top: 10px; }
  .btn-sm { padding: 6px 14px; font-size: 13px; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: 1px solid transparent; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="admin-shell">
 <header class="cart-header" style="margin-bottom: 20px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/admin/transfers" class="btn-sm btn-outline">← Danh sách Điều chuyển</a>
   <a href="${base}/admin/my-store" class="btn-sm btn-outline">🏪 Chi nhánh của tôi</a>
  </div>
 </header>

 <div style="margin-bottom: 20px;">
  <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">KHỞI TẠO PHIẾU ĐIỀU CHUYỂN NỘI BỘ</span>
  <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Lập Phiếu Yêu Cầu Điều Chuyển Kho</h1>
  <p style="margin:0; color:#64748b; font-size:14px;">Chọn chi nhánh đích và các bản sách vật lý cần luân chuyển. Phiếu sẽ được chuyển đến Admin để phê duyệt.</p>
 </div>

 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <form action="${base}/admin/transfers/new" method="post" id="transferForm">
  <div class="panel-box">
   <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">1. Tuyến Đường &amp; Lý Do Luân Chuyển</h2>
   <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:16px; margin-bottom:14px;">
    <div class="form-group">
     <label for="fromBranchId">Chi nhánh xuất kho (Gửi) *</label>
     <c:choose>
      <c:when test="${isSuperAdmin}">
       <select id="fromBranchId" name="fromBranchId" onchange="window.location.href='${base}/admin/transfers/new?fromBranchId=' + this.value;">
        <c:forEach items="${branches}" var="b">
         <option value="${b.id}" ${b.id == effectiveFrom ? 'selected' : ''}><c:out value="${b.name}"/> (<c:out value="${b.code}"/>)</option>
        </c:forEach>
       </select>
      </c:when>
      <c:otherwise>
       <c:forEach items="${branches}" var="b">
        <c:if test="${b.id == effectiveFrom}">
         <input type="text" value="${b.name} (${b.code})" readonly style="background:#f1f5f9; cursor:not-allowed;">
         <input type="hidden" name="fromBranchId" value="${b.id}">
        </c:if>
       </c:forEach>
      </c:otherwise>
     </c:choose>
    </div>

    <div class="form-group">
     <label for="toBranchId">Chi nhánh nhập kho (Đích) *</label>
     <select id="toBranchId" name="toBranchId" required>
      <c:forEach items="${branches}" var="b">
       <c:if test="${b.id != effectiveFrom}">
        <option value="${b.id}"><c:out value="${b.name}"/> (<c:out value="${b.code}"/>)</option>
       </c:if>
      </c:forEach>
     </select>
    </div>

    <div class="form-group">
     <label for="reason">Mục đích luân chuyển *</label>
     <select id="reason" name="reason" required>
      <option value="RESTOCK">Bổ sung hàng tồn kho (RESTOCK)</option>
      <option value="ONLINE_ORDER_CONSOLIDATION">Gom đơn hàng Online (CONSOLIDATION)</option>
     </select>
    </div>
   </div>

   <div class="form-group">
    <label for="note">Ghi chú điều chuyển:</label>
    <textarea id="note" name="note" rows="2" placeholder="VD: Điều chuyển 5 cuốn sách về chi nhánh Thủ Đức theo yêu cầu quản lý..."></textarea>
   </div>
  </div>

  <div class="panel-box">
   <div style="display:flex; justify-content:space-between; align-items:center;">
    <div>
     <h2 style="font-size:16px; margin:0; color:#0f172a;">2. Chọn Bản Sách Cần Điều Chuyển</h2>
     <small style="color:#64748b;">Chỉ hiển thị các cuốn sách đang có sẵn trên kệ (IN_STOCK) tại chi nhánh gửi.</small>
    </div>
    <span id="selectedCount" style="font-weight:700; color:#2563eb; font-size:13px;">Đã chọn 0 cuốn</span>
   </div>

   <div class="table-box">
    <table class="data-table">
     <thead>
      <tr>
       <th style="width:40px;"><input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)"></th>
       <th>Mã vạch (Barcode)</th>
       <th>Tên sách</th>
       <th>Tác giả</th>
       <th>Phẩm cấp</th>
       <th>Giá bán</th>
      </tr>
     </thead>
     <tbody>
      <c:choose>
       <c:when test="${empty availableItems}">
        <tr><td colspan="6" style="text-align:center; padding:24px; color:#94a3b8;">Không có bản sách khả dụng nào tại chi nhánh gửi.</td></tr>
       </c:when>
       <c:otherwise>
        <c:forEach items="${availableItems}" var="it">
         <tr>
          <td><input type="checkbox" name="bookItemIds" value="${it.id}" onchange="updateSelectedCount()"></td>
          <td><code><c:out value="${it.serialCode}"/></code></td>
          <td><strong><c:out value="${it.bookTitle.title}"/></strong></td>
          <td><c:out value="${it.bookTitle.author}"/></td>
          <td><span style="font-weight:600; color:#2563eb;"><c:out value="${it.grade}"/></span></td>
          <td><fmt:formatNumber value="${it.sellingPrice}" type="number" groupingUsed="true"/> đ</td>
         </tr>
        </c:forEach>
       </c:otherwise>
      </c:choose>
     </tbody>
    </table>
   </div>
  </div>

  <div style="display:flex; justify-content:flex-end; gap:12px;">
   <a href="${base}/admin/transfers" class="btn-sm btn-outline" style="padding:10px 18px;">Hủy bỏ</a>
   <button type="submit" class="btn-sm btn-primary" style="padding:10px 24px; font-size:14px;">
    ✓ Gửi Yêu Cầu Điều Chuyển
   </button>
  </div>
 </form>
</main>

<script>
 function toggleSelectAll(master) {
   const checkboxes = document.querySelectorAll('input[name="bookItemIds"]');
   checkboxes.forEach(cb => cb.checked = master.checked);
   updateSelectedCount();
 }

 function updateSelectedCount() {
   const checked = document.querySelectorAll('input[name="bookItemIds"]:checked');
   document.getElementById('selectedCount').innerText = 'Đã chọn ' + checked.length + ' cuốn';
 }
</script>
</body>
</html>
