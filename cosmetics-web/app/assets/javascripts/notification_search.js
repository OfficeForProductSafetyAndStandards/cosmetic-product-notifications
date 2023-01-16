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
    const radioInputs = filterForm.querySelectorAll('.govuk-radios__input')
    const checkboxes = filterForm.querySelectorAll('.govuk-checkboxes__input')
    const dateInputs = filterForm.querySelectorAll('.govuk-radios--conditional .govuk-date-input__input')
    const prodSelect = document.getElementById('notification_search_form_category')
    const defaultInputs = filterForm.querySelectorAll('.govuk-radios input#search-by_all_fields')

    document.getElementById('opss-reset').addEventListener('click', function () { // click the filter's form reset link/button
      if (prodSelect !== null) {
        prodSelect.querySelectorAll('option').forEach(function (s) { // all options
          s.removeAttribute('selected')
        })
        prodSelect.querySelector('option').setAttribute('selected', 'selected') // the first option
      }

      radioConditionalElements.forEach(function (element) {
        element.classList.add('govuk-radios__conditional--hidden')
      })
      radioInputs.forEach(function (element) {
        element.setAttribute('aria-expanded', false)
        element.removeAttribute('checked')
      })
      checkboxes.forEach(function (element) {
        element.removeAttribute('checked')
      })
      defaultInputs.forEach(function (element) {
        element.setAttribute('checked', true)
      })
      dateInputs.forEach(function (element) {
        element.setAttribute('value', '')
      })
    }, false)
  }

  const ingredientsFilterForm = document.getElementById('ingredients_search_form_filters')
  if (ingredientsFilterForm !== null) {
    const radioInputs = ingredientsFilterForm.querySelectorAll('.govuk-radios__input')
    const dateInputs = ingredientsFilterForm.querySelectorAll('.govuk-date-input__input')

    document.getElementById('opss-reset').addEventListener('click', function () { // click the filter's form reset link/button
      radioInputs.forEach(function (element) {
        element.setAttribute('aria-expanded', false)
        element.removeAttribute('checked')
      })
      const fieldsets = ingredientsFilterForm.querySelectorAll('fieldset')
      fieldsets.forEach(function (fieldset) {
        const radios = fieldset.querySelectorAll('.govuk-radios__input')
        if (radios.length > 0) {
          radios[0].setAttribute('checked', 'checked')
        }
      })
      dateInputs.forEach(function (element) {
        element.setAttribute('value', '')
      })
    }, false)
  }

  const ingredientsSortBy = document.getElementById('ingredient_search_form_sort_by')
  if (ingredientsSortBy !== null) {
    ingredientsSortBy.addEventListener('change', function () {
      document.getElementById('new_ingredient_search_form_sort').submit()
    })
  }
})
