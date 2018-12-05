/* globals simpleAccessibleAutocomplete */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('hazard-type-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('product-type-picker', { showAllValues: true });
});
