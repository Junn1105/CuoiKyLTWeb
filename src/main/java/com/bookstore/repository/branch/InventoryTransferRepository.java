package com.bookstore.repository.branch;

import com.bookstore.entity.branch.InventoryTransfer;
import com.bookstore.entity.branch.TransferStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("bkInventoryTransferRepository")
public interface InventoryTransferRepository extends JpaRepository<InventoryTransfer, Long> {
    Optional<InventoryTransfer> findByTransferCode(String transferCode);
    List<InventoryTransfer> findByFromBranchId(Long fromBranchId);
    List<InventoryTransfer> findByToBranchId(Long toBranchId);
    List<InventoryTransfer> findByFromBranchIdOrToBranchId(Long fromBranchId, Long toBranchId);
    List<InventoryTransfer> findByStatus(TransferStatus status);
}
