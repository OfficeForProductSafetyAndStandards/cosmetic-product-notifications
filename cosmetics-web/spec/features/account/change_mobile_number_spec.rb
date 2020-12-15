require "rails_helper"

RSpec.describe "Changing mobile number", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:submit_user, has_accepted_declaration: true) }

  before do
    configure_requests_for_submit_domain
  end

  before do
    visit "/sign-in"
    fill_in_credentials

    expect(page).to have_css("h1", text: "Check your phone")
    fill_in "Enter security code", with: "#{otp_code} "
    click_on "Continue"

    click_on "Your account"
    expect_to_be_on_my_account_page

    wait_for = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::CHANGE_MOBILE_NUMBER]
    travel_to((wait_for + 1).seconds.from_now)

    click_on "Change mobile number"
    expect(page).to have_css("h1", text: "Check your phone")
    fill_in "Enter security code", with: "#{otp_code} "
    click_on "Continue"
  end

  context "when the password change is fine" do
    it "changes password properly" do
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "07234234234"
      click_on "Continue"

      expect(page).to have_css("h1", text: "Check your phone")
      fill_in "Enter security code", with: "#{otp_code} "
      click_on "Continue"

      expect_to_be_on_my_account_page
      expect(page).to have_text(/Mobile number changed successfully/)
    end
  end

  context "when the update cant be done" do
    it "does not get updated when password is wrong" do
      fill_in "Password", with: "user.password"
      fill_in "New mobile number", with: "07500111000"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Password is incorrect", href: "#password")
    end

    it "does not get updated when new mobile number is empty" do
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: ""
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Mobile number can not be blank", href: "#mobile_number")
    end

    it "does not get updated when new mobile number has an incorrect format" do
      fill_in "Password", with: user.password
      fill_in "New mobile number", with: "12345678(wrong)9101112"
      click_on "Continue"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_link("Enter a mobile number, like 07700 900 982 or +44 7700 900 982", href: "#mobile_number")
    end
  end
end
