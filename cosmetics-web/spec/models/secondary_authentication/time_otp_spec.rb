require "rails_helper"

RSpec.describe SecondaryAuthentication::TimeOtp do
  describe "#valid_otp?", :with_2fa_app do
    subject(:totp) { described_class.new(user, user.totp_secret_key) }

    let(:user) { build_stubbed(:submit_user, :with_app_secondary_authentication) }

    it "is valid when matches the time otp for the user" do
      expect(totp.valid_otp?(correct_app_code)).to eq true
    end

    it "is false when does not match the time otp for the user" do
      expect(totp.valid_otp?(correct_app_code.reverse)).to eq false
    end

    it "is false when no code is provided" do
      expect(totp.valid_otp?("")).to eq false
    end
  end

  describe "#qr_code" do
    subject(:totp) { described_class.new(user, user.totp_secret_key) }

    let(:user) { build_stubbed(:submit_user, :with_app_secondary_authentication) }

    it "generates a png image" do
      expect(totp.qr_code).to start_with "data:image/png;base64,"
    end

    it "multiple calls with the same user generate the same qr code image" do
      first_image = totp.qr_code
      expect(totp.qr_code).to eq first_image
    end

    it "generates a different qr code if the user changes its email" do
      first_image = totp.qr_code
      user.email = "newemailfortotptest@example.com"
      expect(described_class.new(user, user.totp_secret_key).qr_code).not_to eq first_image
    end

    it "generates a different qr code when given a different totp secret key" do
      first_image = totp.qr_code
      expect(described_class.new(user, ROTP::Base32.random).qr_code).not_to eq first_image
    end
  end

  describe ".generate_secret_key" do
    it "returns a 32 chars key" do
      expect(described_class.generate_secret_key.size).to eq 32
    end

    it "each call returns a new key" do
      first_key = described_class.generate_secret_key
      expect(described_class.generate_secret_key).not_to eq first_key
    end
  end
end
