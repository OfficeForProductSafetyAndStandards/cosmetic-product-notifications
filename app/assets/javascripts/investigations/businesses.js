/* globals searchOnInputChange, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  var investigationId = $('.businesses-search-form').data('investigation-id');
  var excludedBusinessIds = $('.businesses-search-form').data('business-ids');
  searchOnInputChange(
    $('.investigation-business-page .search-term'),
    '/investigations/' + investigationId + '/businesses/suggested?excluded_businesses=' + excludedBusinessIds,
    buildCompaniesHouseQuery,
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
