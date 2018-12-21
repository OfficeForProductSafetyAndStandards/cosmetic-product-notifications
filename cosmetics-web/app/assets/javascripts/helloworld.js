function sendEmail() { // eslint-disable-line no-unused-vars
  $.ajax({
    url: 'send',
    success: () => console.log('sent email')
  });
}
