require "net/http"
require "json"

module CountriesHelper
  PATH_TO_COUNTRIES_LIST =
    "node_modules/govuk-country-and-territory-autocomplete/dist/location-autocomplete-canonical-list.json".freeze

  # JSON is of the form [["Abu Dhabi", "territory:AE-AZ"], ["Afghanistan", "country:AF"]]
  def country_from_code(code)
    all_countries.find { |country| country[1] == code }[0]
  end

  def all_countries
    JSON.parse(File.read(PATH_TO_COUNTRIES_LIST))
  end
end
