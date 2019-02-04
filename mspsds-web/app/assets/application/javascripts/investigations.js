import $ from 'jquery';
import { simpleAccessibleAutocomplete } from './autocomplete';

$(document).ready(function () {
  simpleAccessibleAutocomplete('assignee-picker-select_someone_else');
  simpleAccessibleAutocomplete('assignee-picker-select_other_team', { showAllValues: true });
  simpleAccessibleAutocomplete('assignee-picker-select_previously_assigned', { showAllValues: true });
  simpleAccessibleAutocomplete('assignee-picker-select_team_member', { showAllValues: true });
});
