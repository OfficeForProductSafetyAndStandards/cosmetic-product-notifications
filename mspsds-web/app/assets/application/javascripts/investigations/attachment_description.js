import $ from 'jquery';

$(document).ready(function () {
  var attachmentFileInput = document.getElementById('attachment-file-input');
  var attachmentDescription = document.getElementById('attachment-description');
  var currentAttachmentDetails = document.getElementById('current-attachment-details');

  if (attachmentFileInput) {
    attachmentFileInput.onchange = function () {
      if (this.value) {
        $(attachmentDescription).show();
      } else {
        $(attachmentDescription).hide();
      }
    };
  }

  if (attachmentDescription) {
    if (currentAttachmentDetails) {
      $(attachmentDescription).show();
    } else {
      $(attachmentDescription).hide();
    }
  }
});
