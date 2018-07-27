$(document).on("turbolinks:load", function() {
    addSelect2AjaxSearchToElement($(".js-investigation-products"), "/products", mapAjaxDataToProduct);
    addSelect2AjaxSearchToElement($(".js-investigation-businesses"), "/businesses", mapAjaxDataToBusiness);
});

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