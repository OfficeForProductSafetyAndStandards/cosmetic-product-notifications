/* globals simpleAccessibleAutocomplete, searchOnInputChange */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('company-type');
  simpleAccessibleAutocomplete('company-status');
  simpleAccessibleAutocomplete('sic-code');
  var $form = $('.new-business-page form');
  $form.find('#search-button').remove();

  searchOnInputChange(
    $form.find('.search-trigger input, .search-trigger textarea'),
    '/businesses/search',
    function () {
      return $form.serialize();
    },
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
