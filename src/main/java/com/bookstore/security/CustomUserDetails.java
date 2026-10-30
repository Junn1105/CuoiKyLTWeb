package com.bookstore.security;

import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

public class CustomUserDetails implements UserDetails {

    private final Long userId;
    private final String email;
    private final String fullName;
    private final String passwordHash;
    private final RoleCode roleCode;
    private final Long branchId;
    private final String branchCode;
    private final boolean active;
    private final Collection<? extends GrantedAuthority> authorities;

    public CustomUserDetails(Long userId, String email, String fullName, String passwordHash,
                             RoleCode roleCode, Long branchId, String branchCode, boolean active) {
        this.userId = userId;
        this.email = email;
        this.fullName = fullName;
        this.passwordHash = passwordHash;
        this.roleCode = roleCode;
        this.branchId = branchId;
        this.branchCode = branchCode;
        this.active = active;
        this.authorities = roleCode != null
                ? List.of(new SimpleGrantedAuthority(roleCode.name()))
                : Collections.emptyList();
    }

    public static CustomUserDetails fromEntity(User user) {
        Long branchId = user.getBranch() != null ? user.getBranch().getId() : null;
        String branchCode = user.getBranch() != null ? user.getBranch().getCode() : null;
        RoleCode roleCode = user.getRole() != null ? user.getRole().getCode() : RoleCode.ROLE_CUSTOMER;

        return new CustomUserDetails(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPasswordHash(),
                roleCode,
                branchId,
                branchCode,
                user.isActive()
        );
    }

    public Long getUserId() {
        return userId;
    }

    public String getEmail() {
        return email;
    }

    public String getFullName() {
        return fullName;
    }

    public RoleCode getRoleCode() {
        return roleCode;
    }

    public Long getBranchId() {
        return branchId;
    }

    public String getBranchCode() {
        return branchCode;
    }

    public boolean isSuperAdmin() {
        return RoleCode.ROLE_SUPER_ADMIN.equals(roleCode);
    }

    public boolean isBranchManager() {
        return RoleCode.ROLE_BRANCH_MANAGER.equals(roleCode);
    }

    public boolean isStaff() {
        return RoleCode.ROLE_STAFF.equals(roleCode);
    }

    public boolean isCustomer() {
        return RoleCode.ROLE_CUSTOMER.equals(roleCode);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return passwordHash;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return active;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }
}
