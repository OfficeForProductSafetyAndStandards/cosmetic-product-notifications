/* globals simpleAccessibleAutocomplete, searchOnInputChange */
$(document).ready(function () {
  simpleAccessibleAutocomplete('company-type');
  simpleAccessibleAutocomplete('company-status');
  simpleAccessibleAutocomplete('sic-code');
  var $form = $('.new-business-page form');
  $form.find('#search-button').remove();

  searchOnInputChange(
    $form.find('.search-trigger input, .search-trigger textarea'),
    '/businesses/suggested',
    function () {
      return $form.find(':not(input[type=hidden])').serialize();
    },
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
