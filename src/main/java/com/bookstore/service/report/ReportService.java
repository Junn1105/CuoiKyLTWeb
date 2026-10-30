package com.bookstore.service.report;

import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.buyback.BuybackRequest;
import com.bookstore.entity.buyback.BuybackStatus;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.buyback.BuybackRequestRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.security.SecurityUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class ReportService {

    private final BranchRepository branchRepository;
    private final BookItemRepository bookItemRepository;
    private final BuybackRequestRepository buybackRequestRepository;

    public ReportService(BranchRepository branchRepository,
                         BookItemRepository bookItemRepository,
                         BuybackRequestRepository buybackRequestRepository) {
        this.branchRepository = branchRepository;
        this.bookItemRepository = bookItemRepository;
        this.buybackRequestRepository = buybackRequestRepository;
    }

    /**
     * Module 5: Real-time Multi-Branch Financial & Inventory Performance Report
     */
    @Transactional(readOnly = true)
    public List<BranchPerformanceReportDTO> getBranchPerformanceReports(Long targetBranchId) {
        List<Branch> branches;
        if (targetBranchId != null) {
            SecurityUtils.assertBranchAccess(targetBranchId);
            branches = branchRepository.findById(targetBranchId).map(List::of).orElse(List.of());
        } else {
            if (!SecurityUtils.isSuperAdmin()) {
                Long currentBranch = SecurityUtils.getCurrentUserBranchId();
                if (currentBranch != null) {
                    branches = branchRepository.findById(currentBranch).map(List::of).orElse(List.of());
                } else {
                    branches = List.of();
                }
            } else {
                branches = branchRepository.findAll();
            }
        }

        List<BranchPerformanceReportDTO> reports = new ArrayList<>();

        for (Branch b : branches) {
            BranchPerformanceReportDTO dto = new BranchPerformanceReportDTO(b.getId(), b.getCode(), b.getName());

            // 1. Calculate Buyback Payouts
            List<BuybackRequest> buybacks = buybackRequestRepository.findByTargetBranchIdAndStatus(b.getId(), BuybackStatus.COMPLETED);
            BigDecimal totalBuyback = buybacks.stream()
                    .map(BuybackRequest::getTotalFinalPrice)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            dto.setTotalBuybackPayout(totalBuyback);

            // 2. Calculate Inventory & Sales
            List<BookItem> items = bookItemRepository.findByCurrentBranchId(b.getId());
            long inStockCount = 0;
            BigDecimal costValue = BigDecimal.ZERO;
            BigDecimal retailValue = BigDecimal.ZERO;
            BigDecimal soldRevenue = BigDecimal.ZERO;

            for (BookItem item : items) {
                if (item.getStatus() == BookItemStatus.IN_STOCK) {
                    inStockCount++;
                    if (item.getCostPrice() != null) {
                        costValue = costValue.add(item.getCostPrice());
                    }
                    if (item.getSellingPrice() != null) {
                        retailValue = retailValue.add(item.getSellingPrice());
                    }
                } else if (item.getStatus() == BookItemStatus.SOLD) {
                    if (item.getSellingPrice() != null) {
                        soldRevenue = soldRevenue.add(item.getSellingPrice());
                    }
                }
            }

            dto.setCurrentInventoryCount(inStockCount);
            dto.setInventoryCostValue(costValue);
            dto.setInventoryRetailValue(retailValue);
            dto.setTotalSoldRevenue(soldRevenue);

            reports.add(dto);
        }

        return reports;
    }

    /**
     * Module 5: Aging Dead Stock Report
     * Identifies books in stock > thresholdDays (default 90 days).
     */
    @Transactional(readOnly = true)
    public List<AgingStockReportDTO> getAgingStockReport(Long targetBranchId, int thresholdDays) {
        LocalDateTime thresholdDate = LocalDateTime.now().minusDays(thresholdDays > 0 ? thresholdDays : 90);
        LocalDateTime now = LocalDateTime.now();

        List<BookItem> agingItems;
        if (targetBranchId != null) {
            SecurityUtils.assertBranchAccess(targetBranchId);
            agingItems = bookItemRepository.findAgingStockByBranch(targetBranchId, BookItemStatus.IN_STOCK, thresholdDate);
        } else {
            if (!SecurityUtils.isSuperAdmin()) {
                Long currentBranch = SecurityUtils.getCurrentUserBranchId();
                if (currentBranch != null) {
                    agingItems = bookItemRepository.findAgingStockByBranch(currentBranch, BookItemStatus.IN_STOCK, thresholdDate);
                } else {
                    agingItems = List.of();
                }
            } else {
                agingItems = bookItemRepository.findAgingStock(BookItemStatus.IN_STOCK, thresholdDate);
            }
        }

        List<AgingStockReportDTO> results = new ArrayList<>();
        for (BookItem item : agingItems) {
            long daysInStock = (item.getCreatedAt() != null)
                    ? Duration.between(item.getCreatedAt(), now).toDays()
                    : thresholdDays;

            results.add(new AgingStockReportDTO(
                    item.getId(),
                    item.getSerialCode(),
                    item.getBookTitle().getTitle(),
                    item.getBookTitle().getAuthor(),
                    item.getCurrentBranch().getName(),
                    item.getGrade(),
                    item.getCostPrice(),
                    item.getSellingPrice(),
                    item.getCreatedAt(),
                    daysInStock
            ));
        }

        return results;
    }
}
