function buildCompaniesHouseQuery() {
  return {
    q: $('.businesses-search-form .search-term').val()
  };
}
