/* Generates SQL Server demo fixtures from the inspected catalog; no DB writes here. */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const bcrypt = require(process.env.BCRYPT_MODULE || 'bcryptjs');
const root = path.resolve(__dirname, '..');
const catalog = JSON.parse(fs.readFileSync(path.join(root, 'database/before-demo-catalog.json'), 'utf8').replace(/^\uFEFF/, ''));
const schema = JSON.parse(fs.readFileSync(path.join(root, 'database/before-demo-schema.json'), 'utf8').replace(/^\uFEFF/, ''));
const out = [], data = {}, matrix = [];
const raw = sql => ({sql});
const q = v => v === null ? 'NULL' : v && typeof v === 'object' ? v.sql : typeof v === 'number' ? String(v) : typeof v === 'boolean' ? (v ? '1' : '0') : "N'" + String(v).replaceAll("'", "''") + "'";
const time = minute => raw(`DATEADD(minute,${minute},@asof)`);
const day = n => n * 1440;
const ref = (table, key) => raw(`@${table}_${String(key).replace(/[^a-zA-Z0-9]/g, '_')}`);
const idColumns = Object.fromEntries(schema.Columns.filter(c => c.is_identity).map(c => [c.TableName,c.ColumnName]));
function add(table, key, fields) {
  const columns = schema.Columns.filter(c => c.TableName === table);
  if (columns.some(c => c.ColumnName === 'CreatedAt') && !('CreatedAt' in fields)) fields.CreatedAt=time(day(-65));
  if (columns.some(c => c.ColumnName === 'UpdatedAt') && !('UpdatedAt' in fields)) fields.UpdatedAt=fields.CreatedAt || time(day(-65));
  const id = idColumns[table];
  out.push(`INSERT dbo.[${table}] (${Object.keys(fields).map(c => `[${c}]`).join(',')}) VALUES (${Object.values(fields).map(q).join(',')});`);
  if (id) out.push(`DECLARE ${ref(table,key).sql} ${columns.find(c => c.ColumnName===id).DataType}=SCOPE_IDENTITY();`);
  (data[table] ||= []).push({key,fields});
  return ref(table,key);
}
function update(table,key,fields) {
  out.push(`UPDATE dbo.[${table}] SET ${Object.entries(fields).map(([k,v])=>`[${k}]=${q(v)}`).join(',')} WHERE [${idColumns[table]}]=${ref(table,key).sql};`);
}
const password='123456';
const accountConfig=Object.fromEntries(JSON.parse(fs.readFileSync(path.join(root,'tools/demo-accounts.json'),'utf8')).map(a=>[a.key,a]));
const accounts = [
 ['admin','ACTIVE','Quản trị mẫu'],['manager1','ACTIVE','Quản lý chi nhánh 1'],['manager2','ACTIVE','Quản lý chi nhánh 2'],['manager3','ACTIVE','Quản lý chi nhánh 3'],
 ['staff1','ACTIVE','Nhân viên chi nhánh 1'],['staff2','ACTIVE','Nhân viên chi nhánh 2'],['staff3','ACTIVE','Nhân viên chi nhánh 3'],
 ['former','ACTIVE','Nhân viên đã nghỉ'],['lockedstaff','LOCKED','Nhân viên bị khóa'],
 ['customer1','ACTIVE','Nguyễn An mẫu'],['customer2','ACTIVE','Trần Bình mẫu'],['customer3','ACTIVE','Lê Chi mẫu'],
 ['locked','LOCKED','Khách hàng bị khóa'],['pending','PENDING','Khách hàng chờ duyệt'],['empty','ACTIVE','Khách hàng mới'],['unassigned','ACTIVE','Tài khoản chưa phân quyền']
];
for (const [key,status,name] of accounts) {
 const account=accountConfig[key];
 if (!account) throw Error('Missing account configuration '+key);
 add('Users',key,{Username:account.username,Email:`demo.${key}@example.invalid`,PasswordHash:account.passwordHash,FullName:account.fullName,Phone:null,Status:status});
 if (key==='admin') add('UserRoles','admin',{UserId:ref('Users',key),RoleId:raw("(SELECT RoleId FROM dbo.Roles WHERE RoleCode='ADMIN')"),AssignedAt:time(day(-64))});
 if (['admin','customer1','customer2','customer3','locked','pending','empty'].includes(key)) add('UserRoles',key+'_customer',{UserId:ref('Users',key),RoleId:raw("(SELECT RoleId FROM dbo.Roles WHERE RoleCode='CUSTOMER')"),AssignedAt:time(day(-64))});
}
const stores = [[1,'ACTIVE','Kho sách mẫu Thủ Đức'],[2,'ACTIVE','Kho sách mẫu Bình Thạnh'],[3,'ACTIVE','Kho sách mẫu Quận 7'],[4,'TEMPORARILY_CLOSED','Chi nhánh mẫu tạm nghỉ'],[5,'CLOSED','Chi nhánh mẫu đã đóng']];
for (const [key,status,name] of stores) add('Stores',key,{StoreCode:`DEMO-S${key}`,StoreName:name,Address:`Địa chỉ giả lập chi nhánh ${key}, TP. Hồ Chí Minh`,Phone:null,Status:status,OpenedAt:'2025-01-01'});
for (let s=1;s<=3;s++) for (const role of ['MANAGER','STAFF']) add('StaffStoreAssignments',`${role}${s}`,{UserId:ref('Users',role.toLowerCase()+s),StoreId:ref('Stores',s),StoreRole:role,StartAt:time(day(-64)),EndAt:null,Status:'ACTIVE'});
add('StaffStoreAssignments','former',{UserId:ref('Users','former'),StoreId:ref('Stores',1),StoreRole:'STAFF',StartAt:time(day(-64)),EndAt:time(day(-20)),Status:'ENDED'});
add('StaffStoreAssignments','locked',{UserId:ref('Users','lockedstaff'),StoreId:ref('Stores',2),StoreRole:'STAFF',StartAt:time(day(-64)),EndAt:null,Status:'ACTIVE'});
for (const [i,u,def] of [[1,'customer1',true],[2,'customer1',false],[3,'customer2',true],[4,'customer3',true],[5,'locked',true]]) add('CustomerAddresses',i,{UserId:ref('Users',u),RecipientName:`Người nhận mẫu ${i}`,Phone:'0000000000',AddressLine:`Địa chỉ kiểm thử ${i} (không giao hàng)`,AdministrativeArea:'TP. Hồ Chí Minh',PostalCode:i===2?null:'700000',CountryCode:'VN',IsDefault:def});
for (const [key,type,status,user] of [[1,'INDIVIDUAL','ACTIVE','customer1'],[2,'INDIVIDUAL','ACTIVE',null],[3,'ORGANIZATION','ACTIVE',null],[4,'ORGANIZATION','INACTIVE',null]]) add('Suppliers',key,{SupplierType:type,SupplierName:`DEMO - Nguồn thu mua ${key}`,Phone:key===2?null:'0000000000',Email:key===2?null:`supplier${key}@example.invalid`,Address:key===2?null:'Địa chỉ thu mua giả lập',LinkedUserId:user?ref('Users',user):null,Status:status});
const cond = ['LIKE_NEW','GOOD','FAIR','WORN'];
const condition = code => raw(`(SELECT ConditionId FROM dbo.BookConditions WHERE ConditionCode='${code}')`);
const copies={};
for (let s=1;s<=3;s++) {
 add('PurchaseReceipts',s,{ReceiptCode:`DEMO-IN-${s}`,SupplierId:ref('Suppliers',s),StoreId:ref('Stores',s),CreatedBy:ref('Users','staff'+s),Status:'RECEIVED',TotalAmount:0,ReceivedAt:time(day(-59)),CreatedAt:time(day(-60)),UpdatedAt:time(day(-59)),Note:'Lô sách mẫu phục vụ kiểm thử, không phải tồn kho thực tế.'});
 let total=0;
 catalog.Books.forEach((book,i)=>{
  const key=`${s}_${i}`, cost=(s===1 && i===20)?0:20000+(i%8)*5000, price=(s===1 && i===20)?0:cost+30000+(s-1)*5000, co=cond[(i+s-1)%4];
  total+=cost;
  add('PurchaseReceiptItems',key,{ReceiptId:ref('PurchaseReceipts',s),BookId:book.BookId,ConditionId:condition(co),Quantity:1,UnitCost:cost,Note:i%4===0?'Bản mẫu có ghi chú tình trạng':null});
  add('BookCopies',key,{CopyCode:`DEMO-C${s}-${String(i+1).padStart(3,'0')}`,BookId:book.BookId,StoreId:ref('Stores',s),ConditionId:condition(co),PurchaseReceiptItemId:ref('PurchaseReceiptItems',key),CostPrice:cost,SalePrice:price,ConditionNotes:i%4===0?'Mẫu: có ghi chú bằng bút chì ở trang đầu':null,ShelfLocation:`S${s}-K${Math.floor(i/10)+1}`,Status:'AVAILABLE',Version:0,CreatedAt:time(day(-59)),UpdatedAt:time(day(-59))});
  add('InventoryMovements','in_'+key,{CopyId:ref('BookCopies',key),FromStoreId:null,ToStoreId:ref('Stores',s),MovementType:'RECEIPT',OccurredAt:time(day(-59)),ActorId:ref('Users','staff'+s),ReceiptItemId:ref('PurchaseReceiptItems',key),Reason:'DEMO: nhận sách vào kho',OperationKey:'DEMO-RECEIPT-'+key});
  copies[key]={key,book,cost,price,cond:co,store:s};
 });
 update('PurchaseReceipts',s,{TotalAmount:total});
}
for (const [key,status] of [[4,'DRAFT'],[5,'CANCELLED']]) {
 add('PurchaseReceipts',key,{ReceiptCode:`DEMO-IN-${key}`,SupplierId:ref('Suppliers',2),StoreId:ref('Stores',1),CreatedBy:ref('Users','staff1'),Status:status,TotalAmount:90000,ReceivedAt:null,CreatedAt:time(day(-2)),UpdatedAt:time(day(-1)),Note:status==='DRAFT'?'Chưa nhận hàng':'Hủy trước khi nhận hàng'});
 for (let i=0;i<2;i++) add('PurchaseReceiptItems',`${key}_${i}`,{ReceiptId:ref('PurchaseReceipts',key),BookId:catalog.Books[i].BookId,ConditionId:condition('GOOD'),Quantity:3,UnitCost:15000,Note:null});
}
const specs=[
 ['POS-CASH','POS','COMPLETED',[0,1],-35,'CASH','customer1',5000,0],
 ['PARTIAL-RETURN','ONLINE','COMPLETED',[2],-30,'BANK_TRANSFER','customer1',0,20000],
 ['DAMAGED-RETURN','ONLINE','COMPLETED',[3],-29,'E_WALLET','customer2',0,20000],
 ['RETURN-REQUESTED','ONLINE','COMPLETED',[4],-28,'CARD','customer3',0,20000],
 ['RETURN-REJECTED','ONLINE','COMPLETED',[5],-27,'COD','customer1',0,20000],
 ['RETURN-APPROVED','ONLINE','COMPLETED',[6],-26,'BANK_TRANSFER','customer2',0,20000],
 ['RETURN-CANCELLED','ONLINE','COMPLETED',[7],-25,'CARD','customer3',0,20000],
 ['HOLD-ACTIVE','ONLINE','PENDING',[8],0,'CARD','customer1',0,20000],
 ['CONFIRMED','ONLINE','CONFIRMED',[9],0,'BANK_TRANSFER','customer2',0,20000],
 ['PROCESSING','ONLINE','PROCESSING',[10],0,'E_WALLET','customer3',0,20000],
 ['SHIPPED-COD','ONLINE','SHIPPED',[11],-2,'COD','customer1',0,20000],
 ['EXPIRED','ONLINE','CANCELLED',[12],-2,'CARD','customer2',0,20000],
 ['CANCELLED','ONLINE','CANCELLED',[13],-3,'BANK_TRANSFER','customer3',0,20000],
 ['PAYMENT-RETRY','ONLINE','COMPLETED',[14],-20,'E_WALLET','customer3',0,20000],
 ['PAID-CANCELLED','ONLINE','CANCELLED',[15],-19,'CARD','customer1',0,20000],
 ['RESALE','POS','COMPLETED',[2],-10,'CASH','customer2',0,0],
 ['GUEST','POS','COMPLETED',[16],-15,'CASH',null,0,0],
 ['REFUND-RETRY','ONLINE','COMPLETED',[17,18],-18,'BANK_TRANSFER','customer1',0,20000],
 ['REFUND-CANCELLED-RETRY','ONLINE','COMPLETED',[19],-17,'CARD','customer2',0,20000],
 ['FREE','POS','COMPLETED',[20],-14,null,'customer3',0,0],
 ['HOLD-OVERDUE','ONLINE','PENDING',[21],0,'CARD','customer1',0,20000],
 ['SHIPPING','ONLINE','COMPLETED',[22],-12,'COD','customer2',0,30000],
 ['MULTI-HOLD','ONLINE','PENDING',[23,24],0,'E_WALLET','customer3',0,20000],
 ['POS-CANCELLED','POS','CANCELLED',[25],-11,'CASH',null,0,0],
 ['ZERO-RETURN-QUOTE','ONLINE','COMPLETED',[26],-9,'BANK_TRANSFER','customer1',0,20000],
 ['CANCELLED-REFUND-PENDING','ONLINE','CANCELLED',[27],-8,'CARD','customer2',0,20000],
 ['HISTORY-NULLS','POS','COMPLETED',[28],-7,'CASH',null,0,0]
];
const orders={};
function saleMovement(o,idx,minute) {
 add('InventoryMovements',`sale_${o.key}_${idx}`,{CopyId:ref('BookCopies','1_'+idx),FromStoreId:ref('Stores',1),ToStoreId:null,MovementType:'SALE',OccurredAt:time(minute),ActorId:ref('Users','staff1'),OrderItemId:ref('OrderItems',`${o.key}_${idx}`),Reason:'DEMO: xuất bán',OperationKey:`DEMO-SALE-${o.key}-${idx}`});
 update('BookCopies','1_'+idx,{Status:'SOLD',Version:raw('Version+1'),UpdatedAt:time(minute)});
}
for (const [key,channel,status,items,age,method,customer,discount,shipping] of specs) {
 const start=age===0?-20:day(age), step=age===0?5:60;
 const subtotal=items.reduce((n,i)=>n+copies['1_'+i].price,0), total=subtotal-discount+shipping;
 const o=orders[key]={key,channel,status,items,start,method,customer,subtotal,total,discount,shipping};
 add('Orders',key,{OrderCode:'DEMO-'+key,StoreId:ref('Stores',1),CustomerId:customer?ref('Users',customer):null,CreatedBy:channel==='POS'?ref('Users','staff1'):null,Channel:channel,Status:status,RecipientName:channel==='ONLINE'?'Người nhận kiểm thử':null,RecipientPhone:channel==='ONLINE'?'0000000000':null,ShippingAddressSnapshot:channel==='ONLINE'?'Địa chỉ giả lập tại TP. Hồ Chí Minh — không giao hàng':null,Subtotal:subtotal,DiscountAmount:discount,ShippingFee:shipping,TotalAmount:total,Version:1,CreatedAt:time(start),UpdatedAt:time(start+step)});
 let chain=['PENDING'];
 if (status==='CANCELLED') { if (key.includes('PAID')||key==='CANCELLED-REFUND-PENDING') chain.push('CONFIRMED'); chain.push('CANCELLED'); }
 else if (status!=='PENDING') {
  const full=channel==='ONLINE'?['CONFIRMED','PROCESSING','SHIPPED','COMPLETED']:['CONFIRMED','COMPLETED'];
  chain.push(...full.slice(0,full.indexOf(status)+1));
 }
 o.end=start+(chain.length-1)*step;
 chain.forEach((st,i)=>add('OrderStatusHistory',`${key}_${i}`,{OrderId:ref('Orders',key),FromStatus:i?chain[i-1]:null,ToStatus:st,ChangedBy:key==='EXPIRED'?null:channel==='POS'?ref('Users','staff1'):ref('Users',i===0?customer:'staff1'),ChangedAt:time(start+i*step),Reason:`DEMO: ${key} / ${st}`}));
 update('Orders',key,{UpdatedAt:time(o.end),Version:chain.length-1});
 items.forEach((idx,i)=>{
  const c=copies['1_'+idx], lineDiscount=i===0?discount:0;
  add('OrderItems',`${key}_${idx}`,{OrderId:ref('Orders',key),CopyId:ref('BookCopies',c.key),BookTitleSnapshot:c.book.Title,ConditionSnapshot:c.cond,UnitPrice:c.price,UnitCostSnapshot:c.cost,DiscountAmount:lineDiscount,LineTotal:c.price-lineDiscount});
  if (channel==='ONLINE') {
   const hold=['PENDING','CONFIRMED','PROCESSING'].includes(status), rs=hold?'ACTIVE':status==='CANCELLED'?(key==='EXPIRED'?'EXPIRED':'CANCELLED'):'CONSUMED';
   const expiry=key==='HOLD-OVERDUE'?-5:hold?30:rs==='EXPIRED'?start+15:start+1440;
   const release=rs==='EXPIRED'?start+15:Math.max(start+10,o.end);
   add('StockReservations',`${key}_${idx}`,{CopyId:ref('BookCopies',c.key),OrderId:ref('Orders',key),Status:rs,ReservedAt:time(start),ExpiresAt:time(expiry),ReleasedAt:hold?null:time(release)});
   if (hold) update('BookCopies',c.key,{Status:'RESERVED',Version:raw('Version+1'),UpdatedAt:time(start)});
  }
  if (['COMPLETED','SHIPPED'].includes(status)) saleMovement(o,idx,channel==='ONLINE'?start+3*step:o.end);
 });
 if (method) {
  let ps=status==='CANCELLED'?(key==='EXPIRED'?'FAILED':key.includes('PAID')||key==='CANCELLED-REFUND-PENDING'?'SUCCEEDED':'CANCELLED'):status==='PENDING'||key==='SHIPPED-COD'?'PENDING':'SUCCEEDED';
  if (key==='PAYMENT-RETRY') add('Payments',key+'_failed',{OrderId:ref('Orders',key),Method:method,Provider:'DEMO_GATEWAY',Amount:total,Currency:'VND',Status:'FAILED',ProviderTransactionId:'DEMO-FAILED-'+key,IdempotencyKey:'DEMO-PAY-FAILED-'+key,PaidAt:null,CreatedAt:time(start+1)});
  const paid=method==='COD'?o.end:start+step;
  add('Payments',key,{OrderId:ref('Orders',key),Method:method,Provider:method==='CASH'?'DEMO_CASH':'DEMO_GATEWAY',Amount:total,Currency:'VND',Status:ps,ProviderTransactionId:ps==='PENDING'?null:'DEMO-TXN-'+key,IdempotencyKey:'DEMO-PAY-'+key,PaidAt:ps==='SUCCEEDED'?time(paid):null,CreatedAt:time(key==='PAYMENT-RETRY'?start+2:start)});
 }
 matrix.push({code:'DEMO-'+key,kind:'Order',status,description:key,copyCodes:items.map(i=>'DEMO-C1-'+String(i+1).padStart(3,'0'))});
}
// Returns occur after completion. A returned copy can subsequently be sold again.
const returns=[
 ['PARTIAL-RETURN','COMPLETED','ACCEPTED','RESTOCK',0.5],['DAMAGED-RETURN','COMPLETED','ACCEPTED','DAMAGED',1],
 ['RETURN-REQUESTED','REQUESTED','PENDING',null,1],['RETURN-REJECTED','REJECTED','REJECTED',null,0],
 ['RETURN-APPROVED','APPROVED','PENDING',null,1],['RETURN-CANCELLED','CANCELLED','REJECTED',null,0],
 ['REFUND-RETRY','COMPLETED','ACCEPTED','RESTOCK',1],['REFUND-CANCELLED-RETRY','COMPLETED','ACCEPTED','RESTOCK',1],
 ['ZERO-RETURN-QUOTE','REQUESTED','PENDING',null,0]
];
function refund(key,order,returnKey,amount,status,minute) {
 add('Refunds',key,{ReturnId:returnKey?ref('SalesReturns',returnKey):null,PaymentId:ref('Payments',order.key),OrderId:ref('Orders',order.key),Amount:amount,Reason:'DEMO: '+key,Status:status,Provider:order.method==='CASH'?'DEMO_CASH':'DEMO_GATEWAY',ProviderRefundId:status==='PENDING'?null:'DEMO-RF-TXN-'+key,IdempotencyKey:'DEMO-REFUND-'+key,RefundedAt:status==='SUCCEEDED'?time(minute+30):null,CreatedAt:time(minute)});
}
for (const [key,status,itemStatus,resolution,ratio] of returns) {
 const o=orders[key],idx=o.items[0],c=copies['1_'+idx],at=o.start+day(3),amount=c.price*ratio;
 add('SalesReturns',key,{OrderId:ref('Orders',key),ReceivingStoreId:ref('Stores',1),Status:status,RequestedBy:ref('Users',o.customer),ProcessedBy:status==='REQUESTED'?null:ref('Users','staff1'),Reason:'DEMO: '+key,CreatedAt:time(at),ApprovedAt:['APPROVED','COMPLETED'].includes(status)?time(at+60):null});
 add('SalesReturnItems',key,{ReturnId:ref('SalesReturns',key),OrderId:ref('Orders',key),OrderItemId:ref('OrderItems',`${key}_${idx}`),ReceivedConditionId:itemStatus==='ACCEPTED'?condition(resolution==='DAMAGED'?'WORN':c.cond):null,Resolution:resolution,RefundAmount:amount,Status:itemStatus});
 if (itemStatus==='ACCEPTED') {
  add('InventoryMovements','return_'+key,{CopyId:ref('BookCopies',c.key),FromStoreId:null,ToStoreId:ref('Stores',1),MovementType:'RETURN',OccurredAt:time(at+120),ActorId:ref('Users','staff1'),OrderItemId:ref('OrderItems',`${key}_${idx}`),ReturnItemId:ref('SalesReturnItems',key),Reason:'DEMO: nhận lại sách',OperationKey:'DEMO-RETURN-'+key});
  // PARTIAL-RETURN was subsequently resold by DEMO-RESALE; preserve its latest state.
  if (key!=='PARTIAL-RETURN') update('BookCopies',c.key,{Status:resolution==='DAMAGED'?'DAMAGED':'AVAILABLE',ConditionId:condition(resolution==='DAMAGED'?'WORN':c.cond),Version:raw('Version+1'),UpdatedAt:time(at+120)});
  if (key==='REFUND-RETRY') { refund(key+'_failed',o,key,amount,'FAILED',at+180); refund(key+'_pending',o,key,amount,'PENDING',at+240); }
  else if (key==='REFUND-CANCELLED-RETRY') { refund(key+'_cancelled',o,key,amount,'CANCELLED',at+180); refund(key+'_success',o,key,amount,'SUCCEEDED',at+240); }
  else refund(key,o,key,amount,'SUCCEEDED',at+180);
 }
}
refund('PAID-CANCELLED',orders['PAID-CANCELLED'],null,orders['PAID-CANCELLED'].total,'SUCCEEDED',orders['PAID-CANCELLED'].end+60);
refund('CANCELLED-REFUND-PENDING',orders['CANCELLED-REFUND-PENDING'],null,orders['CANCELLED-REFUND-PENDING'].total,'PENDING',orders['CANCELLED-REFUND-PENDING'].end+60);
for (const [key,status,indices] of [['DRAFT','DRAFT',[30]],['APPROVED','APPROVED',[31]],['TRANSIT','IN_TRANSIT',[32]],['RECEIVED','RECEIVED',[33,34,35]],['CANCELLED','CANCELLED',[36]]]) {
 const shipped=['IN_TRANSIT','RECEIVED'].includes(status);
 add('StockTransfers',key,{TransferCode:'DEMO-TRANSFER-'+key,FromStoreId:ref('Stores',1),ToStoreId:ref('Stores',2),Status:status,RequestedBy:ref('Users','staff1'),ApprovedBy:['APPROVED','IN_TRANSIT','RECEIVED'].includes(status)?ref('Users','manager1'):null,ShippedAt:shipped?time(day(-5)):null,ReceivedAt:status==='RECEIVED'?time(day(-4)):null,CreatedAt:time(day(-6)),UpdatedAt:time(status==='RECEIVED'?day(-4):day(-5))});
 for (const idx of indices) {
  const c=copies['1_'+idx],receipt=idx===33?'RECEIVED':idx===34?'DAMAGED':idx===35?'MISSING':'PENDING';
  add('StockTransferItems',idx,{TransferId:ref('StockTransfers',key),CopyId:ref('BookCopies',c.key),SentConditionId:condition(c.cond),ReceivedConditionId:['RECEIVED','DAMAGED'].includes(receipt)?condition(receipt==='DAMAGED'?'WORN':c.cond):null,ReceiptStatus:receipt,Note:receipt==='MISSING'?'DEMO: thất lạc trên đường chuyển':receipt==='DAMAGED'?'DEMO: hỏng khi vận chuyển':null});
  if (shipped) {
   add('InventoryMovements','transferout_'+idx,{CopyId:ref('BookCopies',c.key),FromStoreId:ref('Stores',1),ToStoreId:ref('Stores',2),MovementType:'TRANSFER_OUT',OccurredAt:time(day(-5)),ActorId:ref('Users','staff1'),TransferItemId:ref('StockTransferItems',idx),Reason:'DEMO: xuất điều chuyển',OperationKey:'DEMO-TRANSFER-OUT-'+idx});
   update('BookCopies',c.key,{Status:receipt==='MISSING'?'LOST':'IN_TRANSIT',Version:raw('Version+1'),UpdatedAt:time(day(-5))});
  }
  if (['RECEIVED','DAMAGED'].includes(receipt)) {
   add('InventoryMovements','transferin_'+idx,{CopyId:ref('BookCopies',c.key),FromStoreId:ref('Stores',1),ToStoreId:ref('Stores',2),MovementType:'TRANSFER_IN',OccurredAt:time(day(-4)),ActorId:ref('Users','staff2'),TransferItemId:ref('StockTransferItems',idx),Reason:'DEMO: nhận điều chuyển',OperationKey:'DEMO-TRANSFER-IN-'+idx});
   update('BookCopies',c.key,{StoreId:ref('Stores',2),Status:receipt==='DAMAGED'?'DAMAGED':'AVAILABLE',ConditionId:condition(receipt==='DAMAGED'?'WORN':c.cond),ShelfLocation:'S2-KHANGCHUYEN',Version:raw('Version+1'),UpdatedAt:time(day(-4))});
  }
 }
}
const stocktakeSpecs=[['OLD','FINALIZED',1,-13],['FINAL','FINALIZED',1,-3],['DRAFT','DRAFT',2,-1],['COUNTING','COUNTING',3,0],['CANCELLED','CANCELLED',2,-2]];
for (const [key,status,s,age] of stocktakeSpecs) {
 const start=age===0?-60:day(age);
 add('Stocktakes',key,{StoreId:ref('Stores',s),Status:status,StartedAt:status==='DRAFT'?null:time(start+10),FinalizedAt:status==='FINALIZED'?time(start+60):null,CreatedBy:ref('Users','staff'+s),ApprovedBy:status==='FINALIZED'?ref('Users','manager'+s):null,CreatedAt:time(start)});
 let items=key==='OLD'?[[40,true,false,null,'LOST']]:key==='FINAL'?[[37,true,false,null,'LOST'],[38,true,true,'WORN','DAMAGED'],[39,true,true,copies['1_39'].cond,null],[40,false,true,copies['1_40'].cond,'AVAILABLE']]:key==='COUNTING'?[[1,true,null,null,null],[2,true,true,copies['3_2'].cond,null],[3,true,false,null,null]]:[[1,true,null,null,null]];
 for (const [idx,expected,actual,co,state] of items) {
  const c=copies[s+'_'+idx];
  add('StocktakeItems',key+'_'+idx,{StocktakeId:ref('Stocktakes',key),CopyId:ref('BookCopies',c.key),ExpectedPresent:expected,ActualPresent:actual,ActualConditionId:co?condition(co):null,DifferenceReason:state?'DEMO: '+(state==='AVAILABLE'?'Tìm lại cuốn đã ghi thất lạc':state==='LOST'?'Thiếu khi kiểm kê':'Phát hiện hư hỏng'):null});
  if (state) {
   add('InventoryMovements','adjust_'+key+'_'+idx,{CopyId:ref('BookCopies',c.key),FromStoreId:state==='AVAILABLE'?null:ref('Stores',s),ToStoreId:state==='LOST'?null:ref('Stores',s),MovementType:'ADJUSTMENT',OccurredAt:time(start+60),ActorId:ref('Users','manager'+s),StocktakeItemId:ref('StocktakeItems',key+'_'+idx),Reason:'DEMO: điều chỉnh kiểm kê '+state,OperationKey:`DEMO-ADJUST-${key}-${idx}`});
   update('BookCopies',c.key,{Status:state,ConditionId:condition(co||c.cond),Version:raw('Version+1'),UpdatedAt:time(start+60)});
  }
 }
}
for (const [key,u,s,status,items] of [['A','customer1',1,'ACTIVE',[41,42]],['B','customer2',1,'ACTIVE',[41]],['C','customer1',2,'ACTIVE',[1]],['DONE','customer3',1,'CHECKED_OUT',[14]],['ABANDONED','customer1',1,'ABANDONED',[43]],['EMPTY','empty',3,'ACTIVE',[]],['STALE','customer3',1,'ACTIVE',[0]]]) {
 const at=key==='DONE'?orders['PAYMENT-RETRY'].start-60:-30;
 add('Carts',key,{UserId:ref('Users',u),StoreId:ref('Stores',s),Status:status,CreatedAt:time(at),UpdatedAt:time(key==='DONE'?orders['PAYMENT-RETRY'].start:at)});
 for (const idx of items) add('CartItems',key+'_'+idx,{CartId:ref('Carts',key),CopyId:ref('BookCopies',`${s}_${idx}`),AddedAt:time(at)});
}
// Real existing files, or an explicit fallback; no invented photos of a physical copy.
for (const book of catalog.Books) {
 const exists=book.CoverImage && fs.existsSync(path.join(root,'src/main/resources/static',book.CoverImage));
 add('MediaAssets','book_'+book.BookId,{Provider:'LOCAL',Url:exists?book.CoverImage:'/images/book-placeholder.svg',PublicId:null,ResourceType:'image',Format:exists?'jpg':'svg',Width:exists?null:400,Height:exists?null:560,AltText:exists?'Bìa '+book.Title:'Ảnh dự phòng: '+book.Title,SortOrder:0,IsPrimary:true,BookId:book.BookId});
}
for (const author of catalog.Authors.filter(a=>a.AuthorPhoto)) add('MediaAssets','author_'+author.AuthorId,{Provider:'LOCAL',Url:author.AuthorPhoto,Format:'jpg',AltText:author.AuthorName,SortOrder:0,IsPrimary:true,AuthorId:author.AuthorId});
for (let i=41;i<=44;i++) add('MediaAssets','copy_'+i,{Provider:'LOCAL',Url:'/images/book-placeholder.svg',Format:'svg',Width:400,Height:560,AltText:'DEMO: ảnh dự phòng cuốn sách, chưa có ảnh chụp thực tế',SortOrder:0,IsPrimary:true,CopyId:ref('BookCopies','1_'+i)});
add('MediaAssets','avatar',{Provider:'LOCAL',Url:'/images/demo-avatar.svg',Format:'svg',Width:160,Height:160,AltText:'Avatar tài khoản mẫu',SortOrder:0,IsPrimary:true,UserId:ref('Users','customer1')});
add('MediaAssets','missing',{Provider:'LOCAL',Url:'/images/demo-intentionally-missing.jpg',Format:'jpg',AltText:'DEMO: ảnh cố ý không tồn tại để kiểm thử fallback',SortOrder:1,IsPrimary:false,CopyId:ref('BookCopies','1_44')});
add('MediaAssets','cloud',{Provider:'CLOUDINARY',Url:'https://res.cloudinary.com/demo/image/upload/sample.jpg',PublicId:'sample',ResourceType:'image',Format:'jpg',AltText:'DEMO: tài nguyên Cloudinary công khai, không phải ảnh sách hay người dùng',SortOrder:1,IsPrimary:false,UserId:ref('Users','customer1')});
// Raw refresh secrets intentionally never stored; these hashes are fixture data only.
const family=crypto.randomUUID();
for (const [key,created,expires,revoked,fam] of [['active',-60,day(7),null,crypto.randomUUID()],['expired',day(-8),day(-1),null,crypto.randomUUID()],['revoked',day(-3),day(4),day(-1),crypto.randomUUID()],['rotated',day(-2),day(5),day(-1),family],['replacement',day(-1),day(6),null,family]]) add('RefreshTokens',key,{UserId:ref('Users','customer1'),TokenHash:raw('0x'+crypto.createHash('sha256').update(crypto.randomBytes(32)).digest('hex')),FamilyId:fam,CreatedAt:time(created),ExpiresAt:time(expires),RevokedAt:revoked===null?null:time(revoked),ReplacedByTokenId:null});
update('RefreshTokens','rotated',{ReplacedByTokenId:ref('RefreshTokens','replacement')});
for (const [i,type,u,s,read] of [[1,'ORDER','customer1',1,true],[2,'PAYMENT','customer2',1,false],[3,'RETURN','customer3',1,false],[4,'TRANSFER','manager2',2,true],[5,'STOCK_ALERT','staff1',1,false],[6,'SYSTEM','admin',null,false]]) add('Notifications',i,{UserId:ref('Users',u),StoreId:s?ref('Stores',s):null,Type:type,Title:`Thông báo mẫu ${type}`,Content:'DEMO: thông báo phục vụ kiểm thử danh sách, Unicode và trạng thái đã đọc/chưa đọc.',TargetUrl:type==='SYSTEM'?null:'/account/notifications',CreatedAt:time(-120),ReadAt:read?time(-60):null});
for (const [i,action,actor] of [[1,'ORDER_CREATE','staff1'],[2,'PAYMENT_CALLBACK',null],[3,'STOCK_TRANSFER','manager1'],[4,'LOGIN_REJECTED','locked'],[5,'TOKEN_ROTATE','customer1']]) add('AuditLogs',i,{ActorId:actor?ref('Users',actor):null,StoreId:i===5?null:ref('Stores',1),Action:action,EntityType:i===5?'RefreshTokens':'DemoScenario',EntityId:i===5?raw(`CONVERT(varchar(100),${ref('RefreshTokens','replacement').sql})`):String(i),Summary:'DEMO: nhật ký mẫu '+action,CreatedAt:time(-30),CorrelationId:crypto.randomUUID()});
add('AuditLogs','marker',{ActorId:ref('Users','admin'),StoreId:null,Action:'DEMO_SEED_V1',EntityType:'DemoDataset',EntityId:'v1',Summary:'DEMO: bộ dữ liệu mẫu v1; CreatedAt là mốc UTC để kiểm thử thời gian.',CreatedAt:raw('@asof'),CorrelationId:crypto.randomUUID()});

