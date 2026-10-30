package com.bookstore.controller.pricing;

import com.bookstore.entity.buyback.ConditionGrade;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.service.pricing.BookValuationResult;
import com.bookstore.service.pricing.PricingEngineService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/pricing")
public class PricingRestController {

    private final PricingEngineService pricingEngineService;
    private final BookItemRepository bookItemRepository;

    public PricingRestController(PricingEngineService pricingEngineService,
                                 BookItemRepository bookItemRepository) {
        this.pricingEngineService = pricingEngineService;
        this.bookItemRepository = bookItemRepository;
    }

    /**
     * Real-time valuation endpoint for AJAX Buyback Appraisal Calculator.
     */
    @GetMapping("/estimate")
    public ResponseEntity<Map<String, Object>> estimatePrice(
            @RequestParam BigDecimal coverPrice,
            @RequestParam(defaultValue = "B") String grade,
            @RequestParam(required = false) BigDecimal rarityFactor,
            @RequestParam(required = false) Long bookTitleId
    ) {
        ConditionGrade conditionGrade;
        try {
            conditionGrade = ConditionGrade.valueOf(grade.toUpperCase().trim());
        } catch (Exception e) {
            conditionGrade = ConditionGrade.B;
        }

        long chainWideStock = 0;
        if (bookTitleId != null) {
            chainWideStock = bookItemRepository.countByBookTitleIdAndStatus(bookTitleId, BookItemStatus.IN_STOCK);
        }

        BookValuationResult val = pricingEngineService.calculateValuation(
                coverPrice,
                conditionGrade,
                rarityFactor,
                chainWideStock
        );

        Map<String, Object> resp = new HashMap<>();
        resp.put("success", true);
        resp.put("coverPrice", val.getCoverPrice());
        resp.put("grade", val.getGrade().name());
        resp.put("gradeLabel", val.getGrade().getDescription());
        resp.put("buyMultiplier", val.getGrade().getBuyMultiplier());
        resp.put("sellMultiplier", val.getGrade().getSellMultiplier());
        resp.put("chainWideStockCount", val.getChainWideStockCount());
        resp.put("kStock", val.getkStock());
        resp.put("recommendedBuybackPrice", val.getRecommendedBuybackPrice());
        resp.put("recommendedSellingPrice", val.getRecommendedSellingPrice());
        resp.put("minStaffBuybackPrice", val.getMinStaffBuybackPrice());
        resp.put("maxStaffBuybackPrice", val.getMaxStaffBuybackPrice());

        return ResponseEntity.ok(resp);
    }
}
