$(document).on('turbolinks:load', function () {
  $('#correspondence_email_attachment').on('change', function () {
    var attachementDescription = $('#attachement-description');
    // Set value of textbox to empty
    attachementDescription.children(1).val('');
    if ($(this).get(0).files.length === 0) {
      attachementDescription.css('display', 'none');
    } else {
      attachementDescription.css('display', 'block');
    }
  });
});
