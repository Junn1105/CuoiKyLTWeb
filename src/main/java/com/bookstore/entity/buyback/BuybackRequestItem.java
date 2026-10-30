package com.bookstore.entity.buyback;

import com.bookstore.entity.catalog.BookTitle;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "bk_buyback_request_items")
public class BuybackRequestItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyback_request_id", nullable = false)
    private BuybackRequest buybackRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_title_id")
    private BookTitle bookTitle;

    @Column(name = "custom_book_title", length = 250)
    private String customBookTitle;

    @Column(name = "isbn", length = 30)
    private String isbn;

    @Column(name = "declared_cover_price", precision = 12, scale = 2)
    private BigDecimal declaredCoverPrice;

    @Column(name = "customer_condition_note", length = 1000)
    private String customerConditionNote;

    @Column(name = "cloudinary_images_json", columnDefinition = "NVARCHAR(MAX)")
    private String cloudinaryImagesJson;

    @Column(name = "pre_quoted_price", precision = 12, scale = 2)
    private BigDecimal preQuotedPrice;

    @Enumerated(EnumType.STRING)
    @Column(name = "final_grade", length = 20)
    private ConditionGrade finalGrade;

    @Column(name = "final_price", precision = 12, scale = 2)
    private BigDecimal finalPrice;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;

    @Column(name = "spawned_book_item_id")
    private Long spawnedBookItemId;

    public BuybackRequestItem() {
    }

    public BuybackRequestItem(BuybackRequest buybackRequest, BookTitle bookTitle, String customBookTitle, String isbn, BigDecimal declaredCoverPrice) {
        this.buybackRequest = buybackRequest;
        this.bookTitle = bookTitle;
        this.customBookTitle = customBookTitle;
        this.isbn = isbn;
        this.declaredCoverPrice = declaredCoverPrice;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BuybackRequest getBuybackRequest() {
        return buybackRequest;
    }

    public void setBuybackRequest(BuybackRequest buybackRequest) {
        this.buybackRequest = buybackRequest;
    }

    public BookTitle getBookTitle() {
        return bookTitle;
    }

    public void setBookTitle(BookTitle bookTitle) {
        this.bookTitle = bookTitle;
    }

    public String getCustomBookTitle() {
        return customBookTitle;
    }

    public void setCustomBookTitle(String customBookTitle) {
        this.customBookTitle = customBookTitle;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public BigDecimal getDeclaredCoverPrice() {
        return declaredCoverPrice;
    }

    public void setDeclaredCoverPrice(BigDecimal declaredCoverPrice) {
        this.declaredCoverPrice = declaredCoverPrice;
    }

    public String getCustomerConditionNote() {
        return customerConditionNote;
    }

    public void setCustomerConditionNote(String customerConditionNote) {
        this.customerConditionNote = customerConditionNote;
    }

    public String getCloudinaryImagesJson() {
        return cloudinaryImagesJson;
    }

    public void setCloudinaryImagesJson(String cloudinaryImagesJson) {
        this.cloudinaryImagesJson = cloudinaryImagesJson;
    }

    public BigDecimal getPreQuotedPrice() {
        return preQuotedPrice;
    }

    public void setPreQuotedPrice(BigDecimal preQuotedPrice) {
        this.preQuotedPrice = preQuotedPrice;
    }

    public ConditionGrade getFinalGrade() {
        return finalGrade;
    }

    public void setFinalGrade(ConditionGrade finalGrade) {
        this.finalGrade = finalGrade;
    }

    public BigDecimal getFinalPrice() {
        return finalPrice;
    }

    public void setFinalPrice(BigDecimal finalPrice) {
        this.finalPrice = finalPrice;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Long getSpawnedBookItemId() {
        return spawnedBookItemId;
    }

    public void setSpawnedBookItemId(Long spawnedBookItemId) {
        this.spawnedBookItemId = spawnedBookItemId;
    }
}
