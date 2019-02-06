$(document).ready(function () {
  var autocompleteElement = document.getElementById('location-autocomplete');
  if (autocompleteElement) {
    openregisterLocationPicker({
      selectElement: autocompleteElement,
      url: '/assets/govuk-country-and-territory-autocomplete/dist/location-autocomplete-graph.json'
    });
  }
});
