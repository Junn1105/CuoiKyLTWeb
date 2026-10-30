package com.bookstore.service.buyback;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class OnlineSubmissionDTO {

    private Long targetBranchId;
    private String customerName;
    private String customerPhone;
    private List<ItemDTO> items = new ArrayList<>();

    public static class ItemDTO {
        private String isbn;
        private String customTitle;
        private String author;
        private BigDecimal declaredCoverPrice;
        private String customerConditionNote;
        private String cloudinaryImagesJson;

        public String getIsbn() {
            return isbn;
        }

        public void setIsbn(String isbn) {
            this.isbn = isbn;
        }

        public String getCustomTitle() {
            return customTitle;
        }

        public void setCustomTitle(String customTitle) {
            this.customTitle = customTitle;
        }

        public String getAuthor() {
            return author;
        }

        public void setAuthor(String author) {
            this.author = author;
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
    }

    public Long getTargetBranchId() {
        return targetBranchId;
    }

    public void setTargetBranchId(Long targetBranchId) {
        this.targetBranchId = targetBranchId;
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

    public List<ItemDTO> getItems() {
        return items;
    }

    public void setItems(List<ItemDTO> items) {
        this.items = items;
    }
}
