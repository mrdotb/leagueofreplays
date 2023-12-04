const fs = require('fs')
const path = require('path')
const plugin = require('tailwindcss/plugin')

// Embeds Hero Icons (https://heroicons.com) into your app.css bundle
// See your `CoreComponents.icon/1` for more information.
exports.heroComponent = plugin(({ matchComponents, theme }) => {
  const iconsDir = path.join(__dirname, './vendor/heroicons/optimized')
  const icons = [
    ['', '/24/outline'],
    ['-solid', '/24/solid'],
    ['-mini', '/20/solid']
  ]
  const values = icons.reduce((acc, [suffix, dir]) => (
    fs.readdirSync(path.join(iconsDir, dir)).reduce((iconsAcc, file) => {
      const name = path.basename(file, '.svg') + suffix
      iconsAcc[name] = { name, fullPath: path.join(iconsDir, dir, file) }
      return iconsAcc
    }, acc)
  ), {})

  matchComponents({
    hero: ({ name, fullPath }) => {
      const content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, '')
      return {
        [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        '-webkit-mask': `var(--hero-${name})`,
        mask: `var(--hero-${name})`,
        'background-color': 'currentColor',
        'vertical-align': 'middle',
        display: 'inline-block',
        width: theme('spacing.5'),
        height: theme('spacing.5')
      }
    }
  }, { values })
})

exports.svgComponent = plugin(({ matchComponents, theme }) => {
  const iconsDir = path.join(__dirname, './vendor/svgs')
  const values = fs.readdirSync(iconsDir).reduce((iconsAcc, file) => {
    const name = path.basename(file, '.svg')
    iconsAcc[name] = { name, fullPath: path.join(iconsDir, file) }
    return iconsAcc
  }, {})

  matchComponents({
    svg: ({ name, fullPath }) => {
      const content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, '')
      return {
        [`--svg-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        '-webkit-mask': `var(--svg-${name})`,
        mask: `var(--svg-${name})`,
        'background-color': 'currentColor',
        'vertical-align': 'middle',
        display: 'inline-block',
        width: theme('spacing.5'),
        height: theme('spacing.5')
      }
    }
  }, { values })
})
