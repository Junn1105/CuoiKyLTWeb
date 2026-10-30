package com.bookstore.service.report;

import java.math.BigDecimal;

public class BranchPerformanceReportDTO {

    private Long branchId;
    private String branchCode;
    private String branchName;
    private BigDecimal totalBuybackPayout = BigDecimal.ZERO;
    private BigDecimal totalSoldRevenue = BigDecimal.ZERO;
    private BigDecimal grossProfit = BigDecimal.ZERO;
    private long currentInventoryCount = 0;
    private BigDecimal inventoryCostValue = BigDecimal.ZERO;
    private BigDecimal inventoryRetailValue = BigDecimal.ZERO;

    public BranchPerformanceReportDTO() {
    }

    public BranchPerformanceReportDTO(Long branchId, String branchCode, String branchName) {
        this.branchId = branchId;
        this.branchCode = branchCode;
        this.branchName = branchName;
    }

    public Long getBranchId() {
        return branchId;
    }

    public void setBranchId(Long branchId) {
        this.branchId = branchId;
    }

    public String getBranchCode() {
        return branchCode;
    }

    public void setBranchCode(String branchCode) {
        this.branchCode = branchCode;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public BigDecimal getTotalBuybackPayout() {
        return totalBuybackPayout;
    }

    public void setTotalBuybackPayout(BigDecimal totalBuybackPayout) {
        this.totalBuybackPayout = totalBuybackPayout;
        calculateProfit();
    }

    public BigDecimal getTotalSoldRevenue() {
        return totalSoldRevenue;
    }

    public void setTotalSoldRevenue(BigDecimal totalSoldRevenue) {
        this.totalSoldRevenue = totalSoldRevenue;
        calculateProfit();
    }

    public BigDecimal getGrossProfit() {
        return grossProfit;
    }

    public void setGrossProfit(BigDecimal grossProfit) {
        this.grossProfit = grossProfit;
    }

    public long getCurrentInventoryCount() {
        return currentInventoryCount;
    }

    public void setCurrentInventoryCount(long currentInventoryCount) {
        this.currentInventoryCount = currentInventoryCount;
    }

    public BigDecimal getInventoryCostValue() {
        return inventoryCostValue;
    }

    public void setInventoryCostValue(BigDecimal inventoryCostValue) {
        this.inventoryCostValue = inventoryCostValue;
    }

    public BigDecimal getInventoryRetailValue() {
        return inventoryRetailValue;
    }

    public void setInventoryRetailValue(BigDecimal inventoryRetailValue) {
        this.inventoryRetailValue = inventoryRetailValue;
    }

    private void calculateProfit() {
        if (totalSoldRevenue != null && totalBuybackPayout != null) {
            this.grossProfit = totalSoldRevenue.subtract(totalBuybackPayout);
        }
    }
}
