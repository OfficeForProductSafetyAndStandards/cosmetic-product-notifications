function simpleAccessibleAutocomplete(id) { // eslint-disable-line no-unused-vars
  var element = document.getElementById(id);
  if (element) {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: element,
      preserveNullOptions: true
    });
    // In the case that the user deletes the entry from the field, we want this to be reflected in the underlying select
    // This is a work-around to https://github.com/alphagov/accessible-autocomplete/issues/205
    var $enhancedElement = $(element).parent().find('input');
    $enhancedElement.on('keyup', function () {
      if ($enhancedElement.val() !== $(element).find('option:selected').text()) {
          $(element).val('');
      }
    });
  }
}

function searchOnInputChange(inputElement, url, buildQuery, callback) { // eslint-disable-line no-unused-vars
  var debounceTimeout = null;
  var searchRequest = null;
  inputElement.on('keyup change', function () {
    clearTimeout(debounceTimeout);
    if (searchRequest) {
      // Cancel previous outstanding requests
      searchRequest.abort();
    }
    // Don't send requests all the time, just every 500ms
    debounceTimeout = setTimeout(function () {
      searchRequest = $.get(url, buildQuery())
        .done(callback);
    }, 500);
  });
}
