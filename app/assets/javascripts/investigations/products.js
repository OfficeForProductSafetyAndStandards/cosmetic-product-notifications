$(document).on("turbolinks:load", function() {
    var investigationId = $(".products-search-form").data("investigation-id");
    var excludedProductIds = $(".products-search-form").data("product-ids");
    searchOnTextInput(
        $('.investigation-product-page .search-term'),
        "/investigations/" + investigationId + "/products/suggested?excluded_products=" + excludedProductIds,
        buildProductQuery,
        function(data) {
            $('#suggested-products').html(data);
        }
    );
});