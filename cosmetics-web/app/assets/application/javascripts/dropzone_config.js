import Dropzone from 'dropzone';
import $ from 'jquery';

$(document).ready(() => {
  Dropzone.options.fileUploadForm = {
    paramName: "uploaded_files", // The name that will be used to transfer the file
    maxFiles: 10,
    uploadMultiple: true,
    autoProcessQueue: false,
    previewTemplate: document.getElementById('preview-template').innerHTML,


    // // The setting up of the dropzone
    // init: function() {
    //   var myDropzone = this;
    //
    //   // First change the button to actually tell Dropzone to process the queue.
    //   this.element.querySelector("button[type=submit]").addEventListener("click", function(e) {
    //     // Make sure that the form isn't actually being sent.
    //     e.preventDefault();
    //     e.stopPropagation();
    //     myDropzone.processQueue();
    //   });
    //
    //   // Listen to the sendingmultiple event. In this case, it's the sendingmultiple event instead
    //   // of the sending event because uploadMultiple is set to true.
    //   this.on("sendingmultiple", function() {
    //     // Gets triggered when the form is actually being sent.
    //     // Hide the success button or the complete form.
    //   });
    //   this.on("successmultiple", function(files, response) {
    //     // Gets triggered when the files have successfully been sent.
    //     // Redirect user or notify of success.
    //   });
    //   this.on("errormultiple", function(files, response) {
    //     // Gets triggered when there was an error sending the files.
    //     // Maybe show form again, and notify user of error
    //   });
    // }

  };

  console.log('DROPZONE OPTIONS LOADED 1');

});
