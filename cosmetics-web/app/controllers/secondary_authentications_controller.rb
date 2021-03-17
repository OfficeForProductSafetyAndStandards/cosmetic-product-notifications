# Dont inherit from authentication controller
class SecondaryAuthenticationsController < ApplicationController
  skip_before_action :authenticate_user!,
                     :require_secondary_authentication,
                     :authorize_user!,
                     :set_cache_headers

  def new
    user_id = session[:secondary_authentication_user_id]
    return render("errors/forbidden", status: :forbidden) unless user_id

    if user_needs_to_choose_secondary_authentication_method?
      redirect_to new_secondary_authentication_method_path
    else
      handler = handler_class.new(current_operation, user_id: user_id)
      @form = handler.form
      handler.pre_actions
      render handler.view
    end
  end

  def create
    handler = handler_class.new(current_operation, secondary_authentication_params)
    @form = handler.form
    if @form.valid?
      set_secondary_authentication_cookie(Time.zone.now.to_i)
      handler.on_success
      session[:secondary_authentication_user_id] = nil
      session[:secondary_authentication_method] = nil
      redirect_to_saved_path
    else
      handler.on_failure
      render handler.view
    end
  end

private

  def handler_class
    if secondary_authentication_with_sms?
      Handler::Sms
    elsif secondary_authentication_with_app?
      Handler::App
    end
  end

  def secondary_authentication_params
    params.permit(:otp_code, :user_id)
  end

  def redirect_to_saved_path
    if session[:secondary_authentication_redirect_to]
      redirect_to session.delete(:secondary_authentication_redirect_to), notice: session.delete(:secondary_authentication_notice), confirmation: session.delete(:secondary_authentication_confirmation)
    else
      redirect_to root_path
    end
  end

  module Handler
    class Handler
      def initialize(operation, params)
        @operation = operation
        @params = params
      end

      def view
        self.class::VIEW
      end

      def form
        @form ||= self.class::FORM_CLASS.new(@params)
      end

      def pre_actions; end

      def on_success; end

      def on_failure; end
    end

    class App < Handler
      VIEW = :app
      FORM_CLASS = SecondaryAuthenticationWithAppForm

      def on_success
        form.user.update!(last_totp_at: form.last_totp_at)
      end
    end

    class Sms < Handler
      VIEW = :sms
      FORM_CLASS = SecondaryAuthenticationWithSmsForm

      def pre_actions
        sms_authentication.generate_and_send_code(@operation)
      end

      def on_success
        form.try_to_verify_user_mobile_number
      end

      def on_failure
        if sms_authentication.otp_expired? && !sms_authentication.otp_locked?
          sms_authentication.generate_and_send_code(sms_authentication.operation)
        end
      end

    private

      def sms_authentication
        form&.secondary_authentication
      end
    end
  end
end
