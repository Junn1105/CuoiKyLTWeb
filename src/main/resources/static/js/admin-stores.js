'use strict';

/**
 * Mộc Sách - Quản lý Hệ thống Chuỗi & Điều chuyển kho
 * File: admin-stores.js
 */

(function () {
  // Utility: context path helper
  function getBaseUrl() {
    const metaBase = document.querySelector('meta[name="base-url"]');
    if (metaBase) return metaBase.getAttribute('content') || '';
    return '';
  }

  const base = getBaseUrl();

  // Tab switching function
  window.switchStoreTab = function (tabName, e) {
    if (e && e.preventDefault) e.preventDefault();

    document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.tab-button').forEach(btn => btn.classList.remove('active'));

    const target = document.getElementById(tabName + '-section');
    if (target) {
      target.style.display = 'block';
    }

    const links = document.querySelectorAll('.tab-button');
    links.forEach(link => {
      const href = link.getAttribute('href') || '';
      if (href.includes('tab=' + tabName)) {
        link.classList.add('active');
      }
    });

    if (window.history && window.history.replaceState) {
      const currentUrl = new URL(window.location.href);
      currentUrl.searchParams.set('tab', tabName);
      window.history.replaceState(null, '', currentUrl.toString());
    }
  };
  window.showTab = window.switchStoreTab;

  // Update selected copies count badge
  window.updateSelectedCount = function () {
    const checks = document.querySelectorAll('input.copy-check:checked');
    const countMsg = document.getElementById('selectedCountMsg');
    const submitBtn = document.getElementById('submitTransferBtn');

    if (!countMsg) return;

    if (checks.length === 0) {
      countMsg.innerHTML = '<span style="color:#d97706;">⚠️ Chưa chọn cuốn sách nào (hãy tích vào ô vuông để chọn).</span>';
      if (submitBtn) submitBtn.disabled = true;
    } else {
      countMsg.innerHTML = 'Đã chọn <b style="color:#1158c5; font-size:15px;">' + checks.length + '</b> cuốn sách để điều chuyển.';
      if (submitBtn) submitBtn.disabled = false;
    }
  };

  // Toggle select all
  window.toggleSelectAll = function (master) {
    const checks = document.querySelectorAll('input.copy-check');
    checks.forEach(c => { c.checked = master.checked; });
    window.updateSelectedCount();
  };

  // Fetch copies for selected store
  window.loadAvailableCopies = function (storeId) {
    const container = document.getElementById('copiesContainer');
    const submitBtn = document.getElementById('submitTransferBtn');
    const countMsg = document.getElementById('selectedCountMsg');

    if (!container) return;

    if (!storeId || storeId === '0') {
      container.innerHTML = '<p class="hint" style="padding:16px; background:#fff; border:1px dashed #cbd5e1; border-radius:8px; text-align:center;">'
        + '👉 <strong>Bước 1:</strong> Hãy chọn <strong>Chi nhánh gửi</strong> ở trên, danh sách các cuốn sách có sẵn tại chi nhánh đó sẽ xuất hiện ngay tại đây.'
        + '</p>';
      if (submitBtn) submitBtn.style.display = 'none';
      if (countMsg) countMsg.textContent = '';
      return;
    }

    container.innerHTML = '<p class="hint" style="padding:16px; background:#eff6ff; color:#1e40af; border-radius:8px; text-align:center;">'
      + '⏳ <strong>Đang tải danh sách sách có sẵn tại chi nhánh...</strong>'
      + '</p>';

    fetch(base + '/admin/stores/api/copies?storeId=' + encodeURIComponent(storeId), {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      },
      credentials: 'same-origin'
    })
      .then(res => {
        if (!res.ok) {
          throw new Error('Máy chủ trả về mã HTTP ' + res.status);
        }
        return res.json();
      })
      .then(copies => {
        if (!copies || copies.length === 0) {
          container.innerHTML = '<p class="hint" style="padding:16px; color:#b45309; background:#fffbeb; border:1px solid #fde68a; border-radius:8px; text-align:center;">'
            + '⚠️ Chi nhánh này hiện <strong>không có bản sách nào</strong> ở trạng thái SẴN SÀNG (AVAILABLE) để điều chuyển.'
            + '</p>';
          if (submitBtn) submitBtn.style.display = 'none';
          if (countMsg) countMsg.textContent = '';
          return;
        }

        let html = '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">'
          + '<span style="font-weight:600; font-size:13.5px; color:#1e293b;">Tìm thấy <b style="color:#1158c5;">' + copies.length + '</b> cuốn sách sẵn có tại chi nhánh này:</span>'
          + '<label style="font-size:13px; cursor:pointer; color:#1158c5; font-weight:600; user-select:none;"><input type="checkbox" id="selectAllCheckbox" onchange="toggleSelectAll(this)" style="margin-right:4px;"> Chọn tất cả</label>'
          + '</div>';

        html += '<div class="copy-pick-table"><table><thead><tr>'
          + '<th style="width:40px; text-align:center;">Chọn</th>'
          + '<th>Mã bản sách</th>'
          + '<th>Tên đầu sách</th>'
          + '<th>Tình trạng</th>'
          + '<th>Vị trí kệ</th>'
          + '<th>Giá bán</th>'
          + '</tr></thead><tbody>';

        copies.forEach(cp => {
          html += '<tr>'
            + '<td style="text-align:center;"><input type="checkbox" name="copyIds" value="' + cp.copyId + '" class="copy-check" onchange="updateSelectedCount()"></td>'
            + '<td><code>' + (cp.copyCode || '') + '</code></td>'
            + '<td><strong>' + (cp.bookTitle || '') + '</strong></td>'
            + '<td><span class="status-badge ok">' + (cp.conditionName || 'Tốt') + '</span></td>'
            + '<td>' + (cp.shelfLocation || 'Chưa xếp kệ') + '</td>'
            + '<td class="price-col">' + (cp.salePriceLabel || '') + '</td>'
            + '</tr>';
        });

        html += '</tbody></table></div>';
        container.innerHTML = html;
        if (submitBtn) submitBtn.style.display = 'inline-block';
        window.updateSelectedCount();
      })
      .catch(err => {
        container.innerHTML = '<p class="hint" style="padding:16px; color:#dc2626; background:#fef2f2; border:1px solid #fca5a5; border-radius:8px;">'
          + '❌ Không thể tải danh sách sách (' + err.message + '). Vui lòng bấm nút "🔄 Tải lại sách" hoặc thử lại.'
          + '</p>';
        if (submitBtn) submitBtn.style.display = 'none';
        if (countMsg) countMsg.textContent = '';
      });
  };
  window.onFromStoreChange = window.loadAvailableCopies;

  // DOMContentLoaded initialization
  document.addEventListener('DOMContentLoaded', () => {
    // 1. Tab buttons click listeners
    document.querySelectorAll('.tab-button').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const href = btn.getAttribute('href') || '';
        const match = href.match(/tab=([a-z]+)/);
        if (match && match[1]) {
          window.switchStoreTab(match[1], e);
        }
      });
    });

    // 2. From store select dropdown listener
    const fromSelect = document.getElementById('fromStoreSelect');
    if (fromSelect) {
      fromSelect.addEventListener('change', (e) => {
        window.loadAvailableCopies(e.target.value);
      });

      // Auto-load if already selected on initial page load
      if (fromSelect.value && fromSelect.value !== '') {
        const container = document.getElementById('copiesContainer');
        // Only load via API if container does not already have server-rendered table
        if (container && !container.querySelector('table')) {
          window.loadAvailableCopies(fromSelect.value);
        } else {
          window.updateSelectedCount();
        }
      }
    }

    // 3. Form validation on transfer creation
    const transferForm = document.getElementById('createTransferForm');
    if (transferForm) {
      transferForm.addEventListener('submit', (e) => {
        const fromVal = document.getElementById('fromStoreSelect')?.value;
        const toVal = document.getElementById('toStoreSelect')?.value;
        const checks = document.querySelectorAll('input.copy-check:checked');

        if (!fromVal) {
          alert('Vui lòng chọn chi nhánh gửi sách.');
          e.preventDefault();
          return;
        }

        if (!toVal) {
          alert('Vui lòng chọn chi nhánh nhận sách.');
          e.preventDefault();
          return;
        }

        if (fromVal === toVal) {
          alert('Chi nhánh gửi và chi nhánh nhận không được trùng nhau!');
          e.preventDefault();
          return;
        }

        if (checks.length === 0) {
          alert('Vui lòng tích chọn ít nhất 1 cuốn sách để tạo phiếu điều chuyển.');
          e.preventDefault();
          return;
        }
      });
    }

    // 4. Cancel confirmation
    document.querySelectorAll('form[data-confirm-cancel]').forEach(form => {
      form.addEventListener('submit', (e) => {
        if (!confirm('Bạn có chắc chắn muốn hủy phiếu điều chuyển này không? Các bản sách sẽ được hoàn trả lại kho xuất.')) {
          e.preventDefault();
        }
      });
    });

    // 5. End staff assignment confirmation
    document.querySelectorAll('form[data-confirm-end-staff]').forEach(form => {
      form.addEventListener('submit', (e) => {
        if (!confirm('Bạn có chắc chắn muốn kết thúc nhiệm kỳ phân công của nhân viên này tại chi nhánh?')) {
          e.preventDefault();
        }
      });
    });
  });
})();
