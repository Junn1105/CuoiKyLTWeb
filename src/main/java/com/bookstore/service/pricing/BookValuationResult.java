package com.bookstore.service.pricing;

import com.bookstore.entity.buyback.ConditionGrade;
import java.math.BigDecimal;

public class BookValuationResult {

    private BigDecimal coverPrice;
    private ConditionGrade grade;
    private BigDecimal rarityFactor;
    private long chainWideStockCount;
    private BigDecimal kStock;
    private BigDecimal recommendedBuybackPrice;
    private BigDecimal recommendedSellingPrice;
    private BigDecimal minStaffBuybackPrice;
    private BigDecimal maxStaffBuybackPrice;

    public BookValuationResult() {
    }

    public BookValuationResult(BigDecimal coverPrice, ConditionGrade grade, BigDecimal rarityFactor,
                               long chainWideStockCount, BigDecimal kStock,
                               BigDecimal recommendedBuybackPrice, BigDecimal recommendedSellingPrice,
                               BigDecimal minStaffBuybackPrice, BigDecimal maxStaffBuybackPrice) {
        this.coverPrice = coverPrice;
        this.grade = grade;
        this.rarityFactor = rarityFactor;
        this.chainWideStockCount = chainWideStockCount;
        this.kStock = kStock;
        this.recommendedBuybackPrice = recommendedBuybackPrice;
        this.recommendedSellingPrice = recommendedSellingPrice;
        this.minStaffBuybackPrice = minStaffBuybackPrice;
        this.maxStaffBuybackPrice = maxStaffBuybackPrice;
    }

    public BigDecimal getCoverPrice() {
        return coverPrice;
    }

    public void setCoverPrice(BigDecimal coverPrice) {
        this.coverPrice = coverPrice;
    }

    public ConditionGrade getGrade() {
        return grade;
    }

    public void setGrade(ConditionGrade grade) {
        this.grade = grade;
    }

    public BigDecimal getRarityFactor() {
        return rarityFactor;
    }

    public void setRarityFactor(BigDecimal rarityFactor) {
        this.rarityFactor = rarityFactor;
    }

    public long getChainWideStockCount() {
        return chainWideStockCount;
    }

    public void setChainWideStockCount(long chainWideStockCount) {
        this.chainWideStockCount = chainWideStockCount;
    }

    public BigDecimal getkStock() {
        return kStock;
    }

    public void setkStock(BigDecimal kStock) {
        this.kStock = kStock;
    }

    public BigDecimal getRecommendedBuybackPrice() {
        return recommendedBuybackPrice;
    }

    public void setRecommendedBuybackPrice(BigDecimal recommendedBuybackPrice) {
        this.recommendedBuybackPrice = recommendedBuybackPrice;
    }

    public BigDecimal getRecommendedSellingPrice() {
        return recommendedSellingPrice;
    }

    public void setRecommendedSellingPrice(BigDecimal recommendedSellingPrice) {
        this.recommendedSellingPrice = recommendedSellingPrice;
    }

    public BigDecimal getMinStaffBuybackPrice() {
        return minStaffBuybackPrice;
    }

    public void setMinStaffBuybackPrice(BigDecimal minStaffBuybackPrice) {
        this.minStaffBuybackPrice = minStaffBuybackPrice;
    }

    public BigDecimal getMaxStaffBuybackPrice() {
        return maxStaffBuybackPrice;
    }

    public void setMaxStaffBuybackPrice(BigDecimal maxStaffBuybackPrice) {
        this.maxStaffBuybackPrice = maxStaffBuybackPrice;
    }
}
