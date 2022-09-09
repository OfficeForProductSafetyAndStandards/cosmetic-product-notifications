require "rails_helper"

RSpec.describe "User requests new secondary authentication sms code", type: :request, with_stubbed_notify: true, with_2fa: true do
  let(:user_session) { {} }

  before do
    configure_requests_for_submit_domain
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:session).and_return(user_session)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "viewing the form" do
    subject(:request_code) { get new_secondary_authentication_sms_resend_path }

    RSpec.shared_examples "redirect to homepage" do
      it "redirects the user to the homepage" do
        request_code
        expect(response).to redirect_to(submit_root_path)
      end
    end

    RSpec.shared_examples "allow access" do
      it "loads the resend secondary authentication code page", :aggregate_failures do
        request_code

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("secondary_authentication/sms/resend/new")
      end
    end

    let(:user) { create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication) }

    context "when signed in without having requested 2FA" do
      before do
        sign_in(user)
      end

      include_examples "redirect to homepage"
    end

    context "when neither signed in nor having requested 2FA" do
      include_examples "redirect to homepage"
    end

    context "when not signed in but having requested 2FA" do
      let(:user_session) { { secondary_authentication_user_id: user.id } }

      include_examples "allow access"
    end

    context "when signed in and having requested 2FA" do
      let(:user_session) { { secondary_authentication_user_id: user.id } }

      before do
        sign_in(user)
      end

      include_examples "allow access"
    end
  end

  describe "submitting the request" do
    subject(:request_code) { post new_secondary_authentication_sms_resend_path }

    let(:user) { create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication) }

    RSpec.shared_examples "deny access" do
      it "shows an access denied error", :aggregate_failures do
        post secondary_authentication_sms_resend_path

        expect(response).to have_http_status(:forbidden)
        expect(response).to render_template("errors/forbidden")
      end
    end

    RSpec.shared_examples "resend code" do
      it "generates a new secondary authentication code for the user" do
        expect {
          request_code
          follow_redirect!
          user.reload
        }.to change(user, :direct_otp)
      end

      it "sends the code to the user by sms" do
        request_code
        follow_redirect!

        perform_enqueued_jobs

        expect(notify_stub).to have_received(:send_sms).with(
          hash_including(phone_number: user.mobile_number, personalisation: { code: user.reload.direct_otp }),
        )
      end

      it "redirects the user to the secondary authentication page" do
        request_code

        expect(response).to redirect_to(new_secondary_authentication_sms_path)
      end
    end

    RSpec.shared_examples "resend code and update mobile number" do
      context "when a mobile number is not provided" do
        let(:mobile_number) { "" }

        it "shows the submission form" do
          request_code

          expect(response).to render_template("secondary_authentication/sms/resend/new")
        end

        it "does not change the user secondary authentication code" do
          expect {
            request_code
            user.reload
          }.not_to change(user, :direct_otp)
        end

        it "does not send any sms to the user" do
          request_code

          expect(notify_stub).not_to have_received(:send_sms)
        end
      end

      context "when an incorrect mobile number is provied" do
        let(:mobile_number) { "00thisIsWrong" }

        it "shows the submission form" do
          request_code

          expect(response).to render_template("secondary_authentication/sms/resend/new")
        end

        it "does not change the user secondary authentication code" do
          expect {
            request_code
            user.reload
          }.not_to change(user, :direct_otp)
        end

        it "does not send any sms to the user" do
          request_code

          expect(notify_stub).not_to have_received(:send_sms)
        end
      end

      context "when a mobile number is provided" do
        let(:mobile_number) { "+(44)7123456789" }

        it "generates a new secondary authentication code for the user" do
          expect {
            request_code
            follow_redirect!
            user.reload
          }.to change(user, :direct_otp)
        end

        it "updates the user mobile number" do
          expect {
            request_code

            perform_enqueued_jobs

            user.reload
          }.to change(user, :mobile_number).to(mobile_number)
        end

        it "sends the code to the user by sms" do
          request_code
          follow_redirect!

          perform_enqueued_jobs

          expect(notify_stub).to have_received(:send_sms).with(
            hash_including(phone_number: mobile_number, personalisation: { code: user.reload.direct_otp }),
          )
        end

        it "redirects the user to the secondary authentication page" do
          request_code

          expect(response).to redirect_to(new_secondary_authentication_sms_path)
        end
      end
    end

    context "when neither signed in nor having requested 2FA" do
      include_examples "deny access"
    end

    context "when signed in without having requested 2FA" do
      before do
        sign_in(user)
      end

      include_examples "deny access"
    end

    context "when not signed in but having requested 2FA" do
      let(:user_session) { { secondary_authentication_user_id: user.id } }

      context "when user has a verified mobile number" do
        include_examples "resend code"
      end

      context "when user haven't verified their mobile number" do
        subject(:request_code) do
          post new_secondary_authentication_sms_resend_path, params: { submit_user: { mobile_number: } }
        end

        let(:user) do
          create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication, mobile_number_verified: false)
        end

        include_examples "resend code and update mobile number"
      end
    end

    context "when user is signed in and have requested 2FA" do
      let(:user_session) { { secondary_authentication_user_id: user.id } }

      before do
        sign_in(user)
      end

      context "when user has a verified mobile number" do
        include_examples "resend code"
      end

      context "when user haven't verified their mobile number" do
        subject(:request_code) do
          post new_secondary_authentication_sms_resend_path, params: { submit_user: { mobile_number: } }
        end

        let(:user) do
          create(:submit_user, :with_responsible_person, :with_sms_secondary_authentication, mobile_number_verified: false)
        end

        include_examples "resend code and update mobile number"
      end
    end
  end
end
