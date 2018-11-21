$(document).on('turbolinks:load', function () {
  $('#correspondence_email_attachment_file').on('change', function () {
    var attachmentDescription = $('#attachment-description');
    // Set value of textbox to empty
    attachmentDescription.children(1).val('');
    if ($(this).get(0).files.length === 0) {
      attachmentDescription.css('display', 'none');
    } else {
      attachmentDescription.css('display', 'block');
    }
  });
});
