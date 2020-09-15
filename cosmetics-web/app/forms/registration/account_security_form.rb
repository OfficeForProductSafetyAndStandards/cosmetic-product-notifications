module Registration
  class AccountSecurityForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user

    validates :password, length: { minimum: 8 }
    validates :mobile_number, format: { with: /\A[0-9 -]+\z/ }, if: -> { mobile_number.length > 10 }
    validates :mobile_number, length: { minimum: 11 }

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
