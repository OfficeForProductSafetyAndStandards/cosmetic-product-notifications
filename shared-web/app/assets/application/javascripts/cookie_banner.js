import $ from 'jquery';

function cookieBanner() {
  document.getElementById('hideWhenNoJS').style.display='block';
  const myButton = document.getElementById('hideLink');
  function setCookie() {
    const d = new Date();
    d.setTime(d.getTime() + (365 * 24 * 60 * 60 * 1000));
    const expires = `expires=${d.toUTCString()}`;
    document.cookie = `seen_cookie_message = true;${expires};path=/`;
  }
  function hideCookieBanner() {
    setCookie(365);
    document.getElementById('global-cookie-message').style.display = 'none';
  }
  myButton.addEventListener('click', hideCookieBanner);
}
$(document).ready(() => {
  cookieBanner();
});
