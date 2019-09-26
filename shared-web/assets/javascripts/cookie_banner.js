import $ from 'jquery';

function cookieBanner() {
  const hideLinkButton = document.getElementById('hideLink');
  function setCookie(daysToExpire) {
    const date = new Date();
    const msToExpire = daysToExpire * 24 * 60 * 60 * 1000;
    date.setTime(date.getTime() + msToExpire);
    const expires = `expires=${date.toUTCString()}`;
    document.cookie = `seen_cookie_message = true;${expires};path=/`;
  }
  function hideCookieBanner() {
    setCookie(365);
    document.getElementById('global-cookie-message').style.display = 'none';
  }
  hideLinkButton.addEventListener('click', hideCookieBanner);
}
$(document).ready(() => {
  cookieBanner();
});
