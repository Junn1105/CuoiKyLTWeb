'use strict';
document.querySelectorAll('.password-toggle').forEach(button=>button.addEventListener('click',()=>{
 const input=document.getElementById(button.dataset.for);const visible=input.type==='password';
 input.type=visible?'text':'password';button.setAttribute('aria-pressed',String(visible));button.setAttribute('aria-label',visible?'Ẩn mật khẩu':'Hiện mật khẩu');
 if(!button.querySelector('svg'))button.textContent=visible?'Ẩn':'Hiện';
}));
const login=document.getElementById('login-form');
if(login){
 const username=document.getElementById('identifier'),remember=document.getElementById('remember-username');
 try{const saved=localStorage.getItem('mocsach.rememberedUsername');if(saved){if(!username.value)username.value=saved;remember.checked=true;}}catch{}
 remember.addEventListener('change',()=>{if(!remember.checked){try{localStorage.removeItem('mocsach.rememberedUsername');}catch{}}});
 login.addEventListener('submit',()=>{try{if(remember.checked)localStorage.setItem('mocsach.rememberedUsername',username.value.trim());else localStorage.removeItem('mocsach.rememberedUsername');}catch{}});
}
document.querySelectorAll('[data-confirm-password]').forEach(form=>{
 const password=form.elements.password,confirmation=form.elements.confirmPassword;
 const check=()=>confirmation.setCustomValidity(confirmation.value&&password.value!==confirmation.value?'Hai mật khẩu chưa trùng khớp.':'');
 password.addEventListener('input',check);confirmation.addEventListener('input',check);
});
document.querySelectorAll('form').forEach(form=>form.addEventListener('submit',()=>{
 const button=form.querySelector('button[type="submit"]');if(button){button.disabled=true;button.dataset.original=button.innerHTML;button.textContent='Đang xử lý…';}
}));
window.addEventListener('pageshow',()=>document.querySelectorAll('button[data-original]').forEach(b=>{b.innerHTML=b.dataset.original;b.disabled=false;delete b.dataset.original;}));
const resend=document.querySelector('[data-resend-seconds]');
if(resend){let seconds=Number(resend.dataset.resendSeconds)||0;const status=document.querySelector('.countdown');
 const tick=()=>{resend.disabled=seconds>0;status.textContent=seconds>0?`(${seconds}s)`:'';seconds--;};tick();const timer=setInterval(()=>{tick();if(seconds<0)clearInterval(timer);},1000);
}
