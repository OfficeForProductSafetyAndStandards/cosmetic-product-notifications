$(document).ready(function () {
    var normalElements = [
        document.getElementById('businesses_retailer'),
        document.getElementById('businesses_distributor'),
        document.getElementById('businesses_importer'),
        document.getElementById('businesses_manufacturer')
    ];
    var elementOther = document.getElementById('businesses_other');
    var elementNone = document.getElementById('businesses_none');

    var deselectOthers = function() {
        normalElements.forEach(function(element) {element.checked = false});
        if (elementOther.checked) {
            elementOther.click();
            elementNone.checked = true;
        }
    };

    var deselectNone = function() {
        elementNone.checked = false;
    };

    elementNone.addEventListener("input", deselectOthers);

    normalElements.forEach(function(element) {
        element.addEventListener("input", deselectNone)
    });

    elementOther.addEventListener("input", deselectNone)
});
