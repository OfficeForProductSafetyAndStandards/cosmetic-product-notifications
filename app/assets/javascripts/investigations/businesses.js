/* globals searchOnInputChange, buildCompaniesHouseQuery */
$(document).on('turbolinks:load', function () {
  var $form = $('.investigation-business-page');
  var investigationId = $form.data('investigation-id');
  var excludedBusinessIds = $form.data('business-ids');
  $form.find('#search-button').hide();

  searchOnInputChange(
    $form.find('input, textarea'),
    '/investigations/' + investigationId + '/businesses/suggested?excluded_businesses=' + excludedBusinessIds,
    buildCompaniesHouseQuery,
    function (data) {
      $('#suggested-businesses').html(data);
    }
  );
});
