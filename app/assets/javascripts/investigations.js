$(document).on("turbolinks:load", function() {
    addSelect2AjaxSearchToElement($(".js-investigation-products"), "/products", mapAjaxDataToProduct);
    addSelect2AjaxSearchToElement($(".js-investigation-businesses"), "/businesses", mapAjaxDataToBusiness);
});

function addSelect2AjaxSearchToElement(selectElement, url, mapData) {
    selectElement.select2({
        ajax: {
            url: url,
            dataType: "json",
            delay: 250,
            data: function(params) {
                var query = {
                    q: params.term,
                    page: params.page || 1
                }
                return query
            },
            processResults: function (data) {
                return {
                    results: data.map(mapData)
                };
            }
        }
    }).val(getIdsFromOptions(selectElement)).trigger("change");
}

function getIdsFromOptions(selectElement) {
    return selectElement.find("option").map(function() {
        return $(this).val();
    });
}

function mapAjaxDataToProduct(data) {
    return {
        id: data.id,
        text: [data.name, data.brand].join(" - ")
    }
}

function mapAjaxDataToBusiness(data) {
    return {
        id: data.id,
        text: data.company_name
    }
}