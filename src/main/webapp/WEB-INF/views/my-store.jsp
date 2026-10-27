<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="shop" tagdir="/WEB-INF/tags" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<!doctype html>
<html lang="vi">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width,initial-scale=1">
 <title>Không gian Quản lý Chi Nhánh · <c:out value="${store.storeName}"/> · Mộc Sách</title>
 <link rel="icon" href="${base}/images/moc-sach-mark.svg">
 <link rel="stylesheet" href="${base}/css/home.css">
 <link rel="stylesheet" href="${base}/css/cart.css">
 <script defer src="${base}/js/home.js"></script>
 <style>
  .workspace-shell { max-width: 1200px; margin: 0 auto; padding: 24px 20px; }
  .store-header-banner { background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%); color: #fff; border-radius: 16px; padding: 24px 28px; margin-bottom: 24px; box-shadow: 0 10px 25px -5px rgba(15,23,42,0.15); display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px; }
  .store-header-info h1 { font-size: 24px; margin: 0 0 8px 0; color: #fff; }
  .store-header-info p { margin: 0 0 6px 0; color: #cbd5e1; font-size: 14px; }
  .badge-role { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
  .badge-admin { background: #fef3c7; color: #92400e; }
  .badge-manager { background: #e0e7ff; color: #3730a3; }
  .badge-staff { background: #dcfce7; color: #166534; }
  
  .section-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 22px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
  .section-card-head { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #f1f5f9; padding-bottom: 14px; margin-bottom: 18px; flex-wrap: wrap; gap: 12px; }
  .section-card-head h2 { font-size: 18px; color: #0f172a; margin: 0; display: flex; align-items: center; gap: 8px; }
  
  .table-responsive { width: 100%; overflow-x: auto; }
  .data-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
  .data-table th { background: #f8fafc; padding: 10px 12px; text-align: left; font-weight: 600; color: #475569; border-bottom: 1px solid #e2e8f0; }
  .data-table td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
  .data-table tr:hover td { background: #f8fafc; }
  
  .status-badge { display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11.5px; font-weight: 600; }
  .status-badge.pending { background: #fffbeb; color: #b45309; }
  .status-badge.confirmed { background: #eff6ff; color: #1d4ed8; }
  .status-badge.processing { background: #f3e8ff; color: #7e22ce; }
  .status-badge.shipped, .status-badge.transit, .status-badge.in_transit { background: #e0f2fe; color: #0369a1; }
  .status-badge.completed, .status-badge.received { background: #ecfdf5; color: #047857; }
  .status-badge.cancelled { background: #fef2f2; color: #b91c1c; }
  .status-badge.available { background: #ecfdf5; color: #047857; }
  
  .btn-sm { padding: 4px 10px; font-size: 12px; font-weight: 600; border-radius: 6px; border: 1px solid transparent; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
  .btn-primary { background: #2563eb; color: #fff; }
  .btn-primary:hover { background: #1d4ed8; }
  .btn-success { background: #059669; color: #fff; }
  .btn-warning { background: #d97706; color: #fff; }
  .btn-danger { background: #dc2626; color: #fff; }
  .btn-outline { background: #fff; border-color: #cbd5e1; color: #334155; }
  
  .filter-bar { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
  .filter-pill { padding: 4px 10px; border-radius: 20px; font-size: 12px; border: 1px solid #cbd5e1; background: #fff; color: #475569; text-decoration: none; }
  .filter-pill.active { background: #0f172a; color: #fff; border-color: #0f172a; }
  
  .alert-banner { padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 13.5px; }
  .alert-banner.ok { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
  .alert-banner.err { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
 </style>
</head>
<body class="cart-page" data-base="${base}">
<main class="workspace-shell">
 <header class="cart-header" style="margin-bottom: 16px;">
  <a class="brand" href="${base}/home"><img src="${base}/images/moc-sach-mark.svg" alt="" width="30" height="30">Mộc Sách.</a>
  <div style="display:flex; gap:10px; align-items:center;">
   <a href="${base}/home" class="btn-sm btn-outline">← Trang chủ khách</a>
   <c:if test="${userContext.isAdmin()}">
    <a href="${base}/admin" class="btn-sm btn-outline">📊 Dashboard Chung</a>
   </c:if>
   <c:if test="${userContext.isAdmin() || userContext.isManager()}">
    <a href="${base}/admin/stores" class="btn-sm btn-outline">🏬 Chuỗi & Phân quyền</a>
   </c:if>
   <shop:notifications/>
   <span style="font-size:13px; font-weight:600; color:#1e293b;"><c:out value="${displayName}"/></span>
  </div>
 </header>

 <c:if test="${not empty success}"><div class="alert-banner ok">✓ <c:out value="${success}"/></div></c:if>
 <c:if test="${not empty error}"><div class="alert-banner err">✕ <c:out value="${error}"/></div></c:if>

 <!-- BANNER THÔNG TIN CHI NHÁNH ĐƯỢC PHÂN CÔNG -->
 <div class="store-header-banner">
  <div class="store-header-info">
   <div style="display:flex; gap:10px; align-items:center; margin-bottom:6px;">
    <span style="background:rgba(255,255,255,0.2); padding:2px 8px; border-radius:6px; font-size:12px; font-weight:700;"><c:out value="${store.storeCode}"/></span>
    <c:choose>
     <c:when test="${userContext.isAdmin()}"><span class="badge-role badge-admin">Quản trị viên (Toàn quyền)</span></c:when>
     <c:when test="${userContext.isManager()}"><span class="badge-role badge-manager">Quản lý chi nhánh</span></c:when>
     <c:otherwise><span class="badge-role badge-staff">Nhân viên chi nhánh</span></c:otherwise>
    </c:choose>
   </div>
   <h1><c:out value="${store.storeName}"/></h1>
   <p>📍 <strong>Địa chỉ:</strong> <c:out value="${store.address}"/></p>
   <p>📞 <strong>Hotline:</strong> <c:out value="${store.phone}"/> &bull; 📅 <strong>Ngày mở:</strong> <c:out value="${store.openedAt}"/></p>
  </div>
  
  <div style="display:flex; flex-direction:column; gap:10px; align-items:flex-end;">
   <c:if test="${userContext.isAdmin()}">
    <form method="get" action="${base}/admin/my-store" style="display:flex; align-items:center; gap:6px;">
     <label for="switchStore" style="font-size:12px; color:#cbd5e1;">Đổi chi nhánh:</label>
     <select id="switchStore" name="storeId" onchange="this.form.submit()" style="padding:5px 8px; font-size:12.5px; border-radius:6px; border:1px solid rgba(255,255,255,0.3); background:#0f172a; color:#fff;">
      <c:forEach items="${activeStores}" var="as">
       <option value="${as.id}" ${store.storeId == as.id ? 'selected' : ''}><c:out value="${as.name}"/></option>
      </c:forEach>
     </select>
    </form>
   </c:if>
   <div style="display:flex; gap:8px;">
    <a href="#orders-section" class="btn-sm btn-primary">📋 Đơn hàng</a>
    <a href="#inventory-section" class="btn-sm btn-outline" style="color:#fff; border-color:rgba(255,255,255,0.4); background:rgba(255,255,255,0.1);">📦 Kho sách</a>
    <a href="#transfers-section" class="btn-sm btn-outline" style="color:#fff; border-color:rgba(255,255,255,0.4); background:rgba(255,255,255,0.1);">🚚 Điều chuyển</a>
   </div>
  </div>
 </div>

 <!-- PHẦN 1: QUẢN LÝ & DUYỆT ĐƠN HÀNG TẠI CHI NHÁNH -->
 <section class="section-card" id="orders-section">
  <div class="section-card-head">
   <div>
    <h2>📋 Quản lý & Duyệt đơn mua hàng tại chi nhánh <small style="font-size:13px; font-weight:normal; color:#64748b;">(${storeOrders.size()} đơn)</small></h2>
    <span style="font-size:12.5px; color:#64748b;">Duyệt xác nhận, chuẩn bị sách trên kệ và cập nhật tiến độ giao cho khách.</span>
   </div>
   <div class="filter-bar">
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=ALL#orders-section" class="filter-pill ${orderStatus == 'ALL' ? 'active' : ''}">Tất cả</a>
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=PENDING#orders-section" class="filter-pill ${orderStatus == 'PENDING' ? 'active' : ''}">Chờ duyệt</a>
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=CONFIRMED#orders-section" class="filter-pill ${orderStatus == 'CONFIRMED' ? 'active' : ''}">Đã xác nhận</a>
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=PROCESSING#orders-section" class="filter-pill ${orderStatus == 'PROCESSING' ? 'active' : ''}">Đang soạn</a>
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=SHIPPED#orders-section" class="filter-pill ${orderStatus == 'SHIPPED' ? 'active' : ''}">Đang giao</a>
    <a href="${base}/admin/my-store?storeId=${store.storeId}&orderStatus=COMPLETED#orders-section" class="filter-pill ${orderStatus == 'COMPLETED' ? 'active' : ''}">Hoàn tất</a>
   </div>
  </div>

  <c:choose>
   <c:when test="${empty storeOrders}">
    <div style="text-align:center; padding:32px 16px; color:#64748b;">
     <p style="margin:0; font-size:14px;">Không có đơn hàng nào tại chi nhánh phù hợp với trạng thái đã lọc.</p>
    </div>
   </c:when>
   <c:otherwise>
    <div class="table-responsive">
     <table class="data-table">
      <thead>
       <tr>
        <th>Mã đơn</th>
        <th>Khách hàng</th>
        <th>Địa chỉ giao hàng</th>
        <th>Ngày đặt</th>
        <th>Số cuốn</th>
        <th>Tổng tiền</th>
        <th>Trạng thái</th>
        <th style="min-width:180px;">Duyệt / Cập nhật tiến độ</th>
       </tr>
      </thead>
      <tbody>
       <c:forEach items="${storeOrders}" var="o">
        <tr>
         <td><strong>#<c:out value="${o.id}"/></strong></td>
         <td>
          <div style="font-weight:600;"><c:out value="${o.fullName}"/></div>
          <small style="color:#64748b;"><c:out value="${o.phone}"/></small>
         </td>
         <td><small style="max-width:200px; display:inline-block; line-height:1.3;"><c:out value="${o.shippingAddress}"/></small></td>
         <td><small><c:out value="${o.orderDate}"/></small></td>
         <td><b><c:out value="${o.itemCount}"/></b></td>
         <td><strong style="color:#0f172a;"><c:out value="${o.totalAmountLabel}"/></strong></td>
         <td>
          <c:choose>
           <c:when test="${o.status == 'PENDING'}"><span class="status-badge pending">Chờ duyệt</span></c:when>
           <c:when test="${o.status == 'CONFIRMED'}"><span class="status-badge confirmed">Đã xác nhận</span></c:when>
           <c:when test="${o.status == 'PROCESSING'}"><span class="status-badge processing">Đang soạn</span></c:when>
           <c:when test="${o.status == 'SHIPPED'}"><span class="status-badge shipped">Đang giao</span></c:when>
           <c:when test="${o.status == 'COMPLETED'}"><span class="status-badge completed">Hoàn tất</span></c:when>
           <c:otherwise><span class="status-badge cancelled"><c:out value="${o.status}"/></span></c:otherwise>
          </c:choose>
         </td>
         <td>
          <form action="${base}/admin/orders/${o.id}/status" method="post" style="display:flex; gap:6px; align-items:center;">
           <input type="hidden" name="source" value="my-store">
           <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
           <select name="status" style="padding:4px 6px; font-size:12px; border-radius:6px; border:1px solid #cbd5e1; background:#fff;">
            <option value="PENDING" ${o.status == 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
            <option value="CONFIRMED" ${o.status == 'CONFIRMED' ? 'selected' : ''}>Duyệt đơn (Xác nhận)</option>
            <option value="PROCESSING" ${o.status == 'PROCESSING' ? 'selected' : ''}>Đang chuẩn bị hàng</option>
            <option value="SHIPPED" ${o.status == 'SHIPPED' ? 'selected' : ''}>Đã bàn giao vận chuyển</option>
            <option value="COMPLETED" ${o.status == 'COMPLETED' ? 'selected' : ''}>Hoàn thành đơn</option>
            <option value="CANCELLED" ${o.status == 'CANCELLED' ? 'selected' : ''}>Hủy đơn</option>
           </select>
           <button type="submit" class="btn-sm btn-primary">Lưu</button>
          </form>
         </td>
        </tr>
       </c:forEach>
      </tbody>
     </table>
    </div>
   </c:otherwise>
  </c:choose>
 </section>

 <!-- PHẦN 2: KHO SÁCH VẬT LÝ TRÊN KỆ TẠI CHI NHÁNH -->
 <section class="section-card" id="inventory-section">
  <div class="section-card-head">
   <div>
    <h2>📦 Danh mục sách trên kệ chi nhánh <small style="font-size:13px; font-weight:normal; color:#64748b;">(${storeCopies.size()} bản)</small></h2>
    <span style="font-size:12.5px; color:#64748b;">Kiểm tra vị trí kệ, tình trạng sách cũ và tình trạng sẵn sàng bán.</span>
   </div>
   <form method="get" action="${base}/admin/my-store#inventory-section" style="display:flex; gap:6px;">
    <input type="hidden" name="storeId" value="${store.storeId}">
    <input type="text" name="q" value="<c:out value='${q}'/>" placeholder="Tìm tên sách, vị trí kệ..." style="padding:5px 10px; font-size:13px; border-radius:6px; border:1px solid #cbd5e1; width:200px;">
    <button type="submit" class="btn-sm btn-outline">Tìm</button>
    <c:if test="${not empty q}">
     <a href="${base}/admin/my-store?storeId=${store.storeId}#inventory-section" class="btn-sm btn-outline">Xóa</a>
    </c:if>
   </form>
  </div>

  <c:choose>
   <c:when test="${empty storeCopies}">
    <div style="text-align:center; padding:32px 16px; color:#64748b;">
     <p style="margin:0; font-size:14px;">Chưa tìm thấy bản sách nào tại chi nhánh này.</p>
    </div>
   </c:when>
   <c:otherwise>
    <div class="table-responsive">
     <table class="data-table">
      <thead>
       <tr>
        <th>Mã bản</th>
        <th>Tên sách</th>
        <th>Vị trí kệ</th>
        <th>Tình trạng sách</th>
        <th>Giá nhập</th>
        <th>Giá bán</th>
        <th>Trạng thái</th>
        <th>Hành động</th>
       </tr>
      </thead>
      <tbody>
       <c:forEach items="${storeCopies}" var="c">
        <tr>
         <td><code>#<c:out value="${c.id}"/></code></td>
         <td>
          <div style="display:flex; align-items:center; gap:8px;">
           <img src="${base}<c:out value='${c.cover}'/>" alt="" style="width:32px; height:44px; object-fit:cover; border-radius:4px;">
           <div>
            <strong style="display:block; font-size:13px;"><c:out value="${c.title}"/></strong>
            <small style="color:#64748b;"><c:out value="${c.authors}"/></small>
           </div>
          </div>
         </td>
         <td><span style="background:#f1f5f9; padding:2px 6px; border-radius:4px; font-size:12px; font-family:monospace;"><c:out value="${c.shelfLocation}"/></span></td>
         <td>
          <span style="font-weight:600;"><c:out value="${c.conditionLabel}"/></span>
          <c:if test="${not empty c.conditionNotes}"><br><small style="color:#64748b;"><c:out value="${c.conditionNotes}"/></small></c:if>
         </td>
         <td><small style="color:#64748b;"><c:out value="${c.costPriceLabel}"/></small></td>
         <td><strong style="color:#0f172a;"><c:out value="${c.salePriceLabel}"/></strong></td>
         <td>
          <c:choose>
           <c:when test="${c.status == 'AVAILABLE'}"><span class="status-badge available">Có sẵn</span></c:when>
           <c:when test="${c.status == 'HOLD'}"><span class="status-badge pending">Giữ hàng</span></c:when>
           <c:when test="${c.status == 'TRANSFERRING'}"><span class="status-badge transit">Đang chuyển</span></c:when>
           <c:when test="${c.status == 'SOLD'}"><span class="status-badge" style="background:#f1f5f9;color:#64748b;">Đã bán</span></c:when>
           <c:otherwise><span class="status-badge"><c:out value="${c.status}"/></span></c:otherwise>
          </c:choose>
         </td>
         <td>
          <a href="${base}/books/${c.bookId}" target="_blank" class="btn-sm btn-outline">Xem sách ↗</a>
         </td>
        </tr>
       </c:forEach>
      </tbody>
     </table>
    </div>
   </c:otherwise>
  </c:choose>
 </section>

 <!-- PHẦN 3: ĐIỀU CHUYỂN SÁCH LIÊN CHI NHÁNH -->
 <section class="section-card" id="transfers-section">
  <div class="section-card-head">
   <div>
    <h2>🚚 Phiếu điều chuyển sách liên quan đến chi nhánh <small style="font-size:13px; font-weight:normal; color:#64748b;">(${storeTransfers.size()} phiếu)</small></h2>
    <span style="font-size:12.5px; color:#64748b;">
     Lưu ý: <strong>Chỉ Quản trị viên (Admin) mới có quyền duyệt phiếu</strong>. Nhân viên/Quản lý chi nhánh chỉ thực hiện <strong>Xuất kho</strong> (khi là nơi gửi) hoặc <strong>Nhập kho nhận sách</strong> (khi là nơi nhận).
    </span>
   </div>
   <c:if test="${userContext.isAdmin() || userContext.isManager()}">
    <a href="${base}/admin/stores?tab=transfers#create-transfer-card" class="btn-sm btn-primary">+ Tạo yêu cầu chuyển sách mới</a>
   </c:if>
  </div>

  <c:choose>
   <c:when test="${empty storeTransfers}">
    <div style="text-align:center; padding:32px 16px; color:#64748b;">
     <p style="margin:0; font-size:14px;">Chưa có phiếu điều chuyển nào liên quan đến chi nhánh này.</p>
    </div>
   </c:when>
   <c:otherwise>
    <div class="table-responsive">
     <table class="data-table">
      <thead>
       <tr>
        <th>Mã phiếu</th>
        <th>Tuyến chuyển sách</th>
        <th>Số bản sách</th>
        <th>Người tạo</th>
        <th>Trạng thái</th>
        <th>Thao tác kho</th>
       </tr>
      </thead>
      <tbody>
       <c:forEach items="${storeTransfers}" var="t">
        <tr>
         <td>
          <strong><c:out value="${t.code}"/></strong>
          <br><small style="color:#64748b;"><c:out value="${t.createdAt}"/></small>
         </td>
         <td>
          <span style="font-weight:${t.fromStoreId == store.storeId ? 'bold' : 'normal'};">📍 <c:out value="${t.fromStoreName}"/></span>
          <span style="color:#2563eb; font-weight:bold;"> &rarr; </span>
          <span style="font-weight:${t.toStoreId == store.storeId ? 'bold' : 'normal'};">📍 <c:out value="${t.toStoreName}"/></span>
          <c:if test="${t.fromStoreId == store.storeId}">
           <br><small style="color:#b45309;">(Chi nhánh bạn: Nơi xuất sách)</small>
          </c:if>
          <c:if test="${t.toStoreId == store.storeId}">
           <br><small style="color:#047857;">(Chi nhánh bạn: Nơi tiếp nhận sách)</small>
          </c:if>
         </td>
         <td><b><c:out value="${t.copyCount}"/></b> cuốn</td>
         <td><small><c:out value="${t.requestedBy}"/></small></td>
         <td>
          <c:choose>
           <c:when test="${t.status == 'PENDING'}"><span class="status-badge pending">Chờ Admin duyệt</span></c:when>
           <c:when test="${t.status == 'APPROVED'}"><span class="status-badge confirmed">Admin đã duyệt</span></c:when>
           <c:when test="${t.status == 'IN_TRANSIT'}"><span class="status-badge transit">Đang vận chuyển</span></c:when>
           <c:when test="${t.status == 'RECEIVED'}"><span class="status-badge completed">Đã nhập kho</span></c:when>
           <c:otherwise><span class="status-badge cancelled"><c:out value="${t.statusLabel}"/></span></c:otherwise>
          </c:choose>
         </td>
         <td>
          <div style="display:flex; gap:6px; flex-wrap:wrap;">
           <!-- Nếu ADMIN: Có thể duyệt -->
           <c:if test="${userContext.isAdmin() and t.status == 'PENDING'}">
            <form action="${base}/admin/stores/transfers/${t.id}/approve" method="post" style="display:inline;">
             <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
             <button type="submit" class="btn-sm btn-primary">✓ Duyệt phiếu (Admin)</button>
            </form>
           </c:if>

           <!-- Nếu là nơi gửi và phiếu đã duyệt: Xuất kho -->
           <c:if test="${t.fromStoreId == store.storeId and t.status == 'APPROVED'}">
            <form action="${base}/admin/stores/transfers/${t.id}/ship" method="post" style="display:inline;">
             <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
             <button type="submit" class="btn-sm btn-warning">🚚 Xuất kho vận chuyển</button>
            </form>
           </c:if>

           <!-- Nếu là nơi nhận và phiếu đang vận chuyển: Nhập kho -->
           <c:if test="${t.toStoreId == store.storeId and t.status == 'IN_TRANSIT'}">
            <form action="${base}/admin/stores/transfers/${t.id}/receive" method="post" style="display:inline;">
             <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
             <button type="submit" class="btn-sm btn-success">📥 Nhập kho nhận sách</button>
            </form>
           </c:if>

           <a href="${base}/admin/stores?tab=transfers&transferId=${t.id}#transfers-section" class="btn-sm btn-outline">Chi tiết ↗</a>
          </div>
         </td>
        </tr>
       </c:forEach>
      </tbody>
     </table>
    </div>
   </c:otherwise>
  </c:choose>
 </section>

 <footer style="margin-top: 30px; text-align:center; color:#64748b; font-size:13px;">
  <span>Mộc Sách.</span> Không gian điều hành chi nhánh &bull; <a href="${base}/home">Về trang khách</a>
 </footer>
</main>
</body>
</html>
