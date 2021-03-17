require "rails_helper"

RSpec.describe SecondaryAuthenticationMethodForm do
  describe "#partially_hidden_mobile_number" do
    it "is null for forms where there is no mobile number" do
      form = described_class.new(mobile_number: nil)
      expect(form.partially_hidden_mobile_number).to eq nil
    end

    it "is null for forms where the mobile number is empty" do
      form = described_class.new(mobile_number: "")
      expect(form.partially_hidden_mobile_number).to eq nil
    end

    it "replaces all the mobile number digits but the last 4 with asterisks" do
      form = described_class.new(mobile_number: "07123456789")
      expect(form.partially_hidden_mobile_number).to eq "*******6789"
    end
  end

  describe "validations" do
    it "is not valid when the authentication method is not present" do
      form = described_class.new
      expect(form).not_to be_valid
      expect(form.errors.full_messages_for(:authentication_method)).to eq ["Select an option"]
    end

    it "is valid when the authentication method is present" do
      form = described_class.new(authentication_method: "sms")
      expect(form).to be_valid
    end
  end
end
