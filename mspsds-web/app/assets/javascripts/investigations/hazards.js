$(document).ready(function () {
  var element = $('#hazard-type-autocomplete-container')[0];
  var id = 'hazard-type-autocomplete';
  accessibleAutocomplete({
    element: element,
    id: id,
    name: 'new[report][hazardType]',
    showAllValues: true
  });
});
