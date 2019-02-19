import $ from 'jquery';
import { simpleAccessibleAutocomplete } from './autocomplete';

$(document).ready(() => {
  simpleAccessibleAutocomplete('picker-hazard_type', { showAllValues: true });
  simpleAccessibleAutocomplete('picker-product_category', { showAllValues: true });
});
