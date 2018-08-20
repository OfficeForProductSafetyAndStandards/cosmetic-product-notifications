$(document).on("turbolinks:load", function() {
    searchOnTextInput(
        $('.investigation-product-page .search-term'),
        `/investigations/${$(".products-search-form").data("investigation-id")}/products/suggested`,
        buildProductQuery,
        function(data) {
            $('#suggested-products').html(data);
        }
    );
});