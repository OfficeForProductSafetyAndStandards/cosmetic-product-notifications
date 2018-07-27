require_relative "../clients/companies_house_client"

module BusinessesHelper
  def companies_house_client
    CompaniesHouseClient.instance
  end
end
