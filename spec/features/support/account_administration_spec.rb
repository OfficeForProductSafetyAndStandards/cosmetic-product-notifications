require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Account administration", :with_2fa, :with_2fa_app, :with_stubbed_mailer, :with_stubbed_notify, type: :feature do
  let(:user) { create(:support_user, :with_all_secondary_authentication_methods) }
  let(:search_user_a) { create(:search_user) }
  let(:search_user_b) { create(:search_user) }
  let(:search_user_c) { create(:opss_general_user, name: search_user_a.name) }
  let(:submit_user_a) { create(:submit_user) }
  let(:submit_user_b) { create(:submit_user) }
  let(:responsible_person_user_a) { create(:responsible_person_user, user: submit_user_a) }
  let(:responsible_person_user_b) { create(:responsible_person_user, user: submit_user_b) }
  let(:responsible_person_user_c) { create(:responsible_person_user, user: submit_user_a, responsible_person: responsible_person_user_b.responsible_person) }
  let(:responsible_person_user_d) { create(:responsible_person_user, user: submit_user_b) }

  before do
    configure_requests_for_support_domain

    search_user_a
    search_user_b
    search_user_c
    submit_user_a
    submit_user_b
    responsible_person_user_a
    responsible_person_user_b
    responsible_person_user_c
    responsible_person_user_d

    sign_in user
    select_secondary_authentication_app
    complete_secondary_authentication_app
  end

  scenario "Searching for an account that exists" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"
    click_link "Search for an account"

    expect(page).to have_h1("Search for an account")

    fill_in "Enter a search term", with: search_user_b.name
    click_on "Search"

    expect(page).to have_text(search_user_b.name)
    expect(page).to have_text(search_user_b.email)
    expect(page).not_to have_text(search_user_a.name)
    expect(page).not_to have_text(search_user_a.email)
    expect(page).not_to have_text(search_user_c.name)
    expect(page).not_to have_text(search_user_c.email)
  end

  scenario "Searching for an account that exists with multiple results" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"
    click_link "Search for an account"

    expect(page).to have_h1("Search for an account")

    fill_in "Enter a search term", with: search_user_a.name
    click_on "Search"

    expect(page).to have_text(search_user_a.name)
    expect(page).to have_text(search_user_a.email)
    expect(page).to have_text(search_user_c.name)
    expect(page).to have_text(search_user_c.email)
    expect(page).not_to have_text(search_user_b.name)
    expect(page).not_to have_text(search_user_b.email)
  end

  scenario "Searching for a user that doesn't exist" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"
    click_link "Search for an account"

    expect(page).to have_h1("Search for an account")

    fill_in "Enter a search term", with: "Random name"
    click_on "Search"

    expect(page).to have_text('There are no accounts for "Random name".')

    click_on "Clear search results"

    expect(page).to have_text("Enter a search term")
  end

  scenario "Searching for an empty string" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"
    click_link "Search for an account"

    expect(page).to have_h1("Search for an account")

    click_on "Search"

    expect(page).to have_text(search_user_a.name)
    expect(page).to have_text(search_user_a.email)
    expect(page).to have_text(search_user_b.name)
    expect(page).to have_text(search_user_b.email)
    expect(page).to have_text(search_user_c.name)
    expect(page).to have_text(search_user_c.email)
    expect(page).to have_text(submit_user_a.name)
    expect(page).to have_text(submit_user_a.email)
    expect(page).to have_text(submit_user_b.name)
    expect(page).to have_text(submit_user_b.email)
  end

  scenario "Viewing account details" do
    visit "/account-admin/#{search_user_b.id}"

    expect(page).to have_h1(search_user_b.name)

    expect(page).to have_text(search_user_b.name)
    expect(page).to have_text(search_user_b.email)
    expect(page).to have_h2("Last login details")
  end

  scenario "Changing the name on an account" do
    existing_name = search_user_b.name

    visit "/account-admin/#{search_user_b.id}"

    expect(page).to have_h1(search_user_b.name)

    click_link "Change name"

    expect(page).to have_h1("Change account name")

    fill_in "Full name", with: ""
    click_on "Save changes"

    expect(page).to have_link("Name cannot be blank", href: "#search-user-name-field-error")

    fill_in "Full name", with: "This is a different name"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The name has been updated from #{existing_name} to This is a different name")
  end

  scenario "Changing the email on an account" do
    existing_email = search_user_c.email

    visit "/account-admin/#{search_user_c.id}"

    expect(page).to have_h1(search_user_c.name)

    click_link "Change email"

    expect(page).to have_h1("Change account email address")

    fill_in "Email address", with: ""
    click_on "Save changes"

    expect(page).to have_link("Enter an email address", href: "#search-user-email-field-error")

    fill_in "Email address", with: "something@something@example.com"
    click_on "Save changes"

    expect(page).to have_link("Enter an email address in the correct format, like name@example.com", href: "#search-user-email-field-error")

    fill_in "Email address", with: "something@example.com"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The email address has been updated from #{existing_email} to something@example.com")
  end

  scenario "Changing the role on an account" do
    visit "/account-admin/#{search_user_c.id}"

    expect(page).to have_h1(search_user_c.name)

    click_link "Change role type"

    expect(page).to have_h1("Change account role type")

    choose "OPSS Incident Management Team (IMT)"
    click_on "Save changes"

    expect(page).to have_css("div.govuk-notification-banner", text: "The account role type has been updated from OPSS General to OPSS Incident Management Team (IMT)")
  end

  scenario "Removing a Responsible Person from an account" do
    visit "/account-admin/#{submit_user_b.id}"

    expect(page).to have_h1(submit_user_b.name)

    click_link "Change Responsible Person accounts"

    expect(page).to have_h1("#{submit_user_b.name} - Responsible Person accounts")

    expect(page).to have_css("th", text: responsible_person_user_b.responsible_person.name)
    expect(page).to have_css("th", text: responsible_person_user_d.responsible_person.name)

    click_link "Remove access", href: "/account-admin/#{submit_user_b.id}/delete-responsible-person-user/#{responsible_person_user_b.id}/confirm"

    expect(page).to have_h1("#{submit_user_b.name} - Remove access")
    expect(page).to have_text("Removing #{submit_user_b.name} from #{responsible_person_user_b.responsible_person.name} means that #{submit_user_b.name} will no longer have access to #{responsible_person_user_b.responsible_person.name} when logging back in to SCPN.")

    click_on "Remove access"

    expect(page).to have_css("div.govuk-notification-banner", text: "#{submit_user_b.name} has been removed from #{responsible_person_user_b.responsible_person.name}")
  end

  scenario "Attempting to remove a Responsible Person from an account when it is the only account with access" do
    visit "/account-admin/#{submit_user_b.id}"

    expect(page).to have_h1(submit_user_b.name)

    click_link "Change Responsible Person accounts"

    expect(page).to have_h1("#{submit_user_b.name} - Responsible Person accounts")

    expect(page).to have_css("th", text: responsible_person_user_b.responsible_person.name)
    expect(page).to have_css("th", text: responsible_person_user_d.responsible_person.name)

    click_link "Remove access", href: "/account-admin/#{submit_user_b.id}/delete-responsible-person-user/#{responsible_person_user_d.id}/confirm"

    expect(page).to have_h1("#{submit_user_b.name} - Remove access")
    expect(page).to have_text("#{submit_user_b.name} cannot be removed from the Responsible Person because #{responsible_person_user_d.responsible_person.name} does not have any other user accounts with access.")
  end

  scenario "Resetting an account" do
    visit "/account-admin/#{submit_user_b.id}"

    travel_to(30.seconds.from_now)

    expect(page).to have_h1(submit_user_b.name)

    click_link "Reset"
    select_secondary_authentication_app
    expect_to_be_on_secondary_authentication_app_page
    complete_secondary_authentication_app

    expect(page).to have_h1("Reset account")
    click_link("Cancel")

    expect(page).not_to have_css("div.govuk-notification-banner", text: "The account has been reset")

    click_link "Reset"

    expect(page).to have_h1("Reset account")
    click_button("Reset account")

    expect(page).to have_css("div.govuk-notification-banner", text: "The account has been reset")
  end

  scenario "Inviting a new search user" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"
    click_link "Add a new search user account"

    expect(page).to have_h1("Invite a new search user")

    click_on "Send invitation"

    expect(page).to have_link("Name cannot be blank", href: "#search-user-name-field-error")
    expect(page).to have_link("Enter an email", href: "#search-user-email-field-error")
    expect(page).to have_link("Select a role type for the user account", href: "#search-user-role-field-error")

    fill_in "Full name", with: "Fake faker"
    fill_in "Email", with: "fake@example.com"
    choose "OPSS Enforcement"

    click_on "Send invitation"

    expect(page).to have_text("New search user account invitation sent")
  end
end
