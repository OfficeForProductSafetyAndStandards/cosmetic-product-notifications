'use strict'

document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('#file-upload-form')) {
    const fileUploadForm = document.querySelector('#file-upload-form')
    const fileInput = document.querySelector('#uploaded_files')
    const { maxNumberOfFiles } = fileUploadForm.dataset
    const errorSummary = document.querySelector('.error-summary-js')
    const fileUploadFormGroup = document.querySelector('#file-upload-form-group')
    const fileUploadErrorMessage = document.querySelector('#file-upload-error-message')

    const tooManyFilesMessage = `You can only select up to ${maxNumberOfFiles} files at the same time`
    const noFilesSelectedMessage = 'Select a file'

    const errorSummaryText = errorSummary.querySelector('.govuk-error-summary__list a')

    fileUploadForm.addEventListener('submit', (event) => {
      if (fileInput.files.length === 0) {
        errorSummary.style.display = 'inline'
        fileUploadFormGroup.classList.add('govuk-form-group--error')
        fileUploadErrorMessage.innerHTML = noFilesSelectedMessage
        errorSummaryText.innerHTML = noFilesSelectedMessage
      }

      if (fileInput.files.length > maxNumberOfFiles) {
        event.preventDefault()
        errorSummary.style.display = 'inline'
        fileUploadFormGroup.classList.add('govuk-form-group--error')
        fileUploadErrorMessage.innerHTML = tooManyFilesMessage
        errorSummaryText.innerHTML = tooManyFilesMessage
      }
    })
  }
})
