const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./templates/**/*.html', './content/**/*.md'],
  theme: {
    extend: {
      colors: {
        // theme: nord
        bg: "#2e3440",
        'bg-light': "#3b4252",
        text: "#e5e9f0",
        accent: "#8fbcbb",
        'accent-text': "#2e3440",
        border: "#4c566a",
        link: "#88c0d0",
        secondary: "#b48ead",
      },
      fontFamily: {
        'sans': ['"MPLUS1"', ...defaultTheme.fontFamily.sans],
        'mono': ['"MPLUS1Code"', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [],
}

