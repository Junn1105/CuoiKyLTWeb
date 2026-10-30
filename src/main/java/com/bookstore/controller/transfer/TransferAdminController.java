package com.bookstore.controller.transfer;

import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.branch.InventoryTransfer;
import com.bookstore.entity.branch.TransferReason;
import com.bookstore.entity.branch.TransferStatus;
import com.bookstore.entity.buyback.ConditionGrade;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.branch.InventoryTransferService;
import com.bookstore.service.branch.ReceiptItemDTO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/admin/transfers")
public class TransferAdminController {

    private final InventoryTransferService transferService;
    private final BranchRepository branchRepository;
    private final BookItemRepository bookItemRepository;

    public TransferAdminController(InventoryTransferService transferService,
                                   BranchRepository branchRepository,
                                   BookItemRepository bookItemRepository) {
        this.transferService = transferService;
        this.branchRepository = branchRepository;
        this.bookItemRepository = bookItemRepository;
    }

    @GetMapping
    public String listTransfers(
            @RequestParam(required = false) Long branchId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        Long targetBranch = branchId;
        if (!SecurityUtils.isSuperAdmin()) {
            targetBranch = (userDetails != null) ? userDetails.getBranchId() : null;
        }

        List<InventoryTransfer> transfers = transferService.listTransfers(targetBranch);
        model.addAttribute("transfers", transfers);
        model.addAttribute("targetBranch", targetBranch);
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());
        model.addAttribute("branches", branchRepository.findAll());

