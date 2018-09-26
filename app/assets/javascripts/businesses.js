/* globals simpleAccessibleAutocomplete, searchOnInputChange, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('company-type');
  simpleAccessibleAutocomplete('company-status');
  simpleAccessibleAutocomplete('sic-code');
  $('#search-button').hide();

  searchOnInputChange(
    $('.new-business-page .search-trigger input, .new-business-page .search-trigger textarea'),
    '/businesses/search',
    buildCompaniesHouseQuery,
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
