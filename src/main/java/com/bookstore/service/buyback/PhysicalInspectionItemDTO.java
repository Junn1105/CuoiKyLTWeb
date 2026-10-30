package com.bookstore.service.buyback;

import com.bookstore.entity.buyback.ConditionGrade;
import java.math.BigDecimal;

public class PhysicalInspectionItemDTO {

    private Long itemId;
    private ConditionGrade finalGrade;
    private BigDecimal customPrice; // Optional override
    private boolean accepted = true;
    private String rejectionReason;

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public ConditionGrade getFinalGrade() {
        return finalGrade;
    }

    public void setFinalGrade(ConditionGrade finalGrade) {
        this.finalGrade = finalGrade;
    }

    public BigDecimal getCustomPrice() {
        return customPrice;
    }

    public void setCustomPrice(BigDecimal customPrice) {
        this.customPrice = customPrice;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }
}
