import $ from 'jquery'

$(document).ready(() => {
  let element = document.getElementById("notification_search_form_sort_by")
  if (element !== null) {
    element.addEventListener("change", function(){
      document.getElementById("new_notification_search_form_sort").submit();
    });
  }
})
