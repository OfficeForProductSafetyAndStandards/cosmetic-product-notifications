class SignUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include EmailFormValidation

  attribute :name
  attribute :mobile_number
  attribute :password
  attribute :password_confirmation

  private_class_method def self.error_message(attr, key)
    I18n.t(key, scope: "sign_up_form.#{attr}")
  end

  validates_presence_of :name, message: error_message(:name, :blank)
  validates_presence_of :mobile_number, message: error_message(:mobile_number, :blank)
  validates_presence_of :password_confirmation, message: error_message(:password_confirmation, :blank)
  validates_presence_of :password, message: error_message(:password, :blank)
  validates_confirmation_of :password, message: error_message(:password_confirmation, :missmatch), if: -> { password_confirmation.present? }
  validates :mobile_number,
            phone: { message: error_message(:mobile_number, :wrong_format) },
            if: -> { mobile_number.present? }
end
