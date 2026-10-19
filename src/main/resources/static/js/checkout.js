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
