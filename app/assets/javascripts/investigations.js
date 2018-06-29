// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {
    $(".js-investigation-products").select2({
        ajax: {
            url: "/products",
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
                // Tranforms the top-level key of the response object from 'items' to 'results'
                return {
                    results: data.map(function(product) {
                        return {
                            id: product.id,
                            text: [product.name, product.brand].join(" - ")
                        }
                    })
                };
            }
            // Additional AJAX parameters go here; see the end of this chapter for the full code of this example
        }
    }).val(getIdsFromOptions()).trigger("change");
});

function getIdsFromOptions() {
    return $(".js-investigation-products option").map(function() {
        return $(this).val();
    });
}