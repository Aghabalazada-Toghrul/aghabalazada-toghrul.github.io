/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./**/*.html"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          '"Segoe UI"',
          '-apple-system',
          'BlinkMacSystemFont',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          'sans-serif'
        ],
        display: [
          '"Segoe UI Semibold"',
          '"Segoe UI"',
          'sans-serif'
        ]
      },
      colors: {
        ms: {
          blue: '#0078D4',
          'blue-dark': '#005A9E',
          'blue-text': '#0067B8',
          gray: '#242424',
          secondary: '#505050',
          light: '#E1DFDD',
          bg: '#F3F2F1',
          card: '#FFFFFF',
          red: '#F25022',
          green: '#7FBA00',
          yellow: '#FFB900',
          cyan: '#00A4EF'
        }
      },
      boxShadow: {
        fluent: '0 2px 4px rgba(0, 0, 0, 0.08), 0 4px 12px rgba(0, 0, 0, 0.04)',
        'fluent-hover': '0 4px 8px rgba(0, 0, 0, 0.12), 0 8px 24px rgba(0, 0, 0, 0.08)'
      }
    }
  },
  plugins: []
};
