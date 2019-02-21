import $ from 'jquery';

$(document).ready(() => {
  if ($('#which-businesses-page').length) {
    const normalElements = [
      $('#businesses_retailer')[0],
      $('#businesses_distributor')[0],
      $('#businesses_importer')[0],
      $('#businesses_manufacturer')[0],
    ];
    const elementOther = $('#businesses_other')[0];
    const elementNone = $('#businesses_none')[0];

    const deselectOthers = () => {
      normalElements.forEach((element) => {
        element.checked = false; // eslint-disable-line no-param-reassign
      });
      if (elementOther.checked) {
        // This element must be clicked because it is responsible for showing and hiding a text box,
        // which doesn't happen if the checked property is manually set to true
        elementOther.click();
        elementNone.checked = true;
      }
    };

    const deselectNone = () => {
      elementNone.checked = false;
    };

    elementNone.addEventListener('input', deselectOthers);

    normalElements.forEach((element) => {
      element.addEventListener('input', deselectNone);
    });

    elementOther.addEventListener('input', deselectNone);
  }
});
