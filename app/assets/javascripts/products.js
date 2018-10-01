/* globals searchOnInputChange, buildProductQuery */
$(document).on('turbolinks:load', function () {
  searchOnInputChange($('.new-product-page .search-term'), '/products/suggested', buildProductQuery, function (data) {
    $('#suggested-products').html(data);
  });
});
