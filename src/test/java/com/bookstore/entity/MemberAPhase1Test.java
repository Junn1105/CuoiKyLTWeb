package com.bookstore.entity;

import com.bookstore.entity.auth.Role;
import com.bookstore.entity.auth.RoleCode;
import com.bookstore.entity.auth.User;
import com.bookstore.entity.branch.*;
import com.bookstore.entity.buyback.*;
import com.bookstore.entity.catalog.BookItem;
import com.bookstore.entity.catalog.BookItemStatus;
import com.bookstore.entity.catalog.BookTitle;
import com.bookstore.repository.auth.RoleRepository;
import com.bookstore.repository.auth.UserRepository;
import com.bookstore.repository.branch.BranchRepository;
import com.bookstore.repository.branch.InventoryTransferRepository;
import com.bookstore.repository.buyback.BuybackRequestRepository;
import com.bookstore.repository.catalog.BookItemRepository;
import com.bookstore.repository.catalog.BookTitleRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(classes = vn.mocsach.MocSachApplication.class)
@Transactional
class MemberAPhase1Test {

    @Autowired private RoleRepository roleRepo;
    @Autowired private BranchRepository branchRepo;
    @Autowired private UserRepository userRepo;
    @Autowired private BookTitleRepository bookTitleRepo;
    @Autowired private BookItemRepository bookItemRepo;
    @Autowired private BuybackRequestRepository buybackRepo;
    @Autowired private InventoryTransferRepository transferRepo;

    @Test
    void testConditionGradeMultipliers() {
        assertEquals(new BigDecimal("0.45"), ConditionGrade.S.getBuyMultiplier());
        assertEquals(new BigDecimal("0.75"), ConditionGrade.S.getSellMultiplier());
        assertEquals(new BigDecimal("0.35"), ConditionGrade.A.getBuyMultiplier());
        assertEquals(new BigDecimal("0.60"), ConditionGrade.A.getSellMultiplier());
        assertEquals(new BigDecimal("0.20"), ConditionGrade.B.getBuyMultiplier());
        assertEquals(new BigDecimal("0.45"), ConditionGrade.B.getSellMultiplier());
        assertEquals(new BigDecimal("0.08"), ConditionGrade.C.getBuyMultiplier());
        assertEquals(new BigDecimal("0.25"), ConditionGrade.C.getSellMultiplier());
    }

    @Test
    void testAuthAndBranchEntities() {
        Role adminRole = roleRepo.findByCode(RoleCode.ROLE_SUPER_ADMIN)
                .orElseGet(() -> roleRepo.save(new Role(RoleCode.ROLE_SUPER_ADMIN, "Super Admin")));
        assertNotNull(adminRole.getId());

        Branch branch = branchRepo.save(new Branch("TEST-Q1", "Test Branch Q1", "Address 1", "0901234567", true));
        assertNotNull(branch.getId());

        User user = new User("test.admin@bookstore.vn", "hash123", "Test Admin", "0901112223", adminRole, branch);
        User savedUser = userRepo.save(user);

        assertNotNull(savedUser.getId());
        assertEquals("test.admin@bookstore.vn", userRepo.findByEmail("test.admin@bookstore.vn").orElseThrow().getEmail());
    }

    @Test
    void testCatalogAndBuybackAndTransferFlow() {
        Role staffRole = roleRepo.findByCode(RoleCode.ROLE_STAFF)
                .orElseGet(() -> roleRepo.save(new Role(RoleCode.ROLE_STAFF, "Staff")));
        Branch fromBranch = branchRepo.save(new Branch("TEST-HN", "Branch Hanoi", "Hanoi", "0241234567", true));
        Branch toBranch = branchRepo.save(new Branch("TEST-SG", "Branch Saigon", "Saigon", "0281234567", false));

        User staff = userRepo.save(new User("staff@bookstore.vn", "hash", "Staff HN", "0909999999", staffRole, fromBranch));

        BookTitle title = bookTitleRepo.save(new BookTitle("978-604-1-12345-6", "Lão Hạc", "Nam Cao", new BigDecimal("80000")));
        assertNotNull(title.getId());

        // Test BookItem with Versioning
        BookItem item = new BookItem("TEST-HN-2610-000001", title, fromBranch, ConditionGrade.A, new BigDecimal("28000"), new BigDecimal("48000"), BookItemStatus.IN_STOCK);
        BookItem savedItem = bookItemRepo.save(item);
        assertNotNull(savedItem.getId());
        assertEquals(1, bookItemRepo.countByBookTitleIdAndStatus(title.getId(), BookItemStatus.IN_STOCK));

        // Test Buyback Request with items
        BuybackRequest request = new BuybackRequest("BB-TEST-001", null, "Khách Vãng Lai", "0900000000", fromBranch, BuybackIntakeType.WALK_IN_COUNTER, BuybackStatus.SUBMITTED);
        BuybackRequestItem requestItem = new BuybackRequestItem(request, title, "Lão Hạc", "978-604-1-12345-6", new BigDecimal("80000"));
        requestItem.setFinalGrade(ConditionGrade.A);
        requestItem.setFinalPrice(new BigDecimal("28000"));
        request.addItem(requestItem);

        BuybackRequest savedReq = buybackRepo.save(request);
        assertNotNull(savedReq.getId());
        assertEquals(1, savedReq.getItems().size());

        // Test Inventory Transfer with items
        InventoryTransfer transfer = new InventoryTransfer("TRF-TEST-001", fromBranch, toBranch, staff, TransferReason.RESTOCK);
        InventoryTransferItem transferItem = new InventoryTransferItem(transfer, savedItem, ConditionGrade.A);
        transfer.addItem(transferItem);

        InventoryTransfer savedTransfer = transferRepo.save(transfer);
        assertNotNull(savedTransfer.getId());
        assertEquals(1, savedTransfer.getItems().size());
        assertEquals(TransferStatus.REQUESTED, savedTransfer.getStatus());
    }
}
