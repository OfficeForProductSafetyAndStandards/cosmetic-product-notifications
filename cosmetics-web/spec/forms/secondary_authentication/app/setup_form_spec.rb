require "rails_helper"

RSpec.describe SecondaryAuthentication::App::SetupForm, :with_2fa_app do
  subject(:form) do
    described_class.new(user: user, password: password, app_authentication_code: app_authentication_code)
  end

  let(:app_authentication_code) { "123456" }
  let(:password) { user.password }
  let(:user) { build_stubbed(:submit_user) }

  RSpec.shared_examples_for "invalid form" do |field, error_message|
    it "is not valid" do
      expect(form).to be_invalid
    end

    it "populates an error message" do
      expect(form.errors.full_messages_for(field)).to eq([error_message])
    end
  end

  describe "#valid?" do
    before { form.validate }

    context "with correct password and valid authentication code" do
      it "is valid" do
        expect(form).to be_valid
      end

      it "does not contain error messages for the field" do
        expect(form.errors.full_messages).to be_empty
      end
    end

    context "when the user password is incorrect" do
      let(:password) { "wrongPassword" }

      include_examples "invalid form", :password, "Password is incorrect"
    end

    context "when the user password is misssing" do
      let(:password) { "" }

      include_examples "invalid form", :password, "Password can not be blank"
    end

    context "when the authentication code is missing" do
      let(:app_authentication_code) { "" }

      include_examples "invalid form", :app_authentication_code, "Enter an access code"
    end

    context "when the authentication code is wrong" do
      let(:app_authentication_code) { "notAphone" }

      include_examples "invalid form", :app_authentication_code, "Access code is incorrect"
    end
  end
end
