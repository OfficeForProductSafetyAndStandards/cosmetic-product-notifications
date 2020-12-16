module Registration
  class AccountSecurityForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user
    attribute :full_name

    validates_presence_of :full_name, if: :name_required?
    validates :mobile_number, presence: true
    validates :mobile_number,
              phone: { message: :invalid, allow_international: true },
              if: :validate_international_mobile_number?
    validates :mobile_number,
              phone: { message: :invalid, allow_international: false },
              if: :validate_uk_mobile_number?
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

    def validate_uk_mobile_number?
      mobile_number.present? && user && !user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
    end

    def validate_international_mobile_number?
      mobile_number.present? && user && user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
    end
  end
end
