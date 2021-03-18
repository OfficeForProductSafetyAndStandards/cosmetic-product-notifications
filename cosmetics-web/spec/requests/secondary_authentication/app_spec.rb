require "rails_helper"

RSpec.describe "Secondary Authentication with App submit", :with_2fa, type: :request do
  before do
    configure_requests_for_submit_domain
  end

  describe "#new" do
    let(:user) { create(:submit_user, :with_app_secondary_authentication) }
    let(:user_session) { {} }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(SecondaryAuthentication::AppController)
        .to receive(:session).and_return(user_session)
      # rubocop:enable RSpec/AnyInstance
      sign_in(user)
    end

    it "cannot be directly accessed" do
      get new_secondary_authentication_app_path
      expect(response).to have_http_status(:forbidden)
    end

    context "when accessed user session contains 2fa user id" do
      let(:user_session) { { secondary_authentication_user_id: user.id } }

      it "displays app authentication page" do
        get new_secondary_authentication_app_path
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create", :with_2fa_app do
    subject(:submit_2fa) do
      post secondary_authentication_app_path,
           params: { otp_code: submitted_code, user_id: user.id }
    end

    let(:user) do
      create(:submit_user, :with_responsible_person, :with_app_secondary_authentication)
    end

    before do
      sign_in(user)
    end

    context "with a correct code" do
      let(:submitted_code) { correct_app_code }

      it "redirects to the main page" do
        submit_2fa
        expect(response).to redirect_to(root_path)
      end

      it "user is signed in" do
        submit_2fa
        follow_redirect!
        expect(response.body).not_to include("Sign in")
        expect(response.body).to include("Sign out")
      end
    end

    context "with an incorrect code" do
      let(:submitted_code) { correct_app_code.reverse }

      it "does not leave the two factor form page" do
        submit_2fa
        expect(response).to render_template(:new)
      end

      it "displays an error to the user" do
        submit_2fa
        expect(response.body).to include("Incorrect access code")
      end
    end
  end
end
