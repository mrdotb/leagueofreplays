const ColorSchemeHook = {
  deadViewCompatible: true,
  mounted() {
    this.init();
  },
  updated() {
    this.init();
  },
  init() {
    initScheme();
    this.el.addEventListener("click", window.toggleScheme);
  },
};


export default ColorSchemeHook
