package com.bookstore.repository.buyback;

import com.bookstore.entity.buyback.BuybackRequest;
import com.bookstore.entity.buyback.BuybackStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("bkBuybackRequestRepository")
public interface BuybackRequestRepository extends JpaRepository<BuybackRequest, Long> {
    Optional<BuybackRequest> findByRequestCode(String requestCode);
    List<BuybackRequest> findByTargetBranchId(Long branchId);
    List<BuybackRequest> findByCustomerId(Long customerId);
    List<BuybackRequest> findByStatus(BuybackStatus status);
    List<BuybackRequest> findByTargetBranchIdAndStatus(Long branchId, BuybackStatus status);
}
