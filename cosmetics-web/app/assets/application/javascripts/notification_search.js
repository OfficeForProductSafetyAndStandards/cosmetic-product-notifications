import $ from 'jquery'

$(function () {
  const sortBy = document.getElementById('notification_search_form_sort_by')
  if (sortBy !== null) {
    sortBy.addEventListener('change', function () {
      document.getElementById('new_notification_search_form_sort').submit()
    })
  }

  const filterForm = document.getElementById('new_notification_search_form_filters')
  if (filterForm !== null) {
    const radioConditionalElements = filterForm.querySelectorAll('.govuk-radios__conditional')
    const radioInputs = filterForm.querySelectorAll('.govuk-radios--conditional .govuk-radios__input')
    const dateInputs = filterForm.querySelectorAll('.govuk-radios--conditional .govuk-date-input__input')
    const prodSelect = document.getElementById('notification_search_form_category')

    document.getElementById('opss-reset').addEventListener('click', function () { // click the filter's form reset link/button
      prodSelect.querySelectorAll('option').forEach(function (s) { // all options
        s.removeAttribute('selected')
      })
      prodSelect.querySelector('option').setAttribute('selected', 'selected') // the first option

      radioConditionalElements.forEach(function (element) {
        element.classList.add('govuk-radios__conditional--hidden')
      })
      radioInputs.forEach(function (element) {
        element.setAttribute('aria-expanded', false)
        element.removeAttribute('checked')
      })
      dateInputs.forEach(function (element) {
        element.setAttribute('value', '')
      })
    }, false)
  }
})
