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
    $('.new-product-page .gtin-input').on('keyup change', function() {
        const gtinInput = this;
        clearTimeout(debounceTimeout);
        if (searchRequest) {
            // Cancel previous outstanding requests
            searchRequest.abort();
        }
        // Don't send requests all the time, just every 500ms
        debounceTimeout = setTimeout(function() {
            searchRequest = $.get('/products/table', {q: $(gtinInput).val()})
                .done(function(data) {
                    $('#suggested-products').html(data);
                });
        }, 500);
    });
}
