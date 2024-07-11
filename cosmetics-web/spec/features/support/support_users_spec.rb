require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Support Users", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:support_user, :with_all_secondary_authentication_methods) }
  let(:support_user_a) { create(:support_user) }
  let(:support_user_b) { create(:support_user) }
  let(:support_user_c) { create(:support_user) }

  before do
    configure_requests_for_support_domain

    support_user_a
    support_user_b
    support_user_c

    sign_in user
    select_secondary_authentication_app
    complete_secondary_authentication_app
  end

  scenario "Viewing all active SupportUser accounts" do
    expect(page).to have_h1("Dashboard")

    click_link "Your account"
    click_link "View team members"

    expect(page).to have_h1("Team members")

    expect(page).to have_css("th", text: "Team member name")
    expect(page).to have_css("th", text: "Email address")
    expect(page).to have_css("th", text: "Date last active")
    expect(page).to have_css("th", text: support_user_a.name)
    expect(page).to have_css("td", text: support_user_a.email)
    expect(page).to have_css("th", text: support_user_b.name)
    expect(page).to have_css("td", text: support_user_b.email)
    expect(page).to have_css("th", text: support_user_c.name)
    expect(page).to have_css("td", text: support_user_c.email)
  end

  scenario "Removing an account" do
    expect(page).to have_h1("Dashboard")

    click_link "Your account"
    click_link "View team members"

    expect(page).to have_h1("Team members")

    click_link("Remove account", match: :first)
    expect(page).to have_h1("Remove #{support_user_a.name}")

    click_on "Remove account"

    expect(page).to have_css("div.govuk-notification-banner__heading", text: "Team member #{support_user_a.name} removed from OSU portal")
    expect(page).not_to have_css("th", text: support_user_a.name)
    expect(page).not_to have_css("td", text: support_user_a.email)
  end

  scenario "when trying to remove user's own account" do
    visit "/support_users/#{user.id}/remove"

    expect(page).to have_current_path("/support_users")
  end
end
