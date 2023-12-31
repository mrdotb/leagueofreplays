const ScriptHook = {
  deadViewCompatible: true,
  mounted () {
    // launch download
    window.location.href = this.el.dataset.url
  }
}

export default ScriptHook
