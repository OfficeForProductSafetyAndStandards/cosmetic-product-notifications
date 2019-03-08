import $ from 'jquery';

$(document).ready(() => {
    const fileUploadForm = document.getElementById('file-upload-form');
    const fileInput = document.getElementById('uploaded_files');
    const maxNumberOfFiles = fileUploadForm.dataset.maxNumberOfFiles;
    const tooManyFilesErrorSummary = document.getElementById('too-many-files-error-summary');
    const fileUploadFormGroup = document.getElementById('file-upload-form-group');
    const fileUploadErrorMessage = document.getElementById('file-upload-error-message');

    fileUploadForm.addEventListener('submit', function (event) {
        if (fileInput.files.length > maxNumberOfFiles) {
            event.preventDefault();
            tooManyFilesErrorSummary.style.display = "inline";
            fileUploadFormGroup.classList.add("govuk-form-group--error");
            fileUploadErrorMessage.innerHTML =
                `Too many files selected. Please select no more than ${maxNumberOfFiles} files`;
        }
    });
});
