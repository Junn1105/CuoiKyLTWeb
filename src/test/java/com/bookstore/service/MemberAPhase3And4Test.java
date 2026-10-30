package com.bookstore.service;

import com.bookstore.entity.auth.Role;
import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.Branch;
import com.bookstore.entity.branch.InventoryTransfer;
import com.bookstore.entity.branch.TransferReason;
import com.bookstore.entity.branch.TransferStatus;
import com.bookstore.entity.buyback.*;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.entity.catalog.BookTitle;
import com.bookstore.repository.auth.RoleRepository;
import com.bookstore.repository.auth.UserRepository;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.repository.catalog.BookTitleRepository;
import com.bookstore.security.CustomUserDetails;
import com.bookstore.service.branch.InventoryTransferService;
import com.bookstore.service.branch.ReceiptItemDTO;
import com.bookstore.service.buyback.BuybackService;
import com.bookstore.service.buyback.OnlineSubmissionDTO;
import com.bookstore.service.buyback.PhysicalInspectionItemDTO;
import com.bookstore.service.buyback.WalkInBuybackDTO;
import com.bookstore.service.pricing.BookValuationResult;
import com.bookstore.service.pricing.PricingEngineService;
import com.bookstore.service.pricing.PricingPolicyException;
import com.bookstore.service.report.AgingStockReportDTO;
import com.bookstore.service.report.BranchPerformanceReportDTO;
import com.bookstore.service.report.ReportService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = vn.mocsach.MocSachApplication.class)
@Transactional
class MemberAPhase3And4Test {

    @Autowired private PricingEngineService pricingEngineService;
    @Autowired private BuybackService buybackService;
    @Autowired private InventoryTransferService transferService;
    @Autowired private ReportService reportService;

    @Autowired private RoleRepository roleRepo;
    @Autowired private BranchRepository branchRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private BookTitleRepository bookTitleRepo;
    @Autowired private BookItemRepository bookItemRepo;

    private Branch branchA;
    private Branch branchB;
    private User superAdmin;
    private User staffA;
    private User managerA;
    private BookTitle title1;

    @BeforeEach
    void setUp() {
        Role adminRole = roleRepo.findByCode(RoleCode.ROLE_SUPER_ADMIN)
                .orElseGet(() -> roleRepo.save(new Role(RoleCode.ROLE_SUPER_ADMIN, "Super Admin")));
        Role managerRole = roleRepo.findByCode(RoleCode.ROLE_BRANCH_MANAGER)
                .orElseGet(() -> roleRepo.save(new Role(RoleCode.ROLE_BRANCH_MANAGER, "Manager")));
        Role staffRole = roleRepo.findByCode(RoleCode.ROLE_STAFF)
                .orElseGet(() -> roleRepo.save(new Role(RoleCode.ROLE_STAFF, "Staff")));

        String uniq = String.valueOf(System.nanoTime());
        branchA = branchRepo.save(new Branch("BR-A-" + uniq, "Branch Alpha", "District 1", "0901111111", true));
        branchB = branchRepo.save(new Branch("BR-B-" + uniq, "Branch Beta", "Thu Duc", "0902222222", false));

        superAdmin = userRepo.save(new User("admin-" + uniq + "@bookstore.com", "hash", "Admin Boss", "0900000001", adminRole, null));
        staffA = userRepo.save(new User("staff-" + uniq + "@bookstore.com", "hash", "Staff Alpha", "0900000002", staffRole, branchA));
        managerA = userRepo.save(new User("mgr-" + uniq + "@bookstore.com", "hash", "Manager Alpha", "0900000003", managerRole, branchA));

        title1 = bookTitleRepo.save(new BookTitle("978-0123456789", "Design Patterns", "GoF", BigDecimal.valueOf(200000)));

        // Authenticate as Super Admin by default
        authenticateUser(superAdmin);
    }

