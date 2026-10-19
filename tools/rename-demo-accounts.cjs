const fs=require('node:fs'),path=require('node:path');
const bcrypt=require(process.env.BCRYPT_MODULE || 'bcryptjs');
const root=path.resolve(__dirname,'..');
const entries=[
 ['admin','admin','Quản trị viên'],['manager1','manager','Nguyễn Đức Long'],['manager2','manager2','Trần Quốc Hùng'],['manager3','manager3','Lê Thanh Hà'],
 ['staff1','staff','Nguyễn Quốc Bảo'],['staff2','staff2','Trần Ngọc Mai'],['staff3','staff3','Lê Tuấn Anh'],['former','staff4','Phạm Minh Đức'],['lockedstaff','staff5','Đỗ Thanh Tâm'],
 ['customer1','khang','Nguyễn Minh Khang'],['customer2','hoang','Trần Hoàng'],['customer3','van','Lê Ngọc Vân'],['locked','minh','Phạm Minh'],['pending','linh','Đỗ Thùy Linh'],['empty','nam','Nguyễn Hoài Nam'],['unassigned','huy','Trần Quang Huy']
];
const configFile=path.join(root,'tools/demo-accounts.json');
let accounts=fs.existsSync(configFile)?JSON.parse(fs.readFileSync(configFile,'utf8')):null;
if(!accounts) {
 accounts=entries.map(([key,username,fullName])=>({key,username,fullName,passwordHash:bcrypt.hashSync('123456',12)}));
 fs.writeFileSync(configFile,JSON.stringify(accounts,null,2));
}
const quote=s=>"N'"+s.replaceAll("'","''")+"'";
let sql=`USE [WebsiteQuanLyCuaHangSachCu];
SET NOCOUNT ON; SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
BEGIN TRY
BEGIN TRANSACTION;
DECLARE @m TABLE(OldName nvarchar(50) COLLATE Latin1_General_100_CI_AS,NewName nvarchar(50) COLLATE Latin1_General_100_CI_AS,Email nvarchar(254) COLLATE Latin1_General_100_CI_AS,FullName nvarchar(150),PasswordHash varchar(255));
INSERT @m VALUES
${accounts.map(a=>'('+[ 'demo.'+a.key,a.username,`demo.${a.key}@example.invalid`,a.fullName,a.passwordHash].map(quote).join(',')+')').join(',\n')};
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
`;
fs.writeFileSync(path.join(root,'database/008-rename-demo-accounts.sql'),sql);
// Update fixture user INSERT values while retaining stable IDs/keys and fixture email addresses.
const seedPath=path.join(root,'database/004-seed-demo-data.sql');
let seed=fs.readFileSync(seedPath,'utf8');
for(const a of accounts){
 const re=new RegExp("VALUES \\(N'(?:demo\\."+a.key+'|'+a.username+")',N'demo\\."+a.key+"@example\\.invalid',N'[^']+',N'[^']+'");
 if(!re.test(seed)) throw Error('Missing seed user '+a.key);
 seed=seed.replace(re,()=>`VALUES (${quote(a.username)},${quote('demo.'+a.key+'@example.invalid')},${quote(a.passwordHash)},${quote(a.fullName)}`);
}
fs.writeFileSync(seedPath,seed);
const files=['README.md','docs/DuLieuMauVaTestCase.md','docs/demo-fixture-summary.json','docs/demo-actual-summary.json','docs/demo-negative-test-cases.json','tools/build-demo-negative-tests.cjs','database/004-seed-demo-data.sql','database/005-verify-demo-data.sql','database/006-test-demo-negative-cases.sql'];
for(const file of files){
 let text=fs.readFileSync(path.join(root,file),'utf8');
 for(const a of accounts) text=text.replace(new RegExp('demo\\.'+a.key+'(?![A-Za-z0-9_.@])','g'),a.username);
 text=text.replaceAll('Demo@2026!','123456');
 fs.writeFileSync(path.join(root,file),text);
}
for(const file of ['database/007-demo-scenario-queries.sql','database/export-demo-summary.sql']){
 let text=fs.readFileSync(path.join(root,file),'utf8').replaceAll("u.Username LIKE 'demo.%'","u.Email LIKE 'demo.%'").replaceAll("WHERE Username LIKE 'demo.%'","WHERE Email LIKE 'demo.%'");
 fs.writeFileSync(path.join(root,file),text);
}
console.log('Prepared account migration and updated fixture references.');

