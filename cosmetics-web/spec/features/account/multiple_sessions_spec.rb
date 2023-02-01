require "rails_helper"

RSpec.feature "One user can use only one session", :with_2fa, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  shared_examples "multiple sessions" do
    scenario "Invalidate all sessions when user is logged in on different browser" do
      visit "/sign-in"

      fill_in "Email address", with: user.email
      fill_in "Password", with: user.password
      click_button "Continue"

      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      complete_secondary_authentication_sms_with("#{otp_code} ")

      expect(page).to have_current_path(path)

      Capybara.using_session("Other browser") do
        visit "/sign-in"

        fill_in "Email address", with: user.email
        fill_in "Password", with: user.password
        click_button "Continue"

        select_secondary_authentication_sms
        expect_to_be_on_secondary_authentication_sms_page
        complete_secondary_authentication_sms_with("#{otp_code} ")

        expect(page).to have_current_path(path)
      end

      visit path
      expect(page).to have_css("h2", text: "Your login credentials were used in another browser. Please sign in again to continue in this browser.")
    end

    scenario "Invalidate all sessions when user is logging out" do
      visit "/sign-in"

      fill_in "Email address", with: user.email
      fill_in "Password", with: user.password
      click_button "Continue"

      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      complete_secondary_authentication_sms_with("#{otp_code} ")

      expect(page).to have_current_path(path)

      stolen_cookies = Capybara.current_session.driver.request.cookies

      Capybara.using_session("Other browser") do
        stolen_cookies.each do |k, v|
          page.driver.browser.set_cookie("#{k}=#{v}")
        end
        visit path
        expect(page).to have_current_path(path)
      end

      visit path
      click_link "Sign out"

      Capybara.using_session("Other browser") do
        visit path
        expect(page).to have_css("h2", text: "Your login credentials were used in another browser. Please sign in again to continue in this browser.")
      end
    end
  end

  describe "for search" do
    let(:user) { create(:poison_centre_user, has_accepted_declaration: true) }
    let(:path) { "/notifications" }

    before do
      configure_requests_for_search_domain
    end

    include_examples "multiple sessions"
  end

  describe "for submit" do
    let(:user) { create(:submit_user, has_accepted_declaration: true) }
    let(:path) { "/responsible_persons/account/overview" }

    before do
      configure_requests_for_submit_domain
    end

    include_examples "multiple sessions"
  end
end
