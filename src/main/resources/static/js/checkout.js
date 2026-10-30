document.querySelectorAll('[data-payment-card]').forEach(card=>{
 const radio=card.querySelector('input[type="radio"]');
 if(!radio)return;
 radio.addEventListener('change',()=>{
  document.querySelectorAll('[data-payment-card]').forEach(c=>c.classList.toggle('selected',c.contains(radio)&&radio.checked));
 });
});
document.querySelectorAll('[data-print-invoice]').forEach(btn=>{
 btn.addEventListener('click',()=>window.print());
});
document.querySelectorAll('[data-confirm-cancel]').forEach(form=>{
 form.addEventListener('submit',e=>{
  if(!window.confirm('Bạn có chắc chắn muốn hủy đơn hàng này không?'))e.preventDefault();
 });
});
document.querySelectorAll('[data-confirm-received]').forEach(form=>{
 form.addEventListener('submit',e=>{
  if(!window.confirm('Bạn xác nhận đã nhận được đầy đủ sách và muốn chuyển trạng thái đơn hàng sang Đã giao thành công?'))e.preventDefault();
 });
});

const countdownBox=document.getElementById('qr-countdown-box');
const timerEl=document.getElementById('countdown-timer');
if(countdownBox&&timerEl){
 let remaining=parseInt(countdownBox.dataset.remaining,10);
 if(isNaN(remaining))remaining=0;
 function updateDisplay(){
  if(remaining<=0){
   timerEl.textContent='00:00 (Hết giờ)';
   timerEl.style.color='#dc2626';
   setTimeout(()=>{window.location.reload();},1200);
   return;
  }
  const mins=Math.floor(remaining/60);
  const secs=remaining%60;
  timerEl.textContent=String(mins).padStart(2,'0')+':'+String(secs).padStart(2,'0');
  remaining--;
 }
 updateDisplay();
 const interval=setInterval(()=>{
  if(remaining<0){clearInterval(interval);return;}
  updateDisplay();
 },1000);
}

const qrPanel=document.querySelector('.qr-checkout-panel');
if(qrPanel){
 const orderId=qrPanel.dataset.orderId;
 const orderStatus=qrPanel.dataset.orderStatus;
 const base=document.body.dataset.base||'';

 if(orderId&&orderStatus==='PENDING'){
  let isRedirecting=false;
  let userInteracting=false;

  document.querySelectorAll('[data-confirm-cancel]').forEach(form=>{
   form.addEventListener('submit',()=>{
    userInteracting=true;
    setTimeout(()=>{userInteracting=false;},2000);
   });
  });

  const pollStatus=async()=>{
   if(isRedirecting||userInteracting)return;
   try{
    const res=await fetch(base+'/checkout/qr/'+orderId+'/status',{
     headers:{'Accept':'application/json'},
     cache:'no-store'
    });
    if(!res.ok)return;
    const data=await res.json();

    if(data.shouldRedirect){
     isRedirecting=true;
     const notice=document.getElementById('qr-auto-check-notice');
     if(notice){
      notice.style.background='#ecfdf5';
      notice.style.borderColor='#a7f3d0';
      notice.style.color='#065f46';
      notice.innerHTML='<span style="font-size:16px;">✓</span> <strong>Thanh toán thành công!</strong> Đơn hàng đã được '+(data.status==='PROCESSING'?'chuẩn bị hàng':'xác nhận')+'. Đang chuyển đến chi tiết đơn hàng...';
     }
     setTimeout(()=>{
      const target=data.redirectUrl.startsWith('/')?data.redirectUrl:('/'+data.redirectUrl);
      window.location.replace(base+target);
     },900);
     return;
    }

    if(data.isCancelled){
     isRedirecting=true;
     window.location.reload();
    }
   }catch(err){
    // Retry on next cycle
   }
  };

  const statusTimer=setInterval(pollStatus,5000);
  window.addEventListener('beforeunload',()=>{
   clearInterval(statusTimer);
  });
 }
}
