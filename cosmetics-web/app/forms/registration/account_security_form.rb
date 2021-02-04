module Registration
  class AccountSecurityForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :mobile_number
    attribute :password
    attribute :user
    attribute :full_name
    attribute :totp_attempt
    attribute :totp_secret_key

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
    validates :totp_attempt, presence: { message: "Authenticator app one-time password can not be blank" }
    validate :totp_attempt, :validate_totp_code, if: -> { totp_attempt.present? }

    def update!
      valid? && user.update!(mobile_number: mobile_number,
                             password: password,
                             name: full_name,
                             account_security_completed: true,
                             confirmation_token: nil,
                             confirmation_sent_at: nil,
                             confirmed_at: Time.zone.now,
                             totp_secret_key: totp_secret_key,
                             last_totp_at: last_totp_at)
    end

    def totp_secret_key
      @totp_secret_key ||= (super.presence || ROTP::Base32.random)
    end

    def totp
      @totp ||= ROTP::TOTP.new(totp_secret_key, issuer: "Submit Cosmetics")
    end

    def totp_qr_code
      binding.pry
      RQRCode::QRCode
        .new(totp.provisioning_uri(user.email))
        .as_png(resize_exactly_to: 300)
        .to_data_url
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

    def last_totp_at
      totp.verify(totp_attempt, drift_behind: 15)
    end

    def validate_totp_code
      unless totp_attempt.present? && last_totp_at.present?
        errors.add(:totp_attempt, "The code you provided was invalid!")
      end
    end
  end
end
