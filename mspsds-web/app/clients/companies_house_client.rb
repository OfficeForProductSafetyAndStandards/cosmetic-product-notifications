require "companies_house/client"

class CompaniesHouseClient
  include Singleton

  class ClientException < StandardError
    def initialize(msg = nil)
      super(msg)
    end
  end

  def initialize
    @client = CompaniesHouse::Client.new(api_key: ENV["COMPANIES_HOUSE_API_KEY"])
    super
  end

  def companies_house_businesses(search_term)
    response = company_search(search_term)
    # Results shape definition at
    # https://developer.companieshouse.gov.uk/api/docs/search-overview/CompanySearch-resource.html
    response["items"].collect do |business|
      {
        company_name: business["title"],
        company_number: business["company_number"],
        company_type_code: business["company_type"],
        company_status_code: business["company_status"],
        url: Rails.application.config.view_company_url + business["company_number"]
      }
    end
  end

  def create_business_from_companies_house_number(company_number)
    profile = get_company(company_number)
    Business.from_companies_house_response(profile)
  end

  def update_business_from_companies_house(business)
    profile = get_company(business.company_number)
    business.with_company_house_info(profile)
  end

private

  def company_search(search_term)
    begin
      response = @client.company_search(search_term)
    rescue StandardError => e
      raise ClientException.new "Failed to search Companies House, #{e}"
    end
    response
  end

  def get_company(company_number)
    begin
      profile = @client.company(company_number)
    rescue StandardError => e
      raise ClientException.new "Failed to fetch business data from Companies House, #{e}"
    end
    profile
  end
end
