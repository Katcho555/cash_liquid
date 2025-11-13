function initUXFeatures() {
  /* ===== SIDEBAR MOBILE ===== */
  const sidebar = document.getElementById('uxSidebar');
  const toggle = document.getElementById('uxToggleSidebar');
  const closeBtn = document.getElementById('uxCloseSidebar');
  const overlay = document.getElementById('uxOverlay');

  function openSidebar() {
    sidebar?.classList.add('show');
    overlay?.classList.add('show');
  }

  function closeSidebar() {
    sidebar?.classList.remove('show');
    overlay?.classList.remove('show');
  }

  if (toggle) toggle.addEventListener('click', openSidebar);
  if (closeBtn) closeBtn.addEventListener('click', closeSidebar);
  if (overlay) overlay.addEventListener('click', closeSidebar);

  /* Fermer auto après clic sur lien (mobile) */
  document.querySelectorAll('.ux-nav-link').forEach(link => {
    link.addEventListener('click', () => {
      const parent = link.parentElement;
      if (window.innerWidth < 992 && !parent.classList.contains('has-dropdown')) {
        closeSidebar();
      }
    });
  });

  /* ===== DROPDOWNS ===== */
  document.querySelectorAll('.ux-nav-item.has-dropdown > a').forEach(item => {
    // on clone l'élément pour supprimer les anciens listeners
    const newItem = item.cloneNode(true);
    item.replaceWith(newItem);

    newItem.addEventListener('click', function (e) {
      e.preventDefault();
      this.parentElement.classList.toggle('open');
    });
  });

  /* ===== THEME SOMBRE PERSISTANT ===== */
  const themeToggle = document.getElementById('uxThemeToggle');
  const body = document.body;

  if (themeToggle) {
    if (localStorage.getItem('ux-theme') === 'dark') {
      body.classList.add('ux-dark');
      themeToggle.checked = true;
    }

    themeToggle.addEventListener('change', () => {
      if (themeToggle.checked) {
        body.classList.add('ux-dark');
        localStorage.setItem('ux-theme', 'dark');
      } else {
        body.classList.remove('ux-dark');
        localStorage.setItem('ux-theme', 'light');
      }
    });
  }

  /* ===== COMPTES ANIMÉS ===== */
  document.querySelectorAll('.ux-card-val[data-target]').forEach(el => {
    const target = parseInt(el.dataset.target);
    let current = 0;
    const inc = target / (1200 / 16);
    const timer = setInterval(() => {
      current += inc;
      if (current >= target) { current = target; clearInterval(timer); }
      el.textContent = Math.floor(current).toLocaleString() + (el.textContent.includes('FCFA') ? ' FCFA' : '');
    }, 16);
  });

  /* ===== POPUP BIENVENUE ===== */
  const modal = document.getElementById('uxWelcomeModal');
  const closeWelcome = document.getElementById('uxCloseWelcome');
  if (modal && closeWelcome) {
    modal.classList.add('show');
    closeWelcome.addEventListener('click', () => {
      modal.classList.remove('show');
    });
  }

  /* ===== COPIE CODE PARRAINAGE ===== */
  const copyBtn = document.getElementById('copyBtn');
  const referralCode = document.getElementById('referralCode');

  if (copyBtn && referralCode) {
    copyBtn.replaceWith(copyBtn.cloneNode(true));
    const newCopyBtn = document.getElementById('copyBtn');

    newCopyBtn.addEventListener('click', function () {
      const code = referralCode.textContent.trim();

      navigator.clipboard.writeText(code)
        .then(() => {
          newCopyBtn.innerHTML = '<i class="fas fa-check"></i>';
          newCopyBtn.classList.add('btn-success');
          newCopyBtn.classList.remove('btn-light');

          setTimeout(() => {
            newCopyBtn.innerHTML = '<i class="fas fa-copy"></i>';
            newCopyBtn.classList.add('btn-light');
            newCopyBtn.classList.remove('btn-success');
          }, 2000);
        })
        .catch(err => console.error('Erreur de copie :', err));
    });
  }
}

document.addEventListener('turbo:load', initUXFeatures);
document.addEventListener('DOMContentLoaded', initUXFeatures);
