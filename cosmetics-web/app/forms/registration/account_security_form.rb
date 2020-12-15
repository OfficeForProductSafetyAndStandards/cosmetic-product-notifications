module Registration
  class AccountSecurityForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user
    attribute :full_name

    private_class_method def self.error_message(attr, key)
      I18n.t(key, scope: "account_security.#{attr}")
    end

    validates_presence_of :full_name, message: error_message(:full_name, :blank), if: :name_required?
    validates :mobile_number, presence: true
    validates :mobile_number,
              phone: { message: :invalid, allow_international: -> { user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER } },
              if: -> { mobile_number.present? }
    validates :password, length: { minimum: 8 }, if: -> { password.present? }
    validates :password, presence: true

    def update!
      valid? && user.update!(mobile_number: mobile_number,
                             password: password,
                             name: full_name,
                             account_security_completed: true,
                             confirmation_token: nil,
                             confirmation_sent_at: nil,
                             confirmed_at: Time.zone.now)
    end

    def [](field)
      public_send(field.to_sym)
    end

    def full_name
      name_required? ? super : user.name
    end

    def name_required?
      user.name.blank?
    end
  end
end
