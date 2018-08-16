$(document).on("turbolinks:load", function() {
    addSelect2AjaxSearchToElement($(".js-investigation-products"), "/products", mapAjaxDataToProduct);
    addSelect2AjaxSearchToElement($(".js-investigation-businesses"), "/businesses", mapAjaxDataToBusiness);
    addSelect2AjaxSearchToElement($(".js-assignee-email"), "/businesses", mapAjaxDataToEmail);

    $(".js-assignee-email").select2()
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

function mapAjaxDataToEmail(data) {
    return {
        text: data.email + "som"
    }
}
