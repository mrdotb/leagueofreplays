import { render, cancel } from '../../vendor/timeago.js'
const local = 'en_short'

const TimeAgoHook = {
  deadViewCompatible: true,
  mounted () {
    render(this.el, local)
  },
  updated () {
    render(this.el, local)
  },
  destroyed () {
    cancel(this.el)
  }
}

export default TimeAgoHook
