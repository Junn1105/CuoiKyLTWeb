package com.bookstore.repository.branch;

import com.bookstore.entity.branch.Branch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("bkBranchRepository")
public interface BranchRepository extends JpaRepository<Branch, Long> {
    Optional<Branch> findByCode(String code);
    boolean existsByCode(String code);
    List<Branch> findByActiveTrue();
    List<Branch> findByIsHubTrue();
}
