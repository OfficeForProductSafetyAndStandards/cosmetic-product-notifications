import $ from 'jquery';
import accessibleAutocomplete from 'accessible-autocomplete';

export function simpleAccessibleAutocomplete(id, autocompleteOptions) {
  const element = document.getElementById(id);
  const options = autocompleteOptions || {};
  if (element) {
    accessibleAutocomplete.enhanceSelectElement({
      defaultValue: '',
      selectElement: element,
      showAllValues: options.showAllValues,
      preserveNullOptions: true,
    });
    // In the case that the user deletes the entry from the field, we want this to be reflected in
    // the underlying select. This is a work-around to
    // https://github.com/alphagov/accessible-autocomplete/issues/205
    const $enhancedElement = $(element).parent().find('input');
    $enhancedElement.on('keyup', () => {
      if ($enhancedElement.val() !== $(element).find('option:selected').text()) {
        $(element).val('');
      }
    });
  }
}
