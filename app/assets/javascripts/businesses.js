$(document).on("turbolinks:load", function() {
    $('.js-business-company-type').select2();
    $('.js-business-sic-codes').select2();

    searchOnTextInput(
        $('.new-business-page .companies-house-search-term'),
        '/businesses/search_companies_house',
        buildCompaniesHouseQuery,
        function(data) {
            $('#companies-house-businesses').html(data);
        }
    );
});

function buildCompaniesHouseQuery() {
    return {
        q: $('.new-business-page .companies-house-search-term').val()
    };
}
