/* globals simpleAccessibleAutocomplete */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('product-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('business-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('legislation-picker', { showAllValues: true });
});
