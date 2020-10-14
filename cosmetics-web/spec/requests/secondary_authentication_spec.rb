require "rails_helper"

RSpec.describe "Secondary Authentication submit", :with_2fa, :with_stubbed_notify, type: :request do
  before do
    configure_requests_for_submit_domain
  end

  describe "#new" do
    it "cannot be directly accessed" do
      get new_secondary_authentication_path
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "#create" do
    subject(:submit_2fa) do
      post secondary_authentication_path,
           params: {
             secondary_authentication_form: {
               otp_code: submitted_code,
               user_id: user.id,
             },
           }
    end

    let(:attempts) { 0 }
    let(:direct_otp_sent_at) { Time.new.utc }
    let(:secondary_authentication) { SecondaryAuthentication.new(user) }
    let(:submitted_code) { secondary_authentication.direct_otp }
    let(:max_attempts) { SecondaryAuthentication::MAX_ATTEMPTS }
    let(:second_factor_attempts_locked_at) { nil }

    let(:previous_attempts_count) { 1 }
    let(:user) do
      create(
        :submit_user,
        :with_responsible_person,
        mobile_number_verified: false,
        direct_otp_sent_at: direct_otp_sent_at,
        second_factor_attempts_count: attempts,
        second_factor_attempts_locked_at: second_factor_attempts_locked_at,
      )
    end

    before do
      sign_in(user)
    end

    shared_examples_for "code not accepted" do |*errors|
      it "does not leave the two factor form page" do
        submit_2fa
        expect(response).to render_template(:new)
      end

      it "displays an error to the user" do
        submit_2fa
        errors.each do |error|
          expect(response.body).to include(error)
        end
      end
    end

    context "when code is invalid" do
      let(:submitted_code) { "" }

      include_examples "code not accepted", "Enter the security code"
    end

    context "with correct otp" do
      it "redirects to the main page" do
        submit_2fa
        expect(response).to redirect_to(root_path)
      end

      it "user is signed in" do
        sign_in(user)
        submit_2fa
        follow_redirect!
        expect(response.body).not_to include("Sign in")
        expect(response.body).to include("Sign out")
      end

      it "marks the mobile number as verified" do
        submit_2fa
        expect(user.reload.mobile_number_verified).to be true
      end
    end

    context "with incorrect otp" do
      let(:submitted_code) { secondary_authentication.direct_otp.reverse }

      include_examples "code not accepted", "Incorrect security code"
    end

    context "with expired otp" do
      let(:direct_otp_sent_at) { (SecondaryAuthentication::OTP_EXPIRY_SECONDS * 2).seconds.ago }

      include_examples "code not accepted", "The security code has expired. New code sent."
    end

    context "with too many attempts" do
      let(:attempts) { max_attempts + 1 }

      include_examples "code not accepted", "Incorrect security code"
    end

    context "with resending otp code" do
      # rubocop:disable RSpec/AnyInstance
      context "when code is expired" do
        let(:direct_otp_sent_at) { (SecondaryAuthentication::OTP_EXPIRY_SECONDS * 2).seconds.ago }

        context "when secondary authentication is locked" do
          let(:second_factor_attempts_locked_at) { Time.now.utc }

          it "does not send the code" do
            expect_any_instance_of(SecondaryAuthentication).not_to receive(:generate_and_send_code)
            submit_2fa
          end
        end

        it "resends the code" do
          expect_any_instance_of(SecondaryAuthentication).to receive(:generate_and_send_code)
          submit_2fa
        end
      end
      # rubocop:enable RSpec/AnyInstance
    end
  end
end
