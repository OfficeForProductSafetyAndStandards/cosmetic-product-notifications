import $ from 'jquery';
import { simpleAccessibleAutocomplete } from '../autocomplete';

$(document).ready(() => {
  simpleAccessibleAutocomplete('product-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('business-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('legislation-picker', { showAllValues: true });
});
