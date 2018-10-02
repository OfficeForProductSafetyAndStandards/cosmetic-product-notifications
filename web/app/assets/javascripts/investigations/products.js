/* globals searchOnInputChange */
$(document).on('turbolinks:load', function () {
  let $page = $('.investigation-product-page');
  var investigationId = $page.data('investigation-id');
  var excludedProductIds = $page.data('product-ids');
  $page.find('#search-button').remove();
  searchOnInputChange(
    $page.find('.search-term'),
    '/investigations/' + investigationId + '/products/suggested?excluded_products=' + excludedProductIds,
    function () {
      return $page.find('form').serialize();
    },
    function (data) {
      $('#suggested-products').html(data);
    }
  );
});
