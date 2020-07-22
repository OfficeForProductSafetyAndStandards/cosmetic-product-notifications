require "rails_helper"

RSpec.describe SignInForm do
  subject(:form) { described_class.new(email: email, password: password) }

  let(:password) { "password" }
  let(:email)    { "test@example.com" }

  describe "#valid?" do
    before { form.validate }

    describe "when the email is blank" do
      let(:email) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:email)).to eq(["Enter your email address"])
      end
    end

    context "when the email is not blank" do
      context "when it does not contain an @" do
        let(:email) { "not_an_email" }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:email)).to eq(["Enter your email address in the correct format, like name@example.com"])
        end
      end
    end

    describe "when the password is blank" do
      let(:password) { "" }

      it "is not valid" do
        expect(form).to be_invalid
      end

      it "populates an error message" do
        expect(form.errors.full_messages_for(:password)).to eq(["Enter your password"])
      end
    end
  end
end
