'use strict';
document.querySelectorAll('[data-password]').forEach(button => {
  button.addEventListener('click', () => {
    const field = document.getElementById(button.dataset.password);
    const visible = field.type === 'password';
    field.type = visible ? 'text' : 'password';
    button.textContent = visible ? 'Ẩn' : 'Hiện';
    button.setAttribute('aria-pressed', String(visible));
  });
});
