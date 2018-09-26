/* globals searchOnTextInput, buildProductQuery */
$(document).on('turbolinks:load', function () {
  searchOnTextInput($('.new-product-page .search-term'), '/products/suggested', buildProductQuery, function (data) {
    $('#suggested-products').html(data);
  });
});
