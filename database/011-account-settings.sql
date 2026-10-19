USE [WebsiteQuanLyCuaHangSachCu];
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Users','AvatarPath') IS NULL
 ALTER TABLE dbo.Users ADD AvatarPath varchar(100) NULL;
IF COL_LENGTH('dbo.AuthChallenges','VersionAtIssue') IS NULL
 ALTER TABLE dbo.AuthChallenges ADD VersionAtIssue int NULL;
IF OBJECT_ID('dbo.CK_AuthChallenges_Purpose','C') IS NOT NULL
 ALTER TABLE dbo.AuthChallenges DROP CONSTRAINT CK_AuthChallenges_Purpose;
ALTER TABLE dbo.AuthChallenges WITH CHECK ADD CONSTRAINT CK_AuthChallenges_Purpose CHECK(Purpose IN ('REGISTER','RESET','EMAIL'));
COMMIT;
