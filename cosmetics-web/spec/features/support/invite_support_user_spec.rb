require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Invite support user", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:support_user, :with_sms_secondary_authentication) }
  let(:new_user_email) { "new-support-user@example.gov.uk" }
  let(:support_user) { create(:support_user) }

  before do
    configure_requests_for_support_domain

    support_user

    sign_in user
  end

  scenario "inviting a new team member" do
    expect(page).to have_h1("Dashboard")

    click_link "Your account"

    expect(page).to have_h1("Your account")

    expect(page).to have_h2("User management")

    click_link "Invite"

    expect(page).to have_h1("Invite a team member")

    fill_in "Full name", with: "John Doe"
    fill_in "Email", with: new_user_email
    click_on "Send invitation"

    expect(page).to have_current_path("/invite-support-user/new")

    expect(page).to have_css(
      "div.govuk-notification-banner__heading",
      text: "Invitation sent to John Doe at #{new_user_email}",
    )

    new_user = SupportUser.where(email: new_user_email).first

    expect(delivered_emails.size).to eq 1
    email = delivered_emails.first
    expect(email).to have_attributes(
      recipient: new_user_email,
      template: SupportNotifyMailer::TEMPLATES[:invitation],
      personalization: { invitation_url: "http://#{ENV['SUPPORT_HOST']}/users/#{new_user.id}/complete-registration?invitation=#{new_user.invitation_token}" },
    )
  end

  scenario "Removing and reinviting support user" do
    expect(page).to have_h1("Dashboard")

    click_link "Your account"
    click_link "View team members"

    expect(page).to have_h1("Team members")

    click_link("Remove account", match: :first)
    expect(page).to have_h1("Remove #{support_user.name}")

    click_on "Remove account"

    expect(page).to have_css("div.govuk-notification-banner__heading", text: "Team member #{support_user.name} removed from OSU portal")
    expect(page).not_to have_css("th", text: support_user.name)
    expect(page).not_to have_css("td", text: support_user.email)

    click_link "Your account"
    click_link "Invite"

    fill_in "Full name", with: "John Doe"
    fill_in "Email", with: new_user_email
    click_on "Send invitation"

    expect(page).to have_current_path("/invite-support-user/new")

    expect(page).to have_css(
      "div.govuk-notification-banner__heading",
      text: "Invitation sent to John Doe at #{new_user_email}",
    )

    new_user = SupportUser.where(email: new_user_email).first

    expect(delivered_emails.size).to eq 1
    email = delivered_emails.first
    expect(email).to have_attributes(
      recipient: new_user_email,
      template: SupportNotifyMailer::TEMPLATES[:invitation],
      personalization: { invitation_url: "http://#{ENV['SUPPORT_HOST']}/users/#{new_user.id}/complete-registration?invitation=#{new_user.invitation_token}" },
    )
  end
end
