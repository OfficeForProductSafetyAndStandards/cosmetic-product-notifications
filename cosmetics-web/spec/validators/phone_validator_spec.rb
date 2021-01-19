require "rails_helper"

RSpec.describe PhoneValidator do
  subject(:validator) { validator_class.new(phone, allow_international, allow_landline) }

  let(:error_msg) { "Enter a mobile number, like 07700 900 982 or +44 7700 900 982" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :phone
      attr_reader :allow_int_but_no_uk_landlines,
                  :do_not_allow_int_or_uk_landlines,
                  :allow_int_and_uk_landlines,
                  :allow_uk_landlines_but_not_int

      validates :phone,
                phone: { message: ERROR_MSG, allow_international: true, allow_landline: false },
                if: :allow_int_but_no_uk_landlines
      validates :phone,
                phone: { message: ERROR_MSG, allow_international: false, allow_landline: false },
                if: :do_not_allow_int_or_uk_landlines
      validates :phone,
                phone: { message: ERROR_MSG, allow_international: true, allow_landline: true },
                if: :allow_int_and_uk_landlines
      validates :phone,
                phone: { message: ERROR_MSG, allow_international: false, allow_landline: true },
                if: :allow_uk_landlines_but_not_int

      def initialize(phone, allow_int, allow_landline = false)
        @phone = phone

        @allow_int_but_no_uk_landlines = (allow_int && !allow_landline)
        @do_not_allow_int_or_uk_landlines = (!allow_int && !allow_landline)
        @allow_int_and_uk_landlines = (allow_int && allow_landline)
        @allow_uk_landlines_but_not_int = (!allow_int && allow_landline)
      end

      def self.name
        "ValidatorClass"
      end
    end
  end

  before { stub_const("ERROR_MSG", error_msg) }

  RSpec.shared_examples_for "valid phone numbers" do |valid_phone_numbers|
    valid_phone_numbers.each do |phone_number|
      context "with valid phone number #{phone_number}" do
        let(:phone) { phone_number }

        before { validator.validate }

        it "is valid" do
          expect(validator).to be_valid
        end

        it "does not populate an error message" do
          expect(validator.errors.messages[:phone]).to be_empty
        end
      end
    end
  end

  RSpec.shared_examples_for "invalid phone numbers" do |invalid_phone_numbers|
    invalid_phone_numbers.each do |phone_number|
      context "with invalid phone number #{phone_number}" do
        let(:phone) { phone_number }

        before { validator.validate }

        it "is not valid" do
          expect(validator).not_to be_valid
        end

        it "populates an error message" do
          expect(validator.errors.messages[:phone]).to eq [error_msg]
        end
      end
    end
  end

  context "when international numbers are allowed" do
    let(:allow_international) { true }
    let(:allow_landline) { nil }

    valid_phone_numbers = [
      "7123456789",
      "07123456789",
      "07123 456789",
      "07123-456-789",
      "00447123456789",
      "00 44 7123456789",
      "+447123456789",
      "+44 7123 456 789",
      "+44 (0)7123 456 789",
      "\u200B+44 (0)7123 \uFEFF 456 789", # Allowed whitespaces & characters
      "+34629012345", # Spanish mobile number,
      "71234567123",  # Too long UK number is valid as Russian phone.
    ]

    invalid_phone_numbers = [
      "712345671",             # Too short
      "7123LM6789",            # Not allowed characters
      "+48123 45",             # Too short international phone
      "+48123456789123456789", # Too long international phone
      "+99029012345",          # '990' Country code not allowed
      "009904567891",          # '990' Country code not allowed
    ]

    include_examples "valid phone numbers", valid_phone_numbers
    include_examples "invalid phone numbers", invalid_phone_numbers
  end

  context "when international numbers are not allowed" do
    let(:allow_international) { false }
    let(:allow_landline) { nil }

    valid_phone_numbers = [
      "7123456789",
      "07123456789",
      "07123 456789",
      "07123-456-789",
      "00447123456789",
      "00 44 7123456789",
      "+447123456789",
      "+44 7123 456 789",
      "+44 (0)7123 456 789",
      "\u200B+44 (0)7123 \uFEFF 456 789", # Allowed whitespaces & characters
    ]

    invalid_phone_numbers = [
      "712345671",      # Too short
      "71234567123",    # Too long
      "7123LM6789",     # Not allowed characters
      "00123456789",    # Not UK Phone
      "+111123 456789", # Not UK Phone
      "+34629012345",   # Not UK Phone
    ]

    include_examples "valid phone numbers", valid_phone_numbers
    include_examples "invalid phone numbers", invalid_phone_numbers
  end

  context "when uk landlines and international numbers are allowed" do
    let(:allow_landline) { true }
    let(:allow_international) { true }

    valid_phone_numbers = [
      "7123456789",
      "07123456789",
      "07123 456789",
      "07123-456-789",
      "00447123456789",
      "00 44 7123456789",
      "+447123456789",
      "+44 7123 456 789",
      "+44 (0)7123 456 789",
      "\u200B+44 (0)7123 \uFEFF 456 789", # Allowed whitespaces & characters
      "+34629012345", # Spanish mobile number,
      "71234567123",  # Too long UK number is valid as Russian phone.
      "01632 960123", # UK landline number is valid
    ]

    invalid_phone_numbers = [
      "712345",                # Too short (even for landline)
      "7123LM6789",            # Not allowed characters
      "+48123 4",              # Too short international phone or landline
      "+48123456789123456789", # Too long international phone
      "+99029012345",          # '990' Country code not allowed
      "009904567891",          # '990' Country code not allowed
    ]

    include_examples "valid phone numbers", valid_phone_numbers
    include_examples "invalid phone numbers", invalid_phone_numbers
  end

  context "when uk landlines are allowed but international numbers are not" do
    let(:allow_landline) { true }
    let(:allow_international) { false }

    valid_phone_numbers = [
      "7123456789",
      "07123456789",
      "07123 456789",
      "07123-456-789",
      "00447123456789",
      "00 44 7123456789",
      "+447123456789",
      "+44 7123 456 789",
      "+44 (0)7123 456 789",
      "\u200B+44 (0)7123 \uFEFF 456 789", # Allowed whitespaces & characters
      "01632 960123", # UK landline number is valid
    ]

    invalid_phone_numbers = [
      "712345",         # Too short (even for landline)
      "71234567123",    # Too long
      "7123LM6789",     # Not allowed characters
      "00123456789",    # Not UK Phone
      "+111123 456789", # Not UK Phone
      "+34629012345",   # Not UK Phone
    ]

    include_examples "valid phone numbers", valid_phone_numbers
    include_examples "invalid phone numbers", invalid_phone_numbers
  end
end
