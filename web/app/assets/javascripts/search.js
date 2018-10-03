function simpleAccessibleAutocomplete(id) { // eslint-disable-line no-unused-vars
  if (document.getElementById(id)) {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: document.getElementById(id),
      preserveNullOptions: true
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
