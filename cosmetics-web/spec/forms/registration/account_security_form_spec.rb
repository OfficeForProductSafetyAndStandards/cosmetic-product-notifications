require "rails_helper"

RSpec.describe Registration::AccountSecurityForm do
  let(:password) { "foobarbaz" }
  let(:mobile_number) { "07000 000 000" }
  let(:user) { create(:submit_user) }

  let(:form) do
    described_class.new(password: password, mobile_number: mobile_number, user: user)
  end

  context "when the password is too short" do
    let(:password) { "foobar" }

    it "is invalid" do
      expect(form).not_to be_valid
    end

    it "contains errors" do
      form.valid?
      expect(form.errors.full_messages_for(:password)).to eq ["Password is too short (minimum is 8 characters)"]
    end
  end

  describe "#name_required?" do
    context "when user is created by invitation" do
      let(:user) { create(:submit_user, created_by_invitation: true) }

      it "returns true" do
        expect(form).to be_name_required
      end
    end

    context "when user is not created by invitation" do
      let(:user) { create(:submit_user, created_by_invitation: false) }

      it "returns false" do
        expect(form).not_to be_name_required
      end
    end
  end

  describe "mobile number vaildations" do
    shared_examples "mobile number" do
      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "contains errors" do
        form.valid?
        expect(form.errors.full_messages_for(:mobile_number)).to include(message)
      end
    end

    context "when the mobile number is empty" do
      include_examples "mobile number" do
        let(:mobile_number) { "" }
        let(:message) { "Please enter mobile number" }
      end
    end

    context "when mobile number has letters" do
      include_examples "mobile number" do
        let(:mobile_number) { "070000assd" }
        let(:message) { "Enter your mobile number in the correct format, like 07700 900 982" }
      end
    end

    context "when mobile number has not enough characters" do
      include_examples "mobile number" do
        let(:mobile_number) { "0700710120" }
        let(:message) { "Enter your mobile number in the correct format, like 07700 900 982" }
      end
    end
  end
end
