import $ from 'jquery'
import openregisterLocationPicker from 'govuk-country-and-territory-autocomplete'

import locationGraph from 'govuk-country-and-territory-autocomplete/dist/location-autocomplete-graph.json'

// TODO progressive enhancement for https://github.com/alphagov/govuk-country-and-territory-autocomplete

$(document).ready(() => {
  const autocompleteElement = document.getElementById('location-autocomplete')
  if (autocompleteElement) {
    openregisterLocationPicker({
      selectElement: autocompleteElement,
      url: locationGraph
    })
  }
})
