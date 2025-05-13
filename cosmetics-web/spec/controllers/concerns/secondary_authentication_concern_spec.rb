require "rails_helper"
require "feature_flags"

RSpec.describe SecondaryAuthenticationConcern, type: :controller do
  controller(ApplicationController) do
    # Using SecondaryAuthenticationConcern directly instead of described_class
    # because described_class is not available in this context
    # rubocop:disable RSpec/DescribedClass
    include SecondaryAuthenticationConcern
    # rubocop:enable RSpec/DescribedClass

    skip_before_action :authenticate_user!
    skip_before_action :ensure_secondary_authentication
    before_action :authenticate_for_test

    def index
      if require_secondary_authentication
        # Secondary authentication was required, control was already redirected
        return
      end

      # If we get here, secondary authentication was not required
      render plain: "Authentication successful"
    end

  private

    def authenticate_for_test
      # Simulate authenticated user
      current_user = User.find_by(id: params[:user_id])
      sign_in(current_user) if current_user
    end

    def submit_domain?
      true
    end
  end

  let(:user) { create(:submit_user, :with_sms_secondary_authentication, :with_responsible_person) }

  before do
    routes.draw do
      get "anonymous/index"
    end
    allow(Rails.configuration).to receive(:secondary_authentication_enabled).and_return(true)
  end

  context "when 2FA feature flag is enabled" do
    before do
      # Enable 2FA feature flag
      allow(FeatureFlags).to receive(:two_factor_authentication_enabled?).and_return(true)
      get :index, params: { user_id: user.id }
    end

    it "requires 2FA authentication" do
      # With 2FA enabled, the user should be redirected to secondary authentication
      expect(response).to be_redirect
      expect(response.location).to include("two-factor")
    end
  end

  context "when 2FA feature flag is disabled" do
    before do
      # Disable 2FA feature flag
      allow(FeatureFlags).to receive(:two_factor_authentication_enabled?).and_return(false)
      get :index, params: { user_id: user.id }
    end

    it "does not require 2FA authentication" do
      # With 2FA disabled, the controller action should complete successfully
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Authentication successful")
    end
  end
end
