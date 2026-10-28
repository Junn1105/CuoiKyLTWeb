<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Quản lý Chuỗi Cửa Hàng & Điều Chuyển Kho · Mộc Sách</title>
 <meta name="base-url" content="${base}">
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <script defer src="${base}/js/home.js"></script>
 <script defer src="${base}/js/checkout.js"></script>
 <script defer src="${base}/js/admin-stores.js"></script>
 <style>
  .admin-nav-pills { display: flex; gap: 8px; flex-wrap: wrap; }
  .tab-button { padding: 8px 16px; border-radius: 8px; font-weight: 600; font-size: 13.5px; border: 1px solid #cbd8eb; background: #fff; color: #1e293b; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
  .tab-button.active, .tab-button:hover { background: #1158c5; color: #fff; border-color: #1158c5; }
  .status-badge.draft { background: #f1f5f9; color: #475569; }
  .status-badge.approved { background: #eff6ff; color: #1d4ed8; }
  .status-badge.transit, .status-badge.in_transit { background: #fef3c7; color: #b45309; }
  .status-badge.received { background: #ecfdf5; color: #047857; }
  .status-badge.cancelled { background: #fef2f2; color: #b91c1c; }
  .transfer-flow-arrow { font-weight: bold; color: #2563eb; padding: 0 4px; }
  .inline-actions { display: flex; gap: 6px; flex-wrap: wrap; }
  .btn-sm { padding: 4px 10px; font-size: 12px; font-weight: 600; border-radius: 6px; border: 1px solid transparent; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; text-decoration: none; }
  .btn-primary { background: #1158c5; color: #fff; }
  .btn-primary:hover { background: #0c4399; }
  .btn-success { background: #059669; color: #fff; }
  .btn-success:hover { background: #047857; }
  .btn-warning { background: #d97706; color: #fff; }
  .btn-warning:hover { background: #b45309; }
  .btn-danger { background: #dc2626; color: #fff; }
  .btn-danger:hover { background: #b91c1c; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  .btn-outline:hover { background: #f8fafc; border-color: #94a3b8; }
  .copy-pick-table { max-height: 320px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px; margin: 10px 0; background: #fff; }
  .copy-pick-table table { width: 100%; border-collapse: collapse; font-size: 12.5px; }
  .copy-pick-table th { background: #f1f5f9; padding: 9px 10px; position: sticky; top: 0; text-align: left; z-index: 2; border-bottom: 1px solid #cbd5e1; }
  .copy-pick-table td { padding: 7px 10px; border-bottom: 1px solid #edf2f7; vertical-align: middle; }
  .detail-box { background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 12px; padding: 18px; margin-bottom: 24px; }
  .detail-box h3 { margin: 0 0 12px; font-size: 16px; color: #1e293b; display: flex; justify-content: space-between; align-items: center; }
  .create-card { background: #f8fbff; border: 1.5px solid #bfdbfe; border-radius: 12px; padding: 20px; margin-top: 20px; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="cart-shell">
 <header class="cart-header">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div class="admin-nav-pills">
   <c:if test="${userContext.isAdmin()}">
    <a class="tab-button ${tab == 'stores' ? 'active' : ''}" href="${base}/admin/stores?tab=stores#stores-section" onclick="showTab('stores', event)">🏢 Chi nhánh (${stores.size()})</a>
   </c:if>
   <a class="tab-button ${tab == 'transfers' ? 'active' : ''}" href="${base}/admin/stores?tab=transfers#transfers-section" onclick="showTab('transfers', event)">🚚 Điều chuyển kho (${transfers.size()})</a>
   <c:if test="${userContext.isAdmin() || userContext.isManager()}">
    <a class="tab-button ${tab == 'staff' ? 'active' : ''}" href="${base}/admin/stores?tab=staff#staff-section" onclick="showTab('staff', event)">👥 Nhân sự chi nhánh (${staffAssignments.size()})</a>
   </c:if>
   <c:if test="${userContext.isAdmin()}">
    <a class="tab-button ${tab == 'users' ? 'active' : ''}" href="${base}/admin/stores?tab=users#users-section" onclick="showTab('users', event)">👤 Tài khoản & Phân quyền (${allUsers.size()})</a>
   </c:if>
   <a class="tab-button btn-outline" href="${base}/admin/my-store">🏪 Chi nhánh của tôi</a>
   <c:if test="${userContext.isAdmin()}">
    <a class="tab-button btn-outline" href="${base}/admin">📊 Dashboard Admin</a>
   </c:if>
  </div>
  <div class="header-links">
   <a href="${base}/home">← Về trang khách</a>
   <shop:notifications/>
   <a href="${base}/account"><c:out value="${displayName}"/></a>
  </div>
 </header>

 <div class="cart-heading">
  <span class="eyebrow">HỆ THỐNG PHÂN QUYỀN & CHUỖI CỬA HÀNG MỘC SÁCH</span>
  <h1>Quản Lý Mạng Lưới Chi Nhánh & Điều Chuyển Kho Sách Cũ</h1>
  <p>
   Giám sát tồn kho theo từng chi nhánh, phân công nhân sự và quản lý luân chuyển sách vật lý.
   <c:if test="${userContext.isAdmin()}"><strong>(Bạn đang đăng nhập với quyền Quản trị viên cao nhất - ADMIN)</strong></c:if>
   <c:if test="${userContext.isManager()}"><strong>(Bạn đang quản lý chi nhánh: <c:out value="${userContext.storeName()}"/>)</strong></c:if>
  </p>
 </div>

 <c:if test="${not empty success}"><p class="cart-message success" role="status"><c:out value="${success}"/></p></c:if>
 <c:if test="${not empty error}"><p class="cart-message error" role="alert"><c:out value="${error}"/></p></c:if>

 <!-- ==================== PHẦN 1: QUẢN LÝ CHI NHÁNH (ADMIN ONLY) ==================== -->
 <c:if test="${userContext.isAdmin()}">
  <section id="stores-section" class="panel admin-section tab-content" style="${tab == 'stores' ? '' : 'display:none;'}">
   <div class="panel-top">
    <div>
     <span class="eyebrow">HỆ THỐNG CƠ SỞ MỘC SÁCH</span>
     <h2>Danh sách Chi nhánh Cửa hàng & Hiệu suất kinh doanh</h2>
    </div>
    <a class="checkout-button" href="#add-store-form" style="padding: 8px 14px; font-size: 13px;">+ Thêm Chi Nhánh Mới</a>
   </div>

   <div class="table-scroll">
    <table class="admin-table">
     <thead>
      <tr>
       <th>Mã / Tên Chi Nhánh</th>
       <th>Địa chỉ & Điện thoại</th>
       <th>Trạng thái</th>
       <th>Tồn khả dụng</th>
       <th>Giá trị kho (Giá nhập)</th>
       <th>Giá trị kho (Giá bán)</th>
       <th>Doanh thu tích lũy</th>
       <th>Nhân sự</th>
       <th>Thao tác</th>
      </tr>
     </thead>
     <tbody>
      <c:forEach items="${stores}" var="st">
       <tr>
        <td>
         <strong><c:out value="${st.storeName}"/></strong><br>
         <code><c:out value="${st.storeCode}"/></code> · Khai trương: <c:out value="${st.openedAt}"/>
        </td>
        <td>
         <c:out value="${st.address}"/><br>
         <small class="muted">📞 <c:out value="${st.phone}"/></small>
        </td>
        <td>
         <c:choose>
          <c:when test="${st.status == 'ACTIVE'}"><span class="status-badge ok">Đang hoạt động</span></c:when>
          <c:when test="${st.status == 'TEMPORARILY_CLOSED'}"><span class="status-badge warn">Tạm nghỉ</span></c:when>
          <c:otherwise><span class="status-badge error">Đã đóng</span></c:otherwise>
         </c:choose>
        </td>
        <td>
         <strong><c:out value="${st.availableCopies}"/></strong> / <c:out value="${st.totalCopies}"/> bản<br>
         <small class="muted">(<c:out value="${st.distinctBooks}"/> đầu sách)</small>
        </td>
        <td><c:out value="${st.inventoryCostLabel}"/></td>
        <td><c:out value="${st.inventorySaleLabel}"/></td>
        <td class="price-col"><strong><c:out value="${st.revenueLabel}"/></strong><br><small class="muted">(<c:out value="${st.orderCount}"/> đơn)</small></td>
        <td><strong><c:out value="${st.activeStaffCount}"/></strong> nhân viên</td>
        <td>
         <details>
          <summary class="btn-sm btn-outline">✎ Sửa</summary>
          <form method="post" action="${base}/admin/stores/${st.storeId}/update" style="margin-top:8px; display:grid; gap:6px; min-width:240px; background:#f8fafc; padding:10px; border-radius:8px; border:1px solid #cbd5e1;">
           <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
           <label style="font-size:11.5px; font-weight:600;">Tên chi nhánh:</label>
           <input type="text" name="storeName" value="<c:out value='${st.storeName}'/>" required style="font-size:12px; padding:4px;">
           <label style="font-size:11.5px; font-weight:600;">Địa chỉ:</label>
           <input type="text" name="address" value="<c:out value='${st.address}'/>" required style="font-size:12px; padding:4px;">
           <label style="font-size:11.5px; font-weight:600;">Điện thoại:</label>
           <input type="text" name="phone" value="<c:out value='${st.phone}'/>" style="font-size:12px; padding:4px;">
           <label style="font-size:11.5px; font-weight:600;">Trạng thái:</label>
           <select name="status" style="font-size:12px; padding:4px;">
            <option value="ACTIVE" ${st.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Hoạt động)</option>
            <option value="TEMPORARILY_CLOSED" ${st.status == 'TEMPORARILY_CLOSED' ? 'selected' : ''}>TEMPORARILY_CLOSED (Tạm nghỉ)</option>
            <option value="CLOSED" ${st.status == 'CLOSED' ? 'selected' : ''}>CLOSED (Đã đóng cửa)</option>
           </select>
           <button type="submit" class="btn-sm btn-primary" style="margin-top:4px;">Lưu thay đổi</button>
          </form>
         </details>
        </td>
       </tr>
      </c:forEach>
     </tbody>
    </table>
   </div>

   <hr class="admin-divider" id="add-store-form">
   <div class="panel-top">
    <h3>+ Mở Thêm Chi Nhánh Mới Vào Hệ Thống Chuỗi</h3>
   </div>
   <form method="post" action="${base}/admin/stores/create" class="admin-book-form">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <div class="form-row-4">
     <div class="field-group">
      <label>Mã chi nhánh (Duy nhất, viết hoa) <span>*</span></label>
      <input type="text" name="storeCode" placeholder="Ví dụ: HCM-Q1, HN-CG" required minlength="2" maxlength="30">
     </div>
     <div class="field-group">
      <label>Tên chi nhánh <span>*</span></label>
      <input type="text" name="storeName" placeholder="Ví dụ: Không gian sách Mộc Sách Quận 1" required minlength="2" maxlength="150">
     </div>
     <div class="field-group">
      <label>Số điện thoại / Hotline</label>
      <input type="text" name="phone" placeholder="Ví dụ: 0901234567">
     </div>
     <div class="field-group">
      <label>Trạng thái ban đầu</label>
      <select name="status">
       <option value="ACTIVE">Đang hoạt động (ACTIVE)</option>
       <option value="TEMPORARILY_CLOSED">Tạm nghỉ sửa chữa (TEMPORARILY_CLOSED)</option>
      </select>
     </div>
    </div>
    <div class="form-row-4" style="grid-template-columns: 3fr 1fr;">
     <div class="field-group">
      <label>Địa chỉ chi nhánh <span>*</span></label>
      <input type="text" name="address" placeholder="Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố..." required minlength="5" maxlength="500">
     </div>
     <div class="field-group" style="align-self: flex-end;">
      <button type="submit" class="checkout-button" style="width:100%; height:42px;">+ Tạo Chi Nhánh</button>
     </div>
    </div>
   </form>
  </section>
 </c:if>

 <!-- ==================== PHẦN 2: ĐIỀU CHUYỂN KHO NỘI BỘ ==================== -->
 <section id="transfers-section" class="panel admin-section tab-content" style="${tab == 'transfers' ? '' : 'display:none;'}">
  <div class="panel-top">
   <div>
    <span class="eyebrow">QUY TRÌNH LUÂN CHUYỂN HÀNG HÓA CHUỖI CỬA HÀNG</span>
    <h2>Quản lý Điều chuyển Sách giữa các Chi nhánh (Inter-Store Transfers)</h2>
    <p class="hint" style="margin:4px 0 0 0; color:#dc2626; font-weight:600;">
     Lưu ý quy định bảo mật: <strong>Duy nhất Quản trị viên (ADMIN) mới có quyền Duyệt phiếu điều chuyển liên chi nhánh</strong>. Quản lý chi nhánh & nhân viên phụ trách xuất/nhập kho.
    </p>
   </div>
   <a class="checkout-button" href="#create-transfer-box" style="padding: 8px 14px; font-size: 13px;">+ Lập Phiếu Điều Chuyển Mới</a>
  </div>

  <c:if test="${not empty selectedTransfer}">
   <div class="detail-box">
    <h3>
     <span>Chi tiết Phiếu Điều Chuyển: <code><c:out value="${selectedTransfer.transferCode}"/></code></span>
     <a href="${base}/admin/stores?tab=transfers#transfers-section" class="btn-sm btn-outline">× Đóng chi tiết</a>
    </h3>
    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap:12px; margin-bottom:14px; font-size:13px;">
     <div><strong>Tuyến chuyển:</strong> <c:out value="${selectedTransfer.fromStoreName}"/> <span class="transfer-flow-arrow">➔</span> <c:out value="${selectedTransfer.toStoreName}"/></div>
     <div><strong>Trạng thái:</strong> <span class="status-badge ${selectedTransfer.status.toLowerCase()}"><c:out value="${selectedTransfer.statusLabel}"/></span></div>
     <div><strong>Người lập phiếu:</strong> <c:out value="${selectedTransfer.requesterName}"/> (<c:out value="${selectedTransfer.createdAt}"/>)</div>
     <div><strong>Người phê duyệt:</strong> <c:out value="${selectedTransfer.approverName}"/></div>
     <div><strong>Ngày xuất kho:</strong> <c:out value="${selectedTransfer.shippedAt}"/></div>
     <div><strong>Ngày nhận hàng:</strong> <c:out value="${selectedTransfer.receivedAt}"/></div>
    </div>

    <h4>Danh sách các bản sách vật lý trong phiếu (<c:out value="${selectedTransfer.items.size()}"/> cuốn):</h4>
    <div class="table-scroll">
     <table class="admin-table">
      <thead>
       <tr>
        <th>Mã bản sách</th>
        <th>Bìa</th>
        <th>Tên sách</th>
        <th>Tình trạng gửi</th>
        <th>Giá vốn (CostPrice)</th>
        <th>Giá bán (SalePrice)</th>
        <th>Trạng thái nhận</th>
       </tr>
      </thead>
      <tbody>
       <c:forEach items="${selectedTransfer.items}" var="it">
        <tr>
         <td><code><c:out value="${it.copyCode}"/></code></td>
         <td><img src="${base}<c:out value='${it.cover}'/>" alt="" width="32" height="44" data-cover></td>
         <td><strong><c:out value="${it.bookTitle}"/></strong></td>
         <td><span class="status-badge ok"><c:out value="${it.sentCondition}"/></span></td>
         <td><c:out value="${it.costPriceLabel}"/></td>
         <td class="price-col"><c:out value="${it.salePriceLabel}"/></td>
         <td>
          <c:choose>
           <c:when test="${it.receiptStatus == 'RECEIVED'}"><span class="status-badge ok">Đã nhập kho</span></c:when>
           <c:otherwise><span class="status-badge warn"><c:out value="${it.receiptStatus}"/></span></c:otherwise>
          </c:choose>
         </td>
        </tr>
       </c:forEach>
      </tbody>
     </table>
    </div>
   </div>
  </c:if>

  <div class="table-scroll">
   <table class="admin-table">
    <thead>
     <tr>
      <th>Mã phiếu / Ngày tạo</th>
      <th>Chi nhánh gửi ➔ Chi nhánh nhận</th>
      <th>Số lượng sách</th>
      <th>Tổng giá trị chuyển</th>
      <th>Người lập / Người duyệt</th>
      <th>Trạng thái phiếu</th>
      <th>Thao tác quy trình điều chuyển</th>
     </tr>
    </thead>
    <tbody>
     <c:choose>
      <c:when test="${empty transfers}">
       <tr><td colspan="7" class="empty-cell">Chưa có phiếu điều chuyển nào.</td></tr>
      </c:when>
      <c:otherwise>
       <c:forEach items="${transfers}" var="trf">
        <tr>
         <td>
          <strong><a href="${base}/admin/stores?tab=transfers&transferId=${trf.transferId}#transfers-section"><code><c:out value="${trf.transferCode}"/></code></a></strong><br>
          <small class="muted"><c:out value="${trf.createdAt}"/></small>
         </td>
         <td>
          <strong style="color:#0369a1;"><c:out value="${trf.fromStoreName}"/></strong>
          <span class="transfer-flow-arrow">➔</span>
          <strong style="color:#047857;"><c:out value="${trf.toStoreName}"/></strong>
         </td>
         <td><strong><c:out value="${trf.itemCount}"/></strong> cuốn</td>
         <td><c:out value="${trf.totalValueLabel}"/></td>
         <td>
          <c:out value="${trf.requesterName}"/><br>
          <small class="muted">Duyệt: <c:out value="${trf.approverName}"/></small>
         </td>
         <td>
          <span class="status-badge ${trf.status.toLowerCase()}"><c:out value="${trf.statusLabel}"/></span>
         </td>
         <td>
          <div class="inline-actions">
           <a class="btn-sm btn-outline" href="${base}/admin/stores?tab=transfers&transferId=${trf.transferId}#transfers-section">👁 Xem</a>

           <!-- Thao tác theo trạng thái DRAFT / PENDING -->
           <c:if test="${trf.status == 'DRAFT'}">
            <c:choose>
             <c:when test="${userContext.isAdmin()}">
              <form method="post" action="${base}/admin/stores/transfers/${trf.transferId}/approve" class="inline-form">
               <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
               <button type="submit" class="btn-sm btn-primary">✓ Duyệt phiếu (Admin)</button>
              </form>
              <form method="post" action="${base}/admin/stores/transfers/${trf.transferId}/cancel" class="inline-form" data-confirm-cancel>
               <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
               <button type="submit" class="btn-sm btn-danger">Hủy</button>
              </form>
             </c:when>
             <c:otherwise>
              <span class="status-badge draft" style="font-size:11px;">Chờ Admin duyệt</span>
             </c:otherwise>
            </c:choose>
           </c:if>

           <!-- Thao tác theo trạng thái APPROVED -->
           <c:if test="${trf.status == 'APPROVED'}">
            <c:choose>
             <c:when test="${userContext.isAdmin()}">
              <span class="status-badge approved" style="font-size:11px;">Admin đã duyệt (Chờ CN xuất kho)</span>
             </c:when>
             <c:otherwise>
              <c:choose>
               <c:when test="${userContext.storeId() != null and userContext.storeId() == trf.fromStoreId}">
                <form method="post" action="${base}/admin/stores/transfers/${trf.transferId}/ship" class="inline-form">
                 <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                 <button type="submit" class="btn-sm btn-warning">🚚 Xuất kho (Ship)</button>
                </form>
               </c:when>
               <c:otherwise>
                <span class="status-badge approved" style="font-size:11px;">Chờ CN xuất kho</span>
               </c:otherwise>
              </c:choose>
             </c:otherwise>
            </c:choose>
           </c:if>

           <!-- Thao tác theo trạng thái IN_TRANSIT -->
           <c:if test="${trf.status == 'IN_TRANSIT'}">
            <c:choose>
             <c:when test="${userContext.isAdmin()}">
              <span class="status-badge transit" style="font-size:11px;">Đang vận chuyển (Chờ CN nhận hàng)</span>
             </c:when>
             <c:otherwise>
              <c:choose>
               <c:when test="${userContext.storeId() != null and userContext.storeId() == trf.toStoreId}">
                <form method="post" action="${base}/admin/stores/transfers/${trf.transferId}/receive" class="inline-form">
                 <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                 <button type="submit" class="btn-sm btn-success">📦 Xác nhận nhận hàng</button>
                </form>
               </c:when>
               <c:otherwise>
                <span class="status-badge transit" style="font-size:11px;">Đang trên đường giao</span>
               </c:otherwise>
              </c:choose>
             </c:otherwise>
            </c:choose>
           </c:if>
          </div>
         </td>
        </tr>
       </c:forEach>
      </c:otherwise>
     </c:choose>
    </tbody>
   </table>
  </div>

  <c:choose>
   <c:when test="${userContext.isAdmin()}">
    <div class="hint-box" style="margin-top:20px; padding:16px 20px; background:#eff6ff; border:1px solid #bfdbfe; border-radius:10px; color:#1e40af; font-size:13.5px;">
     <p style="margin:0;">ℹ️ <b>Quyền hạn Quản trị viên (Admin):</b> Quản trị viên chỉ phụ trách thẩm định và <b>Phê duyệt</b> các yêu cầu điều chuyển kho sách trên toàn chuỗi. Các thao tác lập phiếu yêu cầu, thực hiện xuất kho (Ship) và tiếp nhận nhập kho (Receive) do Quản lý và Nhân viên tại từng chi nhánh cụ thể phụ trách thực hiện.</p>
    </div>
   </c:when>
   <c:otherwise>
    <hr class="admin-divider" id="create-transfer-box">

    <!-- HỘP TẠO PHIẾU ĐIỀU CHUYỂN MỚI CHO QUẢN LÝ / NHÂN VIÊN CHI NHÁNH -->
    <div class="create-card">
     <div class="panel-top" style="margin-bottom:14px;">
      <div>
       <span class="eyebrow" style="color:#1158c5;">TẠO PHIẾU ĐIỀU CHUYỂN NỘI BỘ MỚI</span>
       <h3 style="margin:4px 0;">+ Lập Phiếu Chuyển Sách Sang Chi Nhánh Khác</h3>
       <p class="hint">Chi nhánh xuất kho mặc định là chi nhánh bạn phụ trách. Vui lòng chọn chi nhánh nhận và các bản sách cần chuyển.</p>
      </div>
     </div>

     <form method="post" action="${base}/admin/stores/transfers/create" class="admin-book-form" id="createTransferForm">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

      <div class="form-row-4">
       <div class="field-group">
        <label>1. Chi nhánh gửi (Xuất kho) <span>*</span> <button type="button" class="btn-sm btn-outline" style="margin-left:6px; padding:2px 8px; font-size:11px;" onclick="loadAvailableCopies(document.getElementById('fromStoreSelect').value)">🔄 Tải lại sách</button></label>
        <input type="hidden" id="fromStoreSelect" name="fromStoreId" value="${userContext.storeId()}">
        <input type="text" value="📍 ${userContext.storeName()} (${userContext.storeCode()})" readonly style="background:#f1f5f9; cursor:not-allowed; font-weight:600; color:#0369a1;">
       </div>
       <div class="field-group">
        <label>2. Chi nhánh nhận (Đích đến) <span>*</span></label>
        <select id="toStoreSelect" name="toStoreId" required>
         <option value="">-- Chọn chi nhánh nhận hàng --</option>
         <c:forEach items="${activeStores}" var="as">
          <c:if test="${as.id != userContext.storeId()}">
           <option value="${as.id}"><c:out value="${as.name}"/> (${as.code})</option>
          </c:if>
         </c:forEach>
        </select>
       </div>
       <div class="field-group" style="grid-column: span 2;">
        <label>Ghi chú điều chuyển</label>
        <input type="text" name="note" placeholder="Ví dụ: Bổ sung sách văn học thiếu hàng theo yêu cầu khách...">
       </div>
      </div>

    <!-- KHU VỰC TỰ ĐỘNG HIỂN THỊ DANH SÁCH SÁCH SẴN CÓ -->
    <div id="copiesContainer" style="margin-top: 14px;">
     <c:choose>
      <c:when test="${not empty availableCopies}">
       <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
        <span style="font-weight:600; font-size:13.5px; color:#1e293b;">Tìm thấy <b style="color:#1158c5;"><c:out value="${availableCopies.size()}"/></b> cuốn sách sẵn có tại chi nhánh này:</span>
        <label style="font-size:13px; cursor:pointer; color:#1158c5; font-weight:600; user-select:none;">
         <input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll(this)" style="margin-right:4px;"> Chọn tất cả
        </label>
       </div>
       <div class="copy-pick-table">
        <table>
         <thead>
          <tr>
           <th style="width:40px; text-align:center;">Chọn</th>
           <th>Mã bản sách</th>
           <th>Tên đầu sách</th>
           <th>Tình trạng</th>
           <th>Vị trí kệ</th>
           <th>Giá bán</th>
          </tr>
         </thead>
         <tbody>
          <c:forEach items="${availableCopies}" var="cp">
           <tr>
            <td style="text-align:center;">
             <input type="checkbox" name="copyIds" value="${cp.copyId}" class="copy-check" onchange="updateSelectedCount()">
            </td>
            <td><code><c:out value="${cp.copyCode}"/></code></td>
            <td><strong><c:out value="${cp.title}"/></strong></td>
            <td><span class="status-badge ok"><c:out value="${cp.conditionLabel}"/></span></td>
            <td><code><c:out value="${cp.shelfLocation}"/></code></td>
            <td class="price-col"><c:out value="${cp.salePriceLabel}"/></td>
           </tr>
          </c:forEach>
         </tbody>
        </table>
       </div>
      </c:when>
      <c:otherwise>
       <p class="hint" style="padding:16px; background:#fff; border:1px dashed #cbd5e1; border-radius:8px; text-align:center;">
        👉 <strong>Bước 1:</strong> Hãy chọn <strong>Chi nhánh gửi</strong> ở trên, danh sách các cuốn sách có sẵn tại chi nhánh đó sẽ xuất hiện ngay tại đây.
       </p>
      </c:otherwise>
     </c:choose>
    </div>

    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px;">
     <div id="selectedCountMsg" style="font-size:13.5px; font-weight:600; color:#475569;"></div>
     <button type="submit" id="submitTransferBtn" class="checkout-button" style="display:none; padding:10px 24px;">🚀 Tạo Phiếu Điều Chuyển</button>
    </div>
   </form>
  </div>
   </c:otherwise>
  </c:choose>
 </section>

 <!-- ==================== PHẦN 3: PHÂN CÔNG NHÂN SỰ CHI NHÁNH (ADMIN & MANAGER) ==================== -->
 <c:if test="${userContext.isAdmin() || userContext.isManager()}">
  <section id="staff-section" class="panel admin-section tab-content" style="${tab == 'staff' ? '' : 'display:none;'}">
   <div class="panel-top">
    <div>
     <span class="eyebrow">QUẢN LÝ NHÂN SỰ CHI NHÁNH</span>
     <h2>
      Phân công Nhân sự theo Chi nhánh
      <c:if test="${userContext.isManager()}"><small style="font-size:14px; color:#2563eb;">(Giới hạn tại chi nhánh: <c:out value="${userContext.storeName()}"/>)</small></c:if>
     </h2>
    </div>
    <a class="checkout-button" href="#assign-staff-form" style="padding: 8px 14px; font-size: 13px;">+ Phân Công Nhân Sự</a>
   </div>

   <div class="table-scroll">
    <table class="admin-table">
     <thead>
      <tr>
       <th>Nhân viên</th>
       <th>Tên đăng nhập / Email</th>
       <th>Chi nhánh công tác</th>
       <th>Chức vụ phụ trách</th>
       <th>Thời gian bắt đầu</th>
       <th>Trạng thái</th>
       <th>Thao tác</th>
      </tr>
     </thead>
     <tbody>
      <c:choose>
       <c:when test="${empty staffAssignments}">
        <tr><td colspan="7" class="empty-cell">Chưa có phân công nhân sự nào cho chi nhánh này.</td></tr>
       </c:when>
       <c:otherwise>
        <c:forEach items="${staffAssignments}" var="sa">
         <tr>
          <td><strong><c:out value="${sa.fullName}"/></strong><br><small class="muted">SĐT: <c:out value="${sa.phone}"/></small></td>
          <td><code><c:out value="${sa.username}"/></code><br><small class="muted"><c:out value="${sa.email}"/></small></td>
          <td><strong style="color:#0369a1;"><c:out value="${sa.storeName}"/></strong> (<c:out value="${sa.storeCode}"/>)</td>
          <td>
           <span class="status-badge ${sa.storeRole == 'MANAGER' ? 'ok' : 'approved'}">
            <c:out value="${sa.storeRoleLabel}"/>
           </span>
          </td>
          <td><c:out value="${sa.startAt}"/></td>
          <td>
           <c:choose>
            <c:when test="${sa.status == 'ACTIVE'}"><span class="status-badge ok">Đang công tác</span></c:when>
            <c:otherwise><span class="status-badge draft">Đã kết thúc (<c:out value="${sa.endAt}"/>)</span></c:otherwise>
           </c:choose>
          </td>
          <td>
           <c:if test="${sa.status == 'ACTIVE'}">
            <form method="post" action="${base}/admin/stores/staff/${sa.assignmentId}/end" class="inline-form" data-confirm-cancel>
             <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
             <button type="submit" class="btn-sm btn-danger">Kết thúc công tác</button>
            </form>
           </c:if>
          </td>
         </tr>
        </c:forEach>
       </c:otherwise>
      </c:choose>
     </tbody>
    </table>
   </div>

   <hr class="admin-divider" id="assign-staff-form">
   <div class="panel-top">
    <h3>+ Phân Công Nhân Viên Làm Việc Tại Chi Nhánh</h3>
   </div>
   <form method="post" action="${base}/admin/stores/staff/assign" class="admin-book-form">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
    <div class="form-row-4">
     <div class="field-group">
      <label>Chọn Nhân sự (User hệ thống) <span>*</span></label>
      <select name="userId" required>
       <c:forEach items="${eligibleUsers}" var="eu">
        <option value="${eu.userId}"><c:out value="${eu.fullName}"/> (@<c:out value="${eu.username}"/>)</option>
       </c:forEach>
      </select>
     </div>

     <div class="field-group">
      <label>Chi nhánh phân công <span>*</span></label>
      <c:choose>
       <c:when test="${userContext.isAdmin()}">
        <select name="storeId" required>
         <c:forEach items="${activeStores}" var="as">
          <option value="${as.id}"><c:out value="${as.name}"/> (${as.code})</option>
         </c:forEach>
        </select>
       </c:when>
       <c:otherwise>
        <input type="hidden" name="storeId" value="${userContext.storeId()}">
        <input type="text" value="📍 ${userContext.storeName()}" readonly style="background:#f1f5f9; cursor:not-allowed;">
       </c:otherwise>
      </c:choose>
     </div>

     <div class="field-group">
      <label>Chức danh tại chi nhánh <span>*</span></label>
      <select name="storeRole" required>
       <option value="STAFF">Nhân viên chi nhánh (STAFF)</option>
       <c:if test="${userContext.isAdmin()}">
        <option value="MANAGER">Quản lý chi nhánh (MANAGER)</option>
       </c:if>
      </select>
     </div>

     <div class="field-group" style="align-self: flex-end;">
      <button type="submit" class="checkout-button" style="width:100%; height:42px;">+ Phân Công Ngay</button>
     </div>
    </div>
   </form>
  </section>
 </c:if>

 <!-- ==================== PHẦN 4: QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN (ADMIN ONLY) ==================== -->
 <c:if test="${userContext.isAdmin()}">
  <section id="users-section" class="panel admin-section tab-content" style="${tab == 'users' ? '' : 'display:none;'}">
   <div class="panel-top">
    <div>
     <span class="eyebrow" style="color:#0369a1;">QUẢN TRỊ TOÀN QUYỀN HỆ THỐNG</span>
     <h2>Quản Lý Tài Khoản Toàn Bộ Người Dùng & Phân Quyền</h2>
     <p class="hint">Tạo nhân sự mới, thiết lập vai trò (ADMIN, MANAGER, STAFF, CUSTOMER), khóa/mở khóa tài khoản và đặt lại mật khẩu.</p>
    </div>
    <a class="checkout-button" href="#create-staff-card" style="padding: 8px 14px; font-size: 13px;">+ Thêm Nhân Sự Mới</a>
   </div>

   <!-- BỘ LỌC TÀI KHOẢN -->
   <form method="get" action="${base}/admin/stores" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin-bottom:16px; background:#f8fafc; padding:12px 16px; border-radius:10px; border:1px solid #e2e8f0;">
    <input type="hidden" name="tab" value="users">
    <div style="flex:1; min-width:220px;">
     <input type="text" name="userSearch" value="<c:out value='${userSearch}'/>" placeholder="Tìm theo tên, username, email, SĐT..." style="width:100%; padding:6px 12px; font-size:13px; border-radius:6px; border:1px solid #cbd5e1;">
    </div>
    <div>
     <select name="roleFilter" style="padding:6px 10px; font-size:13px; border-radius:6px; border:1px solid #cbd5e1; background:#fff;">
      <option value="ALL" ${roleFilter == 'ALL' ? 'selected' : ''}>Tất cả vai trò</option>
      <option value="ADMIN" ${roleFilter == 'ADMIN' ? 'selected' : ''}>ADMIN (Quản trị viên)</option>
      <option value="MANAGER" ${roleFilter == 'MANAGER' ? 'selected' : ''}>MANAGER (Quản lý chi nhánh)</option>
      <option value="STAFF" ${roleFilter == 'STAFF' ? 'selected' : ''}>STAFF (Nhân viên)</option>
      <option value="CUSTOMER" ${roleFilter == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER (Khách hàng)</option>
     </select>
    </div>
    <div>
     <select name="userStatusFilter" style="padding:6px 10px; font-size:13px; border-radius:6px; border:1px solid #cbd5e1; background:#fff;">
      <option value="ALL" ${userStatusFilter == 'ALL' ? 'selected' : ''}>Tất cả trạng thái</option>
      <option value="ACTIVE" ${userStatusFilter == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Đang hoạt động)</option>
      <option value="LOCKED" ${userStatusFilter == 'LOCKED' ? 'selected' : ''}>LOCKED (Đã khóa)</option>
     </select>
    </div>
    <button type="submit" class="btn-sm btn-primary" style="padding:7px 16px;">Lọc tài khoản</button>
    <c:if test="${not empty userSearch or (roleFilter != 'ALL' and not empty roleFilter) or (userStatusFilter != 'ALL' and not empty userStatusFilter)}">
     <a href="${base}/admin/stores?tab=users#users-section" class="btn-sm btn-outline">Xóa lọc</a>
    </c:if>
   </form>

   <!-- BẢNG DANH SÁCH TÀI KHOẢN -->
   <div class="table-scroll">
    <table class="admin-table">
     <thead>
      <tr>
       <th>ID</th>
       <th>Họ tên & SĐT</th>
       <th>Username / Email</th>
       <th>Vai trò hệ thống</th>
       <th>Chi nhánh trực thuộc</th>
       <th>Trạng thái</th>
       <th>Thao tác quản trị</th>
      </tr>
     </thead>
     <tbody>
      <c:choose>
       <c:when test="${empty allUsers}">
        <tr><td colspan="7" class="empty-cell">Không tìm thấy tài khoản nào phù hợp bộ lọc.</td></tr>
       </c:when>
       <c:otherwise>
        <c:forEach items="${allUsers}" var="u">
         <tr>
          <td><code>#<c:out value="${u.userId}"/></code></td>
          <td>
           <strong><c:out value="${u.fullName}"/></strong>
           <br><small class="muted">📞 <c:out value="${u.phone}"/></small>
          </td>
          <td>
           <code>@<c:out value="${u.username}"/></code>
           <br><small class="muted"><c:out value="${u.email}"/></small>
          </td>
          <td>
           <c:choose>
            <c:when test="${u.roles.contains('ADMIN')}"><span class="status-badge" style="background:#fef3c7; color:#92400e; font-weight:700;">ADMIN</span></c:when>
            <c:when test="${u.roles.contains('MANAGER') or u.storeRole == 'MANAGER'}"><span class="status-badge" style="background:#e0e7ff; color:#3730a3; font-weight:700;">MANAGER</span></c:when>
            <c:when test="${u.roles.contains('STAFF')}"><span class="status-badge approved">STAFF</span></c:when>
            <c:otherwise><span class="status-badge draft">CUSTOMER</span></c:otherwise>
           </c:choose>
          </td>
          <td>
           <c:choose>
            <c:when test="${not empty u.storeId}">
             <strong style="color:#0369a1;"><c:out value="${u.storeName}"/></strong>
             <br><small class="muted">(<c:out value="${u.storeRole}"/>)</small>
            </c:when>
            <c:otherwise><span class="muted">Chưa phân công</span></c:otherwise>
           </c:choose>
          </td>
          <td>
           <c:choose>
            <c:when test="${u.status == 'ACTIVE'}"><span class="status-badge ok">Hoạt động</span></c:when>
            <c:otherwise><span class="status-badge error">ĐÃ KHÓA</span></c:otherwise>
           </c:choose>
          </td>
          <td>
           <div class="inline-actions">
             <c:choose>
              <c:when test="${u.roles.contains('ADMIN')}">
               <span style="font-size:11.5px; color:#92400e; font-weight:700; padding:4px 10px; background:#fef3c7; border:1px solid #fde68a; border-radius:6px; display:inline-block;">👑 Quản trị viên cấp cao (Cố định)</span>
              </c:when>
              <c:otherwise>
               <!-- Đổi vai trò -->
               <form action="${base}/admin/stores/users/${u.userId}/role" method="post" style="display:inline-flex; gap:3px;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <select name="role" style="font-size:11px; padding:2px 4px; border-radius:4px; border:1px solid #cbd5e1;">
                 <option value="CUSTOMER" ${u.roles == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                 <option value="STAFF" ${u.roles.contains('STAFF') ? 'selected' : ''}>STAFF</option>
                 <option value="MANAGER" ${u.roles.contains('MANAGER') or u.storeRole == 'MANAGER' ? 'selected' : ''}>MANAGER</option>
                </select>
                <button type="submit" class="btn-sm btn-outline" style="padding:2px 6px; font-size:11px;">Lưu</button>
               </form>

               <!-- Khóa / Mở khóa -->
               <form action="${base}/admin/stores/users/${u.userId}/toggle-status" method="post" style="display:inline;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <c:choose>
                 <c:when test="${u.status == 'ACTIVE'}">
                  <button type="submit" class="btn-sm btn-danger" style="padding:3px 8px; font-size:11px;" onclick="return confirm('Bạn có chắc chắn muốn KHÓA tài khoản ${u.username}?')">🔒 Khóa</button>
                 </c:when>
                 <c:otherwise>
                  <button type="submit" class="btn-sm btn-success" style="padding:3px 8px; font-size:11px;">🔓 Mở</button>
                 </c:otherwise>
                </c:choose>
               </form>
              </c:otherwise>
             </c:choose>

             <!-- Đặt lại mật khẩu -->
            <details style="display:inline-block;">
             <summary class="btn-sm btn-outline" style="padding:3px 6px; font-size:11px; cursor:pointer;">🔑 Reset Pass</summary>
             <div style="position:absolute; right:30px; background:#fff; border:1px solid #cbd5e1; border-radius:8px; padding:12px; box-shadow:0 8px 24px rgba(0,0,0,0.15); z-index:100; min-width:240px; margin-top:4px;">
              <form action="${base}/admin/stores/users/${u.userId}/reset-password" method="post" style="display:grid; gap:6px;">
               <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
               <label style="font-size:11.5px; font-weight:600;">Mật khẩu mới cho @<c:out value="${u.username}"/>:</label>
               <input type="password" name="newPassword" placeholder="Nhập ít nhất 6 ký tự" minlength="6" required style="padding:4px 8px; font-size:12px; border-radius:4px; border:1px solid #cbd5e1;">
               <button type="submit" class="btn-sm btn-primary" style="margin-top:4px;">Xác nhận đổi mật khẩu</button>
              </form>
             </div>
            </details>
           </div>
          </td>
         </tr>
        </c:forEach>
       </c:otherwise>
      </c:choose>
     </tbody>
    </table>
   </div>

   <!-- FORM TẠO NHÂN SỰ MỚI -->
   <hr class="admin-divider" id="create-staff-card">
   <div class="create-card">
    <div class="panel-top" style="margin-bottom:14px;">
     <div>
      <span class="eyebrow" style="color:#059669;">BỔ SUNG NHÂN SỰ VÀO HỆ THỐNG MỘC SÁCH</span>
      <h3 style="margin:4px 0;">+ Thêm Tài Khoản Nhân Sự Mới (Staff / Manager / Admin)</h3>
      <p class="hint">Tạo ngay tài khoản và tự động phân công nhân sự vào chi nhánh làm việc.</p>
     </div>
    </div>

    <form method="post" action="${base}/admin/stores/users/create" class="admin-book-form">
     <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
     <div class="form-row-4">
      <div class="field-group">
       <label>Họ và tên nhân sự <span>*</span></label>
       <input type="text" name="fullName" placeholder="Ví dụ: Nguyễn Văn Quản Lý" required minlength="2">
      </div>
      <div class="field-group">
       <label>Tên đăng nhập (Username) <span>*</span></label>
       <input type="text" name="username" placeholder="Ví dụ: manager_td, staff_bt" required minlength="3">
      </div>
      <div class="field-group">
       <label>Email liên hệ <span>*</span></label>
       <input type="email" name="email" placeholder="Ví dụ: nhansu@mocsach.vn" required>
      </div>
      <div class="field-group">
       <label>Mật khẩu khởi tạo <span>*</span></label>
       <input type="password" name="password" placeholder="Tối thiểu 6 ký tự" minlength="6" required>
      </div>
     </div>

     <div class="form-row-4">
      <div class="field-group">
       <label>Số điện thoại</label>
       <input type="text" name="phone" placeholder="Ví dụ: 0912345678">
      </div>
      <div class="field-group">
       <label>Vai trò hệ thống <span>*</span></label>
       <select name="roleCode" required>
        <option value="STAFF">STAFF (Nhân viên bán hàng & kho)</option>
        <option value="MANAGER">MANAGER (Quản lý chi nhánh)</option>
        <option value="ADMIN">ADMIN (Quản trị viên hệ thống)</option>
       </select>
      </div>
      <div class="field-group">
       <label>Phân công ngay vào chi nhánh</label>
       <select name="storeId">
        <option value="">-- Chưa phân công chi nhánh --</option>
        <c:forEach items="${activeStores}" var="as">
         <option value="${as.id}"><c:out value="${as.name}"/> (${as.code})</option>
        </c:forEach>
       </select>
      </div>
      <div class="field-group" style="align-self: flex-end;">
       <button type="submit" class="checkout-button" style="width:100%; height:42px; background:#059669; border-color:#059669;">+ Tạo Nhân Sự Ngay</button>
      </div>
     </div>
    </form>
   </div>
  </section>
 </c:if>

 <footer>
  <span>Mộc Sách.</span> Hệ thống quản trị chuỗi cửa hàng sách cũ. <a href="${base}/home">Về trang chủ</a>
 </footer>
</main>
<div id="toast" role="status" aria-live="polite" hidden><span></span><button type="button" aria-label="Đóng thông báo">×</button></div>

</body>
</html>
