<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Quản lý Thu mua Sách cũ (Buyback C2B) · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1240px; margin: 0 auto; padding: 24px 20px; }
  .badge-status { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .badge-submitted { background: #fef3c7; color: #92400e; }
  .badge-pre_quoted { background: #e0e7ff; color: #3730a3; }
  .badge-customer_accepted { background: #dbeafe; color: #1e40af; }
  .badge-item_received { background: #f3e8ff; color: #6b21a8; }
  .badge-completed { background: #dcfce7; color: #166534; }
  .badge-customer_rejected, .badge-cancelled { background: #fee2e2; color: #991b1b; }
  .badge-walkin { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
  .badge-online { background: #ecfeff; color: #155e75; border: 1px solid #a5f3fc; }
  .btn-sm { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
  .btn-primary { background: #2563eb; color: #fff; border: 1px solid #2563eb; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-outline { background: #fff; border: 1px solid #cbd5e1; color: #334155; }
  .filter-bar { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; margin-bottom: 16px; }
  .filter-pill { padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 600; text-decoration: none; border: 1px solid #cbd5e1; background: #fff; color: #475569; }
  .filter-pill.active { background: #0f172a; color: #fff; border-color: #0f172a; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.05); }
  .data-table th { background: #f8fafc; padding: 12px 14px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .data-table tr:hover td { background: #f8fafc; }
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
   <a href="${base}/admin/transfers" class="btn-sm btn-outline">🚚 Điều chuyển kho</a>
   <a href="${base}/admin/buybacks" class="btn-sm btn-primary">📖 Thu mua C2B</a>
  </div>
 </header>

 <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 20px; flex-wrap:wrap; gap:12px;">
  <div>
   <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">PHÂN HỆ ERP THU MUA SÁCH CŨ TỪ KHÁCH HÀNG</span>
   <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Quản Lý Đơn Thu Mua &amp; Thẩm Định Sách Cũ (Buyback)</h1>
   <p style="margin:0; color:#64748b; font-size:14px;">Tiếp nhận sách bán lại từ khách vãng lai tại quầy hoặc thẩm định đơn trực tuyến với công thức định giá tự động.</p>
  </div>
  <a href="${base}/admin/buybacks/new-walkin" class="btn-sm btn-primary" style="padding:10px 18px; font-size:14px; box-shadow:0 4px 12px rgba(37,99,235,0.25);">
   + Lập Phiếu Thu Mua Tại Quầy (Walk-in)
  </a>
 </div>

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <!-- BỘ LỌC TRẠNG THÁI -->
 <div class="filter-bar">
  <span style="font-size:13px; font-weight:600; color:#475569;">Trạng thái:</span>
  <a href="${base}/admin/buybacks?status=ALL" class="filter-pill ${statusFilter == 'ALL' ? 'active' : ''}">Tất cả</a>
  <a href="${base}/admin/buybacks?status=SUBMITTED" class="filter-pill ${statusFilter == 'SUBMITTED' ? 'active' : ''}">Chờ định giá sơ bộ</a>
  <a href="${base}/admin/buybacks?status=PRE_QUOTED" class="filter-pill ${statusFilter == 'PRE_QUOTED' ? 'active' : ''}">Đã báo giá</a>
  <a href="${base}/admin/buybacks?status=CUSTOMER_ACCEPTED" class="filter-pill ${statusFilter == 'CUSTOMER_ACCEPTED' ? 'active' : ''}">Khách đồng ý</a>
  <a href="${base}/admin/buybacks?status=ITEM_RECEIVED" class="filter-pill ${statusFilter == 'ITEM_RECEIVED' ? 'active' : ''}">Đã nhận sách tại quầy</a>
  <a href="${base}/admin/buybacks?status=COMPLETED" class="filter-pill ${statusFilter == 'COMPLETED' ? 'active' : ''}">Hoàn tất / Đã nhập kho</a>
  <a href="${base}/admin/buybacks?status=CANCELLED" class="filter-pill ${statusFilter == 'CANCELLED' ? 'active' : ''}">Đã hủy</a>
 </div>

 <div style="background:#fff; border:1px solid #e2e8f0; border-radius:14px; overflow:hidden;">
  <table class="data-table">
   <thead>
    <tr>
     <th>Mã Đơn / Kênh</th>
     <th>Khách hàng</th>
     <th>Chi nhánh tiếp nhận</th>
     <th>Số lượng sách</th>
     <th>Tổng giá trị thu mua</th>
     <th>Trạng thái</th>
     <th>Ngày lập</th>
     <th>Thao tác</th>
    </tr>
   </thead>
   <tbody>
    <c:choose>
     <c:when test="${empty requests}">
      <tr><td colspan="8" style="text-align:center; padding:32px; color:#94a3b8;">Chưa có đơn thu mua nào phù hợp với điều kiện lọc.</td></tr>
     </c:when>
     <c:otherwise>
      <c:forEach items="${requests}" var="req">
       <tr>
        <td>
         <strong><c:out value="${req.requestCode}"/></strong><br>
         <c:choose>
          <c:when test="${req.intakeType == 'WALK_IN_COUNTER'}">
           <span class="badge-status badge-walkin">🏢 Tại quầy</span>
          </c:when>
          <c:otherwise>
           <span class="badge-status badge-online">🌐 Online</span>
          </c:otherwise>
         </c:choose>
        </td>
        <td>
         <strong><c:out value="${req.customerName != null ? req.customerName : 'Khách vãng lai'}"/></strong><br>
         <small style="color:#64748b;"><c:out value="${req.customerPhone}"/></small>
        </td>
        <td>
         <strong><c:out value="${req.targetBranch != null ? req.targetBranch.name : 'Chưa gán'}"/></strong>
        </td>
        <td>
         <strong><c:out value="${req.items.size()}"/></strong> cuốn
        </td>
        <td>
         <strong style="color:#059669; font-size:14px;"><fmt:formatNumber value="${req.totalFinalPrice}" type="number" groupingUsed="true"/> đ</strong>
        </td>
        <td>
         <c:choose>
          <c:when test="${req.status == 'SUBMITTED'}"><span class="badge-status badge-submitted">Mới gửi / Chờ báo giá</span></c:when>
          <c:when test="${req.status == 'PRE_QUOTED'}"><span class="badge-status badge-pre_quoted">Đã báo giá sơ bộ</span></c:when>
          <c:when test="${req.status == 'CUSTOMER_ACCEPTED'}"><span class="badge-status badge-customer_accepted">Khách đã đồng ý</span></c:when>
          <c:when test="${req.status == 'ITEM_RECEIVED'}"><span class="badge-status badge-item_received">Đã nhận sách tại chi nhánh</span></c:when>
          <c:when test="${req.status == 'COMPLETED'}"><span class="badge-status badge-completed">Hoàn tất / Đã nhập kho</span></c:when>
          <c:otherwise><span class="badge-status badge-cancelled"><c:out value="${req.status}"/></span></c:otherwise>
         </c:choose>
        </td>
        <td style="color:#64748b; font-size:12.5px;">
         <c:out value="${req.createdAt}"/>
        </td>
        <td>
         <a href="${base}/admin/buybacks/${req.id}" class="btn-sm btn-outline">Xem chi tiết &rarr;</a>
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
