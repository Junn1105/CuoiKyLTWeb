package com.bookstore.entity.buyback;

import java.math.BigDecimal;

public enum ConditionGrade {
    S("Như mới (95-99%)", new BigDecimal("0.45"), new BigDecimal("0.75")),
    A("Rất tốt (80-90%)", new BigDecimal("0.35"), new BigDecimal("0.60")),
    B("Khá tốt (65-75%)", new BigDecimal("0.20"), new BigDecimal("0.45")),
    C("Chấp nhận được (<65%)", new BigDecimal("0.08"), new BigDecimal("0.25"));

    private final String description;
    private final BigDecimal buyMultiplier;
    private final BigDecimal sellMultiplier;

    ConditionGrade(String description, BigDecimal buyMultiplier, BigDecimal sellMultiplier) {
        this.description = description;
        this.buyMultiplier = buyMultiplier;
        this.sellMultiplier = sellMultiplier;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getBuyMultiplier() {
        return buyMultiplier;
    }

    public BigDecimal getSellMultiplier() {
        return sellMultiplier;
    }
}
