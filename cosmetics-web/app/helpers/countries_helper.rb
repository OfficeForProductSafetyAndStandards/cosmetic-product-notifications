require "net/http"
require "json"

# UnusedCodeAlerting
# This module seems unused. Delete it if all methods are unused.
module CountriesHelper
  PATH_TO_COUNTRIES_LIST =
    "node_modules/govuk-country-and-territory-autocomplete/dist/location-autocomplete-canonical-list.json".freeze
  CACHE_KEY = "all_countries".freeze

  # JSON is of the form [["Abu Dhabi", "territory:AE-AZ"], ["Afghanistan", "country:AF"]]
  def country_from_code(code)
    UnusedCodeAlerting.alert
    country = all_countries.find { |c| c[1] == code }
    (country && country[0]) || code
  end

  def all_countries
    UnusedCodeAlerting.alert
    Rails.cache.fetch(CACHE_KEY, expires_in: 28.days) do
      JSON.parse(File.read(PATH_TO_COUNTRIES_LIST))
    end
  end
end
