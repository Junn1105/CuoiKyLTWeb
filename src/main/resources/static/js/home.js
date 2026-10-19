document.querySelectorAll('[data-cover]').forEach(image=>{
 const fallback=()=>{if(!image.dataset.fallback){image.dataset.fallback='true';image.src=document.body.dataset.base+'/images/book-placeholder.svg';}};
 image.addEventListener('error',fallback);if(image.complete&&image.naturalWidth===0)fallback();
});
const toast=document.getElementById('toast');let toastTimer;
if(toast){
 if(!toast.hidden)toastTimer=setTimeout(()=>toast.hidden=true,4500);
 document.querySelectorAll('[data-soon]').forEach(button=>button.addEventListener('click',()=>{
  toast.querySelector('span').textContent=button.dataset.soon+' sẽ sớm được mở. Bạn tiếp tục khám phá sách nhé!';toast.hidden=false;clearTimeout(toastTimer);toastTimer=setTimeout(()=>toast.hidden=true,4500);
 }));
 toast.querySelector('button').addEventListener('click',()=>{toast.hidden=true;clearTimeout(toastTimer);});
}
document.querySelectorAll('[data-notif-menu]').forEach(menu=>{
 const toggle=menu.querySelector('[data-notif-toggle]'),dropdown=menu.querySelector('[data-notif-dropdown]');
 if(!toggle||!dropdown)return;
 const close=()=>{dropdown.hidden=true;toggle.setAttribute('aria-expanded','false');toggle.classList.remove('active');};
 toggle.addEventListener('click',e=>{
  e.stopPropagation();
  const open=dropdown.hidden;
  document.querySelectorAll('[data-notif-dropdown]').forEach(d=>d.hidden=true);
  document.querySelectorAll('[data-notif-toggle]').forEach(b=>{b.setAttribute('aria-expanded','false');b.classList.remove('active');});
  dropdown.hidden=!open;
  toggle.setAttribute('aria-expanded',String(open));
  toggle.classList.toggle('active',open);
 });
 dropdown.addEventListener('click',e=>e.stopPropagation());
 menu.querySelectorAll('[data-notif-filter]').forEach(tab=>tab.addEventListener('click',()=>{
  const mode=tab.dataset.notifFilter;
  menu.querySelectorAll('[data-notif-filter]').forEach(t=>t.classList.toggle('active',t===tab));
  let visible=0;
  menu.querySelectorAll('.notif-item-form').forEach(item=>{
   const show=mode!=='unread'||item.dataset.unread==='true';
   item.hidden=!show;
   if(show)visible++;
  });
  const emptyUnread=menu.querySelector('[data-notif-empty-unread]');
  if(emptyUnread)emptyUnread.hidden=!(mode==='unread'&&visible===0);
 }));
 document.addEventListener('click',close);
 document.addEventListener('keydown',e=>{if(e.key==='Escape')close();});
});

