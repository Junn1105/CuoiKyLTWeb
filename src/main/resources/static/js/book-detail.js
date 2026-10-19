'use strict';
const quantity = document.getElementById('quantity');
const quantityButtons = document.querySelectorAll('[data-quantity]');
function normalizeQuantity() {
  const maximum = Number(quantity.max);
  const value = Math.max(1, Math.min(maximum, Math.trunc(Number(quantity.value) || 1)));
  quantity.value = String(value);
  quantityButtons.forEach(button => {button.disabled = quantity.disabled || (Number(button.dataset.quantity) < 0 ? value <= 1 : value >= maximum);});
  return value;
}
quantityButtons.forEach(button => button.addEventListener('click', () => {
  quantity.value = String(normalizeQuantity() + Number(button.dataset.quantity));
  normalizeQuantity();
}));
quantity.addEventListener('change', normalizeQuantity);
normalizeQuantity();
const purchaseForm = document.getElementById('purchase-form');
if (purchaseForm) {
  purchaseForm.addEventListener('submit', () => { normalizeQuantity(); });
}
