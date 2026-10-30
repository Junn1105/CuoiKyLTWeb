package com.bookstore.entity.buyback;

import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.Branch;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bk_buyback_requests")
public class BuybackRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "request_code", unique = true, nullable = false, length = 60)
    private String requestCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_user_id")
    private User customer;

    @Column(name = "customer_name", length = 150)
    private String customerName;

    @Column(name = "customer_phone", length = 30)
    private String customerPhone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "target_branch_id")
    private Branch targetBranch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "appraiser_user_id")
    private User appraiser;

    @Enumerated(EnumType.STRING)
    @Column(name = "intake_type", nullable = false, length = 30)
    private BuybackIntakeType intakeType = BuybackIntakeType.WALK_IN_COUNTER;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 30)
    private BuybackStatus status = BuybackStatus.SUBMITTED;

    @Column(name = "total_estimated_price", precision = 12, scale = 2)
    private BigDecimal totalEstimatedPrice = BigDecimal.ZERO;

    @Column(name = "total_final_price", precision = 12, scale = 2)
    private BigDecimal totalFinalPrice = BigDecimal.ZERO;

    @Column(name = "staff_note", length = 1000)
    private String staffNote;

    @OneToMany(mappedBy = "buybackRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BuybackRequestItem> items = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public BuybackRequest() {
    }

    public BuybackRequest(String requestCode, User customer, String customerName, String customerPhone, Branch targetBranch, BuybackIntakeType intakeType, BuybackStatus status) {
        this.requestCode = requestCode;
        this.customer = customer;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.targetBranch = targetBranch;
        this.intakeType = intakeType;
        this.status = status;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public void addItem(BuybackRequestItem item) {
        items.add(item);
        item.setBuybackRequest(this);
    }

    public void removeItem(BuybackRequestItem item) {
        items.remove(item);
        item.setBuybackRequest(null);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRequestCode() {
        return requestCode;
    }

    public void setRequestCode(String requestCode) {
        this.requestCode = requestCode;
    }

    public User getCustomer() {
        return customer;
    }

    public void setCustomer(User customer) {
        this.customer = customer;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public Branch getTargetBranch() {
        return targetBranch;
    }

    public void setTargetBranch(Branch targetBranch) {
        this.targetBranch = targetBranch;
    }

    public User getAppraiser() {
        return appraiser;
    }

    public void setAppraiser(User appraiser) {
        this.appraiser = appraiser;
    }

    public BuybackIntakeType getIntakeType() {
        return intakeType;
    }

    public void setIntakeType(BuybackIntakeType intakeType) {
        this.intakeType = intakeType;
    }

    public BuybackStatus getStatus() {
        return status;
    }

    public void setStatus(BuybackStatus status) {
        this.status = status;
    }

    public BigDecimal getTotalEstimatedPrice() {
        return totalEstimatedPrice;
    }

    public void setTotalEstimatedPrice(BigDecimal totalEstimatedPrice) {
        this.totalEstimatedPrice = totalEstimatedPrice;
    }

    public BigDecimal getTotalFinalPrice() {
        return totalFinalPrice;
    }

    public void setTotalFinalPrice(BigDecimal totalFinalPrice) {
        this.totalFinalPrice = totalFinalPrice;
    }

    public String getStaffNote() {
        return staffNote;
    }

    public void setStaffNote(String staffNote) {
        this.staffNote = staffNote;
    }

    public List<BuybackRequestItem> getItems() {
        return items;
    }

    public void setItems(List<BuybackRequestItem> items) {
        this.items = items;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
