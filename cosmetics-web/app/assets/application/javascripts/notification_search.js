import $ from 'jquery'

$(function() {
  const sortBy = document.getElementById('notification_search_form_sort_by')
  if (sortBy !== null) {
    sortBy.addEventListener('change', function () {
      document.getElementById('new_notification_search_form_sort').submit()
    })
  }

  const filterForm = document.getElementById('new_notification_search_form_filters')
  if (filterForm !== null) {
    const radioSelection = filterForm.querySelectorAll('.govuk-radios__conditional')
    const radioInput = filterForm.querySelectorAll('.govuk-radios--conditional .govuk-radios__input')

    document.getElementById('opss-reset').addEventListener('click', function () {//click the filter's form reset link/button
      radioSelection.forEach(function(element) {
        element.classList.add('govuk-radios__conditional--hidden')
      });
      radioInput.forEach(function(element) {
        element.setAttribute('aria-expanded', false)
      });
    }, false);
  }
})
