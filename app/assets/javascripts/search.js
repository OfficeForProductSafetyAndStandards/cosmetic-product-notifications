function simpleAccessibleAutocomplete(id) {
    if (document.getElementById(id)) {
        accessibleAutocomplete.enhanceSelectElement({
            defaultValue: "",
            selectElement: document.getElementById(id),
            preserveNullOptions: true
        });
    }
}

function searchOnTextInput(inputElement, url, buildQuery, callback) {
    var debounceTimeout = null;
    var searchRequest = null;
    inputElement.on('keyup change', function() {
        clearTimeout(debounceTimeout);
        if (searchRequest) {
            // Cancel previous outstanding requests
            searchRequest.abort();
        }
        // Don't send requests all the time, just every 500ms
        debounceTimeout = setTimeout(function() {
            searchRequest = $.get(url, buildQuery())
                .done(callback);
        }, 500);
    });
}


function getIdsFromOptions(selectElement) {
    return selectElement.find("option").map(function() {
        return $(this).val();
    });
}