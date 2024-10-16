module SecondaryAuthentication
  module Sms
    class ResendForm < Form
      attribute :mobile_number
      attribute :user

      validates_presence_of :mobile_number,
                            if: -> { user.mobile_number_change_allowed? }
      validates :mobile_number,
                phone: { message: :invalid, allow_international: true },
                if: :validate_international_mobile_number?
      validates :mobile_number,
                phone: { message: :invalid, allow_international: false },
                if: :validate_uk_mobile_number?

    private

      def validate_mobile_number?
        user&.mobile_number_change_allowed? && mobile_number.present?
      end

      def validate_uk_mobile_number?
        validate_mobile_number? && !user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end

      def validate_international_mobile_number?
        validate_mobile_number? && user.class::ALLOW_INTERNATIONAL_PHONE_NUMBER
      end
    end
  end
end
