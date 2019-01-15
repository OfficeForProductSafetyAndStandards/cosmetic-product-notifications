module BusinessesHelper
  include SearchHelper
  include UserService

  BUSINESS_SUGGESTION_LIMIT = 3

  def defaults_on_primary_location(business)
    business.primary_location.source ||= UserSource.new(user: current_user)
    business
  end

  def search_for_businesses(page_size)
    Business.full_search(search_query)
      .paginate(page: params[:page], per_page: page_size)
      .records
  end

  def sort_column
    Business.column_names.include?(params[:sort]) ? params[:sort] : "legal_name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def business_params
    params.require(:business).permit(
      :legal_name,
      :trading_name,
      :company_type_code,
      :company_status_code,
      :nature_of_business_id,
      :additional_information,
      location_attributes: %i[id address phone_number locality country postal_code _destroy],
      contact_attributes: %i[name email phone_number job_title]
    )
  end

  def companies_house_constants
    Rails.application.config.companies_house_constants
  end

  def companies_house_new_business_form_url
    @investigation.present? ? companies_house_investigation_businesses_path(@investigation) : companies_house_businesses_path
  end

  def create_business
    if params[:business]
      @business = Business.new(business_params)
      @business.locations.build unless @business.locations.any?
      @business.contacts.build unless @business.contacts.any?
      defaults_on_primary_location(@business)
      @business.source = UserSource.new(user: current_user)
    else
      @business = Business.new
      @business.locations.build
      @business.contacts.build
    end
  end

  def advanced_search(excluded_ids = [])
    @existing_businesses = search_for_similar_businesses(@business, excluded_ids)
    begin
      @companies_house_businesses = search_companies_house_for_similar_businesses(@business)
    rescue CompaniesHouseClient::ClientException => e
      Rails.logger.error e.message
      @companies_house_error = true
    end
  end

  def search_for_similar_businesses(business, excluded_ids)
    return [] if business.legal_name.blank?

    Business.search(query: {
      bool: {
        must: [
          match_name(business),
          match_additional_information(business)
        ].compact,
        must_not: have_excluded_id(excluded_ids),
        filter: filters(business)
      }
    }).paginate(per_page: BUSINESS_SUGGESTION_LIMIT)
      .records
  end

  def search_companies_house_for_similar_businesses(business)
    type_or_status_differ = lambda do |candidate|
      (business.company_type_code.present? && business.company_type_code != candidate[:company_type_code]) ||
        (business.company_status_code.present? && business.company_status_code != candidate[:company_status_code])
      # field matched by nature_of_business_id is not available on the search models returned by companies house
    end
    search_companies_house(business.legal_name)
      .reject(&type_or_status_differ)
      .first(BUSINESS_SUGGESTION_LIMIT)
  end

  def search_companies_house(query)
    companies_house_response = CompaniesHouseClient.instance.companies_house_businesses(query)
    filter_out_existing_businesses(companies_house_response)
  end

  def filter_out_existing_businesses(businesses)
    businesses.reject { |business| Business.exists?(company_number: business[:company_number]) }
  end

  def set_business
    @business = Business.find(params[:id])
  end

private

  def filters(business)
    {
      "company_type_code": business.company_type_code,
      "company_status_code": business.company_status_code,
      "nature_of_business_id": business.nature_of_business_id
    }.
      reject { |_, value| value.blank? }.
      map do |field, value|
      {
        term: { "#{field}": value }
      }
    end
  end

  def have_excluded_id(excluded_ids)
    {
      ids: {
        values: excluded_ids.map(&:to_s)
      }
    }
  end

  def match_name(business)
    {
      match: {
        "legal_name": {
          query: business.legal_name,
          fuzziness: "AUTO"
        }
      }
    }
  end

  def match_additional_information(business)
    return nil if business.additional_information.blank?

    {
      match: {
        "additional_information": {
          query: business.additional_information,
          fuzziness: "AUTO"
        }
      }
    }
  end
end
