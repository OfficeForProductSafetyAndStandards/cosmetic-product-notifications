/*
  Reset a form and remove any errors
*/

function resetOpssForm (form, defaultData) {
  const targetForm = document.getElementById(form)
  // this is needed to clear any form elements the have setAttribute called, i.e. submitted data
  Array.from(targetForm.elements).forEach(element => {
    element.classList.remove('govuk-input--error')

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

  Array.from(document.querySelectorAll('.govuk-error-summary, .govuk-error-message')).forEach(element => {
    element.remove()
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

window.addEventListener('DOMContentLoaded', () => {
  const resetButton = document.querySelectorAll('[data-reset-form]')

  resetButton.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault()
      resetOpssForm(button.dataset.resetForm, button.dataset.formDefaults)
    })
  })
})
