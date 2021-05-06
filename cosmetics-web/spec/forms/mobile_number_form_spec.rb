require "rails_helper"

RSpec.describe MobileNumberForm do
  subject(:form) do
    described_class.new(user: user, password: password, mobile_number: mobile_number)
  end

  let(:password) { user.password }
  let(:mobile_number) { "07123456789" }

  RSpec.shared_examples_for "invalid form" do |field, error_message|
    it "is not valid" do
      expect(form).to be_invalid
    end

    it "populates an error message" do
      expect(form.errors.full_messages_for(field)).to eq([error_message])
    end
  end

  RSpec.shared_examples_for "valid form" do
    it "is valid" do
      expect(form).to be_valid
    end

    it "does not contain error messages for the field" do
      expect(form.errors.full_messages).to be_empty
    end
  end

  RSpec.shared_examples_for "form validation" do
    context "with correct password and valid mobile number" do
      include_examples "valid form"
    end

    context "when the user password is incorrect" do
      let(:password) { "wrongPassword" }

      include_examples "invalid form", :password, "Password is incorrect"
    end

    context "when the user password is misssing" do
      let(:password) { "" }

      include_examples "invalid form", :password, "Password can not be blank"
    end

    context "when the mobile number is missing" do
      let(:mobile_number) { "" }

      include_examples "invalid form", :mobile_number, "Enter a mobile number, like 07700 900 982 or +44 7700 900 982"
    end

    context "when the mobile number has the wrong format" do
      let(:mobile_number) { "notAphone" }

      include_examples "invalid form", :mobile_number, "Enter a mobile number, like 07700 900 982 or +44 7700 900 982"
    end
  end

  describe "#valid?" do
    before { form.validate }

    context "with a submit user" do
      let(:user) { build_stubbed(:submit_user) }

      include_examples "form validation"

      context "when the mobile number in an international number" do
        let(:mobile_number) { "+34629012345" }

        include_examples "valid form"
      end
    end

    context "with a search user" do
      let(:user) { build_stubbed(:search_user) }

      include_examples "form validation"

      context "when the mobile number in an international number" do
        let(:mobile_number) { "+34629012345" }

        include_examples "invalid form", :mobile_number, "Enter a mobile number, like 07700 900 982 or +44 7700 900 982"
      end
    end
  end
end
