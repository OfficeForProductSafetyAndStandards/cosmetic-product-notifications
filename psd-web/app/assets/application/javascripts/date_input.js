import $ from 'jquery';

function dateInput() {
  $(document).ready(() => {
    var dateObj = new Date();
    var current_day = dateObj.getUTCDate();
    var current_month = dateObj.getUTCMonth() + 1;
    var current_year = dateObj.getUTCFullYear();
    var today = document.getElementById("today");
    var yesterday = document.getElementById("yesterday");
    today.onclick = function() {
      var day = document.getElementById('enquiry_date_received-enquiry[date_received][day]');
      day.value = current_day;
      var month = document.getElementById('enquiry_date_received-enquiry[date_received][month]');
      month.value = current_month;
      var year = document.getElementById('enquiry_date_received-enquiry[date_received][year]');
      year.value = current_year;
    }
    yesterday.onclick = function() {
        var day = document.getElementById('enquiry_date_received-enquiry[date_received][day]');
        day.value = current_day - 1;
        var month = document.getElementById('enquiry_date_received-enquiry[date_received][month]');
        month.value = current_month;
        var year = document.getElementById('enquiry_date_received-enquiry[date_received][year]');
        year.value = current_year;
      }
  });
}

window.dateInput = dateInput;
