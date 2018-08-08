require "net/http"
require "json"

module CountriesHelper
  COUNTRIES_REGISTER_URL = "https://country.register.gov.uk/records.json?page-size=5000".freeze

  def all_countries
    fetch_countries
  end

  def fetch_countries
    uri = URI(COUNTRIES_REGISTER_URL)
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = ENV["COMPANIES_HOUSE_API_KEY"]

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(res.body).collect do |country|
      country[1]["item"][0]["name"]
    end
  end
end
