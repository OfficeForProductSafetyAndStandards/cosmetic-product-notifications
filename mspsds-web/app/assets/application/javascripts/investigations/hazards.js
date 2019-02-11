import $ from 'jquery';
import accessibleAutocomplete from 'accessible-autocomplete';

$(document).ready(() => {
  const element = $('#hazard-type-autocomplete-container')[0];
  const id = 'hazard-type-autocomplete';
  accessibleAutocomplete({
    element,
    id,
    name: 'new[report][hazardType]',
    showAllValues: true,
  });
});
