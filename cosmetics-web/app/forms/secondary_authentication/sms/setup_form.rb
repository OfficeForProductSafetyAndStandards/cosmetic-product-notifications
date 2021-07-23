module SecondaryAuthentication
  module Sms
    class SetupForm < Form
      include StripWhitespace
      include UserPasswordCheckFormValidation

      attribute :mobile_number
      attribute :user

      validates :mobile_number, presence: { message: :invalid }
      validates :mobile_number,
                phone: { message: :invalid, allow_international: true },
                if: :validate_international_mobile_number?
      validates :mobile_number,
                phone: { message: :invalid, allow_international: false },
                if: :validate_uk_mobile_number?

    private

      def validate_uk_mobile_number?
        mobile_number.present? && user && !user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end

      def validate_international_mobile_number?
        mobile_number.present? && user && user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end
    end
  end
end
