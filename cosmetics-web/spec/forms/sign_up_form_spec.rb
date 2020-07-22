require "rails_helper"

RSpec.describe SignUpForm do
  subject(:form) do
    described_class.new(name: name,
                        mobile_number: mobile_number,
                        email: email,
                        password: password,
                        password_confirmation: password_confirmation)
  end

  let(:name) { "John" }
  let(:mobile_number) { "07000000000" }
  let(:email)    { "test@example.com" }
  let(:password) { "password" }
  let(:password_confirmation) { "password" }

  shared_examples_for "invalid form" do |attribute, error_message|
    it "is not valid" do
      expect(form).to be_invalid
    end

    it "populates an error message" do
      expect(form.errors.full_messages_for(attribute)).to eq([error_message])
    end
  end

  describe "#valid?" do
    before { form.validate }

    describe "when all the attributes are present an valid" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    describe "when the name is missing" do
      let(:name) { "" }

      include_examples "invalid form", :name, "Enter your name"
    end

    describe "when the mobile number is missing" do
      let(:mobile_number) { "" }

      include_examples "invalid form", :mobile_number, "Enter your mobile number"
    end

    describe "when the mobile number has the wrong format" do
      let(:mobile_number) { "ab07001+34" }

      include_examples("invalid form",
                       :mobile_number,
                       "Enter your mobile number in the correct format, like 07700 900 982")
    end

    describe "when the email is missing" do
      let(:email) { "" }

      include_examples "invalid form", :email, "Enter your email address"
    end

    context "when the email has the wrong format" do
      let(:email) { "not_an_email" }

      include_examples("invalid form",
                       :email,
                       "Enter your email address in the correct format, like name@example.com")
    end

    describe "when the password is missing" do
      let(:password) { "" }

      include_examples "invalid form", :password, "Enter your password"
    end

    describe "when the password confirmation is missing" do
      let(:password_confirmation) { "" }

      include_examples "invalid form", :password_confirmation, "Enter your password confirmation"
    end

    describe "when the password confirmation is different from the password" do
      let(:password_confirmation) { "differentpassword" }

      include_examples "invalid form", :password_confirmation, "Should match password"
    end
  end
end
