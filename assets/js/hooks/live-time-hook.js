const LiveTimeHook = {
  deadViewCompatible: true,
  mounted () {
    this.start = new Date(this.el.dataset.start)
    this.interval =
      setInterval(() => {
        const time = this.timeSince(this.start)
        this.el.innerText = time
      }, 1000)
  },
  destroyed () {
    clearInterval(this.interval)
  },
  timeSince (since) {
    const now = Date.now()
    const diff = now - since

    const minutes = Math.floor(diff / 60000)
    const seconds = Math.floor((diff % 60000) / 1000)

    const minutesStr = minutes.toString().padStart(2, '0')
    const secondsStr = seconds.toString().padStart(2, '0')

    return `${minutesStr}:${secondsStr}`
  }
}

export default LiveTimeHook
