/* globals searchOnInputChange */
$(document).ready(function () {
  var $page = $('.investigation-product-page');
  var investigationId = $page.data('investigation-id');
  var excludedProductIds = $page.data('product-ids');
  $page.find('#search-button').remove();
  searchOnInputChange(
    $page.find('.search-term'),
    '/cases/' + investigationId + '/products/suggested?excluded_products=' + excludedProductIds,
    function () {
      return $page.find('form').find(':not(input[type=hidden])').serialize();
    },
    function (data) {
      $('#suggested-products').html(data);
    }
  );
});
