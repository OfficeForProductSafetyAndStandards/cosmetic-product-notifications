import $ from 'jquery';
import accessibleAutocomplete from 'accessible-autocomplete';

$(document).ready(() => {
  const legislationContainer = document.getElementById('legislation-autocomplete-container');
  const legislationInput = document.getElementById('legislation-input');

  if (legislationContainer) {
    $(legislationInput).remove();

    const model = $(legislationContainer).data('model');
    const value = $(legislationContainer).data('value');
    const source = $(legislationContainer).data('options');

    accessibleAutocomplete({
      element: legislationContainer,
      id: `${model}_legislation`,
      name: `${model}[legislation]`,
      showNoOptionsFound: false,
      showAllValues: true,
      defaultValue: value,
      source,
    });
  }
});
