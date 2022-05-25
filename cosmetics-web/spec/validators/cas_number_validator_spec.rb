require "rails_helper"

RSpec.describe CasNumberValidator do
  subject(:validator) { validator_class.new(cas_number) }

  let(:error_msg) { "Enter a valid name" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :cas_number

      validates_with CasNumberValidator

      def initialize(cas_number)
        @cas_number = cas_number
      end

      def self.name
        "ValidatorClass"
      end
    end
  end

  before do
    validator.validate
  end

  valid_cas_numbers = [
    nil,
    "",
    "51-43-4",
    "150-05-0",
    "16065-83-1",
    "1234567-37-4",
    "12121",
    "1234567121",
  ]

  invalid_cas_numbers = [
    "51 43 4",
    "1234567-1-1",
    "123456-12-12",
    "123456-123-1",
    "51a-43-4",
  ]

  invalid_length_cas_numbers = %w[
    1-12-1
    12345678-12-1
    1234567-12-12
  ]

  valid_cas_numbers.each do |cas_number|
    context "with valid cas number (#{cas_number})" do
      let(:cas_number) { cas_number }

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:cas_number]).to be_empty
      end
    end
  end

  invalid_cas_numbers.each do |cas_number|
    context "with invalid cas number (#{cas_number})" do
      let(:cas_number) { cas_number }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:cas_number]).to eq ["CAS number is invalid"]
      end
    end
  end

  invalid_length_cas_numbers.each do |cas_number|
    context "with invalid cas number (#{cas_number})" do
      let(:cas_number) { cas_number }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates error messages" do
        expect(validator.errors.messages[:cas_number])
          .to eq ["CAS number is invalid", "CAS number must contain between 5 to 10 digits"]
      end
    end
  end
end
