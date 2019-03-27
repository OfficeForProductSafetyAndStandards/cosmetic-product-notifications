import $ from 'jquery';

function closePageOnClick(id) {
  $(document).ready(() => {
    const element = document.getElementById(id);
    const isJSWindow = window.opener;
    if (isJSWindow && element) {
      element.style.display = 'block';
      element.addEventListener('click', () => {
        window.close();
      });
    }
  });
}

window.closePageOnClick = closePageOnClick;
