$(document).on("turbolinks:load", function() {
    addSelect2AjaxSearchToElement($(".js-assignee-email"), "/users", mapAjaxDataToEmail);
});

function mapAjaxDataToEmail(data) {
    return {
        id: data.email,
        text: data.email
    }
}
