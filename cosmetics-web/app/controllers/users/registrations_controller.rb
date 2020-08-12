# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do
        if sign_up_form.invalid?
          handle_invalid_form
          return render :new
        end
      end
    end

  protected

    def after_inactive_sign_up_path_for(_resource)
      check_your_email_path
    end

  private

    def handle_invalid_form
      self.resource = resource_class.new(sign_up_params)
      # self.resource.valid?
      self.resource.errors.merge!(sign_up_form.errors)
    end

    def sign_up_form
      @sign_up_form ||= SignUpForm.new(sign_up_params)
    end
  end
end
