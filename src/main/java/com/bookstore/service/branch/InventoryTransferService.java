package com.bookstore.service.branch;

import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.branch.InventoryTransfer;
import com.bookstore.entity.branch.InventoryTransferItem;
import com.bookstore.entity.branch.TransferReason;
import com.bookstore.entity.branch.TransferStatus;
import com.bookstore.entity.buyback.ConditionGrade;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.repository.auth.UserRepository;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.branch.InventoryTransferItemRepository;
import com.bookstore.repository.branch.InventoryTransferRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.shared.WebSocketNotificationService;
import jakarta.persistence.OptimisticLockException;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class InventoryTransferService {

    private final InventoryTransferRepository transferRepository;
    private final InventoryTransferItemRepository transferItemRepository;
    private final BookItemRepository bookItemRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final WebSocketNotificationService notificationService;

    public InventoryTransferService(InventoryTransferRepository transferRepository,
                                    InventoryTransferItemRepository transferItemRepository,
                                    BookItemRepository bookItemRepository,
                                    BranchRepository branchRepository,
                                    UserRepository userRepository,
                                    WebSocketNotificationService notificationService) {
        this.transferRepository = transferRepository;
        this.transferItemRepository = transferItemRepository;
        this.bookItemRepository = bookItemRepository;
        this.branchRepository = branchRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    /**
     * Generates a unique transfer code:
     * Pattern: TRF-YYYYMMDD-{4-digit-sequence}
     */
    public synchronized String generateTransferCode() {
        String datePart = DateTimeFormatter.ofPattern("yyyyMMdd").format(LocalDate.now());
        long seq = transferRepository.count() + 1;
        String code;
        do {
            code = String.format("TRF-%s-%04d", datePart, seq++);
        } while (transferRepository.findByTransferCode(code).isPresent());
        return code;
    }

    /**
     * Module 4: Step 1 - Transfer Request Creation
     * Source branch manager/staff creates transfer slip to another branch.
     */
    @Transactional
    public InventoryTransfer createTransferRequest(Long fromBranchId, Long toBranchId,
                                                   List<Long> bookItemIds, TransferReason reason,
                                                   String note, Long requestingUserId) {
        if (fromBranchId.equals(toBranchId)) {
            throw new IllegalArgumentException("Chi nhánh gửi và chi nhánh nhận không được trùng nhau.");
        }

        if (bookItemIds == null || bookItemIds.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một cuốn sách để điều chuyển.");
        }

        // Branch Isolation: Current staff/manager can only request transfer from their own branch
        SecurityUtils.assertBranchAccess(fromBranchId);

        User requestingUser = userRepository.findById(requestingUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người yêu cầu: " + requestingUserId));

        Branch fromBranch = branchRepository.findById(fromBranchId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh gửi: " + fromBranchId));
        Branch toBranch = branchRepository.findById(toBranchId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh nhận: " + toBranchId));

        InventoryTransfer transfer = new InventoryTransfer(
                generateTransferCode(),
                fromBranch,
                toBranch,
                requestingUser,
                reason
        );
        transfer.setNote(note);

        for (Long bookItemId : bookItemIds) {
            BookItem item = bookItemRepository.findById(bookItemId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy bản sách ID=" + bookItemId));

            if (!item.getCurrentBranch().getId().equals(fromBranchId)) {
                throw new IllegalStateException("Bản sách [" + item.getSerialCode() + "] không thuộc chi nhánh gửi.");
            }

            if (item.getStatus() != BookItemStatus.IN_STOCK) {
                throw new IllegalStateException("Bản sách [" + item.getSerialCode() + "] hiện không ở trạng thái CÓ SẴN (IN_STOCK).");
            }

            InventoryTransferItem transferItem = new InventoryTransferItem(
                    transfer,
                    item,
                    item.getGrade()
            );
            transfer.getItems().add(transferItem);
        }

        InventoryTransfer saved = transferRepository.save(transfer);

        notificationService.broadcastStockUpdate(
                toBranchId,
                "Có yêu cầu điều chuyển kho mới (" + saved.getTransferCode() + ") từ " + fromBranch.getName()
        );

        return saved;
    }

    /**
     * Module 4: Step 2 - Approval
     * Super Admin ONLY can approve inter-branch transfers.
     */
    @Transactional
    public InventoryTransfer approveTransfer(Long transferId, Long adminUserId) {
        if (!SecurityUtils.isSuperAdmin()) {
            throw new AccessDeniedException("Chỉ Quản trị viên hệ thống (Admin) mới có quyền phê duyệt phiếu điều chuyển kho.");
        }

        InventoryTransfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển: " + transferId));

        if (transfer.getStatus() != TransferStatus.REQUESTED) {
            throw new IllegalStateException("Phiếu điều chuyển phải ở trạng thái CHỜ DUYỆT (REQUESTED) mới có thể phê duyệt.");
        }

        User admin = userRepository.findById(adminUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản quản trị: " + adminUserId));

        transfer.setApprovedBy(admin);
        transfer.setStatus(TransferStatus.APPROVED);

        InventoryTransfer saved = transferRepository.save(transfer);

        notificationService.broadcastStockUpdate(
                transfer.getFromBranch().getId(),
                "Phiếu điều chuyển " + saved.getTransferCode() + " đã được Admin phê duyệt. Có thể tiến hành xuất kho."
        );

        return saved;
    }

    /**
     * Module 4: Step 3 - Dispatch (Xuất kho vận chuyển)
     * Locks BookItems with IN_TRANSIT_TRANSFER using @Version optimistic concurrency control.
     */
    @Transactional
    public InventoryTransfer dispatchTransfer(Long transferId, Long staffUserId) {
        InventoryTransfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển: " + transferId));

        SecurityUtils.assertBranchAccess(transfer.getFromBranch().getId());

        if (transfer.getStatus() != TransferStatus.APPROVED) {
            throw new IllegalStateException("Phiếu điều chuyển phải được Admin phê duyệt (APPROVED) trước khi xuất kho.");
        }

        try {
            for (InventoryTransferItem item : transfer.getItems()) {
                BookItem bookItem = item.getBookItem();

                // Mutate status to IN_TRANSIT_TRANSFER under optimistic lock
                bookItem.setStatus(BookItemStatus.IN_TRANSIT_TRANSFER);
                bookItemRepository.saveAndFlush(bookItem);
            }
        } catch (OptimisticLockException | ObjectOptimisticLockingFailureException e) {
            throw new IllegalStateException("Một hoặc nhiều cuốn sách trong phiếu điều chuyển vừa được bán hoặc xử lý ở giao dịch khác.", e);
        }

        transfer.setStatus(TransferStatus.IN_TRANSIT);
        InventoryTransfer saved = transferRepository.save(transfer);

        notificationService.broadcastStockUpdate(
                transfer.getToBranch().getId(),
                "Kiện hàng " + saved.getTransferCode() + " đang được vận chuyển đến chi nhánh của bạn."
        );

        return saved;
    }

    /**
     * Module 4: Step 4 - Receipt & Reconciliation (Xác nhận nhập kho)
     * Destination branch staff verifies physical condition and absorbs inventory into target branch.
     */
    @Transactional
    public InventoryTransfer confirmReceipt(Long transferId, List<ReceiptItemDTO> itemReceipts, Long receivingUserId) {
        InventoryTransfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển: " + transferId));

        SecurityUtils.assertBranchAccess(transfer.getToBranch().getId());

        if (transfer.getStatus() != TransferStatus.IN_TRANSIT) {
            throw new IllegalStateException("Phiếu điều chuyển phải ở trạng thái ĐANG VẬN CHUYỂN (IN_TRANSIT) mới có thể nhập kho.");
        }

        User receivingUser = userRepository.findById(receivingUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên nhận hàng: " + receivingUserId));

        Map<Long, ReceiptItemDTO> receiptMap = (itemReceipts != null)
                ? itemReceipts.stream().collect(Collectors.toMap(ReceiptItemDTO::getBookItemId, r -> r))
                : Map.of();

        boolean hasDiscrepancy = false;

        for (InventoryTransferItem item : transfer.getItems()) {
            BookItem bookItem = item.getBookItem();
            ReceiptItemDTO receipt = receiptMap.get(bookItem.getId());

            if (receipt != null) {
                ConditionGrade gradeAfter = (receipt.getGradeAfter() != null)
                        ? receipt.getGradeAfter()
                        : item.getGradeBefore();

                item.setGradeAfter(gradeAfter);

                if (receipt.isDamagedOrLost()) {
                    hasDiscrepancy = true;
                    bookItem.setStatus(BookItemStatus.DAMAGED_LOST);
                    item.setDiscrepancyNote(receipt.getDiscrepancyNote() != null
                            ? receipt.getDiscrepancyNote()
                            : "Sách thất lạc hoặc hư hại trong quá trình vận chuyển.");
                } else {
                    if (gradeAfter != item.getGradeBefore()) {
                        hasDiscrepancy = true;
                        item.setDiscrepancyNote(receipt.getDiscrepancyNote() != null
                                ? receipt.getDiscrepancyNote()
                                : "Chênh lệch phẩm cấp: " + item.getGradeBefore() + " -> " + gradeAfter);
                        bookItem.setGrade(gradeAfter);
                    }
                    bookItem.setCurrentBranch(transfer.getToBranch());
                    bookItem.setStatus(BookItemStatus.IN_STOCK);
                }
            } else {
                // Default acceptance
                item.setGradeAfter(item.getGradeBefore());
                bookItem.setCurrentBranch(transfer.getToBranch());
                bookItem.setStatus(BookItemStatus.IN_STOCK);
            }

            bookItemRepository.save(bookItem);
        }

        transfer.setReceivedBy(receivingUser);
        transfer.setCompletedAt(LocalDateTime.now());
        transfer.setStatus(hasDiscrepancy ? TransferStatus.DISCREPANCY : TransferStatus.COMPLETED);

        InventoryTransfer saved = transferRepository.save(transfer);

        notificationService.broadcastStockUpdate(
                transfer.getFromBranch().getId(),
                "Phiếu điều chuyển " + saved.getTransferCode() + " đã hoàn tất tiếp nhận tại " + transfer.getToBranch().getName()
        );

        return saved;
    }

    /**
     * Cancels a transfer request if not yet in transit.
     */
    @Transactional
    public InventoryTransfer cancelTransfer(Long transferId, Long userId, String reason) {
        InventoryTransfer transfer = transferRepository.findById(transferId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển: " + transferId));

        if (transfer.getStatus() == TransferStatus.IN_TRANSIT || transfer.getStatus() == TransferStatus.COMPLETED) {
            throw new IllegalStateException("Không thể hủy phiếu điều chuyển đã xuất kho hoặc đã hoàn tất.");
        }

        SecurityUtils.assertBranchAccess(transfer.getFromBranch().getId());

        transfer.setStatus(TransferStatus.CANCELLED);
        transfer.setNote(transfer.getNote() + " [Hủy: " + reason + "]");

        return transferRepository.save(transfer);
    }

    // ==================== QUERY METHODS ====================

    @Transactional(readOnly = true)
    public List<InventoryTransfer> listTransfers(Long branchId) {
        if (branchId != null) {
            SecurityUtils.assertBranchAccess(branchId);
            return transferRepository.findByFromBranchIdOrToBranchId(branchId, branchId);
        }
        return transferRepository.findAll();
    }

    @Transactional(readOnly = true)
    public InventoryTransfer getTransfer(Long id) {
        InventoryTransfer transfer = transferRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiếu điều chuyển: " + id));

        if (!SecurityUtils.isSuperAdmin()) {
            Long userBranch = SecurityUtils.getCurrentUserBranchId();
            if (userBranch != null) {
                boolean involved = userBranch.equals(transfer.getFromBranch().getId())
                        || userBranch.equals(transfer.getToBranch().getId());
                if (!involved) {
                    throw new AccessDeniedException("Bạn không có quyền xem thông tin điều chuyển của các chi nhánh khác.");
                }
            }
        }
        return transfer;
    }
}
