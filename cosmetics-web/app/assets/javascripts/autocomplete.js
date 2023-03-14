'use strict'

import accessibleAutocomplete from 'accessible-autocomplete'

function simpleAccessibleAutocomplete (id, autocompleteOptions) {
  const element = document.querySelector(`#${id}`)

  const options = autocompleteOptions || {}
  if (element) {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: element,
      showAllValues: options.showAllValues,
      preserveNullOptions: false
    })

    // In the case that the user deletes the entry from the field, we want this to be reflected in
    // the underlying select. This is a work-around to
    // https://github.com/alphagov/accessible-autocomplete/issues/205
    const $enhancedElement = element.parentElement.querySelector('input')
    $enhancedElement.addEventListener('keyup', () => {
      if ($enhancedElement.value !== element.querySelector('option:checked').text) {
        element.value = ''
      }
    })

    // If we display a down arrow we want clicking on it to cause the same effect as clicking on
    // input field, showing all values. This is a work-around to
    // https://github.com/alphagov/accessible-autocomplete/issues/202
    const $downArrow = element.parentElement.querySelector('svg')
    if ($downArrow) {
      $downArrow.addEventListener('click', () => {
        $enhancedElement.focus()
        $enhancedElement.click()
      })
    }

    // This adds ability to remove currently selected input by pressing on an X next to it
    // This is a work-around to
    // https://github.com/alphagov/accessible-autocomplete/issues/240
    const removeButton = document.querySelector(`#clear-${id}`)
    if (removeButton) {
      const removeValue = () => {
        // Clear autocomplete and hidden select
        $enhancedElement.value = ''
        element.parentElement.querySelector('select option:checked').selected = false

        // Needed to collapse menu
        $enhancedElement.click()
        $enhancedElement.focus()
        $enhancedElement.blur()

        // Return focus to the button
        removeButton.focus()
      }

      removeButton.addEventListener('keypress', (e) => {
        // Trigger on enter or space click only
        if (e.keyCode === 13 || e.keyCode === 32) {
          removeValue()
        }
      })

      removeButton.addEventListener('click', () => {
        removeValue()
      })

      // Without JS, remove button won't work, so it is not displayed, this makes it visible
      removeButton.style.display = 'inline-block'
    }
  }
}

window.callAutocompleteWhenReady = (id, options) => {
  document.addEventListener('DOMContentLoaded', () => {
    simpleAccessibleAutocomplete(id, options)
  })
}
