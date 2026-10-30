package com.bookstore.entity.branch;

import com.bookstore.entity.auth.User;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bk_inventory_transfers")
public class InventoryTransfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transfer_code", unique = true, nullable = false, length = 60)
    private String transferCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_branch_id", nullable = false)
    private Branch fromBranch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_branch_id", nullable = false)
    private Branch toBranch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requested_by_user_id", nullable = false)
    private User requestedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by_user_id")
    private User approvedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "received_by_user_id")
    private User receivedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "reason", nullable = false, length = 40)
    private TransferReason reason = TransferReason.RESTOCK;

    @Column(name = "reference_order_code", length = 60)
    private String referenceOrderCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private TransferStatus status = TransferStatus.REQUESTED;

    @Column(name = "note", length = 1000)
    private String note;

    @OneToMany(mappedBy = "inventoryTransfer", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<InventoryTransferItem> items = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    public InventoryTransfer() {
    }

    public InventoryTransfer(String transferCode, Branch fromBranch, Branch toBranch, User requestedBy, TransferReason reason) {
        this.transferCode = transferCode;
        this.fromBranch = fromBranch;
        this.toBranch = toBranch;
        this.requestedBy = requestedBy;
        this.reason = reason;
        this.status = TransferStatus.REQUESTED;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public void addItem(InventoryTransferItem item) {
        items.add(item);
        item.setInventoryTransfer(this);
    }

    public void removeItem(InventoryTransferItem item) {
        items.remove(item);
        item.setInventoryTransfer(null);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTransferCode() {
        return transferCode;
    }

    public void setTransferCode(String transferCode) {
        this.transferCode = transferCode;
    }

    public Branch getFromBranch() {
        return fromBranch;
    }

    public void setFromBranch(Branch fromBranch) {
        this.fromBranch = fromBranch;
    }

    public Branch getToBranch() {
        return toBranch;
    }

    public void setToBranch(Branch toBranch) {
        this.toBranch = toBranch;
    }

    public User getRequestedBy() {
        return requestedBy;
    }

    public void setRequestedBy(User requestedBy) {
        this.requestedBy = requestedBy;
    }

    public User getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(User approvedBy) {
        this.approvedBy = approvedBy;
    }

    public User getReceivedBy() {
        return receivedBy;
    }

    public void setReceivedBy(User receivedBy) {
        this.receivedBy = receivedBy;
    }

    public TransferReason getReason() {
        return reason;
    }

    public void setReason(TransferReason reason) {
        this.reason = reason;
    }

    public String getReferenceOrderCode() {
        return referenceOrderCode;
    }

    public void setReferenceOrderCode(String referenceOrderCode) {
        this.referenceOrderCode = referenceOrderCode;
    }

    public TransferStatus getStatus() {
        return status;
    }

    public void setStatus(TransferStatus status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public List<InventoryTransferItem> getItems() {
        return items;
    }

    public void setItems(List<InventoryTransferItem> items) {
        this.items = items;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
}
