import $ from 'jquery';

function dateInput(idPrefix) {
  $(document).ready(() => {
    const dateObj = new Date();
    const currentDay = dateObj.getUTCDate();
    const currentMonth = dateObj.getUTCMonth() + 1;
    const currentYear = dateObj.getUTCFullYear();
    const today = document.getElementById('today');
    const yesterday = document.getElementById('yesterday');
    today.onclick = function setDateToToday() {
      const day = document.getElementById(`${idPrefix}[day]`);
      day.value = currentDay;
      const month = document.getElementById(`${idPrefix}[month]`);
      month.value = currentMonth;
      const year = document.getElementById(`${idPrefix}[year]`);
      year.value = currentYear;
    };
    yesterday.onclick = function setDateToYesterday() {
      const day = document.getElementById(`${idPrefix}[day]`);
      day.value = currentDay - 1;
      const month = document.getElementById(`${idPrefix}[month]`);
      month.value = currentMonth;
      const year = document.getElementById(`${idPrefix}[year]`);
      year.value = currentYear;
    };
  });
}

window.dateInput = dateInput;
