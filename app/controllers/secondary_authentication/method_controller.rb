module SecondaryAuthentication
  class MethodController < ApplicationController
    skip_before_action :authenticate_user!,
                       :require_secondary_authentication,
                       :authorize_user!,
                       :set_cache_headers

    def new
      unless session[:secondary_authentication_user_id] && secondary_authentication_user
        return redirect_to(root_path)
      end

      @form = MethodForm.new(
        mobile_number: secondary_authentication_user.mobile_number,
      )
    end

    def create
      if form.valid?
        redirect_to authentication_method_path(form.authentication_method)
      else
        render :new
      end
    end

  private

    def authentication_method_path(method)
      case method
      when "app" then new_secondary_authentication_app_path
      when "sms" then new_secondary_authentication_sms_path
      end
    end

    def form
      @form ||= MethodForm.new(
        secondary_authentication_method_params.merge(mobile_number: secondary_authentication_user.mobile_number),
      )
    end

    def secondary_authentication_method_params
      params.permit(:authentication_method)
    end
  end
end
