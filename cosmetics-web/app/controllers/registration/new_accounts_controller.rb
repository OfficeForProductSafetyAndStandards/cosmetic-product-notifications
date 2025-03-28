module Registration
  class NewAccountsController < SubmitApplicationController
    skip_before_action :authorize_user!
    skip_before_action :authenticate_user!
    skip_before_action :require_secondary_authentication

    def new
      sign_out
      @new_account_form = NewAccountForm.new
      session[:form_timestamp] = Time.current.to_i
    end

    def create
      if spam_detected?
        return redirect_to registration_new_submit_user_path, alert: "Sign-ups are disabled at present"
      end

      if new_account_form.save
        render "users/check_your_email/show", locals: { email: new_account_form.email }
      else
        render :new
      end
    end

    def confirm
      return render "signed_as_another_user" if current_submit_user

      token = params[:confirmation_token]
      return render "confirmation_token_is_invalid" if token.blank?

      @new_user = SubmitUser.confirm_by_token(token)
      return render "confirmation_token_is_invalid" unless @new_user

      sign_in(@new_user)
      redirect_to registration_new_account_security_path
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      render "confirmation_token_is_invalid"
    end

    def sign_out_before_confirming_email
      sign_out
      redirect_to registration_confirm_submit_user_path(confirmation_token: params[:confirmation_token])
    end

  protected

    def after_inactive_sign_up_path_for(_resource)
      check_your_email_path
    end

  private

    def spam_detected?
      email = params.dig(:registration_new_account_form, :email) || "unknown"
      ip_address = request.remote_ip || "unknown"

      if params[:subtitle].present?
        Rails.logger.info "SPAM DETECTED: HONEYPOT FIELD 'subtitle' FILLED | Email: #{email} | IP: #{ip_address}"
        return true
      end

      params.each_key do |key|
        if key =~ /[a-z]{8,}-[a-z]/ && params[key].present?
          Rails.logger.info "SPAM DETECTED: SUSPICIOUS FIELD '#{key}' FILLED WITH '#{params[key]}' | Email: #{email} | IP: #{ip_address}"
          return true
        end
      end

      timestamp = session[:form_timestamp]
      if timestamp
        elapsed_time = Time.current.to_i - timestamp.to_i
        if elapsed_time < 2
          Rails.logger.info "SPAM DETECTED: SUBMISSION TOO QUICK (#{elapsed_time} seconds) | Email: #{email} | IP: #{ip_address}"
          return true
        end
      end

      if Flipper.enabled?(:spam_logging)
        Rails.logger.info "FORM SUBMISSION PARAMETERS: #{params.inspect} | IP: #{ip_address}"
        Rails.logger.info "TIMESTAMP CHECK: Form loaded at #{timestamp}, submitted at #{Time.current.to_i}"
      end

      false
    end

    def new_account_form
      @new_account_form ||= NewAccountForm.new(new_account_form_params)
    end

    def new_account_form_params
      params.require(:registration_new_account_form).permit(:full_name, :email)
    end
  end
end
