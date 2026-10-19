/** Tailwind config used by tools/build.ps1 (compiled ahead of time; no CDN needed). */
module.exports = {
  content: ['./index.html', './index_az.html', './index_tr.html', './index_ru.html', './assets/site.js'],
  /* hover: styles only on devices that really hover, so taps on phones don't leave cards "stuck" lifted */
  future: { hoverOnlyWhenSupported: true },
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Roboto', '"Helvetica Neue"', 'Arial', 'sans-serif'],
        display: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'Roboto', '"Helvetica Neue"', 'Arial', 'sans-serif'],
      },
      colors: {
        novum: {
          navy: '#0D2B75',  /* Primary Official Brand Blue */
          hover: '#134074', /* Interactive Hover State */
          dark: '#081B4B',  /* Primary Text & Deep Accents */
          ice: '#EEF4FF',   /* Ice-Blue Container Background */
          soft: '#F4F7FC',  /* Page / Section Background Tint */
        },
      },
      backgroundImage: {
        'novum-gradient': 'linear-gradient(115deg, rgba(13, 43, 117, 0.93) 0%, rgba(6, 20, 89, 1) 70%, rgba(29, 33, 73, 1) 100%)',
        'novum-hero': 'linear-gradient(180deg, #F5F9FF 0%, #E5F1FF 100%)',
      },
    },
  },
  plugins: [],
};
