package com.bookstore.repository.buyback;

import com.bookstore.entity.buyback.BuybackRequestItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository("bkBuybackRequestItemRepository")
public interface BuybackRequestItemRepository extends JpaRepository<BuybackRequestItem, Long> {
    List<BuybackRequestItem> findByBuybackRequestId(Long buybackRequestId);
    List<BuybackRequestItem> findBySpawnedBookItemId(Long spawnedBookItemId);
}
