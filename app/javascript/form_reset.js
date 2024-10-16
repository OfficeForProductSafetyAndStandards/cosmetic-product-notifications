'use strict'

function resetOpssForm (form, defaultData) {
  const targetForm = document.querySelector(`#${form}`)
  // this is needed to clear any form elements the have setAttribute called, i.e. submitted data
  Array.from(targetForm.elements).forEach(element => {
    if (element.type === 'text') {
      element.setAttribute('value', '')
    } else if (element.type === 'search') {
      element.setAttribute('value', '')
    } else if (element.type === 'checkbox') {
      element.removeAttribute('checked')
    } else if (element.type === 'radio') {
      element.setAttribute('aria-expanded', false)
      element.removeAttribute('checked')
    }
  })

  targetForm.reset()

  // restore any default data from a Ruby hash passed into data-form-defaults on the reset button
  if (defaultData) {
    const json = JSON.parse(defaultData)
    Object.entries(json).forEach(([key, defaultValue]) => {
      const element = document.getElementById(key)
      if (element) {
        if (element.type === 'text') {
          element.setAttribute('value', defaultValue)
        } else if (element.type === 'search') {
          element.setAttribute('value', defaultValue)
        } else if (element.type === 'checkbox') {
          element.setAttribute('checked', true)
        } else if (element.type === 'radio') {
          element.setAttribute('aria-expanded', true)
          element.setAttribute('checked', true)
        }
      }
    })
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const resetButton = document.querySelectorAll('[data-reset-form]')

  resetButton.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault()
      resetOpssForm(button.dataset.resetForm, button.dataset.formDefaults)
    })
  })
})
