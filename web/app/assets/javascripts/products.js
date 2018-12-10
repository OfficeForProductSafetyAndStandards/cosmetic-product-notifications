/* globals searchOnInputChange */
$(document).ready(function () {
  var $form = $('.new-product-page form');
  $form.find('#search-button').remove();
  searchOnInputChange(
    $form.find('.search-term'),
    '/products/suggested',
    function () {
      return $form.serialize();
    },
    function (data) {
      $('#suggested-products').html(data);
    }
  );
});
