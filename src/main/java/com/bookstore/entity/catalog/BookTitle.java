package com.bookstore.entity.catalog;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bk_book_titles")
public class BookTitle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "isbn", length = 30)
    private String isbn;

    @Column(name = "title", nullable = false, length = 250)
    private String title;

    @Column(name = "author", length = 150)
    private String author;

    @Column(name = "publisher", length = 150)
    private String publisher;

    @Column(name = "publish_year")
    private Integer publishYear;

    @Column(name = "cover_price", precision = 12, scale = 2)
    private BigDecimal coverPrice;

    @Column(name = "category", length = 100)
    private String category;

    @Column(name = "description", length = 2000)
    private String description;

    @Column(name = "cover_image_url", length = 500)
    private String coverImageUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public BookTitle() {
    }

    public BookTitle(String isbn, String title, String author, BigDecimal coverPrice) {
        this.isbn = isbn;
        this.title = title;
        this.author = author;
        this.coverPrice = coverPrice;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
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

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public Integer getPublishYear() {
        return publishYear;
    }

    public void setPublishYear(Integer publishYear) {
        this.publishYear = publishYear;
    }

    public BigDecimal getCoverPrice() {
        return coverPrice;
    }

    public void setCoverPrice(BigDecimal coverPrice) {
        this.coverPrice = coverPrice;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCoverImageUrl() {
        return coverImageUrl;
    }

    public void setCoverImageUrl(String coverImageUrl) {
        this.coverImageUrl = coverImageUrl;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
