function buildProductQuery() {
    var query = {};
    var q = $('.products-search-form .search-term:not(#gtin-input)')
        .map(function() {
            return $(this).val();
        })
        .get()
        .filter(function(searchTerm) {
            return searchTerm;
        })
        .map(function(searchTerm) {
            // TODO: When doing the advanced products search, we should re-evaluate how we do the
            // search here too
            return searchTerm + "*"
        }).join(" OR ");
    var gtin = $('.products-search-form #gtin-input').val();
    if (q) {
        query.q = q;
    }
    if (gtin) {
        query.gtin = gtin;
    }
    return query;
}
