module BusinessesHelper
  include SearchHelper

  BUSINESS_SUGGESTION_LIMIT = 3

  def defaults_on_primary_address(business)
    business.primary_address.address_type ||= "Registered office address"
    business.primary_address.source ||= UserSource.new(user: current_user)
    business
  end

  def search_for_businesses(page_size)
    Business.fuzzy_search(search_params)
            .paginate(page: params[:page], per_page: page_size)
            .records
  end

  def sort_column
    Business.column_names.include?(params[:sort]) ? params[:sort] : "cases"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def search_companies_house(query, page_size)
    companies_house_response = CompaniesHouseClient.instance.companies_house_businesses(query)
    filter_out_existing_businesses(companies_house_response)
      .first(page_size)
  end

  def filter_out_existing_businesses(businesses)
    businesses.reject { |business| Business.exists?(company_number: business[:company_number]) }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def business_params
    params.require(:business).permit(
      :company_name,
      :company_type_code,
      :nature_of_business_id,
      :additional_information,
      addresses_attributes: %i[id line_1 line_2 locality country postal_code _destroy]
    )
  end
end
