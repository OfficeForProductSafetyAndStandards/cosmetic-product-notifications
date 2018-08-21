module BusinessesHelper
  def defaults_on_primary_address(business)
    business.primary_address.address_type ||= "Registered office address"
    business.primary_address.source ||= UserSource.new(user: current_user)
    business
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
