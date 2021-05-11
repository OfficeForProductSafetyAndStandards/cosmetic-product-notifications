module SecondaryAuthentication
  module Sms
    class SetupController < SubmitApplicationController
      def new
        @user = current_user
        return redirect_to(root_path) unless @user

        @form = SetupForm.new(mobile_number: @user.mobile_number, user: @user)
      end

      def create
        @user = current_user
        return render("errors/forbidden", status: :forbidden) unless @user

        previously_set = @user.mobile_number.present?

        if form.valid?
          @user.update!(mobile_number: form.mobile_number)
          redirect_to my_account_path, confirmation: "Mobile number #{previously_set ? 'changed' : 'set'} successfully"
        else
          render :new
        end
      end

    private

      def current_operation
        SecondaryAuthentication::Operations::SETUP_SMS_AUTHENTICATION
      end

      def form
        @form ||= SetupForm.new(form_params.merge(user: current_user))
      end

      def form_params
        params.require(:secondary_authentication_sms_setup_form)
              .permit(:mobile_number, :password)
      end
    end
  end
end
