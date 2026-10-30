package com.bookstore.controller.buyback;

import com.bookstore.entity.buyback.BuybackRequest;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.service.buyback.BuybackService;
import com.bookstore.service.buyback.OnlineSubmissionDTO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequestMapping("/buybacks")
public class CustomerBuybackController {

    private final BuybackService buybackService;
    private final BranchRepository branchRepository;

    public CustomerBuybackController(BuybackService buybackService, BranchRepository branchRepository) {
        this.buybackService = buybackService;
        this.branchRepository = branchRepository;
    }

    @GetMapping("/new")
    public String newRequestForm(Model model) {
        model.addAttribute("branches", branchRepository.findAll());
        return "buyback/new";
    }

    @PostMapping("/new")
    public String submitRequest(
            @RequestParam Long targetBranchId,
            @RequestParam String customerName,
            @RequestParam String customerPhone,
            @RequestParam List<String> customTitle,
            @RequestParam(required = false) List<String> author,
            @RequestParam(required = false) List<String> isbn,
            @RequestParam(required = false) List<BigDecimal> declaredCoverPrice,
            @RequestParam(required = false) List<String> customerConditionNote,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            OnlineSubmissionDTO dto = new OnlineSubmissionDTO();
            dto.setTargetBranchId(targetBranchId);
            dto.setCustomerName(customerName);
            dto.setCustomerPhone(customerPhone);

            for (int i = 0; i < customTitle.size(); i++) {
                OnlineSubmissionDTO.ItemDTO item = new OnlineSubmissionDTO.ItemDTO();
                item.setCustomTitle(customTitle.get(i));
                item.setAuthor((author != null && i < author.size()) ? author.get(i) : "");
                item.setIsbn((isbn != null && i < isbn.size()) ? isbn.get(i) : "");
                item.setDeclaredCoverPrice((declaredCoverPrice != null && i < declaredCoverPrice.size()) ? declaredCoverPrice.get(i) : BigDecimal.valueOf(100000));
                item.setCustomerConditionNote((customerConditionNote != null && i < customerConditionNote.size()) ? customerConditionNote.get(i) : "");
                dto.getItems().add(item);
            }

            Long customerId = (userDetails != null) ? userDetails.getUserId() : null;
            BuybackRequest req = buybackService.submitOnlineRequest(dto, customerId);
            flash.addFlashAttribute("success", "Đã gửi yêu cầu thẩm định bán sách online (" + req.getRequestCode() + ") thành công! Nhân viên sẽ phản hồi báo giá sớm nhất.");
            return "redirect:/buybacks/my-requests";
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi gửi yêu cầu: " + e.getMessage());
            return "redirect:/buybacks/new";
        }
    }

    @GetMapping("/my-requests")
    public String myRequests(@AuthenticationPrincipal CustomUserDetails userDetails, Model model) {
        Long customerId = (userDetails != null) ? userDetails.getUserId() : null;
        List<BuybackRequest> requests = buybackService.listCustomerRequests(customerId);
        model.addAttribute("requests", requests);
        return "buyback/my-requests";
    }

    @PostMapping("/{id}/accept")
    public String acceptQuote(@PathVariable Long id,
                              @AuthenticationPrincipal CustomUserDetails userDetails,
                              RedirectAttributes flash) {
        try {
            Long customerId = (userDetails != null) ? userDetails.getUserId() : null;
            buybackService.customerRespondToQuote(id, customerId, true, null);
            flash.addFlashAttribute("success", "Bạn đã đồng ý với mức giá thẩm định sơ bộ. Vui lòng gửi hoặc mang sách đến chi nhánh đã chọn.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/buybacks/my-requests";
    }

    @PostMapping("/{id}/reject")
    public String rejectQuote(@PathVariable Long id,
                              @RequestParam(defaultValue = "Giá chưa phù hợp") String reason,
                              @AuthenticationPrincipal CustomUserDetails userDetails,
                              RedirectAttributes flash) {
        try {
            Long customerId = (userDetails != null) ? userDetails.getUserId() : null;
            buybackService.customerRespondToQuote(id, customerId, false, reason);
            flash.addFlashAttribute("success", "Đã từ chối mức giá thẩm định.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/buybacks/my-requests";
    }
}
