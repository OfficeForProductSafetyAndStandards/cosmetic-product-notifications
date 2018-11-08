/* globals simpleAccessibleAutocomplete */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('assignee-picker');

  var commentSubmitButton = $('#action_comment_submit').attr('disabled', true);

  $('#action_comment').keyup(function () {
    if ($(this).val().length > 0) {
      commentSubmitButton.attr('disabled', false);
    } else {
      commentSubmitButton.attr('disabled', true);
    }
  });
});
