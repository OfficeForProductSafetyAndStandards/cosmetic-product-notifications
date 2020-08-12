module DeviseLoginHelpers
  def sign_in(user = create(:poison_centre_user, :activated, has_viewed_introduction: true))
    visit "/sign-in"

    stub_request(:post, "https://api.notifications.service.gov.uk/v2/notifications/sms").and_return(body: {}.to_json, status: 200)
    fill_in "email", with: user.email
    fill_in "password", with: "testpassword123"
    click_on "Continue"

    if page.has_field?("Enter security code")
      fill_in "Enter security code", with: user.reload.direct_otp
      click_on "Continue"
    end
  end

  def sign_out
    return if page.has_css?("a", text: "Sign in to your account")

    click_on "Sign out", match: :first
  end
end

module Devise::Test::TokenGenerator
  def stubbed_devise_generated_token(reset_token = Devise.token_generator.generate(User, :reset_password_token))
    allow(Devise.token_generator)
      .to receive(:generate)
      .and_return(reset_token)

    reset_token
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers
  config.include DeviseLoginHelpers, type: :feature
  config.include Devise::Test::TokenGenerator
  config.before(:each, :with_2fa) do
    allow(Rails.application.config).to receive(
      :secondary_authentication_enabled
    ).and_return(true)
  end
end
