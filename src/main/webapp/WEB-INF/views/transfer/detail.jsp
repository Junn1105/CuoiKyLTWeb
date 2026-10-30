<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Chi Tiết Phiếu Điều Chuyển · <c:out value="${transfer.transferCode}"/> · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1180px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .badge-status { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .badge-requested { background: #fef3c7; color: #92400e; }
  .badge-approved { background: #dbeafe; color: #1e40af; }
  .badge-in_transit { background: #e0f2fe; color: #0369a1; }
  .badge-completed { background: #dcfce7; color: #166534; }
  .badge-discrepancy { background: #ffedd5; color: #9a3412; }
  .badge-cancelled { background: #fee2e2; color: #991b1b; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
  .data-table th { background: #f8fafc; padding: 10px 12px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .btn-sm { padding: 6px 14px; font-size: 13px; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: 1px solid transparent; display: inline-flex; align-items: center; gap: 4px; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-success { background: #059669; color: #fff; }
  .btn-warning { background: #d97706; color: #fff; }
  .btn-danger { background: #dc2626; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  .action-box { background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 18px; margin-top: 20px; }
  .timeline-bar { display: flex; align-items: center; justify-content: space-between; margin: 20px 0; position: relative; }
  .timeline-step { display: flex; flex-direction: column; align-items: center; z-index: 1; }
  .step-dot { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 13px; background: #e2e8f0; color: #64748b; margin-bottom: 6px; }
  .step-dot.active { background: #2563eb; color: #fff; }
  .step-dot.done { background: #059669; color: #fff; }
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

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <!-- BANNER THÔNG TIN PHIẾU ĐIỀU CHUYỂN -->
 <div class="panel-box">
  <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:14px; margin-bottom:16px;">
   <div>
    <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px;">CHI TIẾT PHIẾU ĐIỀU CHUYỂN KHO LIÊN CHI NHÁNH</span>
    <h1 style="margin:4px 0; font-size:22px; color:#0f172a;"><c:out value="${transfer.transferCode}"/></h1>
    <small style="color:#64748b;">Thời gian tạo: <c:out value="${transfer.createdAt}"/> &bull; Mục đích: <strong><c:out value="${transfer.reason}"/></strong></small>
   </div>
   <div style="text-align:right;">
    <div style="margin-bottom:6px;">
     <c:choose>
      <c:when test="${transfer.status == 'REQUESTED'}"><span class="badge-status badge-requested">Chờ Admin duyệt</span></c:when>
      <c:when test="${transfer.status == 'APPROVED'}"><span class="badge-status badge-approved">Đã duyệt / Chờ xuất kho</span></c:when>
      <c:when test="${transfer.status == 'IN_TRANSIT'}"><span class="badge-status badge-in_transit">Đang vận chuyển</span></c:when>
      <c:when test="${transfer.status == 'COMPLETED'}"><span class="badge-status badge-completed">Hoàn tất</span></c:when>
      <c:when test="${transfer.status == 'DISCREPANCY'}"><span class="badge-status badge-discrepancy">Có lệch phẩm cấp/hư hại</span></c:when>
      <c:otherwise><span class="badge-status badge-cancelled"><c:out value="${transfer.status}"/></span></c:otherwise>
     </c:choose>
    </div>
    <div style="font-size:14px; font-weight:600; color:#475569;">
     Quy mô: <strong><c:out value="${transfer.items.size()}"/></strong> cuốn sách
    </div>
   </div>
  </div>

  <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:14px; background:#f8fafc; padding:14px; border-radius:10px;">
   <div>
    <span style="font-size:12px; color:#64748b;">Chi nhánh xuất (Gửi):</span><br>
    <strong><c:out value="${transfer.fromBranch.name}"/></strong> (<c:out value="${transfer.fromBranch.code}"/>)
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Chi nhánh nhập (Đích):</span><br>
    <strong><c:out value="${transfer.toBranch.name}"/></strong> (<c:out value="${transfer.toBranch.code}"/>)
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Người yêu cầu:</span><br>
    <strong><c:out value="${transfer.requestedBy != null ? transfer.requestedBy.fullName : 'Hệ thống'}"/></strong>
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Người duyệt (Admin):</span><br>
    <strong><c:out value="${transfer.approvedBy != null ? transfer.approvedBy.fullName : 'Chưa duyệt'}"/></strong>
   </div>
  </div>

  <c:if test="${not empty transfer.note}">
   <div style="margin-top:12px; font-size:13px; color:#475569;">
    <strong>Ghi chú:</strong> <c:out value="${transfer.note}"/>
   </div>
  </c:if>
 </div>

 <!-- DANH SÁCH BẢN SÁCH -->
 <div class="panel-box">
  <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">Danh Sách Bản Sách Điều Chuyển (<c:out value="${transfer.items.size()}"/> bản)</h2>
  <div style="overflow-x:auto;">
   <table class="data-table">
    <thead>
     <tr>
      <th>Mã vạch (Barcode)</th>
      <th>Tên sách</th>
      <th>Phẩm cấp trước chuyển</th>
      <th>Phẩm cấp khi nhận</th>
      <th>Ghi chú lệch/Hư hại</th>
      <th>Trạng thái vật lý</th>
     </tr>
    </thead>
    <tbody>
     <c:forEach items="${transfer.items}" var="it">
      <tr>
       <td><code><c:out value="${it.bookItem.serialCode}"/></code></td>
       <td><strong><c:out value="${it.bookItem.bookTitle.title}"/></strong></td>
       <td><span style="color:#2563eb; font-weight:700;"><c:out value="${it.gradeBefore}"/></span></td>
       <td>
        <c:choose>
         <c:when test="${it.gradeAfter != null}">
          <span style="color:#059669; font-weight:700;"><c:out value="${it.gradeAfter}"/></span>
         </c:when>
         <c:otherwise><span style="color:#94a3b8;">Chưa nghiệm thu</span></c:otherwise>
        </c:choose>
       </td>
       <td>
        <c:choose>
         <c:when test="${not empty it.discrepancyNote}">
          <span style="color:#dc2626; font-size:12px; font-weight:600;"><c:out value="${it.discrepancyNote}"/></span>
         </c:when>
         <c:otherwise><span style="color:#94a3b8;">Bình thường</span></c:otherwise>
        </c:choose>
       </td>
       <td>
        <span style="font-size:12px; font-weight:600;"><c:out value="${it.bookItem.status}"/></span>
       </td>
      </tr>
     </c:forEach>
    </tbody>
   </table>
  </div>

  <!-- BẢNG THAO TÁC THEO QUYỀN HẠN & TRẠNG THÁI -->
  <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:20px; flex-wrap:wrap;">
   <c:if test="${canApprove}">
    <form action="${base}/admin/transfers/${transfer.id}/approve" method="post">
     <button type="submit" class="btn-sm btn-primary" style="padding:10px 20px;">
      ✓ Admin Phê Duyệt Phiếu Điều Chuyển
     </button>
    </form>
   </c:if>

   <c:if test="${canDispatch}">
    <form action="${base}/admin/transfers/${transfer.id}/dispatch" method="post">
     <button type="submit" class="btn-sm btn-warning" style="padding:10px 20px;">
      🚚 Xuất Kho Vận Chuyển (Khóa IN_TRANSIT)
     </button>
    </form>
   </c:if>

   <c:if test="${canCancel}">
    <form action="${base}/admin/transfers/${transfer.id}/cancel" method="post">
     <button type="submit" class="btn-sm btn-danger" onclick="return confirm('Bạn có chắc chắn muốn hủy phiếu điều chuyển này không?');">
      ✕ Hủy Phiếu
     </button>
    </form>
   </c:if>
  </div>

  <!-- PHẦN TIẾP NHẬN & NGHIỆM THU KHI IN_TRANSIT -->
  <c:if test="${canReceive}">
   <div class="action-box">
    <h3 style="margin:0 0 12px; font-size:15px; color:#1e293b;">Nghiệm thu bản sách khi tiếp nhận tại chi nhánh đích</h3>
    <form action="${base}/admin/transfers/${transfer.id}/receive" method="post">
     <c:forEach items="${transfer.items}" var="it">
      <div style="background:#fff; padding:12px; border-radius:8px; border:1px solid #cbd5e1; margin-bottom:10px; display:grid; grid-template-columns: 2fr 1.5fr 1fr 2fr; gap:12px; align-items:center;">
       <input type="hidden" name="bookItemId" value="${it.bookItem.id}">
       <div>
        <code><c:out value="${it.bookItem.serialCode}"/></code><br>
        <strong><c:out value="${it.bookItem.bookTitle.title}"/></strong>
       </div>
       <div>
        <label style="font-size:12px; font-weight:600;">Phẩm cấp sau vận chuyển:</label>
        <select name="gradeAfter" style="width:100%; padding:6px; border:1px solid #cbd5e1; border-radius:6px;">
         <c:forEach items="${grades}" var="g">
          <option value="${g}" ${g == it.gradeBefore ? 'selected' : ''}>Hạng <c:out value="${g}"/></option>
         </c:forEach>
        </select>
       </div>
       <div style="display:flex; align-items:center; gap:6px;">
        <input type="checkbox" name="damagedOrLost" value="${it.bookItem.id}" id="dmg_${it.bookItem.id}">
        <label for="dmg_${it.bookItem.id}" style="font-size:12px; color:#dc2626; font-weight:600;">Hư hại/Thất lạc</label>
       </div>
       <div>
        <input type="text" name="discrepancyNote" placeholder="Ghi chú lệch phẩm cấp hoặc va đập..." style="width:100%; padding:6px; border:1px solid #cbd5e1; border-radius:6px;">
       </div>
      </div>
     </c:forEach>
     <div style="display:flex; justify-content:flex-end; margin-top:14px;">
      <button type="submit" class="btn-sm btn-success" style="padding:10px 20px;">
       ✓ Hoàn Tất Nghiệm Thu &amp; Nhập Kho Chi Nhánh Đích
      </button>
     </div>
    </form>
   </div>
  </c:if>
 </div>
</main>
</body>
</html>
