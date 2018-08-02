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
    business = add_sic_code_to_business(business, response)
    business.source ||= ReportSource.new(name: "Companies House")
    business.save
    add_registered_address_to_business(business, response)
    business
  end

  def add_registered_address_to_business(business, response)
    return if response["registered_office_address"].nil?
    registered_office_address = business.primary_address || business.addresses.build
    registered_office_address.address_type = "Registered office address"
    registered_office_address = assign_address_details_from_response(registered_office_address, response)
    registered_office_address.source ||= ReportSource.new(name: "Companies House")
    registered_office_address.save
  end

  def assign_address_details_from_response(address, response)
    address.line_1 = response["registered_office_address"]["address_line_1"]
    address.line_2 = response["registered_office_address"]["address_line_2"]
    address.locality = response["registered_office_address"]["locality"]
    address.country = response["registered_office_address"]["country"]
    address.postal_code = response["registered_office_address"]["postal_code"]
    address
  end

  def add_sic_code_to_business(business, response)
    business.nature_of_business_id = response["sic_codes"][0] if response["sic_codes"].present?
    business
  end
end
