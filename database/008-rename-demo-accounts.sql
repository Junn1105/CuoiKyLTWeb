USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON; SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @m TABLE(OldName nvarchar(50) COLLATE Latin1_General_100_CI_AS,NewName nvarchar(50) COLLATE Latin1_General_100_CI_AS,Email nvarchar(254) COLLATE Latin1_General_100_CI_AS,FullName nvarchar(150),PasswordHash varchar(255));
INSERT @m VALUES
(N'demo.admin',N'admin',N'demo.admin@example.invalid',N'Quản trị viên',N'$2a$12$R9gs8wTdwsCDu0Yg0UN2eeaqH/YhL0pfdIJAIKVxKTjwP1E9OwEs.'),
(N'demo.manager1',N'manager',N'demo.manager1@example.invalid',N'Nguyễn Đức Long',N'$2a$12$h/V9eOyEmJHWg/jK9jmmAuRJl6.RtivUMG/t8Rd3CcWhCF2BcPtoe'),
(N'demo.manager2',N'manager2',N'demo.manager2@example.invalid',N'Trần Quốc Hùng',N'$2a$12$GBN8xQVfueGzURql9Hn4GejEbNMiPKy8qglaHXehCsGGy0GQat95e'),
(N'demo.manager3',N'manager3',N'demo.manager3@example.invalid',N'Lê Thanh Hà',N'$2a$12$Z.pF43Vu0h8LbAIv7WzGqeAnVgHDNwvP1Gjx/cHOFZEp/aYwd3IkG'),
(N'demo.staff1',N'staff',N'demo.staff1@example.invalid',N'Nguyễn Quốc Bảo',N'$2a$12$rJsNblLj8g/F0BlacJjegOBajYuf8l9HfTT2TxmlTVbrclnoq1EsO'),
(N'demo.staff2',N'staff2',N'demo.staff2@example.invalid',N'Trần Ngọc Mai',N'$2a$12$ur8HJ7atr9yRfoKslQZdauGe4COWMQ0CNJVfAZm2FGbg77IOvLy9W'),
(N'demo.staff3',N'staff3',N'demo.staff3@example.invalid',N'Lê Tuấn Anh',N'$2a$12$D5IblYQH.m52BZ9N24NpY.gGSOmf7CIKHjmo1s9bGzjLuM0ywZL7i'),
(N'demo.former',N'staff4',N'demo.former@example.invalid',N'Phạm Minh Đức',N'$2a$12$atr9So0g8TIPqoFzktf6rOl28GCfU6yrSqDJ5oOQvgpKQz5kIKEFK'),
(N'demo.lockedstaff',N'staff5',N'demo.lockedstaff@example.invalid',N'Đỗ Thanh Tâm',N'$2a$12$lB5e8PUkOYTBQUONPq3Z3e8F6gXKMG1rD5rHpwaKuXM/dcEL5b4QO'),
(N'demo.customer1',N'khang',N'demo.customer1@example.invalid',N'Nguyễn Minh Khang',N'$2a$12$q4Q/bX9x8Vx7IKe7Qa8P4O1ad.ZPRwOMqDO7Aplq14a.y0aR4vuli'),
(N'demo.customer2',N'hoang',N'demo.customer2@example.invalid',N'Trần Hoàng',N'$2a$12$1eQpYloy/C2qxgG1aMVL1uekYHqwrKGzhaD7JA.4Xw3H5YI39N6rG'),
(N'demo.customer3',N'van',N'demo.customer3@example.invalid',N'Lê Ngọc Vân',N'$2a$12$6XPhmt6tTWm/2hVM6/l3ceRkpFMjdDcQ/eWhsAaSy/sq3wcCWhpL2'),
(N'demo.locked',N'minh',N'demo.locked@example.invalid',N'Phạm Minh',N'$2a$12$tt6uWQRseJ4YaRDgSHDJqewArJTNR2M107ldJZ.fitMAUL03/IgLi'),
(N'demo.pending',N'linh',N'demo.pending@example.invalid',N'Đỗ Thùy Linh',N'$2a$12$jOsyJ676O.c1fAXy7ji/q.SyEFIWcEXM5X6H/T/V1m2YfD.8OfHIq'),
(N'demo.empty',N'nam',N'demo.empty@example.invalid',N'Nguyễn Hoài Nam',N'$2a$12$F5RkjAybyX/A26doqExmneWfrInAWopF9qRxU7pOjgKnHeBMcS/Li'),
(N'demo.unassigned',N'huy',N'demo.unassigned@example.invalid',N'Trần Quang Huy',N'$2a$12$Yl.z3sbdw93sKF/EgEYLTey244ylprrzy5tpQGgn3RlWEVNgjAvDO');
IF (SELECT COUNT(*) FROM dbo.Users u WITH(UPDLOCK,HOLDLOCK) JOIN @m m ON m.Email=u.Email AND (u.Username=m.OldName OR u.Username=m.NewName))<>16
 THROW 51500,'Expected 16 identifiable demo accounts; no changes made.',1;
IF EXISTS(SELECT 1 FROM dbo.Users u JOIN @m m ON u.Username=m.NewName WHERE u.Email<>m.Email)
 THROW 51501,'A requested username belongs to another account.',1;
UPDATE u SET Username=m.NewName,FullName=m.FullName,PasswordHash=m.PasswordHash,UpdatedAt=SYSUTCDATETIME()
FROM dbo.Users u JOIN @m m ON u.Email=m.Email;
IF @@ROWCOUNT<>16 THROW 51502,'Unexpected updated user count.',1;
COMMIT TRANSACTION;
PRINT 'Updated 16 demo accounts; IDs, statuses, roles and related records preserved.';
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;

