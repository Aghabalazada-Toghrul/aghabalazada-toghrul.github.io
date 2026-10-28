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
})();
