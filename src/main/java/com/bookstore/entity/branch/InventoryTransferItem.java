package com.bookstore.entity.branch;

import com.bookstore.entity.buyback.ConditionGrade;
import com.bookstore.entity.catalog.BookItem;
import jakarta.persistence.*;

@Entity
@Table(name = "bk_inventory_transfer_items")
public class InventoryTransferItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transfer_id", nullable = false)
    private InventoryTransfer inventoryTransfer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_item_id", nullable = false)
    private BookItem bookItem;

    @Enumerated(EnumType.STRING)
    @Column(name = "grade_before", length = 20)
    private ConditionGrade gradeBefore;

    @Enumerated(EnumType.STRING)
    @Column(name = "grade_after", length = 20)
    private ConditionGrade gradeAfter;

    @Column(name = "discrepancy_note", length = 500)
    private String discrepancyNote;

    public InventoryTransferItem() {
    }

    public InventoryTransferItem(InventoryTransfer inventoryTransfer, BookItem bookItem, ConditionGrade gradeBefore) {
        this.inventoryTransfer = inventoryTransfer;
        this.bookItem = bookItem;
        this.gradeBefore = gradeBefore;
        this.gradeAfter = gradeBefore;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public InventoryTransfer getInventoryTransfer() {
        return inventoryTransfer;
    }

    public void setInventoryTransfer(InventoryTransfer inventoryTransfer) {
        this.inventoryTransfer = inventoryTransfer;
    }

    public BookItem getBookItem() {
        return bookItem;
    }

    public void setBookItem(BookItem bookItem) {
        this.bookItem = bookItem;
    }

    public ConditionGrade getGradeBefore() {
        return gradeBefore;
    }

    public void setGradeBefore(ConditionGrade gradeBefore) {
        this.gradeBefore = gradeBefore;
    }

    public ConditionGrade getGradeAfter() {
        return gradeAfter;
    }

    public void setGradeAfter(ConditionGrade gradeAfter) {
        this.gradeAfter = gradeAfter;
    }

    public String getDiscrepancyNote() {
        return discrepancyNote;
    }

    public void setDiscrepancyNote(String discrepancyNote) {
        this.discrepancyNote = discrepancyNote;
    }
}
