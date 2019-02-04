$(document).ready(function () {
    var element = document.querySelector('#hazard-type-autocomplete-container');
    var id = 'hazard-type-autocomplete';
    accessibleAutocomplete({
        element: element,
        id: id,
        name: "new[report][hazardType]",
        showAllValues: true
    })
});
