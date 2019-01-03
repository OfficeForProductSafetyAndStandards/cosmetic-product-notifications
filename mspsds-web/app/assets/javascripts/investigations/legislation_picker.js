$(document).ready(function () {
  var legislationContainer = document.getElementById('legislation-autocomplete-container');
  var legislationInput = document.getElementById('legislation-input');

  if (legislationContainer) {
    $(legislationInput).remove();

    var model = $(legislationContainer).data('model');
    var value = $(legislationContainer).data('value');
    var source = $(legislationContainer).data('options');

    accessibleAutocomplete({
      element: legislationContainer,
      id: model + '_legislation',
      name: model + '[legislation]',
      showNoOptionsFound: false,
      showAllValues: true,
      defaultValue: value,
      source: source
    });
  }
});
