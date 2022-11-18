/*
  Reset a form and remove any errors
*/

function resetOpssForm (form) {
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
    } else if (element.type === 'select-one') {
      element.selectedIndex = 0
    }
  })

  Array.from(document.querySelectorAll('.govuk-error-summary, .govuk-error-message')).forEach(element => {
    element.classList.add('govuk-!-display-none')
  })

  targetForm.reset()
}

window.addEventListener('DOMContentLoaded', () => {
  const resetButton = document.querySelectorAll('[data-reset-form]')

  resetButton.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault()
      resetOpssForm(button.dataset.resetForm)
    })
  })
})
