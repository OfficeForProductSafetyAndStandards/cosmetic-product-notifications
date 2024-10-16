'use strict'

document.addEventListener('DOMContentLoaded', () => {
  const printLinks = document.querySelectorAll('.opss-print-link')

  printLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault()
      window.print()
    })
  })
})
