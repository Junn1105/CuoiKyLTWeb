package com.bookstore.repository.auth;

import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("bkUserRepository")
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByBranchId(Long branchId);
    List<User> findByRoleCode(RoleCode roleCode);
    List<User> findByBranchIdAndRoleCode(Long branchId, RoleCode roleCode);
}
