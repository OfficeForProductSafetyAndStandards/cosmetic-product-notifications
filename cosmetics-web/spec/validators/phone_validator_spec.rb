require "rails_helper"

RSpec.describe PhoneValidator do
  subject(:validator) do
    Class.new {
      include ActiveModel::Validations
      attr_accessor :phone
      validates :phone,
                phone: {
                  message: "Enter your mobile number in the correct format, like 07700 900 982"
                }
    }.new
  end

  valid_uk_phone_numbers = [
    "7123456789",
    "07123456789",
    "07123 456789",
    "07123-456-789",
    "00447123456789",
    "00 44 7123456789",
    "+447123456789",
    "+44 7123 456 789",
    "+44 (0)7123 456 789",
    "\u200B\t\t+44 (0)7123 \uFEFF 456 789 \r\n",
  ]

  valid_uk_phone_numbers.each do |phone_number|
    context "with valid phone number #{phone_number}" do
      before do
        validator.phone = phone_number
        validator.validate
      end

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:phone]).to be_empty
      end
    end
  end

  invalid_phone_numbers = [
    "712345671",
    "71234567123",
    "00123456789",
    "+111123 456789",
    "564544554455544"
  ]

  invalid_phone_numbers.each do |phone_number|
    context "with invalid phone number #{phone_number}" do
      before do
        validator.phone = phone_number
        validator.validate
      end

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:phone]).to eq [
          "Enter your mobile number in the correct format, like 07700 900 982"
        ]
      end
    end
  end
end
