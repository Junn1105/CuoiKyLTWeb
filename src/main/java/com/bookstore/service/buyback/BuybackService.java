package com.bookstore.service.buyback;

import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.buyback.*;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.entity.catalog.BookTitle;
import com.bookstore.repository.auth.UserRepository;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.buyback.BuybackRequestItemRepository;
import com.bookstore.repository.buyback.BuybackRequestRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.repository.catalog.BookTitleRepository;
import com.bookstore.security.SecurityUtils;
import com.bookstore.service.pricing.BookValuationResult;
import com.bookstore.service.pricing.PricingEngineService;
import com.bookstore.service.shared.WebSocketNotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class BuybackService {

    private final BuybackRequestRepository buybackRequestRepository;
    private final BuybackRequestItemRepository buybackRequestItemRepository;
    private final BookTitleRepository bookTitleRepository;
    private final BookItemRepository bookItemRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final PricingEngineService pricingEngineService;
    private final WebSocketNotificationService notificationService;

    private static final AtomicLong SEQUENCE_FALLBACK = new AtomicLong(100);

    public BuybackService(BuybackRequestRepository buybackRequestRepository,
                          BuybackRequestItemRepository buybackRequestItemRepository,
                          BookTitleRepository bookTitleRepository,
                          BookItemRepository bookItemRepository,
                          BranchRepository branchRepository,
                          UserRepository userRepository,
                          PricingEngineService pricingEngineService,
                          WebSocketNotificationService notificationService) {
        this.buybackRequestRepository = buybackRequestRepository;
        this.buybackRequestItemRepository = buybackRequestItemRepository;
        this.bookTitleRepository = bookTitleRepository;
        this.bookItemRepository = bookItemRepository;
        this.branchRepository = branchRepository;
        this.userRepository = userRepository;
        this.pricingEngineService = pricingEngineService;
        this.notificationService = notificationService;
    }

    /**
     * Generates a unique barcode for a physical BookItem:
     * Pattern: {BranchCode}-{YYMM}-{6-digit-sequence} (e.g. SGNQ1-2610-000142)
     */
    public synchronized String generateBarcode(Branch branch) {
        String cleanBranchCode = branch.getCode()
                .replaceAll("[^a-zA-Z0-9]", "")
                .toUpperCase();
        String yymm = DateTimeFormatter.ofPattern("yyMM").format(LocalDate.now());

        long count = bookItemRepository.count() + SEQUENCE_FALLBACK.incrementAndGet();
        String barcode;
        do {
            barcode = String.format("%s-%s-%06d", cleanBranchCode, yymm, count++);
        } while (bookItemRepository.existsBySerialCode(barcode));

        return barcode;
    }

    /**
     * Generates a unique buyback request code:
     * Pattern: BB-YYYYMMDD-{4-digit-sequence}
     */
    public synchronized String generateRequestCode() {
        String datePart = DateTimeFormatter.ofPattern("yyyyMMdd").format(LocalDate.now());
        long seq = buybackRequestRepository.count() + 1;
        String code;
        do {
            code = String.format("BB-%s-%04d", datePart, seq++);
        } while (buybackRequestRepository.findByRequestCode(code).isPresent());
        return code;
    }

    /**
     * Module 3: Walk-in Counter Intake
     * Staff values books brought by customer in person.
     * Auto-creates BuybackRequest (status=COMPLETED) and immediately spawns BookItem records (status=IN_STOCK).
     */
    @Transactional
    public BuybackRequest createWalkInCounterBuyback(WalkInBuybackDTO dto, Long staffUserId) {
        User staff = userRepository.findById(staffUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin nhân viên: " + staffUserId));

        Branch targetBranch = staff.getBranch();
        if (targetBranch == null) {
            // If super admin has no branch assigned, use default first active branch
            targetBranch = branchRepository.findAll().stream()
                    .filter(Branch::isActive)
                    .findFirst()
                    .orElseThrow(() -> new IllegalStateException("Hệ thống chưa có chi nhánh nào hoạt động."));
        }

        // Branch Isolation check
        SecurityUtils.assertBranchAccess(targetBranch.getId());

        BuybackRequest request = new BuybackRequest(
                generateRequestCode(),
                null, // Walk-in guest without registered account
                dto.getCustomerName(),
                dto.getCustomerPhone(),
                targetBranch,
                BuybackIntakeType.WALK_IN_COUNTER,
                BuybackStatus.COMPLETED
        );
        request.setAppraiser(staff);
        request.setStaffNote(dto.getStaffNote());

        BigDecimal totalPayout = BigDecimal.ZERO;

        for (WalkInBuybackDTO.ItemDTO itemDTO : dto.getItems()) {
            BookTitle bookTitle = resolveOrCreateBookTitle(itemDTO);

            long chainWideStock = bookItemRepository.countByBookTitleIdAndStatus(bookTitle.getId(), BookItemStatus.IN_STOCK);
            BookValuationResult valuation = pricingEngineService.calculateValuation(
                    bookTitle.getCoverPrice(),
                    itemDTO.getGrade(),
                    itemDTO.getRarityFactor(),
                    chainWideStock
            );

            // Determine final buyback price (staff override must adhere to ±15%)
            BigDecimal finalBuyPrice;
            if (itemDTO.getOfferedPrice() != null) {
                pricingEngineService.validateStaffBuybackPriceOverride(
                        itemDTO.getOfferedPrice(),
                        valuation.getRecommendedBuybackPrice(),
                        staff.getRole().getCode()
                );
                finalBuyPrice = pricingEngineService.roundToNearestThousand(itemDTO.getOfferedPrice());
            } else {
                finalBuyPrice = valuation.getRecommendedBuybackPrice();
            }

            BigDecimal sellingPrice = valuation.getRecommendedSellingPrice();

            // Spawn BookItem with Barcode
            String barcode = generateBarcode(targetBranch);
            BookItem bookItem = new BookItem(
                    barcode,
                    bookTitle,
                    targetBranch,
                    itemDTO.getGrade(),
                    finalBuyPrice,
                    sellingPrice,
                    BookItemStatus.IN_STOCK
            );
            bookItem = bookItemRepository.save(bookItem);

            // Populate BuybackRequestItem
            BuybackRequestItem buybackItem = new BuybackRequestItem();
            buybackItem.setBuybackRequest(request);
            buybackItem.setBookTitle(bookTitle);
            buybackItem.setDeclaredCoverPrice(bookTitle.getCoverPrice());
            buybackItem.setFinalGrade(itemDTO.getGrade());
            buybackItem.setFinalPrice(finalBuyPrice);
            buybackItem.setSpawnedBookItemId(bookItem.getId());
            buybackItem.setIsbn(bookTitle.getIsbn());
            buybackItem.setCustomerConditionNote(itemDTO.getCustomerConditionNote());

            request.getItems().add(buybackItem);
            totalPayout = totalPayout.add(finalBuyPrice);
        }

        request.setTotalEstimatedPrice(totalPayout);
        request.setTotalFinalPrice(totalPayout);

        BuybackRequest saved = buybackRequestRepository.save(request);

        notificationService.broadcastStockUpdate(
                targetBranch.getId(),
                "Nhập kho thành công " + dto.getItems().size() + " cuốn sách từ đơn thu mua tại quầy " + saved.getRequestCode()
        );

        return saved;
    }

    /**
     * Module 3: Online Appraisal - Step 1: Customer submits appraisal request
     */
    @Transactional
    public BuybackRequest submitOnlineRequest(OnlineSubmissionDTO dto, Long customerUserId) {
        User customer = null;
        if (customerUserId != null) {
            customer = userRepository.findById(customerUserId).orElse(null);
        }

        Branch targetBranch = null;
        if (dto.getTargetBranchId() != null) {
            targetBranch = branchRepository.findById(dto.getTargetBranchId()).orElse(null);
        }
        if (targetBranch == null) {
            targetBranch = branchRepository.findAll().stream()
                    .filter(Branch::isActive)
                    .findFirst()
                    .orElseThrow(() -> new IllegalStateException("Hệ thống chưa có chi nhánh hoạt động để nhận thẩm định."));
        }

        BuybackRequest request = new BuybackRequest(
                generateRequestCode(),
                customer,
                dto.getCustomerName(),
                dto.getCustomerPhone(),
                targetBranch,
                BuybackIntakeType.ONLINE_APPRAISAL,
                BuybackStatus.SUBMITTED
        );

        for (OnlineSubmissionDTO.ItemDTO itemDTO : dto.getItems()) {
            BuybackRequestItem item = new BuybackRequestItem();
            item.setBuybackRequest(request);
            item.setIsbn(itemDTO.getIsbn());
            item.setCustomBookTitle(itemDTO.getCustomTitle());
            item.setDeclaredCoverPrice(itemDTO.getDeclaredCoverPrice());
            item.setCustomerConditionNote(itemDTO.getCustomerConditionNote());
            item.setCloudinaryImagesJson(itemDTO.getCloudinaryImagesJson());

            // Attempt to link to catalog if ISBN matches
            if (itemDTO.getIsbn() != null && !itemDTO.getIsbn().isBlank()) {
                bookTitleRepository.findByIsbn(itemDTO.getIsbn().trim())
                        .ifPresent(item::setBookTitle);
            }

            request.getItems().add(item);
        }

        BuybackRequest saved = buybackRequestRepository.save(request);

        notificationService.broadcastStockUpdate(
                targetBranch.getId(),
                "Yêu cầu định giá thu mua mới online: " + saved.getRequestCode()
        );

        return saved;
    }

    /**
     * Module 3: Online Appraisal - Step 2: Staff provides preliminary quote
     */
    @Transactional
    public BuybackRequest providePreliminaryQuote(Long requestId, Long staffUserId,
                                                  Map<Long, BigDecimal> itemQuotes, String staffNote) {
        BuybackRequest request = buybackRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn thu mua: " + requestId));

        User staff = userRepository.findById(staffUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên: " + staffUserId));

        if (request.getTargetBranch() != null) {
            SecurityUtils.assertBranchAccess(request.getTargetBranch().getId());
        }

        BigDecimal totalEstimated = BigDecimal.ZERO;
        for (BuybackRequestItem item : request.getItems()) {
            if (itemQuotes.containsKey(item.getId())) {
                BigDecimal quote = pricingEngineService.roundToNearestThousand(itemQuotes.get(item.getId()));
                item.setPreQuotedPrice(quote);
                totalEstimated = totalEstimated.add(quote);
            }
        }

        request.setAppraiser(staff);
        request.setTotalEstimatedPrice(totalEstimated);
        request.setStaffNote(staffNote);
        request.setStatus(BuybackStatus.PRE_QUOTED);

        return buybackRequestRepository.save(request);
    }

    /**
     * Module 3: Online Appraisal - Step 3: Customer accepts or rejects preliminary quote
     */
    @Transactional
    public BuybackRequest customerRespondToQuote(Long requestId, Long customerUserId, boolean accept, String note) {
        BuybackRequest request = buybackRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn thu mua: " + requestId));

        if (accept) {
            request.setStatus(BuybackStatus.CUSTOMER_ACCEPTED);
        } else {
            request.setStatus(BuybackStatus.CUSTOMER_REJECTED);
            request.setStaffNote(request.getStaffNote() + " [Khách từ chối: " + note + "]");
        }

        return buybackRequestRepository.save(request);
    }

    /**
     * Module 3: Online Appraisal - Step 4: Branch marks physical items received
     */
    @Transactional
    public BuybackRequest markItemReceived(Long requestId, Long staffUserId) {
        BuybackRequest request = buybackRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn thu mua: " + requestId));

        if (request.getTargetBranch() != null) {
            SecurityUtils.assertBranchAccess(request.getTargetBranch().getId());
        }

        request.setStatus(BuybackStatus.ITEM_RECEIVED);
        return buybackRequestRepository.save(request);
    }

    /**
     * Module 3: Online Appraisal - Step 5: Final physical appraisal & intake
     * Generates BookItem records for all accepted books.
     */
    @Transactional
    public BuybackRequest finalizePhysicalAppraisal(Long requestId, Long staffUserId,
                                                    List<PhysicalInspectionItemDTO> inspectedItems, String staffNote) {
        BuybackRequest request = buybackRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn thu mua: " + requestId));

        User staff = userRepository.findById(staffUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy nhân viên: " + staffUserId));

        Branch branch = request.getTargetBranch();
        if (branch != null) {
            SecurityUtils.assertBranchAccess(branch.getId());
        } else {
            branch = staff.getBranch();
        }

        BigDecimal totalFinal = BigDecimal.ZERO;

        for (PhysicalInspectionItemDTO inspection : inspectedItems) {
            BuybackRequestItem item = request.getItems().stream()
                    .filter(i -> i.getId().equals(inspection.getItemId()))
                    .findFirst()
                    .orElse(null);

            if (item == null) continue;

            if (!inspection.isAccepted()) {
                item.setRejectionReason(inspection.getRejectionReason());
                continue;
            }

            BookTitle bookTitle = item.getBookTitle();
            if (bookTitle == null) {
                bookTitle = new BookTitle(
                        item.getIsbn(),
                        item.getCustomBookTitle() != null ? item.getCustomBookTitle() : "Sách thu mua online",
                        "Chưa cập nhật",
                        item.getDeclaredCoverPrice() != null ? item.getDeclaredCoverPrice() : BigDecimal.valueOf(100000)
                );
                bookTitle = bookTitleRepository.save(bookTitle);
                item.setBookTitle(bookTitle);
            }

            item.setFinalGrade(inspection.getFinalGrade());

            long chainStock = bookItemRepository.countByBookTitleIdAndStatus(bookTitle.getId(), BookItemStatus.IN_STOCK);
            BookValuationResult val = pricingEngineService.calculateValuation(
                    bookTitle.getCoverPrice(),
                    inspection.getFinalGrade(),
                    BigDecimal.ONE,
                    chainStock
            );

            BigDecimal finalPrice;
            if (inspection.getCustomPrice() != null) {
                pricingEngineService.validateStaffBuybackPriceOverride(
                        inspection.getCustomPrice(),
                        val.getRecommendedBuybackPrice(),
                        staff.getRole().getCode()
                );
                finalPrice = pricingEngineService.roundToNearestThousand(inspection.getCustomPrice());
            } else {
                finalPrice = val.getRecommendedBuybackPrice();
            }

            item.setFinalPrice(finalPrice);
            totalFinal = totalFinal.add(finalPrice);

            // Spawn BookItem with serial code
            String barcode = generateBarcode(branch);
            BookItem bookItem = new BookItem(
                    barcode,
                    bookTitle,
                    branch,
                    inspection.getFinalGrade(),
                    finalPrice,
                    val.getRecommendedSellingPrice(),
                    BookItemStatus.IN_STOCK
            );
            bookItem = bookItemRepository.save(bookItem);

            item.setSpawnedBookItemId(bookItem.getId());
        }

        request.setAppraiser(staff);
        request.setTotalFinalPrice(totalFinal);
        request.setStatus(BuybackStatus.COMPLETED);
        if (staffNote != null && !staffNote.isBlank()) {
            request.setStaffNote(staffNote);
        }

        return buybackRequestRepository.save(request);
    }

    /**
     * Resolves an existing BookTitle by ISBN or creates a new one.
     */
    private BookTitle resolveOrCreateBookTitle(WalkInBuybackDTO.ItemDTO itemDTO) {
        if (itemDTO.getBookTitleId() != null) {
            return bookTitleRepository.findById(itemDTO.getBookTitleId())
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đầu sách ID=" + itemDTO.getBookTitleId()));
        }

        if (itemDTO.getIsbn() != null && !itemDTO.getIsbn().isBlank()) {
            var existing = bookTitleRepository.findByIsbn(itemDTO.getIsbn().trim());
            if (existing.isPresent()) {
                return existing.get();
            }
        }

        BigDecimal cover = itemDTO.getCoverPrice() != null ? itemDTO.getCoverPrice() : BigDecimal.valueOf(100000);
        String title = (itemDTO.getTitle() != null && !itemDTO.getTitle().isBlank())
                ? itemDTO.getTitle().trim()
                : "Sách cũ vãng lai";

        BookTitle newTitle = new BookTitle(
                itemDTO.getIsbn(),
                title,
                itemDTO.getAuthor() != null ? itemDTO.getAuthor() : "Đang cập nhật",
                cover
        );
        return bookTitleRepository.save(newTitle);
    }

    // ==================== QUERY METHODS ====================

    @Transactional(readOnly = true)
    public List<BuybackRequest> listRequests(Long branchId, BuybackStatus status) {
        if (branchId != null) {
            SecurityUtils.assertBranchAccess(branchId);
            if (status != null) {
                return buybackRequestRepository.findByTargetBranchIdAndStatus(branchId, status);
            }
            return buybackRequestRepository.findByTargetBranchId(branchId);
        }

        if (status != null) {
            return buybackRequestRepository.findByStatus(status);
        }
        return buybackRequestRepository.findAll();
    }

    @Transactional(readOnly = true)
    public BuybackRequest getRequest(Long id) {
        BuybackRequest req = buybackRequestRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn thu mua: " + id));
        if (req.getTargetBranch() != null && !SecurityUtils.isSuperAdmin()) {
            SecurityUtils.assertBranchAccess(req.getTargetBranch().getId());
        }
        return req;
    }

    @Transactional(readOnly = true)
    public List<BuybackRequest> listCustomerRequests(Long customerUserId) {
        return buybackRequestRepository.findByCustomerId(customerUserId);
    }
}