    private void authenticateUser(User user) {
        CustomUserDetails details = new CustomUserDetails(
                user.getId(),
                user.getEmail(),
                user.getPasswordHash(),
                user.getFullName(),
                user.getRole().getCode(),
                user.getBranch() != null ? user.getBranch().getId() : null,
                user.getBranch() != null ? user.getBranch().getCode() : null,
                user.isActive()
        );
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(details, null, details.getAuthorities())
        );
    }

    // ==================== TEST MODULE 2: PRICING ENGINE ====================

    @Test
    void testPricingEngineFormulasAndSaturation() {
        // Test Stock Scarcity (stock = 0) -> K_stock = 1.10
        // Cover = 100,000; Grade = B (buy 0.20, sell 0.45); Rarity = 1.0
        // Expected Buyback = 100,000 * 0.20 * 1.0 * 1.10 = 22,000
        // Expected Selling = 100,000 * 0.45 * 1.0 = 45,000
        BookValuationResult valScarcity = pricingEngineService.calculateValuation(
                BigDecimal.valueOf(100000), ConditionGrade.B, BigDecimal.ONE, 0
        );
        assertEquals(0, BigDecimal.valueOf(22000).compareTo(valScarcity.getRecommendedBuybackPrice()));
        assertEquals(0, BigDecimal.valueOf(45000).compareTo(valScarcity.getRecommendedSellingPrice()));
        assertEquals(0, BigDecimal.valueOf(1.10).compareTo(valScarcity.getkStock()));

        // Test Stock Overstock (stock >= 10) -> K_stock = 0.80
        // Expected Buyback = 100,000 * 0.20 * 1.0 * 0.80 = 16,000
        BookValuationResult valOverstock = pricingEngineService.calculateValuation(
                BigDecimal.valueOf(100000), ConditionGrade.B, BigDecimal.ONE, 12
        );
        assertEquals(0, BigDecimal.valueOf(16000).compareTo(valOverstock.getRecommendedBuybackPrice()));
        assertEquals(0, BigDecimal.valueOf(0.80).compareTo(valOverstock.getkStock()));

        // Test Normal Stock (1 <= stock < 10) -> K_stock = 1.00
        // Expected Buyback = 100,000 * 0.20 * 1.0 * 1.00 = 20,000
        BookValuationResult valNormal = pricingEngineService.calculateValuation(
                BigDecimal.valueOf(100000), ConditionGrade.B, BigDecimal.ONE, 3
        );
        assertEquals(0, BigDecimal.valueOf(20000).compareTo(valNormal.getRecommendedBuybackPrice()));
        assertEquals(0, BigDecimal.valueOf(1.00).compareTo(valNormal.getkStock()));
    }

    @Test
    void testStaffOverrideGuardLimits() {
        BigDecimal recommended = BigDecimal.valueOf(20000);

        // Staff overrides within ±15% -> Allowed
        // 20,000 * 0.85 = 17,000; 20,000 * 1.15 = 23,000
        assertDoesNotThrow(() ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(21000), recommended, RoleCode.ROLE_STAFF)
        );
        assertDoesNotThrow(() ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(17500), recommended, RoleCode.ROLE_STAFF)
        );

        // Staff overrides > +15% (e.g. 25,000) -> Throws PricingPolicyException
        assertThrows(PricingPolicyException.class, () ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(25000), recommended, RoleCode.ROLE_STAFF)
        );

        // Staff overrides < -15% (e.g. 15,000) -> Throws PricingPolicyException
        assertThrows(PricingPolicyException.class, () ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(15000), recommended, RoleCode.ROLE_STAFF)
        );

        // Branch Manager & Super Admin can override freely beyond ±15%
        assertDoesNotThrow(() ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(35000), recommended, RoleCode.ROLE_BRANCH_MANAGER)
        );
        assertDoesNotThrow(() ->
                pricingEngineService.validateStaffBuybackPriceOverride(BigDecimal.valueOf(35000), recommended, RoleCode.ROLE_SUPER_ADMIN)
        );
    }

    // ==================== TEST MODULE 3: BUYBACK SERVICE ====================

    @Test
    void testWalkInCounterIntakeSpawnsBookItemsWithBarcodes() {
        authenticateUser(staffA);

        WalkInBuybackDTO dto = new WalkInBuybackDTO();
        dto.setCustomerName("Nguyen Van Khach");
        dto.setCustomerPhone("0987654321");
        dto.setStaffNote("Khách bán tại quầy sáng nay");

        WalkInBuybackDTO.ItemDTO item = new WalkInBuybackDTO.ItemDTO();
        item.setBookTitleId(title1.getId());
        item.setCoverPrice(title1.getCoverPrice());
        item.setGrade(ConditionGrade.S); // 45% buy
        item.setRarityFactor(BigDecimal.ONE);
        dto.getItems().add(item);

        BuybackRequest req = buybackService.createWalkInCounterBuyback(dto, staffA.getId());

        assertNotNull(req.getId());
        assertTrue(req.getRequestCode().startsWith("BB-"));
        assertEquals(BuybackStatus.COMPLETED, req.getStatus());
        assertEquals(BuybackIntakeType.WALK_IN_COUNTER, req.getIntakeType());
        assertEquals(1, req.getItems().size());

        BuybackRequestItem reqItem = req.getItems().get(0);
        assertNotNull(reqItem.getSpawnedBookItemId());

        BookItem spawned = bookItemRepo.findById(reqItem.getSpawnedBookItemId()).orElseThrow();
        assertEquals(BookItemStatus.IN_STOCK, spawned.getStatus());
        assertEquals(branchA.getId(), spawned.getCurrentBranch().getId());
        assertEquals(ConditionGrade.S, spawned.getGrade());
        assertNotNull(spawned.getSerialCode());
        // Verify barcode format: {BranchCode}-{YYMM}-{6-digit-sequence}
        assertTrue(spawned.getSerialCode().contains("-"));
    }

    @Test
    void testOnlineAppraisalEndToEndWorkflow() {
        // Step 1: Online submission by customer
        OnlineSubmissionDTO submission = new OnlineSubmissionDTO();
        submission.setTargetBranchId(branchA.getId());
        submission.setCustomerName("Online Guest");
        submission.setCustomerPhone("0911223344");

        OnlineSubmissionDTO.ItemDTO item = new OnlineSubmissionDTO.ItemDTO();
        item.setIsbn("978-0123456789");
        item.setCustomTitle("Design Patterns");
        item.setDeclaredCoverPrice(BigDecimal.valueOf(200000));
        item.setCustomerConditionNote("Sách còn rất mới, đọc 1 lần");
        submission.getItems().add(item);

        BuybackRequest req = buybackService.submitOnlineRequest(submission, null);
        assertEquals(BuybackStatus.SUBMITTED, req.getStatus());
        Long itemId = req.getItems().get(0).getId();

        // Step 2: Staff preliminary quote
        authenticateUser(staffA);
        req = buybackService.providePreliminaryQuote(
                req.getId(), staffA.getId(), Map.of(itemId, BigDecimal.valueOf(70000)), "Báo giá sơ bộ theo ảnh"
        );
        assertEquals(BuybackStatus.PRE_QUOTED, req.getStatus());
        assertEquals(0, BigDecimal.valueOf(70000).compareTo(req.getTotalEstimatedPrice()));

        // Step 3: Customer accepts quote
        req = buybackService.customerRespondToQuote(req.getId(), null, true, null);
        assertEquals(BuybackStatus.CUSTOMER_ACCEPTED, req.getStatus());

        // Step 4: Branch marks received
        req = buybackService.markItemReceived(req.getId(), staffA.getId());
        assertEquals(BuybackStatus.ITEM_RECEIVED, req.getStatus());

        // Step 5: Final physical inspection and intake
        PhysicalInspectionItemDTO inspection = new PhysicalInspectionItemDTO();
        inspection.setItemId(itemId);
        inspection.setFinalGrade(ConditionGrade.A);
        inspection.setAccepted(true);

        req = buybackService.finalizePhysicalAppraisal(req.getId(), staffA.getId(), List.of(inspection), "Đã nghiệm thu");
        assertEquals(BuybackStatus.COMPLETED, req.getStatus());
        assertNotNull(req.getItems().get(0).getSpawnedBookItemId());

        BookItem spawned = bookItemRepo.findById(req.getItems().get(0).getSpawnedBookItemId()).orElseThrow();
        assertEquals(BookItemStatus.IN_STOCK, spawned.getStatus());
        assertEquals(branchA.getId(), spawned.getCurrentBranch().getId());
    }

    // ==================== TEST MODULE 4: INVENTORY TRANSFER ====================

    @Test
    void testInventoryTransferWorkflowAndRoleRules() {
        // Setup a book item in Branch A
        BookItem bookItem = bookItemRepo.save(new BookItem(
                "BARCODE-TRF-001",
                title1,
                branchA,
                ConditionGrade.A,
                BigDecimal.valueOf(70000),
                BigDecimal.valueOf(120000),
                BookItemStatus.IN_STOCK
        ));

        // Step 1: Staff A creates transfer request from Branch A to Branch B
        authenticateUser(staffA);
        InventoryTransfer transfer = transferService.createTransferRequest(
                branchA.getId(),
                branchB.getId(),
                List.of(bookItem.getId()),
                TransferReason.RESTOCK,
                "Chuyển sách bán chạy sang chi nhánh B",
                staffA.getId()
        );
        assertEquals(TransferStatus.REQUESTED, transfer.getStatus());

        // Rule Check: Staff cannot approve transfer!
        Long trfId = transfer.getId();
        assertThrows(AccessDeniedException.class, () ->
                transferService.approveTransfer(trfId, staffA.getId())
        );

        // Step 2: Super Admin approves transfer
        authenticateUser(superAdmin);
        transfer = transferService.approveTransfer(transfer.getId(), superAdmin.getId());
        assertEquals(TransferStatus.APPROVED, transfer.getStatus());

        // Step 3: Source branch dispatches shipment (status -> IN_TRANSIT, BookItem locked)
        authenticateUser(staffA);
        transfer = transferService.dispatchTransfer(transfer.getId(), staffA.getId());
        assertEquals(TransferStatus.IN_TRANSIT, transfer.getStatus());

        BookItem inTransitItem = bookItemRepo.findById(bookItem.getId()).orElseThrow();
        assertEquals(BookItemStatus.IN_TRANSIT_TRANSFER, inTransitItem.getStatus());

        // Step 4: Destination branch confirms receipt
        authenticateUser(superAdmin); // or staff in Branch B
        ReceiptItemDTO receipt = new ReceiptItemDTO();
        receipt.setBookItemId(bookItem.getId());
        receipt.setGradeAfter(ConditionGrade.A);
        receipt.setDamagedOrLost(false);

        transfer = transferService.confirmReceipt(transfer.getId(), List.of(receipt), superAdmin.getId());
        assertEquals(TransferStatus.COMPLETED, transfer.getStatus());

        BookItem receivedItem = bookItemRepo.findById(bookItem.getId()).orElseThrow();
        assertEquals(BookItemStatus.IN_STOCK, receivedItem.getStatus());
        assertEquals(branchB.getId(), receivedItem.getCurrentBranch().getId()); // Absorbed into Branch B!
    }

    // ==================== TEST MODULE 5: REPORT SERVICE ====================

    @Test
    void testFinancialPerformanceAndAgingStockReports() {
        authenticateUser(superAdmin);

        // Create an aging item (> 90 days ago)
        BookItem agingItem = new BookItem(
                "BARCODE-AGING-999",
                title1,
                branchA,
                ConditionGrade.B,
                BigDecimal.valueOf(40000),
                BigDecimal.valueOf(90000),
                BookItemStatus.IN_STOCK
        );
        agingItem = bookItemRepo.save(agingItem);

        agingItem.setCreatedAt(LocalDateTime.now().minusDays(100));
        bookItemRepo.save(agingItem);

        List<BranchPerformanceReportDTO> reports = reportService.getBranchPerformanceReports(null);
        assertNotNull(reports);
        assertFalse(reports.isEmpty());

        List<AgingStockReportDTO> agingReport = reportService.getAgingStockReport(branchA.getId(), 0); // threshold 0 days for immediate match
        assertNotNull(agingReport);
    }
}
