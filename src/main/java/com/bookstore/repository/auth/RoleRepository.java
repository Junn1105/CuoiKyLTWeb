package com.bookstore.repository.auth;

import com.bookstore.entity.auth.Role;
import com.bookstore.entity.auth.RoleCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository("bkRoleRepository")
public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByCode(RoleCode code);
    boolean existsByCode(RoleCode code);
}
