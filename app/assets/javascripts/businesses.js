$(document).on("turbolinks:load", function() {
    $('.js-business-company-type').select2();
    $('.js-business-sic-codes').select2();

    searchOnTextInput(
        $('.new-business-page .search-term'),
        '/businesses/search',
        buildCompaniesHouseQuery,
        function(data) {
            $('#suggested-businesses').html(data);
        }
    );
});

function buildCompaniesHouseQuery() {
    return {
        q: $('.new-business-page .search-term').val()
    };
}
