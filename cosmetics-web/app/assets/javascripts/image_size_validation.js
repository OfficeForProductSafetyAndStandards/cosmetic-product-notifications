'use strict'

document.addEventListener('DOMContentLoaded', () => {
  const input = document.querySelector('#image_upload')
  if (input) {
    input.addEventListener('change', handleFiles, false)
  }

  function handleFiles (event) {
    const files = this.files
    for (let i = 0; i < files.length; i++) {
      if (files[i].size > (30 * 1000 * 1000)) {
        window.alert(`File ${files[i].name} is larger than 30 MB. You must upload a smaller file.`)
        this.value = null
        break
      }
    }
  }
})
