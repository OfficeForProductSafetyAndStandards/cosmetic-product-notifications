require "rails_helper"

RSpec.describe SendSubmitSms, :with_stubbed_notify do
  describe ".validate_and_format_number" do
    context "with valid UK numbers without country codes" do
      it "validates and formats '07123456789' correctly" do
        number = "07123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+447123456789")
      end

      it "validates and formats '01234567890' correctly" do
        number = "01234567890"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+441234567890")
      end

      it "validates and formats '08001234567' correctly" do
        number = "08001234567"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+448001234567")
      end
    end

    context "with valid UK numbers with country codes" do
      it "validates and formats '+447123456789' correctly" do
        number = "+447123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+447123456789")
      end

      it "validates and formats '00447123456789' correctly" do
        number = "00447123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+447123456789")
      end

      it "validates and formats '+44 7123 456 789' correctly" do
        number = "+44 7123 456 789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+447123456789")
      end

      it "validates and formats '+44 (0)7123456789' correctly" do
        number = "+44 (0)7123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+447123456789")
      end
    end

    context "with valid foreign numbers with country codes" do
      it "validates and formats '+12025550123' (USA) correctly" do
        number = "+12025550123"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+12025550123")
      end

      it "validates and formats '0012025550123' (USA) correctly" do
        number = "0012025550123"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+12025550123")
      end

      it "validates and formats '+33123456789' (France) correctly" do
        number = "+33123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+33123456789")
      end

      it "validates and formats '0033123456789' (France) correctly" do
        number = "0033123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+33123456789")
      end

      it "validates and formats '+1 (555) 123-4567' (USA) correctly" do
        number = "+1 (202) 555-0123"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to eq("+12025550123")
      end
    end

    context "with invalid numbers" do
      it "returns nil for too short number '07123'" do
        number = "07123"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to be_nil
      end

      it "returns nil for foreign number without country code '123456789'" do
        number = "123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to be_nil
      end

      it "returns nil for invalid country code '+99123456789'" do
        number = "+99123456789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to be_nil
      end

      it "returns nil for alphabetic characters 'abcdefg'" do
        number = "abcdefg"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to be_nil
      end

      it "returns nil for special characters '+44!7123*456%789'" do
        number = "+44!7123*456%789"
        result = SendSubmitSms.validate_and_format_number(number)
        expect(result).to be_nil
      end
    end
  end

  describe ".otp_code" do
    let(:code) { 123 }
    let(:template_id) { described_class::TEMPLATES[:otp_code] }

    context "with valid phone numbers" do
      valid_numbers = [
        { input: "07123456789", expected: "+447123456789" },
        { input: "01234567890", expected: "+441234567890" },
        { input: "08001234567", expected: "+448001234567" },
        { input: "+447123456789", expected: "+447123456789" },
        { input: "00447123456789", expected: "+447123456789" },
        { input: "+44 7123 456 789", expected: "+447123456789" },
        { input: "+44 (0)7123456789", expected: "+447123456789" },
        { input: "+12025550123", expected: "+12025550123" },
        { input: "0012025550123", expected: "+12025550123" },
        { input: "+1 (202) 555-0123", expected: "+12025550123" },
        { input: "+33123456789", expected: "+33123456789" },
        { input: "0033123456789", expected: "+33123456789" }
      ]

      valid_numbers.each do |number_data|
        it "sends the otp code with valid phone number '#{number_data[:input]}'" do
          expected_payload = {
            phone_number: number_data[:expected],
            template_id:,
            personalisation: { code: }
          }

          described_class.otp_code(mobile_number: number_data[:input], code:)

          expect(notify_stub).to have_received(:send_sms).with(expected_payload)
        end
      end
    end

    context "with invalid phone numbers" do
      invalid_numbers = [
        "07123",          # Too short
        "123456789",      # Foreign number without country code
        "+99123456789",   # Invalid country code
        "abcdefg",        # Alphabetic characters
        "+44!7123*456%789" # Special characters
      ]

      invalid_numbers.each do |invalid_phone_number|
        it "raises an error with invalid phone number '#{invalid_phone_number}'" do
          expect {
            described_class.otp_code(mobile_number: invalid_phone_number, code:)
          }.to raise_error(ArgumentError, "Invalid mobile number provided: #{invalid_phone_number}")
        end
      end
    end
  end
end
