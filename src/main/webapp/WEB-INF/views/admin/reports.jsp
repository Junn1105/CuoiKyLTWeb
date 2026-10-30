<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Báo Cáo Hiệu Suất &amp; Tồn Kho Lâu Ngày · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <style>
  .admin-shell { max-width: 1240px; margin: 0 auto; padding: 24px 20px; }
  .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px; }
  .kpi-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 18px 20px; box-shadow: 0 1px 4px rgba(0,0,0,0.04); }
  .kpi-card .eyebrow { font-size: 11.5px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 6px; display: block; }
  .kpi-card .value { font-size: 24px; font-weight: 800; color: #0f172a; margin: 0 0 4px 0; }
  .kpi-card .value.green { color: #059669; }
  .kpi-card .value.blue { color: #2563eb; }
  .kpi-card .value.red { color: #dc2626; }
  .panel-box { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
  .data-table th { background: #f8fafc; padding: 10px 12px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .btn-sm { padding: 5px 12px; font-size: 12px; font-weight: 600; border-radius: 6px; text-decoration: none; border: 1px solid transparent; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  .btn-primary { background: #2563eb; color: #fff; }
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
   <a href="${base}/admin/reports" class="btn-sm btn-primary">📈 Báo cáo ERP</a>
   <a href="${base}/admin/transfers" class="btn-sm btn-outline">🚚 Điều chuyển kho</a>
   <a href="${base}/admin/buybacks" class="btn-sm btn-outline">📖 Thu mua C2B</a>
  </div>
 </header>

 <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 20px; flex-wrap:wrap; gap:12px;">
  <div>
   <span class="eyebrow" style="font-weight:700; color:#2563eb; font-size:12px; text-transform:uppercase;">PHÂN HỆ BÁO CÁO TÀI CHÍNH &amp; TỒN KHO LÂU NGÀY (AGING STOCK)</span>
   <h1 style="margin:4px 0 6px; font-size:24px; color:#0f172a;">Báo Cáo Hiệu Suất Chuỗi &amp; Tồn Đọng</h1>
   <p style="margin:0; color:#64748b; font-size:14px;">Giám sát chi phí thu mua, giá trị kho theo giá vốn/giá bán và phát hiện các cuốn sách tồn kho trên 90 ngày để đề xuất giảm giá hoặc điều chuyển.</p>
  </div>

  <c:if test="${isSuperAdmin}">
   <form method="get" action="${base}/admin/reports" style="display:flex; gap:8px; align-items:center;">
    <label for="branchSelect" style="font-size:13px; font-weight:600; color:#475569;">Chi nhánh:</label>
    <select id="branchSelect" name="branchId" onchange="this.form.submit()" style="padding:6px 10px; font-size:13px; border:1px solid #cbd5e1; border-radius:6px; background:#fff;">
     <option value="">-- Tất cả chi nhánh toàn chuỗi --</option>
     <c:forEach items="${branches}" var="b">
      <option value="${b.id}" ${b.id == targetBranch ? 'selected' : ''}><c:out value="${b.name}"/></option>
     </c:forEach>
    </select>
   </form>
  </c:if>
 </div>

 <!-- BẢNG 1: HIỆU SUẤT TÀI CHÍNH & GIÁ TRỊ KHO TỪNG CHI NHÁNH -->
 <div class="panel-box">
  <h2 style="font-size:16px; margin:0 0 16px; color:#0f172a;">1. Bảng Hiệu Suất Thu Mua, Doanh Thu &amp; Định Giá Tồn Kho</h2>
  <div style="overflow-x:auto;">
   <table class="data-table">
    <thead>
     <tr>
      <th>Chi nhánh</th>
      <th>Tổng Chi Thu Mua (Cost)</th>
      <th>Doanh Thu Bán Ra (Sales)</th>
      <th>Lợi Nhuận Gộp Ước Tính</th>
      <th>Tồn Kho Sẵn Có</th>
      <th>Giá Trị Kho Theo Giá Vốn</th>
      <th>Giá Trị Kho Theo Niêm Yết</th>
     </tr>
    </thead>
    <tbody>
     <c:choose>
      <c:when test="${empty performanceReports}">
       <tr><td colspan="7" style="text-align:center; padding:24px; color:#94a3b8;">Không có dữ liệu báo cáo chi nhánh.</td></tr>
      </c:when>
      <c:otherwise>
       <c:forEach items="${performanceReports}" var="rep">
        <tr>
         <td>
          <strong><c:out value="${rep.branchName}"/></strong><br>
          <small style="color:#64748b;"><code><c:out value="${rep.branchCode}"/></code></small>
         </td>
         <td style="color:#dc2626; font-weight:600;">
          <fmt:formatNumber value="${rep.totalBuybackPayout}" type="number" groupingUsed="true"/> đ
         </td>
         <td style="color:#2563eb; font-weight:600;">
          <fmt:formatNumber value="${rep.totalSoldRevenue}" type="number" groupingUsed="true"/> đ
         </td>
         <td style="font-weight:700; color:${rep.grossProfit >= 0 ? '#059669' : '#dc2626'};">
          <fmt:formatNumber value="${rep.grossProfit}" type="number" groupingUsed="true"/> đ
         </td>
         <td>
          <strong><c:out value="${rep.currentInventoryCount}"/></strong> bản
         </td>
         <td>
          <fmt:formatNumber value="${rep.inventoryCostValue}" type="number" groupingUsed="true"/> đ
         </td>
         <td style="font-weight:600; color:#0f172a;">
          <fmt:formatNumber value="${rep.inventoryRetailValue}" type="number" groupingUsed="true"/> đ
         </td>
        </tr>
       </c:forEach>
      </c:otherwise>
     </c:choose>
    </tbody>
   </table>
  </div>
 </div>

 <!-- BẢNG 2: BẢN SÁCH TỒN KHO LÂU NGÀY (AGING DEAD STOCK > 90 NGÀY) -->
 <div class="panel-box">
  <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
   <div>
    <h2 style="font-size:16px; margin:0; color:#0f172a;">2. Cảnh Báo Tồn Kho Lâu Ngày (&gt; ${thresholdDays} ngày)</h2>
    <small style="color:#64748b;">Các cuốn sách nằm trên kệ quá lâu chưa bán được. Cần xem xét áp dụng giảm giá Markdown hoặc điều chuyển sang chi nhánh khác.</small>
   </div>
   <span style="font-size:13px; font-weight:700; color:#dc2626;">Phát hiện ${agingStock.size()} cuốn</span>
  </div>

  <div style="overflow-x:auto;">
   <table class="data-table">
    <thead>
     <tr>
      <th>Mã vạch (Barcode)</th>
      <th>Tên sách</th>
      <th>Tác giả</th>
      <th>Chi nhánh hiện tại</th>
      <th>Phẩm cấp</th>
      <th>Giá vốn (Cost)</th>
      <th>Giá niêm yết</th>
      <th>Thời gian nằm kệ</th>
      <th>Khuyến nghị đề xuất</th>
     </tr>
    </thead>
    <tbody>
     <c:choose>
      <c:when test="${empty agingStock}">
       <tr><td colspan="9" style="text-align:center; padding:24px; color:#059669; font-weight:600;">✓ Tuyệt vời! Không có cuốn sách nào tồn kho vượt quá ${thresholdDays} ngày.</td></tr>
      </c:when>
      <c:otherwise>
       <c:forEach items="${agingStock}" var="ag">
        <tr>
         <td><code><c:out value="${ag.serialCode}"/></code></td>
         <td><strong><c:out value="${ag.title}"/></strong></td>
         <td><c:out value="${ag.author}"/></td>
         <td><c:out value="${ag.branchName}"/></td>
         <td><span style="font-weight:700; color:#2563eb;"><c:out value="${ag.grade}"/></span></td>
         <td><fmt:formatNumber value="${ag.costPrice}" type="number" groupingUsed="true"/> đ</td>
         <td style="font-weight:600;"><fmt:formatNumber value="${ag.sellingPrice}" type="number" groupingUsed="true"/> đ</td>
         <td>
          <span style="background:#fee2e2; color:#991b1b; padding:2px 8px; border-radius:4px; font-weight:700; font-size:12px;">
           <c:out value="${ag.daysInStock}"/> ngày
          </span>
         </td>
         <td>
          <a href="${base}/admin/transfers/new" class="btn-sm btn-outline" style="font-size:11.5px; padding:3px 8px;">
           🚚 Đề xuất điều chuyển
          </a>
         </td>
        </tr>
       </c:forEach>
      </c:otherwise>
     </c:choose>
    </tbody>
   </table>
  </div>
 </div>
</main>
</body>
</html>
