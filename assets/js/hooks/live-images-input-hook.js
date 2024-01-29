const LiveImagesInputHook = {
  mounted () {
    this.selectedRef = null
    const $uploadedImagesContainer = this.el.querySelector('.uploaded-images-container')
    this.$imgPreview = this.el.querySelector('.image-preview')

    $uploadedImagesContainer.addEventListener('click', this.showImage.bind(this))
    this.updated()
  },
  updated () {
    const $showImageList = Array.from(this.el.querySelectorAll('.show-image'))

    if ($showImageList.length === 0) {
      this.$imgPreview.parentNode.classList.add('hidden')
      this.selectedRef = null
      this.setImagePreview('')
      return
    }

    if (this.selectedRef === null) {
      this.$imgPreview.parentNode.classList.remove('hidden')
    }

    const $lastImagePreview = $showImageList[$showImageList.length - 1]
    const entryRef = this.getEntryRef($lastImagePreview)
    this.selectedRef = entryRef
    this.setImagePreview($lastImagePreview.src)
  },
  setImagePreview (src) {
    this.$imgPreview.src = src
  },
  showImage (event) {
    if (event.target.classList.contains('show-image')) {
      const entryRef = this.getEntryRef(event.target)
      if (this.selectedRef !== entryRef) {
        this.selectedRef = entryRef
        this.setImagePreview(event.target.src)
      }
    }
  },
  getEntryRef ($showImage) {
    return parseInt($showImage.dataset.phxEntryRef, 10)
  }
}

export default LiveImagesInputHook
