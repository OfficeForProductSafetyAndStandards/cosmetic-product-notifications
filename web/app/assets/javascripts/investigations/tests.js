/* globals simpleAccessibleAutocomplete */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('test_product_id');

  var element = document.getElementById('legislation-autocomplete-container');
  var source = $(element).data('options');
  var value = $(element).data('value');

  if (element) {
    accessibleAutocomplete({
      element: element,
      id: 'test_legislation',
      name: 'test[legislation]',
      showNoOptionsFound: false,
      defaultValue: value,
      source: source
    });
  }
});
