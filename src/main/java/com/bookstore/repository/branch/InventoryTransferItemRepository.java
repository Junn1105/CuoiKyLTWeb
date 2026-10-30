package com.bookstore.repository.branch;

import com.bookstore.entity.branch.InventoryTransferItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository("bkInventoryTransferItemRepository")
public interface InventoryTransferItemRepository extends JpaRepository<InventoryTransferItem, Long> {
    List<InventoryTransferItem> findByInventoryTransferId(Long transferId);
    List<InventoryTransferItem> findByBookItemId(Long bookItemId);
}
