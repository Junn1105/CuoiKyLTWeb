<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Chi Tiết Đơn Thu Mua · <c:out value="${request.requestCode}"/> · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1180px; margin: 0 auto; padding: 24px 20px; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .badge-status { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .badge-submitted { background: #fef3c7; color: #92400e; }
  .badge-pre_quoted { background: #e0e7ff; color: #3730a3; }
  .badge-customer_accepted { background: #dbeafe; color: #1e40af; }
  .badge-item_received { background: #f3e8ff; color: #6b21a8; }
  .badge-completed { background: #dcfce7; color: #166534; }
  .badge-customer_rejected, .badge-cancelled { background: #fee2e2; color: #991b1b; }
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

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <!-- BANNER THÔNG TIN PHIẾU THU MUA -->
 <div class="panel-box">
  <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:14px; margin-bottom:16px;">
   <div>
    <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px;">CHI TIẾT ĐƠN THU MUA SÁCH CŨ C2B</span>
    <h1 style="margin:4px 0; font-size:22px; color:#0f172a;"><c:out value="${request.requestCode}"/></h1>
    <small style="color:#64748b;">Thời gian lập: <c:out value="${request.createdAt}"/> &bull; Kênh: <strong><c:out value="${request.intakeType}"/></strong></small>
   </div>
   <div style="text-align:right;">
    <div style="margin-bottom:6px;">
     <c:choose>
      <c:when test="${request.status == 'SUBMITTED'}"><span class="badge-status badge-submitted">Mới gửi / Chờ báo giá</span></c:when>
      <c:when test="${request.status == 'PRE_QUOTED'}"><span class="badge-status badge-pre_quoted">Đã báo giá sơ bộ</span></c:when>
      <c:when test="${request.status == 'CUSTOMER_ACCEPTED'}"><span class="badge-status badge-customer_accepted">Khách đã đồng ý</span></c:when>
      <c:when test="${request.status == 'ITEM_RECEIVED'}"><span class="badge-status badge-item_received">Đã nhận sách tại chi nhánh</span></c:when>
      <c:when test="${request.status == 'COMPLETED'}"><span class="badge-status badge-completed">Hoàn tất / Đã nhập kho</span></c:when>
      <c:otherwise><span class="badge-status badge-cancelled"><c:out value="${request.status}"/></span></c:otherwise>
     </c:choose>
    </div>
    <div style="font-size:18px; font-weight:700; color:#059669;">
     Tổng chi trả: <fmt:formatNumber value="${request.totalFinalPrice}" type="number" groupingUsed="true"/> đ
    </div>
   </div>
  </div>

  <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:14px; background:#f8fafc; padding:14px; border-radius:10px;">
   <div>
    <span style="font-size:12px; color:#64748b;">Khách hàng:</span><br>
    <strong><c:out value="${request.customerName != null ? request.customerName : 'Khách vãng lai'}"/></strong><br>
    <small><c:out value="${request.customerPhone}"/></small>
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Chi nhánh tiếp nhận:</span><br>
    <strong><c:out value="${request.targetBranch != null ? request.targetBranch.name : 'Chưa gán'}"/></strong>
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Nhân viên thẩm định:</span><br>
    <strong><c:out value="${request.appraiser != null ? request.appraiser.fullName : 'Chưa phân công'}"/></strong>
   </div>
   <div>
    <span style="font-size:12px; color:#64748b;">Ghi chú:</span><br>
    <small><c:out value="${request.staffNote != null ? request.staffNote : 'Không có'}"/></small>
   </div>
  </div>
 </div>

 <!-- DANH SÁCH CÁC CUỐN SÁCH -->
 <div class="panel-box">
  <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">Danh Sách Sách Trong Đơn (<c:out value="${request.items.size()}"/> cuốn)</h2>
  <div style="overflow-x:auto;">
   <table class="data-table">
    <thead>
     <tr>
      <th>Tên sách / ISBN</th>
      <th>Giá bìa</th>
      <th>Ghi chú tình trạng khách gửi</th>
      <th>Báo giá sơ bộ</th>
      <th>Phẩm cấp thực tế</th>
      <th>Giá thu mua chốt</th>
      <th>Mã vạch BookItem đã sinh</th>
     </tr>
    </thead>
    <tbody>
     <c:forEach items="${request.items}" var="it">
      <tr>
       <td>
        <strong><c:out value="${it.bookTitle != null ? it.bookTitle.title : it.customBookTitle}"/></strong><br>
        <small style="color:#64748b;">ISBN: <c:out value="${it.isbn != null ? it.isbn : '---'}"/></small>
       </td>
       <td>
        <fmt:formatNumber value="${it.declaredCoverPrice}" type="number" groupingUsed="true"/> đ
       </td>
       <td>
        <small><c:out value="${it.customerConditionNote != null ? it.customerConditionNote : '---'}"/></small>
       </td>
       <td>
        <c:choose>
         <c:when test="${it.preQuotedPrice != null}">
          <fmt:formatNumber value="${it.preQuotedPrice}" type="number" groupingUsed="true"/> đ
         </c:when>
         <c:otherwise><span style="color:#94a3b8;">Chưa báo giá</span></c:otherwise>
        </c:choose>
       </td>
       <td>
        <c:choose>
         <c:when test="${it.finalGrade != null}">
          <span style="font-weight:700; color:#2563eb;">Hạng <c:out value="${it.finalGrade}"/></span>
         </c:when>
         <c:otherwise>---</c:otherwise>
        </c:choose>
       </td>
       <td style="color:#059669; font-weight:700;">
        <c:choose>
         <c:when test="${it.finalPrice != null}">
          <fmt:formatNumber value="${it.finalPrice}" type="number" groupingUsed="true"/> đ
         </c:when>
         <c:otherwise>---</c:otherwise>
        </c:choose>
       </td>
       <td>
        <c:choose>
         <c:when test="${it.spawnedBookItemId != null}">
          <code style="background:#e0f2fe; color:#0369a1; padding:2px 8px; border-radius:4px; font-weight:700;">Item #<c:out value="${it.spawnedBookItemId}"/></code>
         </c:when>
         <c:otherwise><span style="color:#94a3b8;">Chưa nhập kho</span></c:otherwise>
        </c:choose>
       </td>
      </tr>
     </c:forEach>
    </tbody>
   </table>
  </div>

  <!-- CÁC THAO TÁC THEO TRẠNG THÁI -->
  <c:if test="${request.status == 'SUBMITTED'}">
   <div class="action-box">
    <h3 style="margin:0 0 12px; font-size:15px; color:#1e293b;">Báo giá sơ bộ trực tuyến cho khách hàng</h3>
    <form action="${base}/admin/buybacks/${request.id}/pre-quote" method="post">
     <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap:12px; margin-bottom:14px;">
      <c:forEach items="${request.items}" var="it">
       <div style="background:#fff; padding:10px; border-radius:8px; border:1px solid #cbd5e1;">
        <strong style="font-size:13px;"><c:out value="${it.bookTitle != null ? it.bookTitle.title : it.customBookTitle}"/></strong>
        <div style="margin-top:6px;">
         <label style="font-size:12px; color:#475569;">Giá báo sơ bộ (đ):</label>
         <input type="number" name="quote_${it.id}" value="${it.declaredCoverPrice != null ? it.declaredCoverPrice * 0.25 : 30000}" step="1000" style="width:100%; padding:6px; border:1px solid #cbd5e1; border-radius:6px;">
        </div>
       </div>
      </c:forEach>
     </div>
     <div style="display:flex; justify-content:flex-end;">
      <button type="submit" class="btn-sm btn-primary">Gửi Báo Giá Sơ Bộ</button>
     </div>
    </form>
   </div>
  </c:if>

  <c:if test="${request.status == 'CUSTOMER_ACCEPTED'}">
   <div class="action-box" style="display:flex; justify-content:space-between; align-items:center;">
    <div>
     <h3 style="margin:0 0 4px; font-size:15px; color:#1e293b;">Khách hàng đã chấp thuận giá sơ bộ</h3>
     <p style="margin:0; font-size:13px; color:#64748b;">Khi khách mang sách đến cửa hàng hoặc bưu phẩm chuyển phát tới, hãy nhấn xác nhận.</p>
    </div>
    <form action="${base}/admin/buybacks/${request.id}/receive" method="post">
     <button type="submit" class="btn-sm btn-warning">📦 Đã Nhận Sách Tại Chi Nhánh</button>
    </form>
   </div>
  </c:if>

  <c:if test="${request.status == 'ITEM_RECEIVED'}">
   <div class="action-box">
    <h3 style="margin:0 0 12px; font-size:15px; color:#1e293b;">Nghiệm thu thực tế &amp; Sinh mã vạch nhập kho</h3>
    <form action="${base}/admin/buybacks/${request.id}/finalize" method="post">
     <c:forEach items="${request.items}" var="it">
      <div style="background:#fff; padding:12px; border-radius:8px; border:1px solid #cbd5e1; margin-bottom:10px; display:grid; grid-template-columns: 2fr 1.5fr 1.5fr auto; gap:12px; align-items:center;">
       <input type="hidden" name="itemId" value="${it.id}">
       <div>
        <strong><c:out value="${it.bookTitle != null ? it.bookTitle.title : it.customBookTitle}"/></strong>
        <div style="font-size:12px; color:#64748b;">Giá bìa: <fmt:formatNumber value="${it.declaredCoverPrice}" type="number"/> đ</div>
       </div>
       <div>
        <label style="font-size:12px; font-weight:600;">Phẩm cấp sau giám định:</label>
        <select name="finalGrade" style="width:100%; padding:6px; border:1px solid #cbd5e1; border-radius:6px;">
         <option value="S">Hạng S - Như mới (95-99%)</option>
         <option value="A">Hạng A - Rất tốt (80-90%)</option>
         <option value="B" selected>Hạng B - Khá tốt (65-75%)</option>
         <option value="C">Hạng C - Đọc được (&lt;65%)</option>
        </select>
       </div>
       <div>
        <label style="font-size:12px; font-weight:600;">Giá thu mua chốt (đ):</label>
        <input type="number" name="customPrice" placeholder="Tự động theo phẩm cấp" step="1000" style="width:100%; padding:6px; border:1px solid #cbd5e1; border-radius:6px;">
       </div>
       <div style="display:flex; align-items:center; gap:6px;">
        <input type="checkbox" name="accepted" value="${it.id}" checked id="acc_${it.id}">
        <label for="acc_${it.id}" style="font-size:13px; font-weight:600; color:#059669;">Nhận mua</label>
       </div>
      </div>
     </c:forEach>
     <div style="display:flex; justify-content:flex-end; margin-top:14px;">
      <button type="submit" class="btn-sm btn-success" style="padding:10px 20px;">
       ✓ Hoàn Tất Thẩm Định &amp; Sinh Mã Vạch Nhập Kho
      </button>
     </div>
    </form>
   </div>
  </c:if>
 </div>
</main>
</body>
</html>
