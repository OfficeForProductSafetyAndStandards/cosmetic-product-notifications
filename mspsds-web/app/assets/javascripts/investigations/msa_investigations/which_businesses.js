$(document).ready(function () {
    var normalElements = [
        document.getElementById('new-business-type-1'),
        document.getElementById('new-business-type-2'),
        document.getElementById('new-business-type-3'),
        document.getElementById('new-business-type-4')
    ];
    var elementOther = document.getElementById('new-business-type-5');
    var elementNone = document.getElementById('new-business-type-none-1');

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
