import topbar from '../vendor/topbar'

function events (liveSocket) {
  // Show progress bar on live navigation and form submits
  topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
  window.addEventListener('phx:page-loading-start', _info => topbar.show(300))
  window.addEventListener('phx:page-loading-stop', _info => topbar.hide())

  // clipboard event
  window.addEventListener('lor:clipcopy', event => {
    if ('clipboard' in navigator) {
      const text = event.target.dataset.copy
      navigator.clipboard.writeText(text)
    } else {
      console.error('Sorry, your browser does not support clipboard copy.')
    }
  })
}

export default events
