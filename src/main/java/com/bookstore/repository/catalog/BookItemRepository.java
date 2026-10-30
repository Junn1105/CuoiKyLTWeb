package com.bookstore.repository.catalog;

import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository("bkBookItemRepository")
public interface BookItemRepository extends JpaRepository<BookItem, Long> {
    Optional<BookItem> findBySerialCode(String serialCode);
    boolean existsBySerialCode(String serialCode);

    List<BookItem> findByCurrentBranchId(Long branchId);
    List<BookItem> findByCurrentBranchIdAndStatus(Long branchId, BookItemStatus status);
    List<BookItem> findByStatus(BookItemStatus status);

    // Stock saturation count across all branches for automated valuation (PricingEngineService)
    long countByBookTitleIdAndStatus(Long bookTitleId, BookItemStatus status);

    // Aging dead stock report (Section 4 Module 5)
    @Query("SELECT b FROM BookItem b WHERE b.status = :status AND b.createdAt <= :thresholdDate")
    List<BookItem> findAgingStock(@Param("status") BookItemStatus status, @Param("thresholdDate") LocalDateTime thresholdDate);

    @Query("SELECT b FROM BookItem b WHERE b.currentBranch.id = :branchId AND b.status = :status AND b.createdAt <= :thresholdDate")
    List<BookItem> findAgingStockByBranch(@Param("branchId") Long branchId, @Param("status") BookItemStatus status, @Param("thresholdDate") LocalDateTime thresholdDate);
}
