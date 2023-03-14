'use strict'

import openregisterLocationPicker from 'govuk-country-and-territory-autocomplete'
import locationGraph from 'govuk-country-and-territory-autocomplete/dist/location-autocomplete-graph.json'

// TODO progressive enhancement for https://github.com/alphagov/govuk-country-and-territory-autocomplete

document.addEventListener('DOMContentLoaded', () => {
  const autocompleteElement = document.querySelector('#location-autocomplete')
  if (autocompleteElement) {
    openregisterLocationPicker({
      selectElement: autocompleteElement,
      url: locationGraph
    })
  }
})
