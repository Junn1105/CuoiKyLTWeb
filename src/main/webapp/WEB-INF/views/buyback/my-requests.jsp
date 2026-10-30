<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Lịch Sử Bán Sách Cũ Của Tôi · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .portal-shell { max-width: 1080px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
  .data-table th { background: #f8fafc; padding: 12px 14px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .badge-status { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .badge-submitted { background: #fef3c7; color: #92400e; }
  .badge-pre_quoted { background: #e0e7ff; color: #3730a3; }
  .badge-customer_accepted { background: #dbeafe; color: #1e40af; }
  .badge-item_received { background: #f3e8ff; color: #6b21a8; }
  .badge-completed { background: #dcfce7; color: #166534; }
  .badge-cancelled { background: #fee2e2; color: #991b1b; }
  .btn-sm { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; cursor: pointer; text-decoration: none; border: 1px solid transparent; display: inline-flex; align-items: center; gap: 4px; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-success { background: #059669; color: #fff; }
  .btn-danger { background: #dc2626; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="portal-shell">
 <header class="cart-header" style="margin-bottom: 20px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/home" class="btn-sm btn-outline">← Về trang chủ</a>
   <a href="${base}/buybacks/new" class="btn-sm btn-primary">+ Gửi yêu cầu mới</a>
  </div>
 </header>

 <div style="margin-bottom: 20px;">
  <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">THEO DÕI ĐƠN BÁN SÁCH CŨ</span>
  <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Các Yêu Cầu Thu Mua Đã Gửi Của Bạn</h1>
  <p style="margin:0; color:#64748b; font-size:14px;">Xem tiến độ thẩm định, duyệt giá sơ bộ từ chi nhánh và theo dõi tiền thu mua sách cũ.</p>
 </div>

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <div class="panel-box" style="padding:0; overflow:hidden;">
  <table class="data-table">
   <thead>
    <tr>
     <th>Mã yêu cầu</th>
     <th>Chi nhánh tiếp nhận</th>
     <th>Số cuốn</th>
     <th>Giá sơ bộ / Chốt</th>
     <th>Trạng thái</th>
     <th>Ngày gửi</th>
     <th>Hành động</th>
    </tr>
   </thead>
   <tbody>
    <c:choose>
     <c:when test="${empty requests}">
      <tr><td colspan="7" style="text-align:center; padding:32px; color:#94a3b8;">Bạn chưa gửi yêu cầu bán lại sách nào. Hãy thử gửi đơn đầu tiên!</td></tr>
     </c:when>
     <c:otherwise>
      <c:forEach items="${requests}" var="req">
       <tr>
        <td><strong><c:out value="${req.requestCode}"/></strong></td>
        <td><c:out value="${req.targetBranch.name}"/></td>
        <td><strong><c:out value="${req.items.size()}"/></strong> cuốn</td>
        <td>
         <c:choose>
          <c:when test="${req.status == 'COMPLETED'}">
           <strong style="color:#059669;"><fmt:formatNumber value="${req.totalFinalPrice}" type="number" groupingUsed="true"/> đ</strong>
          </c:when>
          <c:when test="${req.totalEstimatedPrice > 0}">
           <strong style="color:#2563eb;"><fmt:formatNumber value="${req.totalEstimatedPrice}" type="number" groupingUsed="true"/> đ</strong>
          </c:when>
          <c:otherwise><span style="color:#94a3b8;">Đang chờ định giá</span></c:otherwise>
         </c:choose>
        </td>
        <td>
         <c:choose>
          <c:when test="${req.status == 'SUBMITTED'}"><span class="badge-status badge-submitted">Đang thẩm định</span></c:when>
          <c:when test="${req.status == 'PRE_QUOTED'}"><span class="badge-status badge-pre_quoted">Đã có báo giá</span></c:when>
          <c:when test="${req.status == 'CUSTOMER_ACCEPTED'}"><span class="badge-status badge-customer_accepted">Đã đồng ý giá</span></c:when>
          <c:when test="${req.status == 'ITEM_RECEIVED'}"><span class="badge-status badge-item_received">Sách đã tới quầy</span></c:when>
          <c:when test="${req.status == 'COMPLETED'}"><span class="badge-status badge-completed">Đã thanh toán</span></c:when>
          <c:otherwise><span class="badge-status badge-cancelled"><c:out value="${req.status}"/></span></c:otherwise>
         </c:choose>
        </td>
        <td style="color:#64748b; font-size:12.5px;"><c:out value="${req.createdAt}"/></td>
        <td>
         <c:if test="${req.status == 'PRE_QUOTED'}">
          <div style="display:flex; gap:6px;">
           <form action="${base}/buybacks/${req.id}/accept" method="post">
            <button type="submit" class="btn-sm btn-success">✓ Đồng ý</button>
           </form>
           <form action="${base}/buybacks/${req.id}/reject" method="post">
            <button type="submit" class="btn-sm btn-danger">✕ Từ chối</button>
           </form>
          </div>
         </c:if>
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
