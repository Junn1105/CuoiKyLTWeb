<%@ tag pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="base" value="${pageContext.request.contextPath}"/>
<div class="notif-menu" data-notif-menu>
 <button class="notification notif-trigger" type="button" data-notif-toggle aria-expanded="false" aria-haspopup="true" aria-label="Thông báo">
  <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></svg>
  <c:if test="${unreadCount > 0}"><span class="notif-badge"><c:out value="${unreadCount > 99 ? '99+' : unreadCount}"/></span></c:if>
 </button>
 <div class="notif-dropdown" data-notif-dropdown hidden>
  <div class="notif-head">
   <h3>Thông báo</h3>
   <c:if test="${not empty displayName and unreadCount > 0}">
    <form method="post" action="${base}/notifications/read-all"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button type="submit" class="notif-mark-all">Đánh dấu đã đọc</button></form>
   </c:if>
  </div>
  <c:choose>
   <c:when test="${not empty displayName}">
    <div class="notif-tabs" role="tablist" aria-label="Bộ lọc thông báo">
     <button type="button" class="notif-tab active" data-notif-filter="all">Tất cả</button>
     <button type="button" class="notif-tab" data-notif-filter="unread">Chưa đọc</button>
    </div>
    <div class="notif-subhead"><span>Trước đó</span><a href="${base}/notifications">Xem tất cả</a></div>
    <div class="notif-list" data-notif-list>
     <c:choose>
      <c:when test="${empty notifications}">
       <p class="notif-empty">Bạn chưa có thông báo nào.</p>
      </c:when>
      <c:otherwise>
       <c:forEach items="${notifications}" var="n">
        <form method="post" action="${base}/notifications/${n.id}/open" class="notif-item-form" data-unread="${n.unread}">
         <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
         <button type="submit" class="notif-item ${n.unread ? 'is-unread' : ''}">
          <span class="notif-avatar" aria-hidden="true"><c:out value="${n.icon}"/></span>
          <span class="notif-content">
           <span class="notif-text"><strong><c:out value="${n.title}"/></strong> · <c:out value="${n.content}"/></span>
           <span class="notif-time ${n.unread ? 'unread' : ''}"><c:out value="${n.timeLabel}"/></span>
          </span>
          <c:if test="${n.unread}"><span class="notif-dot" aria-label="Chưa đọc"></span></c:if>
         </button>
        </form>
       </c:forEach>
       <p class="notif-empty" data-notif-empty-unread hidden>Không có thông báo chưa đọc.</p>
      </c:otherwise>
     </c:choose>
    </div>
    <a class="notif-more-btn" href="${base}/notifications">Xem thông báo trước đó</a>
   </c:when>
   <c:otherwise>
    <div class="notif-guest">
     <p>Đăng nhập để theo dõi thông báo đơn hàng, giỏ sách và phản hồi đánh giá của bạn.</p>
     <a class="notif-more-btn" href="${base}/login">Đăng nhập ngay</a>
    </div>
   </c:otherwise>
  </c:choose>
 </div>
</div>
