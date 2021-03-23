import $ from 'jquery'

$(document).ready(() => {
  const input = document.getElementById('image_upload')
  if (input) {
    input.addEventListener('change', handleFiles, false)
  }

  function handleFiles (event) {
    const files = this.files
    for (let i = 0; i < files.length; i++) {
      console.log(files[i])
      if (files[i].size > (30 * 1024 * 1024)) {
        window.alert(`File ${files[i].name} is bigger than 30 MB. Please resize and try again.`)
        this.value = null
        break
      }
    }
  }
})
