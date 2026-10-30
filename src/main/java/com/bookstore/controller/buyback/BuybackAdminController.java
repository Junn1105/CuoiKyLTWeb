package com.bookstore.controller.buyback;

import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.buyback.BuybackRequest;
import com.bookstore.entity.buyback.BuybackStatus;
import com.bookstore.entity.buyback.ConditionGrade;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.catalog.BookTitleRepository;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.buyback.BuybackService;
import com.bookstore.service.buyback.PhysicalInspectionItemDTO;
import com.bookstore.service.buyback.WalkInBuybackDTO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/buybacks")
public class BuybackAdminController {

    private final BuybackService buybackService;
    private final BookTitleRepository bookTitleRepository;
    private final BranchRepository branchRepository;

    public BuybackAdminController(BuybackService buybackService,
                                  BookTitleRepository bookTitleRepository,
                                  BranchRepository branchRepository) {
        this.buybackService = buybackService;
        this.bookTitleRepository = bookTitleRepository;
        this.branchRepository = branchRepository;
    }

    @GetMapping
    public String listBuybacks(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long branchId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        Long targetBranch = branchId;
        if (!SecurityUtils.isSuperAdmin()) {
            targetBranch = (userDetails != null) ? userDetails.getBranchId() : null;
        }

        BuybackStatus buybackStatus = null;
        if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
            try {
                buybackStatus = BuybackStatus.valueOf(status.toUpperCase().trim());
            } catch (Exception ignored) {}
        }

        List<BuybackRequest> requests = buybackService.listRequests(targetBranch, buybackStatus);
        model.addAttribute("requests", requests);
        model.addAttribute("statusFilter", status != null ? status : "ALL");
        model.addAttribute("targetBranch", targetBranch);
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());
        model.addAttribute("branches", branchRepository.findAll());

        return "buyback-admin/list";
    }

    @GetMapping("/new-walkin")
    public String newWalkInForm(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        model.addAttribute("grades", ConditionGrade.values());
        model.addAttribute("bookTitles", bookTitleRepository.findAll());
        model.addAttribute("userBranchId", userDetails != null ? userDetails.getBranchId() : null);
        return "buyback-admin/new-walkin";
    }

    @PostMapping("/new-walkin")
    public String processWalkIn(
            @RequestParam String customerName,
            @RequestParam String customerPhone,
            @RequestParam(required = false) String staffNote,
            @RequestParam List<String> title,
            @RequestParam(required = false) List<String> author,
            @RequestParam(required = false) List<String> isbn,
            @RequestParam List<BigDecimal> coverPrice,
            @RequestParam List<String> grade,
            @RequestParam(required = false) List<BigDecimal> offeredPrice,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            WalkInBuybackDTO dto = new WalkInBuybackDTO();
            dto.setCustomerName(customerName);
            dto.setCustomerPhone(customerPhone);
            dto.setStaffNote(staffNote);

            List<WalkInBuybackDTO.ItemDTO> items = new ArrayList<>();
            for (int i = 0; i < title.size(); i++) {
                WalkInBuybackDTO.ItemDTO item = new WalkInBuybackDTO.ItemDTO();
                item.setTitle(title.get(i));
                item.setAuthor((author != null && i < author.size()) ? author.get(i) : "");
                item.setIsbn((isbn != null && i < isbn.size()) ? isbn.get(i) : "");
                item.setCoverPrice(coverPrice.get(i));
                item.setGrade(ConditionGrade.valueOf(grade.get(i)));
                if (offeredPrice != null && i < offeredPrice.size() && offeredPrice.get(i) != null) {
                    item.setOfferedPrice(offeredPrice.get(i));
                }
                items.add(item);
            }
            dto.setItems(items);

            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            BuybackRequest req = buybackService.createWalkInCounterBuyback(dto, staffId);
            flash.addFlashAttribute("success", "Đã lập phiếu thu mua tại quầy thành công (" + req.getRequestCode()
                    + ") và tự động nhập kho " + req.getItems().size() + " cuốn sách với mã vạch riêng.");
            return "redirect:/admin/buybacks/" + req.getId();
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi lập phiếu thu mua: " + e.getMessage());
            return "redirect:/admin/buybacks/new-walkin";
        }
    }

    @GetMapping("/{id}")
    public String viewDetail(@PathVariable Long id, Model model) {
        BuybackRequest request = buybackService.getRequest(id);
        model.addAttribute("request", request);
        model.addAttribute("grades", ConditionGrade.values());
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());
        return "buyback-admin/detail";
    }

    @PostMapping("/{id}/pre-quote")
    public String submitPreQuote(
            @PathVariable Long id,
            @RequestParam Map<String, String> allParams,
            @RequestParam(required = false) String staffNote,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            Map<Long, BigDecimal> itemQuotes = new HashMap<>();
            for (Map.Entry<String, String> entry : allParams.entrySet()) {
                if (entry.getKey().startsWith("quote_")) {
                    Long itemId = Long.parseLong(entry.getKey().substring("quote_".length()));
                    BigDecimal quote = new BigDecimal(entry.getValue().replaceAll("[^0-9.]", ""));
                    itemQuotes.put(itemId, quote);
                }
            }

            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            buybackService.providePreliminaryQuote(id, staffId, itemQuotes, staffNote);
            flash.addFlashAttribute("success", "Đã gửi báo giá sơ bộ cho khách hàng.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi định giá sơ bộ: " + e.getMessage());
        }
        return "redirect:/admin/buybacks/" + id;
    }

    @PostMapping("/{id}/receive")
    public String markReceived(@PathVariable Long id,
                               @AuthenticationPrincipal CustomUserDetails userDetails,
                               RedirectAttributes flash) {
        try {
            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            buybackService.markItemReceived(id, staffId);
            flash.addFlashAttribute("success", "Đã xác nhận tiếp nhận kiện sách thực tế tại chi nhánh.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi xác nhận nhận hàng: " + e.getMessage());
        }
        return "redirect:/admin/buybacks/" + id;
    }

    @PostMapping("/{id}/finalize")
    public String finalizeInspection(
            @PathVariable Long id,
            @RequestParam List<Long> itemId,
            @RequestParam List<String> finalGrade,
            @RequestParam(required = false) List<BigDecimal> customPrice,
            @RequestParam(required = false) List<String> accepted,
            @RequestParam(required = false) List<String> rejectionReason,
            @RequestParam(required = false) String staffNote,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            List<PhysicalInspectionItemDTO> inspections = new ArrayList<>();
            for (int i = 0; i < itemId.size(); i++) {
                PhysicalInspectionItemDTO item = new PhysicalInspectionItemDTO();
                item.setItemId(itemId.get(i));
                item.setFinalGrade(ConditionGrade.valueOf(finalGrade.get(i)));
                if (customPrice != null && i < customPrice.size()) {
                    item.setCustomPrice(customPrice.get(i));
                }
                boolean isAccepted = (accepted != null && accepted.contains(String.valueOf(itemId.get(i))));
                item.setAccepted(isAccepted);
                if (!isAccepted && rejectionReason != null && i < rejectionReason.size()) {
                    item.setRejectionReason(rejectionReason.get(i));
                }
                inspections.add(item);
            }

            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            BuybackRequest req = buybackService.finalizePhysicalAppraisal(id, staffId, inspections, staffNote);
            flash.addFlashAttribute("success", "Đã hoàn tất thẩm định đơn " + req.getRequestCode()
                    + " và sinh mã vạch BookItem nhập vào kho sách chi nhánh.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi hoàn tất thẩm định: " + e.getMessage());
        }
        return "redirect:/admin/buybacks/" + id;
    }
}
