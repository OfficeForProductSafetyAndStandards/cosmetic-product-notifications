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
    let debounceTimeout = null;
    let searchRequest = null;
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
    const query = {};
    const q = $('.new-product-page .search-term:not(#gtin-input)')
        .map(function() {
            return $(this).val();
        })
        .get()
        .filter(function(searchTerm) {
            console.log(searchTerm);
            return searchTerm;
        })
        .map(function(searchTerm) {
            return searchTerm + "*"
        }).join(" OR ");
    const gtin = $('.new-product-page #gtin-input').val();
    if (q) {
        query.q = q;
    }
    if (gtin) {
        query.gtin = gtin;
    }
    return query;
}
