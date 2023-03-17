'use strict'

import * as ActiveStorage from '@rails/activestorage'

document.addEventListener('direct-upload:end', (event, file) => {
  const { target, detail } = event
  target.insertAdjacentHTML('beforebegin', `
    <input type="hidden" name="uploaded_files_names[]" value="${detail.file.name}"/>
  `)
})

document.addEventListener('direct-upload:start', event => {
  event.preventDefault()
  document.querySelector('#submit-button').style.display = 'none'
  document.querySelector('#loading-button').style.display = 'block'
})

document.addEventListener('direct-upload:error', event => {
  document.querySelector('#submit-button').style.display = 'block'
  document.querySelector('#loading-button').style.display = 'none'
  event.target.files = null
  event.target.value = null
})

document.addEventListener('DOMContentLoaded', event => {
  if (document.querySelector('#uploaded_files') !== null) {
    document.querySelector('#uploaded_files').addEventListener('change', event => {
      try {
        const max = 100
        if (event.target.files.length > max) {
          window.alert(`Please select no more than ${max} files`)
          event.target.files = null
          event.target.value = null
        }
      } catch (e) { console.log(e) }
    })
  }
})

ActiveStorage.start()
