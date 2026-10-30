package com.bookstore.security;

import com.bookstore.entity.auth.Role;
import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.Branch;
import com.bookstore.repository.auth.RoleRepository;
import com.bookstore.repository.auth.UserRepository;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.service.auth.AuthService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = vn.mocsach.MocSachApplication.class)
@Transactional
class MemberAPhase2SecurityTest {

    @Autowired private JwtTokenProvider tokenProvider;
    @Autowired private AuthService authService;
    @Autowired private UserRepository userRepository;
    @Autowired private RoleRepository roleRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private BranchAccessGuard branchAccessGuard;

    private User superAdmin;
    private User branchManagerQ1;
    private User staffQ1;
    private User customer;
    private Branch branchQ1;
    private Branch branchTD;

    @BeforeEach
    void setUp() {
        Role adminRole = roleRepository.findByCode(RoleCode.ROLE_SUPER_ADMIN).orElseThrow();
        Role managerRole = roleRepository.findByCode(RoleCode.ROLE_BRANCH_MANAGER).orElseThrow();
        Role staffRole = roleRepository.findByCode(RoleCode.ROLE_STAFF).orElseThrow();
        Role customerRole = roleRepository.findByCode(RoleCode.ROLE_CUSTOMER).orElseThrow();

        branchQ1 = branchRepository.findByCode("SGN-Q1").orElseThrow();
        branchTD = branchRepository.findByCode("SGN-TD").orElseThrow();

        superAdmin = userRepository.findByEmail("admin@bookstore.vn").orElseThrow();
        branchManagerQ1 = userRepository.findByEmail("manager.q1@bookstore.vn").orElseThrow();
        staffQ1 = userRepository.findByEmail("staff.q1@bookstore.vn").orElseThrow();
        customer = userRepository.findByEmail("customer@bookstore.vn").orElseThrow();
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void testJwtTokenGenerationAndClaimsExtraction() {
        String token = tokenProvider.generateToken(branchManagerQ1);
        assertNotNull(token);
        assertTrue(tokenProvider.validateToken(token));

        CustomUserDetails details = tokenProvider.getUserDetailsFromToken(token);
        assertEquals(branchManagerQ1.getId(), details.getUserId());
        assertEquals("manager.q1@bookstore.vn", details.getEmail());
        assertEquals(RoleCode.ROLE_BRANCH_MANAGER, details.getRoleCode());
        assertEquals(branchQ1.getId(), details.getBranchId());
        assertEquals("SGN-Q1", details.getBranchCode());
        assertTrue(details.isBranchManager());
        assertFalse(details.isSuperAdmin());
    }

    @Test
    void testSuperAdminAccessAcrossAllBranches() {
        CustomUserDetails adminDetails = CustomUserDetails.fromEntity(superAdmin);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(adminDetails, null, adminDetails.getAuthorities()));

        // Super Admin must be allowed to access any branch
        assertDoesNotThrow(() -> SecurityUtils.assertBranchAccess(branchQ1.getId()));
        assertDoesNotThrow(() -> SecurityUtils.assertBranchAccess(branchTD.getId()));
        assertTrue(branchAccessGuard.canAccessBranch(branchQ1.getId()));
        assertTrue(branchAccessGuard.canAccessBranch(branchTD.getId()));
        assertTrue(branchAccessGuard.canManageBranch(branchQ1.getId()));
        assertTrue(branchAccessGuard.isSuperAdmin());
    }

    @Test
    void testBranchManagerDataIsolation() {
        CustomUserDetails managerDetails = CustomUserDetails.fromEntity(branchManagerQ1);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(managerDetails, null, managerDetails.getAuthorities()));

        // Allowed on own branch (Q1)
        assertDoesNotThrow(() -> SecurityUtils.assertBranchAccess(branchQ1.getId()));
        assertTrue(branchAccessGuard.canAccessBranch(branchQ1.getId()));
        assertTrue(branchAccessGuard.canManageBranch(branchQ1.getId()));

        // BLOCKED on other branch (TD)
        AccessDeniedException ex = assertThrows(AccessDeniedException.class,
                () -> SecurityUtils.assertBranchAccess(branchTD.getId()));
        assertTrue(ex.getMessage().contains("không có quyền thao tác trên dữ liệu của chi nhánh khác"));
        assertFalse(branchAccessGuard.canAccessBranch(branchTD.getId()));
        assertFalse(branchAccessGuard.canManageBranch(branchTD.getId()));
    }

    @Test
    void testStaffDataIsolationAndManagementRestrictions() {
        CustomUserDetails staffDetails = CustomUserDetails.fromEntity(staffQ1);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(staffDetails, null, staffDetails.getAuthorities()));

        // Allowed to view/work on own branch (Q1)
        assertDoesNotThrow(() -> SecurityUtils.assertBranchAccess(branchQ1.getId()));
        assertTrue(branchAccessGuard.canAccessBranch(branchQ1.getId()));

        // Staff CANNOT manage branch
        assertFalse(branchAccessGuard.canManageBranch(branchQ1.getId()));

        // BLOCKED on other branch (TD)
        assertThrows(AccessDeniedException.class, () -> SecurityUtils.assertBranchAccess(branchTD.getId()));
    }

    @Test
    void testCustomerRestrictedFromAdminBranchAccess() {
        CustomUserDetails customerDetails = CustomUserDetails.fromEntity(customer);
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(customerDetails, null, customerDetails.getAuthorities()));

        assertThrows(AccessDeniedException.class, () -> SecurityUtils.assertBranchAccess(branchQ1.getId()));
        assertFalse(branchAccessGuard.canAccessBranch(branchQ1.getId()));
        assertFalse(branchAccessGuard.canManageBranch(branchQ1.getId()));
    }

    @Test
    void testAuthServiceAuthenticationSuccessAndFailure() {
        // Successful authentication
        User authed = authService.authenticate("manager.q1@bookstore.vn", "123456");
        assertNotNull(authed);
        assertEquals("manager.q1@bookstore.vn", authed.getEmail());

        // Invalid password
        assertThrows(BadCredentialsException.class,
                () -> authService.authenticate("manager.q1@bookstore.vn", "wrong_password"));

        // Non-existent user
        assertThrows(BadCredentialsException.class,
                () -> authService.authenticate("unknown@bookstore.vn", "123456"));
    }
}
