package com.bookstore.service.report;

import com.bookstore.entity.buyback.ConditionGrade;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AgingStockReportDTO {

    private Long bookItemId;
    private String serialCode;
    private String title;
    private String author;
    private String branchName;
    private ConditionGrade grade;
    private BigDecimal costPrice;
    private BigDecimal sellingPrice;
    private LocalDateTime createdAt;
    private long daysInStock;

    public AgingStockReportDTO() {
    }

    public AgingStockReportDTO(Long bookItemId, String serialCode, String title, String author,
                               String branchName, ConditionGrade grade, BigDecimal costPrice,
                               BigDecimal sellingPrice, LocalDateTime createdAt, long daysInStock) {
        this.bookItemId = bookItemId;
        this.serialCode = serialCode;
        this.title = title;
        this.author = author;
        this.branchName = branchName;
        this.grade = grade;
        this.costPrice = costPrice;
        this.sellingPrice = sellingPrice;
        this.createdAt = createdAt;
        this.daysInStock = daysInStock;
    }

    public Long getBookItemId() {
        return bookItemId;
    }

    public void setBookItemId(Long bookItemId) {
        this.bookItemId = bookItemId;
    }

    public String getSerialCode() {
        return serialCode;
    }

    public void setSerialCode(String serialCode) {
        this.serialCode = serialCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public ConditionGrade getGrade() {
        return grade;
    }

    public void setGrade(ConditionGrade grade) {
        this.grade = grade;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public BigDecimal getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(BigDecimal sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public long getDaysInStock() {
        return daysInStock;
    }

    public void setDaysInStock(long daysInStock) {
        this.daysInStock = daysInStock;
    }
}
