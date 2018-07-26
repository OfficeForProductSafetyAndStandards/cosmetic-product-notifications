require "net/http"
require "json"

module BusinessesHelper
  COMPANIES_HOUSE_BASE_URL = "https://api.companieshouse.gov.uk/".freeze

  def companies_house_businesses(search_term)
    uri = URI(COMPANIES_HOUSE_BASE_URL + "search?q=#{search_term}")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV["COMPANIES_HOUSE_API_KEY"], ""

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
      http.request(req)
    }
    JSON.parse(res.body)["items"].collect do |business|
      {
        company_name: business["title"],
        company_number: business["company_number"]
      }
    end
  end
end
