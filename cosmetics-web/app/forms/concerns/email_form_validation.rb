module EmailFormValidation
  extend ActiveSupport::Concern

  included do
    attribute :email

    validates :email,
              email: {
                message: I18n.t(:wrong_email_or_password, scope: "sign_in_form.email"),
                if: ->(sign_in_form) { sign_in_form.email.present? }
              }
    validates_presence_of :email, message: I18n.t(:enter_email_address)
  end
end
