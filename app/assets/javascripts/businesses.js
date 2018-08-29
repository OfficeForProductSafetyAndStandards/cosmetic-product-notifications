$(document).on("turbolinks:load", function() {
    simpleAccessibleAutocomplete("company-type");
    simpleAccessibleAutocomplete("sic-code");

    searchOnTextInput(
        $('.new-business-page .search-term'),
        '/businesses/search',
        buildCompaniesHouseQuery,
        function(data) {
            $('#suggested-businesses').html(data);
        }
    );
});
