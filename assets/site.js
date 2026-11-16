/* ==========================================================================
   Toghrul Aghabalazada portfolio - shared interactions for every language page.
   Plain JS, no dependencies. Loaded with `defer`; every feature degrades to the
   static page if a browser API is missing or the visitor prefers reduced motion.
   ========================================================================== */
(function () {
  'use strict';

  window.siteReady = true; // tells the <head> safety timer not to un-hide content

  var doc = document;
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  var finePointer = window.matchMedia('(hover: hover) and (pointer: fine)');
  var raf = window.requestAnimationFrame.bind(window);
  var hasIO = 'IntersectionObserver' in window;

  function $(sel, ctx) { return (ctx || doc).querySelector(sel); }
  function $$(sel, ctx) { return Array.prototype.slice.call((ctx || doc).querySelectorAll(sel)); }
  function clamp(v, min, max) { return Math.min(max, Math.max(min, v)); }
  function onMediaChange(mq, fn) {
    if (mq.addEventListener) mq.addEventListener('change', fn); else mq.addListener(fn);
  }

  /* ---- Theme: light / dark ------------------------------------------------
     The <head> bootstrap already set data-theme before first paint. Until the
     visitor picks a theme it follows the OS/browser; a pick is remembered. */
  var root = doc.documentElement;
  var THEME_KEY = 'theme';
  var THEME_COLORS = { light: '#0D2B75', dark: '#0A1122' };
  var systemDark = window.matchMedia('(prefers-color-scheme: dark)');
  var themeMeta = $('meta[name="theme-color"]');
  var themeToggles = $$('[data-theme-toggle]');

  function storedTheme() {
    try {
      var t = localStorage.getItem(THEME_KEY);
      return t === 'light' || t === 'dark' ? t : null;
    } catch (e) { return null; }
  }
  function currentTheme() { return root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light'; }
  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
    root.style.colorScheme = theme;
    if (themeMeta) themeMeta.setAttribute('content', THEME_COLORS[theme]);
    themeToggles.forEach(function (btn) {
      // the label names the action, so it points at the other theme
      var label = btn.getAttribute(theme === 'dark' ? 'data-label-light' : 'data-label-dark');
      if (!label) return;
      btn.setAttribute('aria-label', label);
      btn.setAttribute('title', label);
    });
  }
  function switchTheme(theme, origin) {
    if (theme === currentTheme()) return;
    if (!doc.startViewTransition || reduceMotion.matches) { applyTheme(theme); return; }
    // circular reveal from the toggle that was pressed
    var x = origin ? origin.x : window.innerWidth;
    var y = origin ? origin.y : 0;
    var r = Math.hypot(Math.max(x, window.innerWidth - x), Math.max(y, window.innerHeight - y));
    root.style.setProperty('--vt-x', x + 'px');
    root.style.setProperty('--vt-y', y + 'px');
    root.style.setProperty('--vt-r', Math.ceil(r) + 'px');
    doc.startViewTransition(function () { applyTheme(theme); });
  }

  applyTheme(currentTheme());
  themeToggles.forEach(function (btn) {
    btn.addEventListener('click', function () {
      var next = currentTheme() === 'dark' ? 'light' : 'dark';
      try { localStorage.setItem(THEME_KEY, next); } catch (e) { /* private mode: still switch */ }
      var r = btn.getBoundingClientRect();
      switchTheme(next, { x: r.left + r.width / 2, y: r.top + r.height / 2 });
    });
  });
  onMediaChange(systemDark, function (e) {
    if (!storedTheme()) switchTheme(e.matches ? 'dark' : 'light');
  });

  /* ---- Menus: mobile navigation + language dropdowns --------------------- */
  var menuBtn = $('#mobile-menu-btn');
  var mobileMenu = $('#mobile-menu');
  var langMenus = [
    { btn: $('#lang-menu-btn'), menu: $('#lang-menu-dropdown') },
    { btn: $('#mobile-lang-menu-btn'), menu: $('#mobile-lang-menu-dropdown') }
  ].filter(function (p) { return p.btn && p.menu; });

  function isOpen(menu) { return !menu.classList.contains('hidden'); }
  function setOpen(btn, menu, open) {
    menu.classList.toggle('hidden', !open);
    btn.setAttribute('aria-expanded', String(open));
  }
  function closeLangMenus(except) {
    langMenus.forEach(function (p) { if (p !== except) setOpen(p.btn, p.menu, false); });
  }
  function closeMobileMenu() {
    if (menuBtn && mobileMenu) setOpen(menuBtn, mobileMenu, false);
  }

  if (menuBtn && mobileMenu) {
    menuBtn.addEventListener('click', function () {
      var open = !isOpen(mobileMenu);
      closeLangMenus();
      setOpen(menuBtn, mobileMenu, open);
    });
    $$('a', mobileMenu).forEach(function (link) { link.addEventListener('click', closeMobileMenu); });
    onMediaChange(window.matchMedia('(min-width: 1024px)'), function (e) { if (e.matches) closeMobileMenu(); });
  }

  langMenus.forEach(function (p) {
    p.btn.addEventListener('click', function (e) {
      e.stopPropagation();
      var open = !isOpen(p.menu);
      closeLangMenus(p);
      if (open) closeMobileMenu();
      setOpen(p.btn, p.menu, open);
    });
  });

  doc.addEventListener('click', function (e) {
    if (!e.target.closest('#lang-dropdown-wrapper, #mobile-lang-dropdown-wrapper')) closeLangMenus();
    if (mobileMenu && isOpen(mobileMenu) && !e.target.closest('#mobile-menu, #mobile-menu-btn')) closeMobileMenu();
  });

  doc.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    langMenus.forEach(function (p) {
      if (isOpen(p.menu)) { setOpen(p.btn, p.menu, false); p.btn.focus(); }
    });
    if (mobileMenu && isOpen(mobileMenu)) { closeMobileMenu(); menuBtn.focus(); }
  });

  /* ---- Scroll reveal ------------------------------------------------------ */
  var revealEls = $$('.reveal');
  if (!hasIO || reduceMotion.matches) {
    revealEls.forEach(function (el) { el.classList.add('active'); });
  } else {
    var revealIO = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('active');
        revealIO.unobserve(entry.target);
      });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0 }); // threshold 0: tall stacked grids on phones reveal as soon as they enter
    revealEls.forEach(function (el) { revealIO.observe(el); });
  }

  /* ---- Stat counters (100+, 10 yrs, 4 langs) ------------------------------ */
  function digitsNode(el) {
    var walker = doc.createTreeWalker(el, NodeFilter.SHOW_TEXT);
    var node;
    while ((node = walker.nextNode())) { if (/\d/.test(node.nodeValue)) return node; }
    return null;
  }
  function countUp(el) {
    var node = digitsNode(el);
    if (!node) return;
    var target = parseInt(node.nodeValue.match(/\d+/)[0], 10);
    var duration = 1600;
    var start = null;
    function frame(now) {
      if (start === null) start = now;
      var p = clamp((now - start) / duration, 0, 1);
      var eased = 1 - Math.pow(1 - p, 4);
      node.nodeValue = node.nodeValue.replace(/\d+/, String(Math.round(target * eased)));
      if (p < 1) raf(frame);
    }
    node.nodeValue = node.nodeValue.replace(/\d+/, '0');
    raf(frame);
  }
  var counters = $$('[data-countup]');
  if (counters.length && hasIO && !reduceMotion.matches) {
    var countIO = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        countUp(entry.target);
        countIO.unobserve(entry.target);
      });
    }, { threshold: 0.6 });
    counters.forEach(function (el) { countIO.observe(el); });
  }

  /* ---- Scroll-spy: highlight the nav link of the section in view ---------- */
  var navLinks = $$('.nav-link').concat($$('#mobile-menu a[href^="#"]'));
  function setActiveSection(id) {
    navLinks.forEach(function (a) {
      var match = id && a.getAttribute('href') === '#' + id;
      a.classList.toggle('is-active', !!match);
      if (match) a.setAttribute('aria-current', 'location'); else a.removeAttribute('aria-current');
    });
  }
  if (navLinks.length && hasIO) {
    var spyIO = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) setActiveSection(entry.target.id);
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    $$('main > section').forEach(function (section) { spyIO.observe(section); });
  }

  /* ---- Cursor spotlight on cards (Fluent "reveal highlight") -------------- */
  if (finePointer.matches && !reduceMotion.matches) {
    var spotCard = null;
    var spotX = 0;
    var spotY = 0;
    var spotQueued = false;
    doc.addEventListener('pointermove', function (e) {
      var card = e.target.closest && e.target.closest('.glass-panel');
      if (!card) return;
      spotCard = card;
      spotX = e.clientX;
      spotY = e.clientY;
      if (spotQueued) return;
      spotQueued = true;
      raf(function () {
        spotQueued = false;
        var r = spotCard.getBoundingClientRect();
        spotCard.style.setProperty('--mx', (spotX - r.left).toFixed(1) + 'px');
        spotCard.style.setProperty('--my', (spotY - r.top).toFixed(1) + 'px');
      });
    }, { passive: true });
  }

  /* ---- Floating WhatsApp button ------------------------------------------- */
  var waSource = $('#contact a[href^="https://wa.me/"]');
  var fab = null;
  if (waSource) {
    var waLabel = $('.min-w-0 > span', waSource);
    var waIcon = $('svg', waSource);
    var labelText = (waLabel && waLabel.textContent.trim()) || 'WhatsApp';
    fab = doc.createElement('a');
    fab.className = 'fab-wa';
    fab.href = waSource.href;
    fab.target = '_blank';
    fab.rel = 'noopener noreferrer';
    fab.setAttribute('aria-label', labelText);
    fab.tabIndex = -1; // focusable only once visible
    if (waIcon) {
      var icon = waIcon.cloneNode(true);
      icon.removeAttribute('class');
      icon.setAttribute('aria-hidden', 'true');
      fab.appendChild(icon);
    }
    var tip = doc.createElement('span');
    tip.className = 'fab-wa__label';
    tip.setAttribute('aria-hidden', 'true');
    tip.textContent = labelText;
    fab.appendChild(tip);
    doc.body.appendChild(fab);
  }
  var contactInView = false;
  if (fab && hasIO) {
    new IntersectionObserver(function (entries) {
      contactInView = entries[0].isIntersecting;
      requestUpdate();
    }, { threshold: 0.15 }).observe($('#contact'));
  }

  /* ---- Scroll-linked updates (one rAF per frame) -------------------------- */
  var header = $('.site-header');
  var hero = $('.hero');
  var timeline = $('.timeline-line');
  var timelineDots = timeline ? $$('.timeline-dot', timeline) : [];
  var progressBar = null;
  if (header) {
    progressBar = doc.createElement('div');
    progressBar.className = 'scroll-progress';
    progressBar.setAttribute('aria-hidden', 'true');
    header.appendChild(progressBar);
    if (window.CSS && CSS.supports && CSS.supports('animation-timeline: scroll()')) progressBar = null; // CSS drives it
  }

  function updateTimeline(vh) {
    // Reads first, then writes, so the browser lays out once per frame.
    var r = timeline.getBoundingClientRect();
    if (r.bottom < -vh || r.top > vh * 2) return;
    var start = r.top + 24;
    var length = Math.max(1, r.height - 48);
    var progress = clamp((vh * 0.62 - start) / length, 0, 1);
    var head = start + progress * length;
    var lit = timelineDots.map(function (dot) {
      var d = dot.getBoundingClientRect();
      return d.height > 0 && d.top + d.height / 2 <= head + 1;
    });
    timeline.style.setProperty('--tl-progress', progress.toFixed(4));
    timelineDots.forEach(function (dot, i) { dot.classList.toggle('is-lit', lit[i]); });
  }

  var ticking = false;
  function update() {
    ticking = false;
    var y = window.scrollY || window.pageYOffset;
    var vh = window.innerHeight;
    if (header) header.classList.toggle('is-scrolled', y > 8);
    if (progressBar) {
      var max = doc.documentElement.scrollHeight - vh;
      progressBar.style.setProperty('--p', max > 0 ? (y / max).toFixed(4) : '0');
    }
    if (timeline) updateTimeline(vh);
    if (fab) {
      var pastHero = hero ? y > hero.offsetTop + hero.offsetHeight * 0.6 : y > vh;
      var show = pastHero && !contactInView;
      fab.classList.toggle('is-visible', show);
      fab.tabIndex = show ? 0 : -1;
    }
  }
  function requestUpdate() {
    if (ticking) return;
    ticking = true;
    raf(update);
  }
  window.addEventListener('scroll', requestUpdate, { passive: true });
  window.addEventListener('resize', requestUpdate, { passive: true });
  update();

  /* ---- Earlier experience: smooth expand / collapse ----------------------- */
  var expBtn = $('#toggle-experience-btn');
  var expBox = $('#earlier-experience');
  var expText = $('#experience-btn-text');
  var expAnim = null;
  if (expBtn && expBox && expText) {
    expBtn.addEventListener('click', function () {
      var open = expBtn.getAttribute('aria-expanded') !== 'true';
      expBtn.setAttribute('aria-expanded', String(open));
      expText.textContent = open
        ? (expBtn.getAttribute('data-less-text') || 'Show less')
        : (expBtn.getAttribute('data-more-text') || 'View earlier experience');

      if (expAnim) { expAnim.cancel(); expAnim = null; }

      if (reduceMotion.matches || !expBox.animate) {
        expBox.classList.toggle('hidden', !open);
        if (!open) expBtn.scrollIntoView({ block: 'nearest' });
        requestUpdate();
        return;
      }

      expBox.classList.remove('hidden');
      var height = expBox.scrollHeight;
      var margin = getComputedStyle(expBox).marginTop;
      var shown = { height: height + 'px', marginTop: margin, opacity: 1 };
      var gone = { height: '0px', marginTop: '0px', opacity: 0 };
      expBox.style.overflow = 'hidden';
      expAnim = expBox.animate(open ? [gone, shown] : [shown, gone], {
        duration: open ? 700 : 450,
        easing: 'cubic-bezier(0.22, 1, 0.36, 1)'
      });
      expAnim.onfinish = function () {
        expAnim = null;
        expBox.style.overflow = '';
        if (!open) {
          expBox.classList.add('hidden');
          expBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
        requestUpdate();
      };
    });
  }

  /* ---- Smart Solution Cards: clickable inquiry modal (WhatsApp / Email) --- */
  var solCards = $$('#solutions .svc-card');
  if (solCards.length) {
    var lang = (doc.documentElement.lang || 'en').toLowerCase().slice(0, 2);
    var copyByLang = {
      en: {
        badge: 'Solution Inquiry',
        msgLabel: 'Pre-filled message (you can edit it)',
        msgTemplate: 'Hello Toghrul, I’d like to discuss {title} solutions for our business.',
        subjTemplate: 'Inquiry: {title} – Microsoft Solutions',
        waBtn: 'Send via WhatsApp',
        mailBtn: 'Send via Email',
        closeLabel: 'Close',
        cardHint: 'Inquire about {title}'
      },
      az: {
        badge: 'Həll Sorğusu',
        msgLabel: 'Hazır mesaj (redaktə edə bilərsiniz)',
        msgTemplate: 'Salam Toğrul, şirkətimiz üçün {title} həllərini müzakirə etmək istərdim.',
        subjTemplate: 'Sorğu: {title} – Microsoft Həlləri',
        waBtn: 'WhatsApp ilə göndər',
        mailBtn: 'E-poçt ilə göndər',
        closeLabel: 'Bağla',
        cardHint: '{title} haqqında sorğu göndər'
      },
      ru: {
        badge: 'Запрос по решению',
        msgLabel: 'Готовое сообщение (можно изменить)',
        msgTemplate: 'Здравствуйте, Тогрул! Хотел бы обсудить решения {title} для нашей компании.',
        subjTemplate: 'Запрос: {title} – Решения Microsoft',
        waBtn: 'Написать в WhatsApp',
        mailBtn: 'Отправить по Email',
        closeLabel: 'Закрыть',
        cardHint: 'Узнать о {title}'
      },
      tr: {
        badge: 'Çözüm Talebi',
        msgLabel: 'Hazır mesaj (düzenleyebilirsiniz)',
        msgTemplate: 'Merhaba Toghrul, şirketimiz için {title} çözümlerini görüşmek istiyorum.',
        subjTemplate: 'Talep: {title} – Microsoft Çözümleri',
        waBtn: 'WhatsApp ile Gönder',
        mailBtn: 'E-posta ile Gönder',
        closeLabel: 'Kapat',
        cardHint: '{title} hakkında bilgi al'
      }
    };
    var t = copyByLang[lang] || copyByLang.en;
    var waBase = waSource ? waSource.href.split('?')[0] : 'https://wa.me/994772803181';
    var mailSource = $('#contact a[href^="mailto:toghrul.aghabalazada@novum.tech"]');
    var mailBase = mailSource ? mailSource.href.split('?')[0] : 'mailto:toghrul.aghabalazada@novum.tech';

    var backdrop = doc.createElement('div');
    backdrop.className = 'sol-modal-backdrop';
    backdrop.setAttribute('role', 'dialog');
    backdrop.setAttribute('aria-modal', 'true');
    backdrop.setAttribute('aria-hidden', 'true');
    backdrop.setAttribute('aria-labelledby', 'sol-modal-title');
    backdrop.innerHTML =
      '<div class="sol-modal">' +
        '<div class="sol-modal__bar"></div>' +
        '<div class="sol-modal__body">' +
          '<div class="sol-modal__head">' +
            '<div class="sol-modal__icon" aria-hidden="true"></div>' +
            '<div class="min-w-0">' +
              '<span class="sol-modal__badge"></span>' +
              '<h3 class="sol-modal__title" id="sol-modal-title"></h3>' +
              '<p class="sol-modal__sub"></p>' +
            '</div>' +
            '<button type="button" class="sol-modal__close" aria-label="' + t.closeLabel + '">' +
              '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6L6 18M6 6l12 12"/></svg>' +
            '</button>' +
          '</div>' +
          '<label class="sol-modal__label" for="sol-modal-msg"></label>' +
          '<textarea id="sol-modal-msg" class="sol-modal__textarea" rows="3"></textarea>' +
          '<div class="sol-modal__actions">' +
            '<a class="sol-modal__btn sol-modal__btn--wa" target="_blank" rel="noopener noreferrer"></a>' +
            '<a class="sol-modal__btn sol-modal__btn--mail"></a>' +
          '</div>' +
        '</div>' +
      '</div>';
    doc.body.appendChild(backdrop);

    var modalEl = $('.sol-modal', backdrop);
    var iconBox = $('.sol-modal__icon', backdrop);
    var badgeEl = $('.sol-modal__badge', backdrop);
    var titleEl = $('.sol-modal__title', backdrop);
    var subEl = $('.sol-modal__sub', backdrop);
    var labelEl = $('.sol-modal__label', backdrop);
    var msgInput = $('#sol-modal-msg', backdrop);
    var waBtn = $('.sol-modal__btn--wa', backdrop);
    var mailBtn = $('.sol-modal__btn--mail', backdrop);
    var closeBtn = $('.sol-modal__close', backdrop);

    badgeEl.textContent = t.badge;
    labelEl.textContent = t.msgLabel;
    waBtn.innerHTML =
      '<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981z"/></svg>' +
      '<span>' + t.waBtn + '</span>';
    mailBtn.innerHTML =
      '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>' +
      '<span>' + t.mailBtn + '</span>';

    var activeSubject = '';
    var lastTrigger = null;

    function syncLinks() {
      var msg = msgInput.value.trim();
      waBtn.href = waBase + '?text=' + encodeURIComponent(msg);
      mailBtn.href = mailBase + '?subject=' + encodeURIComponent(activeSubject) + '&body=' + encodeURIComponent(msg);
    }
    msgInput.addEventListener('input', syncLinks);

    function openSolutionModal(card) {
      var h3 = $('h3', card);
      var sub = $('span', card);
      var bar = $('.svc-bar', card);
      var srcIcon = $('.svc-icon svg, .svc-icon img', card);
      var title = h3 ? h3.textContent.trim() : 'Microsoft Solutions';
      var subtitle = sub ? sub.textContent.trim() : '';
      var accent = (bar && bar.style.backgroundColor) || '#0D2B75';

      lastTrigger = card;
      modalEl.style.setProperty('--sol-accent', accent);
      titleEl.textContent = title;
      subEl.textContent = subtitle;
      iconBox.innerHTML = '';
      if (srcIcon) {
        var cloned = srcIcon.cloneNode(true);
        cloned.style.width = '28px';
        cloned.style.height = '28px';
        iconBox.appendChild(cloned);
      }

      activeSubject = t.subjTemplate.replace('{title}', title);
      msgInput.value = t.msgTemplate.replace('{title}', title);
      syncLinks();

      backdrop.classList.add('is-open');
      backdrop.setAttribute('aria-hidden', 'false');
      setTimeout(function () { msgInput.focus(); }, 60);
    }

    function closeSolutionModal() {
      if (!backdrop.classList.contains('is-open')) return;
      backdrop.classList.remove('is-open');
      backdrop.setAttribute('aria-hidden', 'true');
      if (lastTrigger) {
        lastTrigger.focus();
        lastTrigger = null;
      }
    }

    closeBtn.addEventListener('click', closeSolutionModal);
    backdrop.addEventListener('click', function (e) {
      if (e.target === backdrop) closeSolutionModal();
    });
    doc.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && backdrop.classList.contains('is-open')) closeSolutionModal();
    });

    solCards.forEach(function (card) {
      var h3 = $('h3', card);
      var title = h3 ? h3.textContent.trim() : '';
      card.setAttribute('role', 'button');
      card.setAttribute('tabindex', '0');
      if (title) card.setAttribute('aria-label', t.cardHint.replace('{title}', title));

      var arrow = doc.createElement('span');
      arrow.className = 'svc-arrow';
      arrow.setAttribute('aria-hidden', 'true');
      arrow.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18l6-6-6-6"/></svg>';
      card.appendChild(arrow);

      card.addEventListener('click', function () { openSolutionModal(card); });
      card.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          openSolutionModal(card);
        }
      });
    });
  }
})();
