function sendEmail() { // eslint-disable-line no-unused-vars
  $.ajax({
    url: 'send',
    success: function () {
      console.log('sent email');
    }
  });
}
