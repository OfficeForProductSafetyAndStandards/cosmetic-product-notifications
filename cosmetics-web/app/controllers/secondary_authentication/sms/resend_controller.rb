module SecondaryAuthentication
  module Sms
    class ResendController < ApplicationController
      skip_before_action :authenticate_user!,
                         :require_secondary_authentication,
                         :authorize_user!,
                         :set_cache_headers

      def new
        @user = user_with_secondary_authentication_request
        return redirect_to(root_path) unless @user
      end

      def create
        @user = user_with_secondary_authentication_request
        return render("errors/forbidden", status: :forbidden) unless @user
        return redirect_to new_secondary_authentication_sms_path unless @user.mobile_number_change_allowed?

        @user.mobile_number = mobile_number_param
        if resend_code_form.valid?
          @user.save!
          redirect_to new_secondary_authentication_sms_path
        else
          @user.errors.merge!(resend_code_form.errors)
          render(:new)
        end
      end

    private

      def current_operation
        @user&.secondary_authentication_operation.presence || Operations::DEFAULT
      end

      def resend_code_form
        @resend_code_form ||= ResendForm.new(mobile_number: mobile_number_param, user: @user)
      end

      def user_id_for_secondary_authentication
        current_user&.id || session[:secondary_authentication_user_id]
      end

      def user_with_secondary_authentication_request
        User.find_by(id: session[:secondary_authentication_user_id])
      end

      def mobile_number_param
        params.dig(user_param_key, :mobile_number)
      end
    end
  end
end
