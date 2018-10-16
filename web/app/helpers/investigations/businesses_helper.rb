module Investigations::BusinessesHelper
  def companies_house_new_business_form_url
    @investigation.present? ? companies_house_investigation_businesses_path(@investigation) : companies_house_businesses_path
  end
end
