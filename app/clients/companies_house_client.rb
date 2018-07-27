require "companies_house/client"

class CompaniesHouseClient
  include Singleton

  def initialize
    @client = CompaniesHouse::Client.new(api_key: ENV["COMPANIES_HOUSE_API_KEY"])
    super
  end

  def companies_house_businesses(search_term)
    response = @client.company_search(search_term)
    response["items"].collect do |business|
      {
        company_name: business["title"],
        company_number: business["company_number"],
        url: Rails.application.config.view_company_url + business["company_number"]
      }
    end
  end

  def create_business_from_companies_house_number(company_number)
    profile = @client.company(company_number)
    create_business_from_companies_house_response(profile)
  end

  def update_business_from_companies_house(business)
    profile = @client.company(business.company_number)
    add_companies_house_response_to_business(business, profile)
  end

  private

  def create_business_from_companies_house_response(response)
    add_companies_house_response_to_business(Business.new, response)
  end

  def add_companies_house_response_to_business(business, response)
    business.company_number = response["company_number"]
    business.company_name = response["company_name"]
    business.company_type_code = response["type"]
    business = add_registered_address_to_business(business, response)
    business = add_sic_code_to_business(business, response)
    business.source = ReportSource.new(name: "Companies House")
    business
  end

  def add_registered_address_to_business(business, response)
    if response["registered_office_address"].present?
      business.registered_office_address_line_1 = response["registered_office_address"]["address_line_1"]
      business.registered_office_address_line_2 = response["registered_office_address"]["address_line_2"]
      business.registered_office_address_locality = response["registered_office_address"]["locality"]
      business.registered_office_address_country = response["registered_office_address"]["country"]
      business.registered_office_address_postal_code = response["registered_office_address"]["postal_code"]
    end
    business
  end

  def add_sic_code_to_business(business, response)
    business.nature_of_business_id = response["sic_codes"][0] if response["sic_codes"].present?
    business
  end
end