        return "transfer/list";
    }

    @GetMapping("/new")
    public String newTransferForm(
            @RequestParam(required = false) Long fromBranchId,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        Long userBranch = (userDetails != null) ? userDetails.getBranchId() : null;
        Long effectiveFrom = SecurityUtils.isSuperAdmin() ? (fromBranchId != null ? fromBranchId : userBranch) : userBranch;

        if (effectiveFrom == null) {
            List<Branch> branches = branchRepository.findAll();
            if (!branches.isEmpty()) {
                effectiveFrom = branches.get(0).getId();
            }
        }

        List<BookItem> availableItems = (effectiveFrom != null)
                ? bookItemRepository.findByCurrentBranchIdAndStatus(effectiveFrom, BookItemStatus.IN_STOCK)
                : List.of();

        model.addAttribute("branches", branchRepository.findAll());
        model.addAttribute("effectiveFrom", effectiveFrom);
        model.addAttribute("availableItems", availableItems);
        model.addAttribute("reasons", TransferReason.values());
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());

        return "transfer/new";
    }

    @PostMapping("/new")
    public String createTransfer(
            @RequestParam Long fromBranchId,
            @RequestParam Long toBranchId,
            @RequestParam(name = "bookItemIds", required = false) List<Long> bookItemIds,
            @RequestParam TransferReason reason,
            @RequestParam(required = false) String note,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            Long effectiveFrom = SecurityUtils.isSuperAdmin()
                    ? fromBranchId
                    : (userDetails != null ? userDetails.getBranchId() : fromBranchId);

            Long userId = (userDetails != null) ? userDetails.getUserId() : 1L;
            InventoryTransfer transfer = transferService.createTransferRequest(
                    effectiveFrom,
                    toBranchId,
                    bookItemIds,
                    reason,
                    note,
                    userId
            );

            flash.addFlashAttribute("success", "Đã tạo phiếu yêu cầu điều chuyển (" + transfer.getTransferCode()
                    + ") với " + transfer.getItems().size() + " cuốn sách. Trạng thái: CHỜ ADMIN DUYỆT.");
            return "redirect:/admin/transfers/" + transfer.getId();
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi tạo phiếu điều chuyển: " + e.getMessage());
            return "redirect:/admin/transfers/new?fromBranchId=" + fromBranchId;
        }
    }

    @GetMapping("/{id}")
    public String viewDetail(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            Model model
    ) {
        InventoryTransfer transfer = transferService.getTransfer(id);
        Long currentBranchId = (userDetails != null) ? userDetails.getBranchId() : null;

        boolean canApprove = SecurityUtils.isSuperAdmin() && transfer.getStatus() == TransferStatus.REQUESTED;
        boolean canDispatch = (SecurityUtils.isSuperAdmin() || (currentBranchId != null && currentBranchId.equals(transfer.getFromBranch().getId())))
                && transfer.getStatus() == TransferStatus.APPROVED;
        boolean canReceive = (SecurityUtils.isSuperAdmin() || (currentBranchId != null && currentBranchId.equals(transfer.getToBranch().getId())))
                && transfer.getStatus() == TransferStatus.IN_TRANSIT;
        boolean canCancel = (SecurityUtils.isSuperAdmin() || (currentBranchId != null && currentBranchId.equals(transfer.getFromBranch().getId())))
                && (transfer.getStatus() == TransferStatus.REQUESTED || transfer.getStatus() == TransferStatus.APPROVED);

        model.addAttribute("transfer", transfer);
        model.addAttribute("canApprove", canApprove);
        model.addAttribute("canDispatch", canDispatch);
        model.addAttribute("canReceive", canReceive);
        model.addAttribute("canCancel", canCancel);
        model.addAttribute("grades", ConditionGrade.values());
        model.addAttribute("isSuperAdmin", SecurityUtils.isSuperAdmin());

        return "transfer/detail";
    }

    @PostMapping("/{id}/approve")
    public String approveTransfer(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            Long adminId = (userDetails != null) ? userDetails.getUserId() : 1L;
            InventoryTransfer transfer = transferService.approveTransfer(id, adminId);
            flash.addFlashAttribute("success", "Đã phê duyệt phiếu điều chuyển " + transfer.getTransferCode() + ". Chi nhánh gửi có thể xuất kho.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi phê duyệt: " + e.getMessage());
        }
        return "redirect:/admin/transfers/" + id;
    }

    @PostMapping("/{id}/dispatch")
    public String dispatchTransfer(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            InventoryTransfer transfer = transferService.dispatchTransfer(id, staffId);
            flash.addFlashAttribute("success", "Đã xuất kho phiếu điều chuyển " + transfer.getTransferCode()
                    + ". Các cuốn sách đã chuyển sang trạng thái ĐANG VẬN CHUYỂN.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi xuất kho: " + e.getMessage());
        }
        return "redirect:/admin/transfers/" + id;
    }

    @PostMapping("/{id}/receive")
    public String confirmReceipt(
            @PathVariable Long id,
            @RequestParam(required = false) List<Long> bookItemId,
            @RequestParam(required = false) List<String> gradeAfter,
            @RequestParam(required = false) List<String> damagedOrLost,
            @RequestParam(required = false) List<String> discrepancyNote,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            List<ReceiptItemDTO> receipts = new ArrayList<>();
            if (bookItemId != null) {
                for (int i = 0; i < bookItemId.size(); i++) {
                    ReceiptItemDTO r = new ReceiptItemDTO();
                    r.setBookItemId(bookItemId.get(i));
                    if (gradeAfter != null && i < gradeAfter.size() && gradeAfter.get(i) != null && !gradeAfter.get(i).isBlank()) {
                        r.setGradeAfter(ConditionGrade.valueOf(gradeAfter.get(i)));
                    }
                    boolean lost = (damagedOrLost != null && damagedOrLost.contains(String.valueOf(bookItemId.get(i))));
                    r.setDamagedOrLost(lost);
                    if (discrepancyNote != null && i < discrepancyNote.size()) {
                        r.setDiscrepancyNote(discrepancyNote.get(i));
                    }
                    receipts.add(r);
                }
            }

            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            InventoryTransfer transfer = transferService.confirmReceipt(id, receipts, staffId);
            flash.addFlashAttribute("success", "Đã xác nhận nhập kho thành công cho phiếu " + transfer.getTransferCode()
                    + ". Các bản sách đã chính thức chuyển về chi nhánh nhận.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi tiếp nhận: " + e.getMessage());
        }
        return "redirect:/admin/transfers/" + id;
    }

    @PostMapping("/{id}/cancel")
    public String cancelTransfer(
            @PathVariable Long id,
            @RequestParam(defaultValue = "Người dùng yêu cầu hủy") String reason,
            @AuthenticationPrincipal CustomUserDetails userDetails,
            RedirectAttributes flash
    ) {
        try {
            Long staffId = (userDetails != null) ? userDetails.getUserId() : 1L;
            InventoryTransfer transfer = transferService.cancelTransfer(id, staffId, reason);
            flash.addFlashAttribute("success", "Đã hủy phiếu điều chuyển " + transfer.getTransferCode());
        } catch (Exception e) {
            flash.addFlashAttribute("error", "Lỗi hủy: " + e.getMessage());
        }
        return "redirect:/admin/transfers/" + id;
    }
}
