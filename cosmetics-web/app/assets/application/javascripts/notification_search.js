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

  /* hide first filter for non js - start */
  if (document.getElementById('by-date-range')) {
    /* Removes checked date range radio (collapses date rangge) when there is no query string. */
    if (!window.location.search) {
      document.getElementById('by-date-range').removeAttribute('checked')
    } else { // When there is a query string
      const IDinputs = document.getElementById('conditional-date-block-2')
      const myInputs = IDinputs.getElementsByTagName('input')
      let anyVal = false
      /* Identifies if any of the date inputs has a value */
      for (const input of myInputs) {
        if (input.value !== '') {
          anyVal = true
          break
        }
      }
      /* If all the date range inputs are empty, removes checked radio (collapses date range) */
      if (anyVal === false) {
        document.getElementById('by-date-range').removeAttribute('checked')
      }
    }
    document.getElementById('conditional-date-block-2').classList.remove('opss-js-enabled-hidden')
  }
})
