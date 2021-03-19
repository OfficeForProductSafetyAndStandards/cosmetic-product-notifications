require "rails_helper"

RSpec.describe SecondaryAuthentication::AppAuthForm, :with_2fa_app do
  subject(:form) { described_class.new(otp_code: otp_code, user_id: user.id) }

  let(:user) { create(:submit_user, :with_app_secondary_authentication) }
  let(:otp_code) { user.direct_otp }

  describe "#valid?" do
    context "with form validation" do
      before { form.validate }

      context "with a valid code" do
        let(:otp_code) { correct_app_code }

        it "is valid" do
          expect(form).to be_valid
        end

        it "does not contain error messages" do
          expect(form.errors).to be_empty
        end
      end

      context "when the two factor code is blank" do
        let(:otp_code) { "" }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["Enter the access code"])
        end
      end

      context "when the two factor code is wrong" do
        let(:otp_code) { correct_app_code.reverse }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["Incorrect access code"])
        end
      end

      context "when the two factor code contains letters" do
        let(:otp_code) { "123a56" }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["The code must be 6 numbers"])
        end
      end

      context "when the two factor code has less digits than the required ones" do
        let(:otp_code) { rand.to_s[2..described_class::AUTHENTICATION_APP_CODE_LENGTH] }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["You haven’t entered enough numbers"])
        end
      end

      context "when the two factor code has less digits than the required and contains letters" do
        let(:otp_code) { "1a" }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["The code must be 6 numbers"])
        end
      end

      context "when the two factor code has more digits than the required ones" do
        let(:otp_code) { rand.to_s[2..described_class::AUTHENTICATION_APP_CODE_LENGTH + 3] }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message" do
          expect(form.errors.full_messages_for(:otp_code)).to eq(["You’ve entered too many numbers"])
        end
      end
    end
  end
end
