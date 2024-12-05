require "rails_helper"

RSpec.describe SendSubmitSms, :with_stubbed_notify do
  # Define class methods to provide test data
  def self.valid_numbers
    [
      # UK numbers without country codes
      { input: "07123456789", expected: "+447123456789", description: "UK mobile number without country code" },
      { input: "01234567890", expected: "+441234567890", description: "UK landline number without country code" },
      { input: "08001234567", expected: "+448001234567", description: "UK toll-free number without country code" },

      # UK numbers with country codes
      { input: "+447123456789", expected: "+447123456789", description: "UK mobile number with '+' country code" },
      { input: "00447123456789", expected: "+447123456789", description: "UK mobile number with '00' country code" },
      { input: "+44 7123 456 789", expected: "+447123456789", description: "UK mobile number with spaces" },
      { input: "+44 (0)7123456789", expected: "+447123456789", description: "UK mobile number with optional zero" },

      # Numbers with internal plus signs
      { input: "00+44+7922574123", expected: "+447922574123", description: "Number with internal plus signs and leading '00'" },
      { input: "0044+7922574123", expected: "+447922574123", description: "Number with internal plus sign after country code" },
      { input: "44+ 7922574123", expected: "+447922574123", description: "Number starting with '44' and internal plus sign" },

      # Foreign numbers
      { input: "+12024561111", expected: "+12024561111", description: "US number with '+' country code" },
      { input: "0012024561111", expected: "+12024561111", description: "US number with '00' country code" },
      { input: "+1 (202) 456-1111", expected: "+12024561111", description: "US number with formatting" },
      { input: "+33123456789", expected: "+33123456789", description: "French number with '+' country code" },
      { input: "0033123456789", expected: "+33123456789", description: "French number with '00' country code" },
    ]
  end

  def self.invalid_numbers
    [
      { input: "07123", description: "too short number" },
      { input: "123456789", description: "foreign number without country code" },
      { input: "+99123456789", description: "invalid country code" },
      { input: "abcdefg", description: "alphabetic characters" },
      { input: "+44!7123*456%789", description: "special characters" },
    ]
  end

  describe ".validate_and_format_number" do
    context "with valid numbers" do
      valid_numbers.each do |number_data|
        it "validates and formats '#{number_data[:input]}' correctly (#{number_data[:description]})" do
          result = described_class.validate_and_format_number(number_data[:input])
          expect(result).to eq(number_data[:expected])
        end
      end
    end

    context "with invalid numbers" do
      invalid_numbers.each do |number_data|
        it "returns nil for invalid number '#{number_data[:input]}' (#{number_data[:description]})" do
          result = described_class.validate_and_format_number(number_data[:input])
          expect(result).to be_nil
        end
      end
    end
  end

  describe ".otp_code" do
    let(:code) { 123 }
    let(:template_id) { described_class::TEMPLATES[:otp_code] }

    context "with valid phone numbers" do
      valid_numbers.each do |number_data|
        it "sends the otp code with valid phone number '#{number_data[:input]}'" do
          described_class.otp_code(mobile_number: number_data[:input], code:)

          expect(notify_stub).to have_received(:send_sms).with(
            phone_number: number_data[:expected],
            template_id:,
            personalisation: { code: },
          )
        end
      end
    end

    context "with invalid phone numbers" do
      invalid_numbers.each do |number_data|
        it "raises an error with invalid phone number '#{number_data[:input]}' (#{number_data[:description]})" do
          expect {
            described_class.otp_code(mobile_number: number_data[:input], code:)
          }.to raise_error(ArgumentError, "Invalid mobile number provided: #{number_data[:input]}")
        end
      end
    end
  end
end
