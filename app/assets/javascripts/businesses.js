/* globals simpleAccessibleAutocomplete, searchOnInputChange, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('company-type');
  simpleAccessibleAutocomplete('company-status');
  simpleAccessibleAutocomplete('sic-code');
  $('#search-button').hide();

  searchOnInputChange(
    $('.new-business-page input, .new-business-page textarea'),
    '/businesses/search',
    buildCompaniesHouseQuery,
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
