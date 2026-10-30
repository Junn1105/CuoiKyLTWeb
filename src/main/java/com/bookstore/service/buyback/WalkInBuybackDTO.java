package com.bookstore.service.buyback;

import com.bookstore.entity.buyback.ConditionGrade;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class WalkInBuybackDTO {

    private String customerName;
    private String customerPhone;
    private String staffNote;
    private List<ItemDTO> items = new ArrayList<>();

    public static class ItemDTO {
        private Long bookTitleId;
        private String isbn;
        private String title;
        private String author;
        private BigDecimal coverPrice;
        private ConditionGrade grade;
        private BigDecimal rarityFactor = BigDecimal.ONE;
        private BigDecimal offeredPrice; // Staff customized buy price (must adhere to ±15% guard)
        private String customerConditionNote;

        public Long getBookTitleId() {
            return bookTitleId;
        }

        public void setBookTitleId(Long bookTitleId) {
            this.bookTitleId = bookTitleId;
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

        public BigDecimal getOfferedPrice() {
            return offeredPrice;
        }

        public void setOfferedPrice(BigDecimal offeredPrice) {
            this.offeredPrice = offeredPrice;
        }

        public String getCustomerConditionNote() {
            return customerConditionNote;
        }

        public void setCustomerConditionNote(String customerConditionNote) {
            this.customerConditionNote = customerConditionNote;
        }
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

    public String getStaffNote() {
        return staffNote;
    }

    public void setStaffNote(String staffNote) {
        this.staffNote = staffNote;
    }

    public List<ItemDTO> getItems() {
        return items;
    }

    public void setItems(List<ItemDTO> items) {
        this.items = items;
    }
}
