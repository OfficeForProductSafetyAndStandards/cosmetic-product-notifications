$(document).ready(function () {
    var values = ["Asphyxiation", "Burns", "Chemical", "Choking", "Cuts", "Damage to hearing", "Damage to sight", "Drowning", "Electric shock", "Electromagnetic disturbance", "Energy consumption", "Entrapment", "Environment", "Fire", "Health risk/other", "Injuries", "Incorrect measurement", "Microbiological", "Security", "Strangulation", "Suffocation", "Other",];
    var element = document.querySelector('#hazard-type-autocomplete-container');
    var id = 'hazard-type-autocomplete';
    accessibleAutocomplete({
        element: element,
        id: id,
        name: "new[report][hazardType]",
        showAllValues: true,
        source: values
    })
});
