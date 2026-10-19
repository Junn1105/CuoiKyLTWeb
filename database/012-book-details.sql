USE [WebsiteQuanLyCuaHangSachCu];
SET XACT_ABORT ON;
IF COL_LENGTH('dbo.Books','Translator') IS NULL
 ALTER TABLE dbo.Books ADD Translator nvarchar(250) NULL;
