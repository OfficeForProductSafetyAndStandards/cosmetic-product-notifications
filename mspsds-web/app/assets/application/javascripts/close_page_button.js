import $ from 'jquery';

function closePageOnClick(id) {
  $(document).ready(() => {
    const element = document.getElementById(id);
    if(element){
      element.style.display = "block";
      element.addEventListener('click', () => {
        window.close();
      });
    }
  });
}

window.closePageOnClick = closePageOnClick;
