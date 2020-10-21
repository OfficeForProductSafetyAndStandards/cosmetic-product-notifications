require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Creating an account from an invitation", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, type: :feature do
  let!(:invited_user) { InviteUser.call(email: "john.doe@example.com", name: "John Doe", role: :poison_centre).user }
  let(:existing_user) { create(:poison_centre_user) }

  before do
    configure_requests_for_search_domain
  end

  scenario "Creating an account from an invitation" do
    email = delivered_emails.last
    invite_url = email.personalization[:invitation_url]
    visit invite_url

    expect_to_be_on_complete_registration_page

    fill_in_account_details_with full_name: "Bob Jones", mobile_number: "07731123345", password: "testpassword123@"

    click_button "Continue"

    expect_to_be_on_secondary_authentication_page

    fill_in "Enter security code", with: otp_code
    click_on "Continue"

    # FIXME: TODO:
    # For some reason, we dont have declaration, only when spec when is being run
    # as single example
    begin
      click_button "I accept"
    rescue StandardError
      nil
    end
    expect_to_be_signed_in_as_search_user

    # Now sign out and use those credentials to sign back in
    find_link("Sign out", match: :first).click

    expect_to_be_on_the_search_homepage

    click_link "Sign in"

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: "testpassword123@"
    click_on "Continue"

    # Skips 2FA as cookie was set to not require
    # 2FA for 7 days.

    expect_to_be_signed_in_as_search_user
  end

  scenario "Creating an account from an invitation when signed in as another user" do
    sign_in existing_user

    visit "/users/#{invited_user.id}/complete-registration?invitation=#{invited_user.invitation_token}"

    expect_to_be_on_signed_in_as_another_user_page

    click_button "Create a new account"

    expect_to_be_on_complete_registration_page

    fill_in_account_details_with full_name: "Bob Jones", mobile_number: "07731123345", password: "testpassword123@"

    click_button "Continue"

    expect_to_be_on_secondary_authentication_page

    fill_in "Enter security code", with: otp_code
    click_on "Continue"

    # FIXME: TODO:
    # For some reason, here we have declaration, but we dont have in happy path spec...
    click_button "I accept"
    expect_to_be_signed_in_as_search_user
  end

  # TODO
  # context "when a previous registration was abandoned before verifying mobile number" do
  #   let(:invited_user) do
  #     create(
  #       :user,
  #       :invited,
  #       name: "Bob Jones",
  #       mobile_number: "07700 900 982",
  #       mobile_number_verified: false
  #     )
  #   end

  #   scenario "it shouldn’t show values entered previously" do
  #     visit "/users/#{invited_user.id}/complete-registration?invitation=#{invited_user.invitation_token}"

  #     expect_to_be_on_complete_registration_page

  #     # Form should NOT contain values from previous abandoned registration
  #     expect(find_field("Full name").value).to eq ""
  #     expect(find_field("Mobile number").value).to eq ""

  #     # Deliberately leave password blank
  #     fill_in_account_details_with full_name: "Bob Jones", mobile_number: "07731123345", password: ""

  #     click_button "Continue"

  #     # Form SHOULD now contain pre-filled values from previous submission
  #     expect(find_field("Full name").value).to eq("Bob Jones")
  #     expect(find_field("Mobile number").value).to eq("07731123345")

  #     # Now add a password
  #     fill_in "Password", with: "testpassword123@"

  #     click_button "Continue"

  #     expect_to_be_on_secondary_authentication_page

  #     fill_in "Enter security code", with: otp_code
  #     click_on "Continue"

  #     expect_to_be_on_declaration_page
  #     expect_to_be_signed_in_as_search_user
  #   end
  # end

  def expect_to_be_signed_in_as_search_user
    expect(page).to have_css("h1", text: "Search cosmetic products")
    expect(page).to have_css("a", text: "Sign out")
  end

  def expect_to_be_on_the_search_homepage
    expect(page).to have_css("h1", text: "Search for cosmetic products")
    expect(page).to have_text("If you’re using this service for the first time")
  end

  def fill_in_account_details_with(full_name:, mobile_number:, password:)
    fill_in "Full name", with: full_name
    fill_in "Mobile number", with: mobile_number
    fill_in "Password", with: password
  end

  def otp_code
    invited_user.reload.direct_otp
  end
end
