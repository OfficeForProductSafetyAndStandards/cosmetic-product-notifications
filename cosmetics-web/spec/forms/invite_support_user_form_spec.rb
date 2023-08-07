require "rails_helper"

RSpec.describe InviteSupportUserForm do
  subject(:form) do
    described_class.new(email:,
                        name:)
  end

  let(:email) { "invited.user@example.gov.uk" }
  let(:name) { "Invited User" }

  describe "#valid?" do
    before { form.validate }

    context "when all the data is present" do
      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end

    context "when the name is blank" do
      let(:name) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:name)).to eq(["Enter the full name"])
      end
    end

    context "when the email is blank" do
      let(:email) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:email)).to eq(["Enter an email address"])
      end
    end

    context "when the email format is wrong" do
      let(:email) { "email.address.wrongly.formatted" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:email))
          .to eq(["Enter an email address in the correct format and end in gov.uk"])
      end
    end
  end
end
