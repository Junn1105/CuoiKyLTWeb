package com.bookstore.service.pricing;

import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.buyback.ConditionGrade;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
public class PricingEngineService {

    public static final BigDecimal K_OVERSTOCK = BigDecimal.valueOf(0.80);
    public static final BigDecimal K_SCARCITY = BigDecimal.valueOf(1.10);
    public static final BigDecimal K_NORMAL = BigDecimal.valueOf(1.00);

    public static final BigDecimal STAFF_LOWER_MARGIN = BigDecimal.valueOf(0.85); // -15%
    public static final BigDecimal STAFF_UPPER_MARGIN = BigDecimal.valueOf(1.15); // +15%

    /**
     * Determines K_stock saturation coefficient based on chain-wide in-stock count.
     */
    public BigDecimal determineKStock(long chainWideStockCount) {
        if (chainWideStockCount >= 10) {
            return K_OVERSTOCK;
        } else if (chainWideStockCount == 0) {
            return K_SCARCITY;
        } else {
            return K_NORMAL;
        }
    }

    /**
     * Rounds a monetary amount to the nearest 1,000 VND.
     */
    public BigDecimal roundToNearestThousand(BigDecimal amount) {
        if (amount == null) {
            return BigDecimal.ZERO;
        }
        return amount.divide(BigDecimal.valueOf(1000), 0, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(1000));
    }

    /**
     * Calculates full valuation result including recommended buyback, selling, and staff limits.
     */
    public BookValuationResult calculateValuation(BigDecimal coverPrice, ConditionGrade grade,
                                                  BigDecimal rarityFactor, long chainWideStockCount) {
        if (coverPrice == null || coverPrice.compareTo(BigDecimal.ZERO) <= 0) {
            coverPrice = BigDecimal.ZERO;
        }
        if (grade == null) {
            grade = ConditionGrade.B;
        }
        if (rarityFactor == null || rarityFactor.compareTo(BigDecimal.ZERO) <= 0) {
            rarityFactor = BigDecimal.ONE;
        }

        BigDecimal kStock = determineKStock(chainWideStockCount);

        // recommendedBuybackPrice = coverPrice * grade.buyMultiplier * rarityFactor * K_stock
        BigDecimal rawBuyback = coverPrice
                .multiply(grade.getBuyMultiplier())
                .multiply(rarityFactor)
                .multiply(kStock);
        BigDecimal recommendedBuyback = roundToNearestThousand(rawBuyback);

        // recommendedSellingPrice = coverPrice * grade.sellMultiplier * rarityFactor
        BigDecimal rawSelling = coverPrice
                .multiply(grade.getSellMultiplier())
                .multiply(rarityFactor);
        BigDecimal recommendedSelling = roundToNearestThousand(rawSelling);

        BigDecimal minStaff = roundToNearestThousand(recommendedBuyback.multiply(STAFF_LOWER_MARGIN));
        BigDecimal maxStaff = roundToNearestThousand(recommendedBuyback.multiply(STAFF_UPPER_MARGIN));

        return new BookValuationResult(coverPrice, grade, rarityFactor, chainWideStockCount, kStock,
                recommendedBuyback, recommendedSelling, minStaff, maxStaff);
    }

    /**
     * Convenience method to calculate recommended buyback price directly.
     */
    public BigDecimal calculateBuybackPrice(BigDecimal coverPrice, ConditionGrade grade,
                                            BigDecimal rarityFactor, long chainWideStockCount) {
        return calculateValuation(coverPrice, grade, rarityFactor, chainWideStockCount).getRecommendedBuybackPrice();
    }

    /**
     * Convenience method to calculate recommended selling price directly.
     */
    public BigDecimal calculateSellingPrice(BigDecimal coverPrice, ConditionGrade grade, BigDecimal rarityFactor) {
        return calculateValuation(coverPrice, grade, rarityFactor, 1).getRecommendedSellingPrice();
    }

    /**
     * Enforces the ±15% price adjustment limit for staff.
     * Managers and Admins are permitted to override prices freely.
     */
    public void validateStaffBuybackPriceOverride(BigDecimal proposedPrice, BigDecimal recommendedPrice, RoleCode userRole) {
        if (userRole == RoleCode.ROLE_SUPER_ADMIN || userRole == RoleCode.ROLE_BRANCH_MANAGER) {
            return; // Manager and Super Admin have authority to override
        }

        if (proposedPrice == null || recommendedPrice == null) {
            return;
        }

        BigDecimal lowerLimit = roundToNearestThousand(recommendedPrice.multiply(STAFF_LOWER_MARGIN));
        BigDecimal upperLimit = roundToNearestThousand(recommendedPrice.multiply(STAFF_UPPER_MARGIN));

        if (proposedPrice.compareTo(lowerLimit) < 0 || proposedPrice.compareTo(upperLimit) > 0) {
            throw new PricingPolicyException(
                    String.format("Giá nhập đề xuất (%,.0f đ) vượt quá hạn mức ±15%% cho phép của nhân viên (%,.0f đ - %,.0f đ). Cần Quản lý chi nhánh phê duyệt.",
                            proposedPrice.doubleValue(), lowerLimit.doubleValue(), upperLimit.doubleValue())
            );
        }
    }
}
