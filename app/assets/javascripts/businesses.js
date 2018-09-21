/* globals simpleAccessibleAutocomplete, searchOnTextInput, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('company-type');
  simpleAccessibleAutocomplete('company-status');
  simpleAccessibleAutocomplete('sic-code');

  searchOnTextInput(
    $('.new-business-page .search-term'),
    '/businesses/search',
    buildCompaniesHouseQuery,
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
