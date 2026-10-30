package com.bookstore.service.branch;

import com.bookstore.entity.buyback.ConditionGrade;

public class ReceiptItemDTO {

    private Long bookItemId;
    private ConditionGrade gradeAfter;
    private boolean damagedOrLost = false;
    private String discrepancyNote;

    public Long getBookItemId() {
        return bookItemId;
    }

    public void setBookItemId(Long bookItemId) {
        this.bookItemId = bookItemId;
    }

    public ConditionGrade getGradeAfter() {
        return gradeAfter;
    }

    public void setGradeAfter(ConditionGrade gradeAfter) {
        this.gradeAfter = gradeAfter;
    }

    public boolean isDamagedOrLost() {
        return damagedOrLost;
    }

    public void setDamagedOrLost(boolean damagedOrLost) {
        this.damagedOrLost = damagedOrLost;
    }

    public String getDiscrepancyNote() {
        return discrepancyNote;
    }

    public void setDiscrepancyNote(String discrepancyNote) {
        this.discrepancyNote = discrepancyNote;
    }
}
