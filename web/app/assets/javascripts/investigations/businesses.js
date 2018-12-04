/* globals searchOnInputChange, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  var $page = $('.investigation-business-page');
  var investigationId = $page.data('investigation-id');
  var excludedBusinessIds = $page.data('business-ids');
  $page.find('#search-button').remove();

  searchOnInputChange(
    $page.find('.search-trigger input, .search-trigger textarea'),
    '/cases/' + investigationId + '/businesses/suggested?excluded_businesses=' + excludedBusinessIds,
    function () {
      return $page.find('form').serialize();
    },
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
