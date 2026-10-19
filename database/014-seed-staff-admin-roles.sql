USE [WebsiteQuanLyCuaHangSachCu];
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRANSACTION;

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleCode = 'STAFF')
BEGIN
 INSERT INTO dbo.Roles(RoleCode, RoleName)
 VALUES ('STAFF', N'Nhân viên cửa hàng');
END;

DECLARE @AdminRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'ADMIN');
DECLARE @StaffRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'STAFF');
DECLARE @CustomerRoleId INT = (SELECT RoleId FROM dbo.Roles WHERE RoleCode = 'CUSTOMER');

-- Assign STAFF role to staff and manager accounts
INSERT INTO dbo.UserRoles(UserId, RoleId)
SELECT u.UserId, @StaffRoleId
FROM dbo.Users u
WHERE (u.Username LIKE 'staff%' OR u.Username LIKE 'manager%')
  AND NOT EXISTS (
   SELECT 1 FROM dbo.UserRoles ur WHERE ur.UserId = u.UserId AND ur.RoleId = @StaffRoleId
  );

-- Assign ADMIN role to admin and sang so the active test account has full Admin/Staff access
INSERT INTO dbo.UserRoles(UserId, RoleId)
SELECT u.UserId, @AdminRoleId
FROM dbo.Users u
WHERE u.Username IN ('admin', 'sang')
  AND NOT EXISTS (
   SELECT 1 FROM dbo.UserRoles ur WHERE ur.UserId = u.UserId AND ur.RoleId = @AdminRoleId
  );

COMMIT TRANSACTION;
