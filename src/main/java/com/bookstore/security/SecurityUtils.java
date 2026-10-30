package com.bookstore.security;

import com.bookstore.entity.auth.RoleCode;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static Optional<CustomUserDetails> getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || !(auth.getPrincipal() instanceof CustomUserDetails)) {
            return Optional.empty();
        }
        return Optional.of((CustomUserDetails) auth.getPrincipal());
    }

    public static Long getCurrentUserId() {
        return getCurrentUser().map(CustomUserDetails::getUserId).orElse(null);
    }

    public static String getCurrentUserEmail() {
        return getCurrentUser().map(CustomUserDetails::getEmail).orElse(null);
    }

    public static RoleCode getCurrentUserRole() {
        return getCurrentUser().map(CustomUserDetails::getRoleCode).orElse(null);
    }

    /**
     * Returns the branchId of the currently authenticated staff or manager.
     */
    public static Long getCurrentUserBranchId() {
        return getCurrentUser().map(CustomUserDetails::getBranchId).orElse(null);
    }

    public static boolean isSuperAdmin() {
        return getCurrentUser().map(CustomUserDetails::isSuperAdmin).orElse(false);
    }

    public static boolean isBranchManager() {
        return getCurrentUser().map(CustomUserDetails::isBranchManager).orElse(false);
    }

    public static boolean isStaff() {
        return getCurrentUser().map(CustomUserDetails::isStaff).orElse(false);
    }

    public static boolean isCustomer() {
        return getCurrentUser().map(CustomUserDetails::isCustomer).orElse(false);
    }

    /**
     * Enforces strict branch data isolation.
     * Super Admin has chain-wide access.
     * Branch Manager and Staff are strictly restricted to their assigned branch.
     * Throws AccessDeniedException if the target branch does not match.
     */
    public static void assertBranchAccess(Long targetBranchId) {
        CustomUserDetails user = getCurrentUser()
                .orElseThrow(() -> new AccessDeniedException("Yêu cầu đăng nhập để thực hiện thao tác này"));

        if (user.isSuperAdmin()) {
            return; // Super Admin has chain-wide jurisdiction
        }

        if (user.isBranchManager() || user.isStaff()) {
            if (user.getBranchId() != null && user.getBranchId().equals(targetBranchId)) {
                return; // Valid branch scope
            }
            throw new AccessDeniedException("Bạn không có quyền thao tác trên dữ liệu của chi nhánh khác");
        }

        throw new AccessDeniedException("Tài khoản của bạn không có quyền truy cập dữ liệu quản trị chi nhánh");
    }

    /**
     * Non-throwing boolean check for branch access.
     */
    public static boolean hasBranchAccess(Long targetBranchId) {
        try {
            assertBranchAccess(targetBranchId);
            return true;
        } catch (AccessDeniedException e) {
            return false;
        }
    }
}
