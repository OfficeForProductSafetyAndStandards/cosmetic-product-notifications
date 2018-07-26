$(document).on("turbolinks:load", function() {
    $('.slider-nav').slick({
        slidesToShow: 3,
        slidesToScroll: 1,
        dots: true,
        arrows: true,
        centerMode: true,
        focusOnSelect: true,
        adaptiveHeight: true,
    });

    handleSearchInput();
});

function handleSearchInput() {
    var debounceTimeout = null;
    var searchRequest = null;
    $('.new-product-page .search-term').on('keyup change', function() {
        clearTimeout(debounceTimeout);
        if (searchRequest) {
            // Cancel previous outstanding requests
            searchRequest.abort();
        }
        // Don't send requests all the time, just every 500ms
        debounceTimeout = setTimeout(function() {
            searchRequest = $.get('/products/table', buildQuery())
                .done(function(data) {
                    $('#suggested-products').html(data);
                });
        }, 500);
    });
}

function buildQuery() {
    var query = {};
    var q = $('.new-product-page .search-term:not(#gtin-input)')
        .map(function() {
            return $(this).val();
        })
        .get()
        .filter(function(searchTerm) {
            return searchTerm;
        })
        .map(function(searchTerm) {
            return searchTerm + "*"
        }).join(" OR ");
        var gtin = $('.new-product-page #gtin-input').val();
    if (q) {
        query.q = q;
    }
    if (gtin) {
        query.gtin = gtin;
    }
    return query;
}
