-- ====================================================================
-- MIGRATION 015: MEMBER A (CORE INFRASTRUCTURE, SECURITY & ERP BACK-OFFICE)
-- Database: SQL Server (Transact-SQL) / Compatible with PostgreSQL/MySQL
-- ====================================================================

USE [WebsiteQuanLyCuaHangSachCu];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
GO

-- 1. Table bk_roles
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_roles')
BEGIN
    CREATE TABLE dbo.bk_roles (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        name NVARCHAR(100) NOT NULL
    );
END
GO

-- 2. Table bk_branches
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_branches')
BEGIN
    CREATE TABLE dbo.bk_branches (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        code VARCHAR(50) NOT NULL UNIQUE,
        name NVARCHAR(150) NOT NULL,
        address NVARCHAR(300) NULL,
        phone VARCHAR(30) NULL,
        is_hub BIT NOT NULL DEFAULT 0,
        active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 3. Table bk_users
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_users')
BEGIN
    CREATE TABLE dbo.bk_users (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        email VARCHAR(150) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        full_name NVARCHAR(150) NOT NULL,
        phone VARCHAR(30) NULL,
        role_id BIGINT NOT NULL,
        branch_id BIGINT NULL,
        active BIT NOT NULL DEFAULT 1,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_bk_users_role FOREIGN KEY (role_id) REFERENCES dbo.bk_roles(id),
        CONSTRAINT FK_bk_users_branch FOREIGN KEY (branch_id) REFERENCES dbo.bk_branches(id)
    );
END
GO

-- 4. Table bk_book_titles (Skeleton / Shared with Member B)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_book_titles')
BEGIN
    CREATE TABLE dbo.bk_book_titles (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        isbn VARCHAR(30) NULL,
        title NVARCHAR(250) NOT NULL,
        author NVARCHAR(150) NULL,
        publisher NVARCHAR(150) NULL,
        publish_year INT NULL,
        cover_price DECIMAL(12,2) NULL,
        category NVARCHAR(100) NULL,
        description NVARCHAR(2000) NULL,
        cover_image_url VARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 5. Table bk_book_items (Skeleton with @Version optimistic lock)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_book_items')
BEGIN
    CREATE TABLE dbo.bk_book_items (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        serial_code VARCHAR(60) NOT NULL UNIQUE,
        book_title_id BIGINT NOT NULL,
        branch_id BIGINT NOT NULL,
        grade VARCHAR(20) NOT NULL,
        cost_price DECIMAL(12,2) NULL,
        selling_price DECIMAL(12,2) NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'IN_STOCK',
        images_json NVARCHAR(MAX) NULL,
        version BIGINT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT FK_bk_book_items_title FOREIGN KEY (book_title_id) REFERENCES dbo.bk_book_titles(id),
        CONSTRAINT FK_bk_book_items_branch FOREIGN KEY (branch_id) REFERENCES dbo.bk_branches(id)
    );
END
GO

-- 6. Table bk_buyback_requests
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_buyback_requests')
BEGIN
    CREATE TABLE dbo.bk_buyback_requests (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        request_code VARCHAR(60) NOT NULL UNIQUE,
        customer_user_id BIGINT NULL,
        customer_name NVARCHAR(150) NULL,
        customer_phone VARCHAR(30) NULL,
        target_branch_id BIGINT NULL,
        appraiser_user_id BIGINT NULL,
        intake_type VARCHAR(30) NOT NULL DEFAULT 'WALK_IN_COUNTER',
        status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',
        total_estimated_price DECIMAL(12,2) NOT NULL DEFAULT 0,
        total_final_price DECIMAL(12,2) NOT NULL DEFAULT 0,
        staff_note NVARCHAR(1000) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT FK_bk_buyback_customer FOREIGN KEY (customer_user_id) REFERENCES dbo.bk_users(id),
        CONSTRAINT FK_bk_buyback_branch FOREIGN KEY (target_branch_id) REFERENCES dbo.bk_branches(id),
        CONSTRAINT FK_bk_buyback_appraiser FOREIGN KEY (appraiser_user_id) REFERENCES dbo.bk_users(id)
    );
END
GO

-- 7. Table bk_buyback_request_items
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_buyback_request_items')
BEGIN
    CREATE TABLE dbo.bk_buyback_request_items (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        buyback_request_id BIGINT NOT NULL,
        book_title_id BIGINT NULL,
        custom_book_title NVARCHAR(250) NULL,
        isbn VARCHAR(30) NULL,
        declared_cover_price DECIMAL(12,2) NULL,
        customer_condition_note NVARCHAR(1000) NULL,
        cloudinary_images_json NVARCHAR(MAX) NULL,
        pre_quoted_price DECIMAL(12,2) NULL,
        final_grade VARCHAR(20) NULL,
        final_price DECIMAL(12,2) NULL,
        rejection_reason NVARCHAR(500) NULL,
        spawned_book_item_id BIGINT NULL,
        CONSTRAINT FK_bk_buyback_items_request FOREIGN KEY (buyback_request_id) REFERENCES dbo.bk_buyback_requests(id) ON DELETE CASCADE,
        CONSTRAINT FK_bk_buyback_items_title FOREIGN KEY (book_title_id) REFERENCES dbo.bk_book_titles(id)
    );
END
GO

-- 8. Table bk_inventory_transfers
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_inventory_transfers')
BEGIN
    CREATE TABLE dbo.bk_inventory_transfers (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        transfer_code VARCHAR(60) NOT NULL UNIQUE,
        from_branch_id BIGINT NOT NULL,
        to_branch_id BIGINT NOT NULL,
        requested_by_user_id BIGINT NOT NULL,
        approved_by_user_id BIGINT NULL,
        received_by_user_id BIGINT NULL,
        reason VARCHAR(40) NOT NULL DEFAULT 'RESTOCK',
        reference_order_code VARCHAR(60) NULL,
        status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED',
        note NVARCHAR(1000) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        completed_at DATETIME2 NULL,
        CONSTRAINT FK_bk_transfers_from_branch FOREIGN KEY (from_branch_id) REFERENCES dbo.bk_branches(id),
        CONSTRAINT FK_bk_transfers_to_branch FOREIGN KEY (to_branch_id) REFERENCES dbo.bk_branches(id),
        CONSTRAINT FK_bk_transfers_req_user FOREIGN KEY (requested_by_user_id) REFERENCES dbo.bk_users(id),
        CONSTRAINT FK_bk_transfers_app_user FOREIGN KEY (approved_by_user_id) REFERENCES dbo.bk_users(id),
        CONSTRAINT FK_bk_transfers_rec_user FOREIGN KEY (received_by_user_id) REFERENCES dbo.bk_users(id)
    );
END
GO

-- 9. Table bk_inventory_transfer_items
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bk_inventory_transfer_items')
BEGIN
    CREATE TABLE dbo.bk_inventory_transfer_items (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        transfer_id BIGINT NOT NULL,
        book_item_id BIGINT NOT NULL,
        grade_before VARCHAR(20) NULL,
        grade_after VARCHAR(20) NULL,
        discrepancy_note NVARCHAR(500) NULL,
        CONSTRAINT FK_bk_transfer_items_transfer FOREIGN KEY (transfer_id) REFERENCES dbo.bk_inventory_transfers(id) ON DELETE CASCADE,
        CONSTRAINT FK_bk_transfer_items_item FOREIGN KEY (book_item_id) REFERENCES dbo.bk_book_items(id)
    );
END
GO

-- 10. SEED INITIAL ROLES
IF NOT EXISTS (SELECT 1 FROM dbo.bk_roles WHERE code = 'ROLE_SUPER_ADMIN')
    INSERT INTO dbo.bk_roles (code, name) VALUES ('ROLE_SUPER_ADMIN', N'Tổng Quản Trị Hệ Thống');
IF NOT EXISTS (SELECT 1 FROM dbo.bk_roles WHERE code = 'ROLE_BRANCH_MANAGER')
    INSERT INTO dbo.bk_roles (code, name) VALUES ('ROLE_BRANCH_MANAGER', N'Quản Lý Chi Nhánh');
IF NOT EXISTS (SELECT 1 FROM dbo.bk_roles WHERE code = 'ROLE_STAFF')
    INSERT INTO dbo.bk_roles (code, name) VALUES ('ROLE_STAFF', N'Nhân Viên Chi Nhánh');
IF NOT EXISTS (SELECT 1 FROM dbo.bk_roles WHERE code = 'ROLE_CUSTOMER')
    INSERT INTO dbo.bk_roles (code, name) VALUES ('ROLE_CUSTOMER', N'Khách Hàng');

-- 11. SEED INITIAL BRANCHES
IF NOT EXISTS (SELECT 1 FROM dbo.bk_branches WHERE code = 'SGN-Q1')
    INSERT INTO dbo.bk_branches (code, name, address, phone, is_hub, active)
    VALUES ('SGN-Q1', N'Mộc Sách - Chi Nhánh Quận 1', N'123 Nguyễn Thị Minh Khai, P. Bến Thành, Q.1, TP.HCM', '028-38221144', 1, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.bk_branches WHERE code = 'SGN-TD')
    INSERT INTO dbo.bk_branches (code, name, address, phone, is_hub, active)
    VALUES ('SGN-TD', N'Mộc Sách - Chi Nhánh Thủ Đức', N'45 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức, TP.HCM', '028-37225566', 0, 1);
IF NOT EXISTS (SELECT 1 FROM dbo.bk_branches WHERE code = 'HAN-HK')
    INSERT INTO dbo.bk_branches (code, name, address, phone, is_hub, active)
    VALUES ('HAN-HK', N'Mộc Sách - Chi Nhánh Hoàn Kiếm (Hà Nội)', N'18 Đinh Lễ, P. Tràng Tiền, Q. Hoàn Kiếm, Hà Nội', '024-39338899', 1, 1);

-- 12. SEED INITIAL USERS (Password 123456: $2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.)
DECLARE @SuperAdminRoleId BIGINT = (SELECT id FROM dbo.bk_roles WHERE code = 'ROLE_SUPER_ADMIN');
DECLARE @ManagerRoleId BIGINT = (SELECT id FROM dbo.bk_roles WHERE code = 'ROLE_BRANCH_MANAGER');
DECLARE @StaffRoleId BIGINT = (SELECT id FROM dbo.bk_roles WHERE code = 'ROLE_STAFF');
DECLARE @CustomerRoleId BIGINT = (SELECT id FROM dbo.bk_roles WHERE code = 'ROLE_CUSTOMER');

DECLARE @BranchQ1Id BIGINT = (SELECT id FROM dbo.bk_branches WHERE code = 'SGN-Q1');
DECLARE @BranchTDId BIGINT = (SELECT id FROM dbo.bk_branches WHERE code = 'SGN-TD');

IF NOT EXISTS (SELECT 1 FROM dbo.bk_users WHERE email = 'admin@bookstore.vn')
    INSERT INTO dbo.bk_users (email, password_hash, full_name, phone, role_id, branch_id, active)
    VALUES ('admin@bookstore.vn', '$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.', N'Quản Trị Viên Cấp Cao', '0901000001', @SuperAdminRoleId, NULL, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bk_users WHERE email = 'manager.q1@bookstore.vn')
    INSERT INTO dbo.bk_users (email, password_hash, full_name, phone, role_id, branch_id, active)
    VALUES ('manager.q1@bookstore.vn', '$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.', N'Trần Văn Quản Lý Q1', '0902000001', @ManagerRoleId, @BranchQ1Id, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bk_users WHERE email = 'staff.q1@bookstore.vn')
    INSERT INTO dbo.bk_users (email, password_hash, full_name, phone, role_id, branch_id, active)
    VALUES ('staff.q1@bookstore.vn', '$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.', N'Lê Thị Nhân Viên Q1', '0903000001', @StaffRoleId, @BranchQ1Id, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.bk_users WHERE email = 'customer@bookstore.vn')
    INSERT INTO dbo.bk_users (email, password_hash, full_name, phone, role_id, branch_id, active)
    VALUES ('customer@bookstore.vn', '$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.', N'Nguyễn Văn Khách Mua', '0904000001', @CustomerRoleId, NULL, 1);

COMMIT TRANSACTION;
GO
PRINT 'Migration 015 completed successfully!';
GO
