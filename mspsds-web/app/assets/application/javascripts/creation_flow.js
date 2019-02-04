import $ from 'jquery';
import { simpleAccessibleAutocomplete } from './autocomplete';

$(document).ready(function () {
  simpleAccessibleAutocomplete('hazard-type-picker', { showAllValues: true });
  simpleAccessibleAutocomplete('product-category-picker', { showAllValues: true });
});
