import $ from 'jquery';
import { simpleAccessibleAutocomplete } from '../autocomplete';

$(document).ready(() => {
  simpleAccessibleAutocomplete('picker-product_id', { showAllValues: true });
  simpleAccessibleAutocomplete('picker-business_id', { showAllValues: true });
  simpleAccessibleAutocomplete('picker-legislation', { showAllValues: true });
});
