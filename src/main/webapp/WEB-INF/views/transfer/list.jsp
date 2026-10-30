<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Quản lý Điều chuyển Kho Nội bộ · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1240px; margin: 0 auto; padding: 24px 20px; }
  .badge-status { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .badge-requested { background: #fef3c7; color: #92400e; }
  .badge-approved { background: #dbeafe; color: #1e40af; }
  .badge-in_transit { background: #e0f2fe; color: #0369a1; }
  .badge-completed { background: #dcfce7; color: #166534; }
  .badge-discrepancy { background: #ffedd5; color: #9a3412; }
  .badge-cancelled { background: #fee2e2; color: #991b1b; }
  .btn-sm { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
  .btn-primary { background: #2563eb; color: #fff; border: 1px solid #2563eb; }
  .btn-outline { background: #fff; border: 1px solid #cbd5e1; color: #334155; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.05); }
  .data-table th { background: #f8fafc; padding: 12px 14px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .data-table tr:hover td { background: #f8fafc; }
  .route-arrow { color: #2563eb; font-weight: bold; margin: 0 4px; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="admin-shell">
 <header class="cart-header" style="margin-bottom: 20px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/admin/my-store" class="btn-sm btn-outline">🏪 Chi nhánh của tôi</a>
   <c:if test="${isSuperAdmin}">
    <a href="${base}/admin" class="btn-sm btn-outline">📊 Dashboard Admin</a>
   </c:if>
   <a href="${base}/admin/transfers" class="btn-sm btn-primary">🚚 Điều chuyển kho</a>
   <a href="${base}/admin/buybacks" class="btn-sm btn-outline">📖 Thu mua C2B</a>
  </div>
 </header>

 <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 20px; flex-wrap:wrap; gap:12px;">
  <div>
   <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">HỆ THỐNG ĐIỀU CHUYỂN KHO LIÊN CHI NHÁNH</span>
   <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Quản Lý Phiếu Luân Chuyển Sách Vật Lý</h1>
   <p style="margin:0; color:#64748b; font-size:14px;">Quản lý luồng điều chuyển sách: Tạo yêu cầu &rarr; Admin duyệt &rarr; Xuất kho (Khóa IN_TRANSIT) &rarr; Tiếp nhận &amp; Nghiệm thu.</p>
  </div>
  <a href="${base}/admin/transfers/new" class="btn-sm btn-primary" style="padding:10px 18px; font-size:14px; box-shadow:0 4px 12px rgba(37,99,235,0.25);">
   + Lập Phiếu Điều Chuyển Mới
  </a>
 </div>

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <div style="background:#fff; border:1px solid #e2e8f0; border-radius:14px; overflow:hidden;">
  <table class="data-table">
   <thead>
    <tr>
     <th>Mã Phiếu</th>
     <th>Tuyến Điều Chuyển</th>
     <th>Lý do</th>
     <th>Số lượng sách</th>
     <th>Người tạo</th>
     <th>Trạng thái</th>
     <th>Ngày lập</th>
     <th>Thao tác</th>
    </tr>
   </thead>
   <tbody>
    <c:choose>
     <c:when test="${empty transfers}">
      <tr><td colspan="8" style="text-align:center; padding:32px; color:#94a3b8;">Chưa có phiếu điều chuyển kho nào.</td></tr>
     </c:when>
     <c:otherwise>
      <c:forEach items="${transfers}" var="trf">
       <tr>
        <td>
         <strong><c:out value="${trf.transferCode}"/></strong>
        </td>
        <td>
         <strong><c:out value="${trf.fromBranch.name}"/></strong>
         <span class="route-arrow">&rarr;</span>
         <strong><c:out value="${trf.toBranch.name}"/></strong>
        </td>
        <td>
         <small style="color:#475569;"><c:out value="${trf.reason}"/></small>
        </td>
        <td>
         <strong><c:out value="${trf.items.size()}"/></strong> cuốn
        </td>
        <td>
         <c:out value="${trf.requestedBy != null ? trf.requestedBy.fullName : 'Hệ thống'}"/>
        </td>
        <td>
         <c:choose>
          <c:when test="${trf.status == 'REQUESTED'}"><span class="badge-status badge-requested">Chờ Admin duyệt</span></c:when>
          <c:when test="${trf.status == 'APPROVED'}"><span class="badge-status badge-approved">Đã duyệt / Chờ xuất kho</span></c:when>
          <c:when test="${trf.status == 'IN_TRANSIT'}"><span class="badge-status badge-in_transit">Đang vận chuyển</span></c:when>
          <c:when test="${trf.status == 'COMPLETED'}"><span class="badge-status badge-completed">Hoàn tất</span></c:when>
          <c:when test="${trf.status == 'DISCREPANCY'}"><span class="badge-status badge-discrepancy">Có lệch phẩm cấp/hư hại</span></c:when>
          <c:otherwise><span class="badge-status badge-cancelled"><c:out value="${trf.status}"/></span></c:otherwise>
         </c:choose>
        </td>
        <td style="color:#64748b; font-size:12.5px;">
         <c:out value="${trf.createdAt}"/>
        </td>
        <td>
         <a href="${base}/admin/transfers/${trf.id}" class="btn-sm btn-outline">Chi tiết &rarr;</a>
        </td>
       </tr>
      </c:forEach>
     </c:otherwise>
    </c:choose>
   </tbody>
  </table>
 </div>
</main>
</body>
</html>
