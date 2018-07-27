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

function addSelect2AjaxSearchToElement(selectElement, url, mapData) {
    selectElement.select2({
        ajax: {
            url: url,
            dataType: "json",
            delay: 250,
            data: function(params) {
                var query = {
                    q: params.term,
                    page: params.page || 1
                }
                return query
            },
            processResults: function (data) {
                return {
                    results: data.map(mapData)
                };
            }
        }
    }).val(getIdsFromOptions(selectElement)).trigger("change");
}

function getIdsFromOptions(selectElement) {
    return selectElement.find("option").map(function() {
        return $(this).val();
    });
}