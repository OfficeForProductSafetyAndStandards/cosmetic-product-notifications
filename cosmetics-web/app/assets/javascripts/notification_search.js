'use strict'

document.addEventListener('DOMContentLoaded', () => {
  const sortBy = document.querySelector('#notification_search_form_sort_by')
  if (sortBy !== null) {
    sortBy.addEventListener('change', () => {
      document.querySelector('#new_notification_search_form_sort').submit()
    })
  }

  const filterForm = document.querySelector('#new_notification_search_form_filters')
  if (filterForm !== null) {
    const radioConditionalElements = filterForm.querySelectorAll('.govuk-radios__conditional')
    const radioInputs = filterForm.querySelectorAll('.govuk-radios__input')
    const checkboxes = filterForm.querySelectorAll('.govuk-checkboxes__input')
    const dateInputs = filterForm.querySelectorAll('.govuk-radios--conditional .govuk-date-input__input')
    const prodSelect = document.getElementById('notification_search_form_category')
    const defaultInputs = filterForm.querySelectorAll('.govuk-radios input#search-by_all_fields')

    document.querySelector('#opss-reset').addEventListener('click', () => { // click the filter's form reset link/button
      if (prodSelect !== null) {
        prodSelect.querySelectorAll('option').forEach((s) => { // all options
          s.selected = false
        })
        prodSelect.querySelector('option').selected = true // the first option
      }

      radioConditionalElements.forEach((element) => {
        element.classList.add('govuk-radios__conditional--hidden')
      })

      const groupErrors = filterForm.querySelectorAll('.govuk-form-group--error')
      if (groupErrors.length <= 0) { // there are no errors in the form
        radioInputs.forEach((element) => {
          element.ariaExpanded = true
          element.checked = false
        })
      }
      checkboxes.forEach((element) => {
        element.checked = false
      })
      defaultInputs.forEach((element) => {
        element.checked = true
      })
      dateInputs.forEach((element) => {
        element.value = ''
      })
    }, false)
  }

  const ingredientsFilterForm = document.querySelector('#ingredients_search_form_filters')
  if (ingredientsFilterForm !== null) {
    const radioInputs = ingredientsFilterForm.querySelectorAll('.govuk-radios__input')
    const dateInputs = ingredientsFilterForm.querySelectorAll('.govuk-date-input__input')

    document.querySelector('#opss-reset').addEventListener('click', () => { // click the filter's form reset link/button
      radioInputs.forEach((element) => {
        element.ariaExpanded = false
        element.checked = false
      })
      const fieldsets = ingredientsFilterForm.querySelectorAll('fieldset')
      fieldsets.forEach((fieldset) => {
        const radios = fieldset.querySelectorAll('.govuk-radios__input')
        if (radios.length > 0) {
          radios[0].checked = true
        }
      })
      dateInputs.forEach((element) => {
        element.value = ''
      })
    }, false)
  }

  const ingredientsSortBy = document.querySelector('#ingredient_search_form_sort_by')
  if (ingredientsSortBy !== null) {
    ingredientsSortBy.addEventListener('change', function () {
      document.querySelector('#new_ingredient_search_form_sort').submit()
    })
  }
})
