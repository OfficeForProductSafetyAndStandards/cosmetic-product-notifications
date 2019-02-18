import $ from 'jquery';
import { simpleAccessibleAutocomplete } from './autocomplete';

$(document).ready(() => {
  simpleAccessibleAutocomplete('picker-select_someone_else');
  simpleAccessibleAutocomplete('picker-select_other_team', { showAllValues: true });
  simpleAccessibleAutocomplete('picker-select_previously_assigned', { showAllValues: true });
  simpleAccessibleAutocomplete('picker-select_team_member', { showAllValues: true });
});
