module UserPasswordCheckFormValidation
  extend ActiveSupport::Concern

  included do
    attribute :password

    validates :password,
              presence: { message: I18n.t(:blank, scope: :user_password_check_form_validation) }
    validate :correct_password
  end

  def correct_password
    return if errors[:password].present?

    unless user.valid_password?(password)
      errors.add(:password, I18n.t(:invalid, scope: :user_password_check_form_validation))
    end
  end
end
