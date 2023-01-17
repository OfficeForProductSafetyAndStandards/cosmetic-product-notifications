// JS
import 'core-js/stable'
import 'regenerator-runtime/runtime'

import * as GOVUKFrontend from 'govuk-frontend'

import './location_picker'
import './autocomplete'
import './bulk_file_upload_error_handling'
import './image_size_validation'
import './notification_search'
import './form_reset'

import * as ActiveStorage from '@rails/activestorage'

// Styles
import 'accessible-autocomplete/src/autocomplete.css'
// Images
import 'govuk-frontend/govuk/assets/images/favicon.ico'
import 'govuk-frontend/govuk/assets/images/govuk-mask-icon.svg'
import 'govuk-frontend/govuk/assets/images/govuk-crest-2x.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-180x180.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-167x167.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon-152x152.png'
import 'govuk-frontend/govuk/assets/images/govuk-apple-touch-icon.png'
import 'govuk-frontend/govuk/assets/images/govuk-opengraph-image.png'
import 'govuk-frontend/govuk/assets/images/govuk-logotype-crown.png'

window.GOVUKFrontend = GOVUKFrontend

document.addEventListener('direct-upload:end', (event, file) => {
  const { target, detail } = event
  target.insertAdjacentHTML(
    'beforebegin',
    `
    <input type="hidden" name="uploaded_files_names[]" value="${detail.file.name}"/>
  `
  )
})

document.addEventListener('direct-upload:start', (event) => {
  event.preventDefault()
  document.getElementById('submit-button').style.display = 'none'
  document.getElementById('loading-button').style.display = 'block'
})

document.addEventListener('direct-upload:error', (event) => {
  document.getElementById('submit-button').style.display = 'block'
  document.getElementById('loading-button').style.display = 'none'
  event.target.files = null
  event.target.value = null
})

document.addEventListener('DOMContentLoaded', (event) => {
  if (document.getElementById('uploaded_files') !== null) {
    document
      .getElementById('uploaded_files')
      .addEventListener('change', (event) => {
        try {
          const max = 100
          if (event.target.files.length > max) {
            window.alert(`Please select no more than ${max} files`)
            event.target.files = null
            event.target.value = null
          }
        } catch (e) {
          console.log(e)
        }
      })
  }
})

ActiveStorage.start()
