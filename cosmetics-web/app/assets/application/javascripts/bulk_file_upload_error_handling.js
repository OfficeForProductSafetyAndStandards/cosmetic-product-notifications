import $ from 'jquery';

$(document).ready(() => {
    const fileUploadForm = document.getElementById('file-upload-form');
    const fileInput = document.getElementById('uploaded_files');
    const max_number_of_files = fileUploadForm.dataset.maxNoOfFiles;

    fileUploadForm.addEventListener('submit', function (event) {
        if (fileInput.files.length > max_number_of_files) {
            event.preventDefault();
            location.reload();
        }
    });
});
