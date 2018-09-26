module BusinessesHelper
  include SearchHelper

  BUSINESS_SUGGESTION_LIMIT = 3

  def defaults_on_primary_address(business)
    business.primary_address.address_type ||= "Registered office address"
    business.primary_address.source ||= UserSource.new(user: current_user)
    business
  end

  def search_for_businesses(page_size)
    Business.full_search(search_query)
            .paginate(page: params[:page], per_page: page_size)
            .records
  end

  def sort_column
    Business.column_names.include?(params[:sort]) ? params[:sort] : "company_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def search_companies_house(query)
    companies_house_response = CompaniesHouseClient.instance.companies_house_businesses(query)
    filter_out_existing_businesses(companies_house_response)
  end

  def filter_out_existing_businesses(businesses)
    businesses.reject { |business| Business.exists?(company_number: business[:company_number]) }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def business_params
    params.require(:business).permit(
      :company_name,
      :company_type_code,
      :company_status_code,
      :nature_of_business_id,
      :additional_information,
      addresses_attributes: %i[id line_1 line_2 locality country postal_code _destroy]
    )
  end

  def companies_house_constants
    Rails.application.config.companies_house_constants
  end

  def create_business
    if params[:business]
      @business = Business.new(business_params)
      @business.addresses.build unless @business.addresses.any?
      defaults_on_primary_address(@business)
      @business.source = UserSource.new(user: current_user)
    else
      @business = Business.new
      @business.addresses.build
    end
  end

  def advanced_search(excluded_ids = [])
    @existing_businesses = search_for_similar_businesses(excluded_ids)
    @companies_house_businesses = search_companies_house_for_similar_businesses
  end

  def search_for_similar_businesses(excluded_ids)
    query = [@business.company_name, @business.additional_information].join(' ')
    filters = {}
    filters[:company_type_code] = @business.company_type_code if @business.company_type_code.present?
    filters[:company_status_code] = @business.company_status_code if @business.company_status_code.present?
    filters[:nature_of_business_id] = @business.nature_of_business_id if @business.nature_of_business_id.present?
    Business.full_search(ElasticsearchQuery.new(query, filters, {}))
      .paginate(per_page: 20) # Big enough to return BUSINESS_SUGGESTION_LIMIT after filters get applied
      .records
      .reject { |business| excluded_ids.include?(business.id) }
      .first(BUSINESS_SUGGESTION_LIMIT)
  end

  def search_companies_house_for_similar_businesses
    type_or_status_differ = lambda do |business|
      (@business.company_type_code.present? && @business.company_type_code != business[:company_type_code]) ||
      (@business.company_status_code.present? && @business.company_status_code != business[:company_status_code])
      # field matched by nature_of_business_id is not available on the search models returned by companies house
    end
    search_companies_house(@business.company_name)
      .reject(&type_or_status_differ)
      .first(BUSINESS_SUGGESTION_LIMIT)
  end
end
