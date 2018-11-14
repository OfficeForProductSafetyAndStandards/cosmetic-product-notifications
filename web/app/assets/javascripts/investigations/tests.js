/* globals simpleAccessibleAutocomplete */
$(document).on('turbolinks:load', function () {
  simpleAccessibleAutocomplete('test_product_id');

  var legislationContainer = document.getElementById('legislation-autocomplete-container');
  if (legislationContainer) {
    $('#test_legislation').remove();

    var value = $(legislationContainer).data('value');
    var source = $(legislationContainer).data('options');

    accessibleAutocomplete({
      element: legislationContainer,
      id: 'test_legislation',
      name: 'test[legislation]',
      showNoOptionsFound: false,
      showAllValues: true,
      defaultValue: value,
      source: source
    });
  }

  var attachmentFileInput = document.getElementById('attachment-file-input');
  var attachmentDescription = document.getElementById('attachment-description');
  var currentAttachmentDetails = document.getElementById('current-attachment-details');

  if (attachmentFileInput) {
    attachmentFileInput.onchange = function() {
      if (this.value) {
        $(attachmentDescription).show();
      } else {
        $(attachmentDescription).hide();
      }
    }
  }

  if (attachmentDescription) {
    if (currentAttachmentDetails) {
      $(attachmentDescription).show();
    } else {
      $(attachmentDescription).hide();
    }
  }
});
