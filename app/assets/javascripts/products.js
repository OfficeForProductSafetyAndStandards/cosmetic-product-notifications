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

    if ($("#suggested-products")) {
        searchOnTextInput($('.new-product-page .search-term'), buildSuggestedUrl(), buildProductQuery, function(data) {
            $('#suggested-products').html(data);
        });
    }

    // Rails date_select does not allow the setting of classes
    $('.date-select-control select').addClass("form-control");

    openregisterLocationPicker({
        selectElement: document.getElementById('location-autocomplete'),
        url: '/assets/govuk-country-and-territory-autocomplete/dist/location-autocomplete-graph.json'
    })
});

function buildSuggestedUrl() {
    var url = "/products/suggested";
    var investigationId = $(".new-product-page").data("investigation-id");
    if(investigationId) {
        url = "/investigations/" + investigationId + url;
    }
    return url;
}
