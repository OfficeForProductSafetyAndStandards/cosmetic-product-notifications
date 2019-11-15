import $ from 'jquery';

$(document).ready(() => {
  const fileUploadForm = document.getElementById('file-upload-form');
  const fileInput = document.getElementById('uploaded_files');
  const { maxNumberOfFiles } = fileUploadForm.dataset;
  const errorSummary = document.getElementsByClassName('error-summary-js')[0];
  const fileUploadFormGroup = document.getElementById('file-upload-form-group');
  const fileUploadErrorMessage = document.getElementById('file-upload-error-message');

  const tooManyFilesMessage = `You can only select up to ${maxNumberOfFiles} files at the same time`;
  const noFilesSelectedMessage = 'No files selected';

  const errorSummaryText = errorSummary.getElementsByClassName('govuk-error-summary__list')[0].getElementsByTagName('A')[0];

  fileUploadForm.addEventListener('submit', (event) => {
    if (fileInput.files.length === 0) {
      errorSummary.style.display = 'inline';
      fileUploadFormGroup.classList.add('govuk-form-group--error');
      fileUploadErrorMessage.innerHTML = noFilesSelectedMessage;
      errorSummaryText.innerHTML = noFilesSelectedMessage;
    }

    if (fileInput.files.length > maxNumberOfFiles) {
      event.preventDefault();
      errorSummary.style.display = 'inline';
      fileUploadFormGroup.classList.add('govuk-form-group--error');
      fileUploadErrorMessage.innerHTML = tooManyFilesMessage;
      errorSummaryText.innerHTML = tooManyFilesMessage;
    }
  });
});
