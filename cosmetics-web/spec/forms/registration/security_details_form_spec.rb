require "rails_helper"

RSpec.describe Registration::SecurityDetailsForm do

  let(:password) { "foobarbaz" }
  let(:mobile_number) { "07000 000 000" }

  let(:form) do
    Registration::SecurityDetailsForm.new(password: password, mobile_number: mobile_number)
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

  context "mobile number vaildations" do
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
        let(:message) { "Mobile number can not be blank" }
      end
    end

    context "when mobile number has letters" do
      include_examples "mobile number" do
        let(:mobile_number) { "070000assd" }
        let(:message) { "Mobile number is invalid" }
      end
    end

    context "when mobile number has not enough characters" do
      include_examples "mobile number" do
        let(:mobile_number) { "0700710120" }
        let(:message) { "Mobile number is too short (minimum is 11 characters)" }
      end
    end
  end
end
