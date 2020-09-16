module Registration
  class AccountSecurityForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user

    validates :mobile_number, presence: true
    validates :mobile_number, phone:{ message: I18n.t(:invalid, scope: %i[activerecord errors models user attributes mobile_number]) }, if: -> { mobile_number.present? }
    validates :password, length: { minimum: 8 }, if: -> { password.present? }
    validates :password, presence: true

    private_class_method def self.error_message(attr, key)
      I18n.t(key, scope: "account_security.#{attr}")
    end

    def update!
      valid? && user.update!(mobile_number: mobile_number,
                             password: password,
                             account_security_completed: true,
                             confirmation_token: nil,
                             confirmation_sent_at: nil,
                             confirmed_at: Time.now.utc
                            )
    end

    def [](field)
      public_send(field.to_sym)
    end
  end
end
