$(document).on("turbolinks:load", function() {
    searchOnTextInput($('.new-business-page .companies-house-search-term'), '/businesses/companies_house', buildCompaniesHouseQuery, function(data) {
        $('#companies-house-businesses').html(data);
    });
});

function buildCompaniesHouseQuery() {
    return {
        q: $('.new-business-page .companies-house-search-term').val()
    };
}
