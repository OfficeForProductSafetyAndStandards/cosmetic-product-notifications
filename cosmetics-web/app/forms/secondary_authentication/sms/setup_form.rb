module SecondaryAuthentication
  module Sms
    class SetupForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include StripWhitespace

      attribute :mobile_number
      attribute :password
      attribute :user

      validates :mobile_number, presence: { message: :invalid }
      validates :mobile_number,
                phone: { message: :invalid, allow_international: true },
                if: :validate_international_mobile_number?
      validates :mobile_number,
                phone: { message: :invalid, allow_international: false },
                if: :validate_uk_mobile_number?

      validates :password, presence: true

      validate :correct_password

    private

      def correct_password
        return if errors[:password].present?

        unless user.valid_password?(password)
          errors.add(:password, :invalid)
        end
      end

      def validate_uk_mobile_number?
        mobile_number.present? && user && !user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end

      def validate_international_mobile_number?
        mobile_number.present? && user && user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end
    end
  end
end
