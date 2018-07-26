require "net/http"
require "json"

module BusinessesHelper
  COMPANIES_HOUSE_BASE_URL = "https://api.companieshouse.gov.uk/".freeze

  def companies_house_businesses(search_term)
    uri = URI(COMPANIES_HOUSE_BASE_URL + "search/companies?q=#{search_term}")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV["COMPANIES_HOUSE_API_KEY"], ""

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(res.body)["items"].collect do |business|
      {
        company_name: business["title"],
        company_number: business["company_number"]
      }
    end
  end

  def create_business_from_companies_house_number(company_number)
    uri = URI(COMPANIES_HOUSE_BASE_URL + "company/#{company_number}")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth ENV["COMPANIES_HOUSE_API_KEY"], ""
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    create_business_from_companies_house_response JSON.parse(res.body)
  end

  private

  def create_business_from_companies_house_response(response)
    business = Business.new(
      company_number: response["company_number"],
      company_name: response["company_name"],
      company_type_code: response["type"]
    )
    if response["registered_office_address"].present?
      business.registered_office_address_line_1 = response["registered_office_address"]["address_line_1"]
      business.registered_office_address_line_2 = response["registered_office_address"]["address_line_2"]
      business.registered_office_address_locality = response["registered_office_address"]["locality"]
      business.registered_office_address_country = response["registered_office_address"]["country"]
      business.registered_office_address_postal_code = response["registered_office_address"]["postal_code"]
    end

    business.nature_of_business_id = response["sic_codes"][0] if response["sic_nodes"].present?
    business.source = ReportSource.new(name: "Companies House")
    business
  end
end
