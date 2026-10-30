package com.bookstore.security;

import org.springframework.stereotype.Component;

@Component("branchAccessGuard")
public class BranchAccessGuard {

    /**
     * Checks if current user can view/access records of targetBranchId.
     * Super Admin -> true
     * Branch Manager / Staff of that branch -> true
     * Others -> false
     */
    public boolean canAccessBranch(Long targetBranchId) {
        if (targetBranchId == null) {
            return SecurityUtils.isSuperAdmin();
        }
        return SecurityUtils.hasBranchAccess(targetBranchId);
    }

    /**
     * Checks if current user can perform managerial duties for targetBranchId.
     * Super Admin -> true
     * Branch Manager of that branch -> true
     * Staff -> false (Staff cannot manage staff or approve branch-level actions)
     */
    public boolean canManageBranch(Long targetBranchId) {
        if (SecurityUtils.isSuperAdmin()) {
            return true;
        }
        if (SecurityUtils.isBranchManager()) {
            Long userBranchId = SecurityUtils.getCurrentUserBranchId();
            return userBranchId != null && userBranchId.equals(targetBranchId);
        }
        return false;
    }

    /**
     * Checks if user is Super Admin only.
     */
    public boolean isSuperAdmin() {
        return SecurityUtils.isSuperAdmin();
    }
}
