require "rails_helper"

RSpec.describe UkPostcodeValidator do
  subject(:validator) { validator_class.new(postcode) }

  let(:error_msg) { "Invalid UK Postcode" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :postcode

      validates :postcode,
                uk_postcode: { message: ERROR_MSG }

      def initialize(postcode)
        @postcode = postcode
      end

      def self.name
        "ValidatorClass"
      end
    end
  end

  before { stub_const("ERROR_MSG", error_msg) }

  valid_uk_postcodes = [
    "E102DE",
    "e102de",
    "E102dE",
    "E10 2DE",
    "E1A 2DE",
    "E1 2DE",
    "EW1A 2DE",
    "EW10 2DE",
  ]

  invalid_uk_postcodes = [
    nil,
    "",
    "123456",
    "(E102DE)",
    "E102D",
    "E102D3",
    "E10233",
    "EW101 2DE",
    "1E10 2D",
    "E10 DE2",
  ]

  valid_uk_postcodes.each do |postcode|
    context "with valid UK postal code (#{postcode})" do
      let(:postcode) { postcode }

      before { validator.validate }

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:postcode]).to be_empty
      end
    end
  end

  invalid_uk_postcodes.each do |postcode|
    context "with invalid postal code (#{postcode})" do
      let(:postcode) { postcode }

      before { validator.validate }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:postcode]).to eq [error_msg]
      end
    end
  end
end
