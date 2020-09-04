module Registration
  class SecurityDetailsController < ApplicationController
    skip_before_action :require_secondary_authentication

    def new
      @security_details_form = SecurityDetailsForm.new(user: current_user)
    end

    def create
      if security_details_form.update!
        bypass_sign_in(current_user)
        redirect_to declaration_path
      else
        render :new
      end
    end

    private

    def security_details_form
      @security_details_form ||= SecurityDetailsForm.new(security_details_form_params.merge(user: current_user))
    end

    def security_details_form_params
      params.require(:registration_security_details_form).permit(:mobile_number, :password)
    end
  end
end

