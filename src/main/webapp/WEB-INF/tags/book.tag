<%@ tag pageEncoding="UTF-8" %>
<%@ attribute name="book" required="true" type="java.util.Map" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<article class="book-card">
 <div class="cover-stage"><a class="cover-link" href="${pageContext.request.contextPath}/books/${book.id}"><img src="${pageContext.request.contextPath}<c:out value='${book.cover}'/>" alt="Bìa sách <c:out value='${book.title}'/>" loading="lazy" width="180" height="250" data-cover></a></div>
 <div class="book-category"><c:out value="${book.categoryName}"/></div>
 <h3><a href="${pageContext.request.contextPath}/books/${book.id}"><c:out value="${book.title}"/></a></h3>
 <p class="author"><c:out value="${book.authors}"/></p>
 <div class="book-metrics"><span><span class="star">★</span> <c:choose><c:when test="${book.reviews > 0}"><c:out value="${book.ratingLabel}"/> <small>(<c:out value="${book.reviews}"/>)</small></c:when><c:otherwise><small>Chưa đánh giá</small></c:otherwise></c:choose></span><span>Đã bán <c:out value="${book.sales}"/></span></div>
 <div class="book-bottom"><strong><c:out value="${book.priceLabel}"/></strong><form class="add-book-form" method="post" action="${pageContext.request.contextPath}/cart/add"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="bookId" value="${book.id}"><input type="hidden" name="quantity" value="1"><button type="submit" class="add-book" aria-label="Thêm vào giỏ: <c:out value='${book.title}'/>" ${book.available == 0 ? 'disabled' : ''}>+</button></form></div>
</article>