const counts=Object.fromEntries(schema.Tables.map(t=>[t.TableName,t.TotalRows+(data[t.TableName]?.length||0)]));
fs.writeFileSync(path.join(root,'docs/demo-expected-counts.json'),JSON.stringify(counts,null,2));
fs.writeFileSync(path.join(root,'docs/demo-scenarios.json'),JSON.stringify(matrix,null,2));
const checks=[];
function assert(name,query) { checks.push(`IF EXISTS (${query}) THROW 51210, ${q(name)}, 1;\nPRINT ${q('PASS: '+name)};`); }
for (const [t,n] of Object.entries(counts)) assert('Rows '+t,`SELECT 1 WHERE (SELECT COUNT_BIG(*) FROM dbo.[${t}])<>${n}`);
const coverage={Users:{Status:['ACTIVE','LOCKED','PENDING']},Stores:{Status:['ACTIVE','TEMPORARILY_CLOSED','CLOSED']},StaffStoreAssignments:{Status:['ACTIVE','ENDED'],StoreRole:['MANAGER','STAFF']},Suppliers:{Status:['ACTIVE','INACTIVE'],SupplierType:['INDIVIDUAL','ORGANIZATION']},PurchaseReceipts:{Status:['DRAFT','RECEIVED','CANCELLED']},BookCopies:{Status:['AVAILABLE','RESERVED','SOLD','IN_TRANSIT','DAMAGED','LOST']},MediaAssets:{Provider:['LOCAL','CLOUDINARY']},StockTransfers:{Status:['DRAFT','APPROVED','IN_TRANSIT','RECEIVED','CANCELLED']},StockTransferItems:{ReceiptStatus:['PENDING','RECEIVED','MISSING','DAMAGED']},Stocktakes:{Status:['DRAFT','COUNTING','FINALIZED','CANCELLED']},Carts:{Status:['ACTIVE','CHECKED_OUT','ABANDONED']},Orders:{Status:['PENDING','CONFIRMED','PROCESSING','SHIPPED','COMPLETED','CANCELLED'],Channel:['ONLINE','POS']},StockReservations:{Status:['ACTIVE','CONSUMED','EXPIRED','CANCELLED']},Payments:{Status:['PENDING','SUCCEEDED','FAILED','CANCELLED'],Method:['CASH','BANK_TRANSFER','CARD','E_WALLET','COD']},SalesReturns:{Status:['REQUESTED','APPROVED','COMPLETED','REJECTED','CANCELLED']},SalesReturnItems:{Status:['PENDING','ACCEPTED','REJECTED'],Resolution:['RESTOCK','DAMAGED']},Refunds:{Status:['PENDING','SUCCEEDED','FAILED','CANCELLED']},InventoryMovements:{MovementType:['RECEIPT','SALE','TRANSFER_OUT','TRANSFER_IN','RETURN','ADJUSTMENT']}};
for (const [t,cols] of Object.entries(coverage)) for (const [c,vals] of Object.entries(cols)) assert('Coverage '+t+'.'+c,`SELECT value FROM (VALUES ${vals.map(v=>'('+q(v)+')').join(',')}) e(value) EXCEPT SELECT [${c}] FROM dbo.[${t}]`);
assert('Receipt totals',`SELECT r.ReceiptId FROM dbo.PurchaseReceipts r JOIN dbo.PurchaseReceiptItems i ON i.ReceiptId=r.ReceiptId WHERE r.ReceiptCode LIKE 'DEMO-%' GROUP BY r.ReceiptId,r.TotalAmount HAVING r.TotalAmount<>SUM(i.Quantity*i.UnitCost)`);
assert('Received quantities and no stock for drafts',`SELECT i.ReceiptItemId FROM dbo.PurchaseReceiptItems i JOIN dbo.PurchaseReceipts r ON r.ReceiptId=i.ReceiptId OUTER APPLY(SELECT COUNT(*) n FROM dbo.BookCopies c WHERE c.PurchaseReceiptItemId=i.ReceiptItemId)x WHERE r.ReceiptCode LIKE 'DEMO-%' AND x.n<>CASE WHEN r.Status='RECEIVED' THEN i.Quantity ELSE 0 END`);
assert('Order totals versus lines',`SELECT o.OrderId FROM dbo.Orders o JOIN dbo.OrderItems i ON i.OrderId=o.OrderId WHERE o.OrderCode LIKE 'DEMO-%' GROUP BY o.OrderId,o.Subtotal,o.DiscountAmount,o.TotalAmount,o.ShippingFee HAVING o.Subtotal<>SUM(i.UnitPrice) OR o.DiscountAmount<>SUM(i.DiscountAmount) OR o.TotalAmount<>SUM(i.LineTotal)+o.ShippingFee`);
assert('Successful payments reconcile',`SELECT o.OrderId FROM dbo.Orders o OUTER APPLY(SELECT COALESCE(SUM(p.Amount),0) amount FROM dbo.Payments p WHERE p.OrderId=o.OrderId AND p.Status='SUCCEEDED')x WHERE o.OrderCode LIKE 'DEMO-%' AND (x.amount>o.TotalAmount OR (o.Status='COMPLETED' AND x.amount<>o.TotalAmount))`);
assert('Refund amounts bounded by successful payments',`SELECT p.PaymentId FROM dbo.Payments p JOIN dbo.Refunds r ON r.PaymentId=p.PaymentId WHERE r.IdempotencyKey LIKE 'DEMO-%' AND r.Status IN ('PENDING','SUCCEEDED') GROUP BY p.PaymentId,p.Status,p.Amount HAVING p.Status<>'SUCCEEDED' OR SUM(r.Amount)>p.Amount`);
assert('Return line amounts bounded',`SELECT r.ReturnItemId FROM dbo.SalesReturnItems r JOIN dbo.OrderItems i ON i.OrderItemId=r.OrderItemId WHERE r.RefundAmount>i.LineTotal`);
assert('Refunds tied to accepted return value',`SELECT r.ReturnId FROM dbo.SalesReturns r CROSS APPLY(SELECT COALESCE(SUM(x.RefundAmount),0) amount FROM dbo.SalesReturnItems x WHERE x.ReturnId=r.ReturnId AND x.Status='ACCEPTED')a CROSS APPLY(SELECT COALESCE(SUM(x.Amount),0) amount FROM dbo.Refunds x WHERE x.ReturnId=r.ReturnId AND x.Status IN ('SUCCEEDED','PENDING'))b WHERE b.amount>a.amount`);
assert('Reserved copies and active reservations agree',`SELECT c.CopyId FROM dbo.BookCopies c OUTER APPLY(SELECT COUNT(*) n FROM dbo.StockReservations r WHERE r.CopyId=c.CopyId AND r.Status='ACTIVE')x WHERE c.CopyCode LIKE 'DEMO-%' AND ((c.Status='RESERVED' AND x.n<>1) OR (c.Status<>'RESERVED' AND x.n<>0))`);
assert('Last order history matches current status',`SELECT o.OrderId FROM dbo.Orders o OUTER APPLY(SELECT TOP(1) h.ToStatus FROM dbo.OrderStatusHistory h WHERE h.OrderId=o.OrderId ORDER BY h.ChangedAt DESC,h.HistoryId DESC)x WHERE o.OrderCode LIKE 'DEMO-%' AND (x.ToStatus IS NULL OR x.ToStatus<>o.Status)`);
assert('Order history chain and timestamps',`SELECT OrderId FROM (SELECT h.*,LAG(ToStatus) OVER(PARTITION BY OrderId ORDER BY ChangedAt,HistoryId) previous FROM dbo.OrderStatusHistory h)x WHERE (previous IS NULL AND FromStatus IS NOT NULL) OR (previous IS NOT NULL AND (FromStatus IS NULL OR FromStatus<>previous))`);
assert('Transfer receipt state matches copies',`SELECT c.CopyId FROM dbo.StockTransferItems i JOIN dbo.StockTransfers t ON t.TransferId=i.TransferId JOIN dbo.BookCopies c ON c.CopyId=i.CopyId WHERE t.TransferCode LIKE 'DEMO-%' AND ((t.Status='IN_TRANSIT' AND c.Status<>'IN_TRANSIT') OR (i.ReceiptStatus='RECEIVED' AND (c.StoreId<>t.ToStoreId OR c.Status<>'AVAILABLE')) OR (i.ReceiptStatus='DAMAGED' AND (c.StoreId<>t.ToStoreId OR c.Status<>'DAMAGED')) OR (i.ReceiptStatus='MISSING' AND c.Status<>'LOST'))`);
assert('Receipt movement for every seeded copy',`SELECT c.CopyId FROM dbo.BookCopies c WHERE c.CopyCode LIKE 'DEMO-%' AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.CopyId=c.CopyId AND m.MovementType='RECEIPT' AND m.ReceiptItemId=c.PurchaseReceiptItemId)`);
assert('Sale movement for each fulfilled order line',`SELECT i.OrderItemId FROM dbo.OrderItems i JOIN dbo.Orders o ON o.OrderId=i.OrderId WHERE o.OrderCode LIKE 'DEMO-%' AND o.Status IN ('SHIPPED','COMPLETED') AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.OrderItemId=i.OrderItemId AND m.MovementType='SALE')`);
assert('Return movement for every accepted return line',`SELECT i.ReturnItemId FROM dbo.SalesReturnItems i WHERE i.Status='ACCEPTED' AND NOT EXISTS(SELECT 1 FROM dbo.InventoryMovements m WHERE m.ReturnItemId=i.ReturnItemId AND m.MovementType='RETURN')`);
assert('Latest movement and copy disposition',`SELECT c.CopyId FROM dbo.BookCopies c CROSS APPLY(SELECT TOP(1) m.* FROM dbo.InventoryMovements m WHERE m.CopyId=c.CopyId ORDER BY m.OccurredAt DESC,m.MovementId DESC)m WHERE c.CopyCode LIKE 'DEMO-%' AND ((m.MovementType='SALE' AND c.Status<>'SOLD') OR (m.MovementType='TRANSFER_OUT' AND c.Status NOT IN ('IN_TRANSIT','LOST')) OR (m.MovementType IN ('RECEIPT','RETURN','TRANSFER_IN') AND c.Status NOT IN ('AVAILABLE','RESERVED','DAMAGED')))`);
assert('Finalized stocktakes fully counted',`SELECT i.StocktakeItemId FROM dbo.StocktakeItems i JOIN dbo.Stocktakes s ON s.StocktakeId=i.StocktakeId WHERE s.Status='FINALIZED' AND i.ActualPresent IS NULL`);
assert('No disabled or untrusted constraints',`SELECT 1 FROM sys.foreign_keys WHERE is_disabled=1 OR is_not_trusted=1 UNION ALL SELECT 1 FROM sys.check_constraints WHERE is_disabled=1 OR is_not_trusted=1`);
assert('Active and overdue hold fixtures at seed time',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.StockReservations WHERE Status='ACTIVE' AND ExpiresAt>@seedAsOf) OR NOT EXISTS(SELECT 1 FROM dbo.StockReservations WHERE Status='ACTIVE' AND ExpiresAt<@seedAsOf)`);
assert('Token expiry revocation and rotation coverage',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ExpiresAt>@seedAsOf AND RevokedAt IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ExpiresAt<@seedAsOf) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE RevokedAt IS NOT NULL AND ReplacedByTokenId IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.RefreshTokens WHERE ReplacedByTokenId IS NOT NULL)`);
assert('Read and unread notifications',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Notifications WHERE ReadAt IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.Notifications WHERE ReadAt IS NOT NULL)`);
assert('Expired reservations released after expiration',`SELECT ReservationId FROM dbo.StockReservations WHERE Status='EXPIRED' AND ReleasedAt<ExpiresAt`);
assert('Cancelled orders have released holds by cancellation',`SELECT r.ReservationId FROM dbo.StockReservations r JOIN dbo.Orders o ON o.OrderId=r.OrderId WHERE o.Status='CANCELLED' AND (r.ReleasedAt IS NULL OR r.ReleasedAt>o.UpdatedAt)`);
assert('Payment retry follows failed attempt',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Payments f JOIN dbo.Payments s ON s.OrderId=f.OrderId WHERE f.IdempotencyKey='DEMO-PAY-FAILED-PAYMENT-RETRY' AND s.IdempotencyKey='DEMO-PAY-PAYMENT-RETRY' AND f.CreatedAt<s.CreatedAt)`);
assert('Every catalog title represented at each initial branch',`SELECT b.BookId,s.StoreId FROM dbo.Books b CROSS JOIN dbo.Stores s WHERE s.StoreCode IN ('DEMO-S1','DEMO-S2','DEMO-S3') AND NOT EXISTS(SELECT 1 FROM dbo.BookCopies c JOIN dbo.PurchaseReceiptItems i ON i.ReceiptItemId=c.PurchaseReceiptItemId JOIN dbo.PurchaseReceipts r ON r.ReceiptId=i.ReceiptId WHERE c.BookId=b.BookId AND r.StoreId=s.StoreId)`);
assert('Return occurs after sale',`SELECT r.ReturnId FROM dbo.SalesReturns r JOIN dbo.Orders o ON o.OrderId=r.OrderId WHERE r.CreatedAt<o.UpdatedAt OR o.Status<>'COMPLETED'`);
assert('Empty cart fixture and empty customer history',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Carts c JOIN dbo.Users u ON u.UserId=c.UserId WHERE u.Username='nam' AND NOT EXISTS(SELECT 1 FROM dbo.CartItems i WHERE i.CartId=c.CartId)) OR EXISTS(SELECT 1 FROM dbo.Orders o JOIN dbo.Users u ON u.UserId=o.CustomerId WHERE u.Username='nam')`);
assert('Guest and zero amount order fixtures',`SELECT 1 WHERE NOT EXISTS(SELECT 1 FROM dbo.Orders WHERE OrderCode='DEMO-GUEST' AND CustomerId IS NULL) OR NOT EXISTS(SELECT 1 FROM dbo.Orders o WHERE o.OrderCode='DEMO-FREE' AND o.TotalAmount=0 AND NOT EXISTS(SELECT 1 FROM dbo.Payments p WHERE p.OrderId=o.OrderId))`);
const verifier=`-- Read-only verification of the pristine DEMO v1 fixture. Counts intentionally fail after business data changes.\nSET NOCOUNT ON;\nDECLARE @seedAsOf datetime2(3)=(SELECT MAX(CreatedAt) FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1' AND EntityType='DemoDataset');\nIF @seedAsOf IS NULL THROW 51211, 'Demo seed marker not found.', 1;\n${checks.join('\n')}\nPRINT 'All ${checks.length} demo coverage and consistency checks passed.';\n`;
fs.writeFileSync(path.join(root,'database/005-verify-demo-data.sql'),'USE [WebsiteQuanLyCuaHangSachCu];\n'+verifier);
const settings=`USE [WebsiteQuanLyCuaHangSachCu];\nSET NOCOUNT ON; SET XACT_ABORT ON; SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON; SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON; SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;`;
const guard=`BEGIN TRY\nBEGIN TRANSACTION;\nDECLARE @lock int;\nEXEC @lock=sys.sp_getapplock @Resource=N'DEMO_SEED_V1',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;\nIF @lock<0 THROW 51200,'Cannot lock demo seed.',1;\nIF EXISTS(SELECT 1 FROM dbo.AuditLogs WHERE Action='DEMO_SEED_V1' AND EntityType='DemoDataset')\nBEGIN COMMIT TRANSACTION; PRINT 'DEMO v1 already installed; no data changed.'; RETURN; END;\nIF EXISTS(SELECT 1 FROM dbo.Users WHERE Email LIKE 'demo.%') OR EXISTS(SELECT 1 FROM dbo.Stores WHERE StoreCode LIKE 'DEMO-%') OR EXISTS(SELECT 1 FROM dbo.Orders WHERE OrderCode LIKE 'DEMO-%')\n THROW 51201,'Demo namespace is already in use; inspect before seeding.',1;\nDECLARE @asof datetime2(3)=SYSUTCDATETIME();`;
fs.writeFileSync(path.join(root,'database/004-seed-demo-data.sql'),`-- Generated demo-only dataset. Existing catalog remains unchanged.\n-- Password: 123456; BCrypt cost 12. Raw refresh tokens are not issued.\n${settings}\n${guard}\n${out.join('\n')}\n${verifier}\nCOMMIT TRANSACTION;\nPRINT 'DEMO v1 committed.';\nEND TRY\nBEGIN CATCH\n IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;\n THROW;\nEND CATCH;\n`);
fs.writeFileSync(path.join(root,'docs/demo-fixture-summary.json'),JSON.stringify({generatedAt:new Date().toISOString(),seedVersion:'v1',newRows:Object.fromEntries(Object.entries(data).map(([k,v])=>[k,v.length])),totalNewRows:Object.values(data).reduce((n,v)=>n+v.length,0),checks:checks.length,accounts:accounts.map(([name,status])=>({username:accountConfig[name].username,status})),coverage},null,2));
console.log(JSON.stringify({tablesPopulated:Object.keys(data).length,rows:Object.values(data).reduce((n,v)=>n+v.length,0),checks:checks.length}));

