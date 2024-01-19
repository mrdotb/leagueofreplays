const ScriptHook = {
  deadViewCompatible: true,
  mounted () {
    // launch download after 500 ms
    setTimeout(() => {
      window.location.href = this.el.dataset.url
    }, 500)
  }
}

export default ScriptHook
