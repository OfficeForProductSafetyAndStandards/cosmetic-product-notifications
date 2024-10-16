require "rails_helper"

RSpec.describe EcNumberValidator do
  subject(:validator) { validator_class.new(ec_number) }

  let(:error_msg) { "Enter a valid name" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :ec_number

      validates_with EcNumberValidator

      def initialize(ec_number)
        @ec_number = ec_number
      end

      def self.name
        "ValidatorClass"
      end
    end
  end

  before do
    validator.validate
  end

  valid_ec_numbers = [
    nil,
    "",
    "160-683-1",
    "1212121",
  ]

  invalid_ec_numbers = [
    "5154 43 4",
    "12-34-567",
  ]

  invalid_length_ec_numbers = %w[
    1-12-1
    12345678-12-1
    1234567-12-12
  ]

  valid_ec_numbers.each do |ec_number|
    context "with valid ec number (#{ec_number})" do
      let(:ec_number) { ec_number }

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:ec_number]).to be_empty
      end
    end
  end

  invalid_ec_numbers.each do |ec_number|
    context "with invalid ec number (#{ec_number})" do
      let(:ec_number) { ec_number }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:ec_number]).to eq ["EC number is invalid"]
      end
    end
  end

  invalid_length_ec_numbers.each do |ec_number|
    context "with invalid ec number (#{ec_number})" do
      let(:ec_number) { ec_number }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates error messages" do
        expect(validator.errors.messages[:ec_number])
          .to eq ["EC number is invalid", "EC number must contain 7 digits"]
      end
    end
  end
end
