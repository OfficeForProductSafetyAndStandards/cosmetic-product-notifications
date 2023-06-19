'use strict'

document.addEventListener('DOMContentLoaded', () => {
  const resetButton = document.querySelectorAll('[data-reset-form]')

  resetButton.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault()
      document.querySelector(`form#${button.dataset.resetForm}`).reset()
    })
  })
})
