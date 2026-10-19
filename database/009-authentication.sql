USE [WebsiteQuanLyCuaHangSachCu];
SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
BEGIN TRY
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.Users','AuthVersion') IS NULL
 ALTER TABLE dbo.Users ADD AuthVersion int NOT NULL CONSTRAINT DF_Users_AuthVersion DEFAULT(0);
IF OBJECT_ID('dbo.AuthChallenges','U') IS NULL
BEGIN
 CREATE TABLE dbo.AuthChallenges(
  ChallengeId varchar(36) CONSTRAINT PK_AuthChallenges PRIMARY KEY,
  Purpose varchar(16) NOT NULL,
  Email nvarchar(254) NOT NULL,
  Username nvarchar(50) NULL,
  FullName nvarchar(150) NULL,
  PasswordHash varchar(255) NULL,
  UserId int NULL CONSTRAINT FK_AuthChallenges_Users REFERENCES dbo.Users(UserId),
  CodeHash varchar(64) NOT NULL,
  CreatedAt datetime2(3) NOT NULL,
  ExpiresAt datetime2(3) NOT NULL,
  LastSentAt datetime2(3) NOT NULL,
  VerifiedAt datetime2(3) NULL,
  UsedAt datetime2(3) NULL,
  Attempts int NOT NULL CONSTRAINT DF_AuthChallenges_Attempts DEFAULT(0),
  SendCount int NOT NULL CONSTRAINT DF_AuthChallenges_SendCount DEFAULT(1),
  CONSTRAINT CK_AuthChallenges_Purpose CHECK(Purpose IN ('REGISTER','RESET')),
  CONSTRAINT CK_AuthChallenges_Attempts CHECK(Attempts>=0 AND SendCount>0),
  CONSTRAINT CK_AuthChallenges_Expiry CHECK(ExpiresAt>CreatedAt)
 );
 CREATE INDEX IX_AuthChallenges_EmailCreated ON dbo.AuthChallenges(Email,CreatedAt);
END;
COMMIT;
END TRY
BEGIN CATCH
 IF @@TRANCOUNT>0 ROLLBACK;
 THROW;
END CATCH;
