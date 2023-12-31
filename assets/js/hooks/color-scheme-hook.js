const ColorSchemeHook = {
  deadViewCompatible: true,
  mounted () {
    this.init()
  },
  updated () {
    this.init()
  },
  init () {
    window.initScheme()
    this.el.addEventListener('click', window.toggleScheme)
  }
}

export default ColorSchemeHook
