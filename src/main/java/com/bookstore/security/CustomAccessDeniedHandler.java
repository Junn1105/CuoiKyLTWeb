package com.bookstore.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException, ServletException {

        // 1. CSRF Token violations must always return 403 Forbidden
        if (accessDeniedException instanceof org.springframework.security.web.csrf.CsrfException) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, accessDeniedException.getMessage());
            return;
        }

        // 2. If it's an AJAX / API call, return JSON 403
        String acceptHeader = request.getHeader("Accept");
        String requestedWith = request.getHeader("X-Requested-With");
        boolean isAjax = (acceptHeader != null && acceptHeader.contains("application/json"))
                || "XMLHttpRequest".equalsIgnoreCase(requestedWith);

        if (isAjax) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"error\":\"Forbidden\",\"message\":\"Bạn không có quyền thực hiện thao tác này hoặc truy cập dữ liệu của chi nhánh khác.\"}");
            return;
        }

        // 3. Browser request: redirect according to role
        if (SecurityUtils.isStaff() || SecurityUtils.isBranchManager()) {
            response.sendRedirect(request.getContextPath() + "/admin/my-store?error=access_denied");
        } else if (SecurityUtils.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/home?error=access_denied");
        } else {
            response.sendRedirect(request.getContextPath() + "/login?error=access_denied");
        }
    }
}
