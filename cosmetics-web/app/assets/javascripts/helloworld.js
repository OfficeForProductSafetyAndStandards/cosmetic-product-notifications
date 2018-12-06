// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function send_email() {
  $.ajax({
    url: 'send',
    success: () => console.log('sent email')
  })
}
