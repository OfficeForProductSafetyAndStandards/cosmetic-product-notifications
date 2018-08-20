$(document).on("turbolinks:load", function() {
    var autocomplete_element = document.getElementById('location-autocomplete');
    if (autocomplete_element) {
        openregisterLocationPicker({
            selectElement: autocomplete_element,
            url: '/assets/govuk-country-and-territory-autocomplete/dist/location-autocomplete-graph.json'
        })
    }
});
