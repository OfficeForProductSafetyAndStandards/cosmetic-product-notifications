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

    searchOnTextInput($('.new-product-page .search-term'), "/products/suggested", buildProductQuery, function(data) {
        $('#suggested-products').html(data);
    });
});
