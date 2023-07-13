require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Account administration", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:support_user, :with_all_secondary_authentication_methods) }
  let(:search_user1) { create(:search_user) }
  let(:search_user2) { create(:search_user) }
  let(:search_user3) { create(:search_user, name: search_user1.name) }
  let(:submit_user1) { create(:submit_user) }
  let(:submit_user2) { create(:submit_user) }
  let(:responsible_person_user1) { create(:responsible_person_user, user: submit_user1) }
  let(:responsible_person_user2) { create(:responsible_person_user, user: submit_user2) }
  let(:responsible_person_user3) { create(:responsible_person_user, user: submit_user1, responsible_person: responsible_person_user2.responsible_person) }
  let(:responsible_person_user4) { create(:responsible_person_user, user: submit_user2) }

  before do
    configure_requests_for_support_domain

    search_user1
    search_user2
    search_user3
    submit_user1
    submit_user2
    responsible_person_user1
    responsible_person_user2
    responsible_person_user3
    responsible_person_user4

    sign_in user
    select_secondary_authentication_app
    complete_secondary_authentication_app
  end

  scenario "Searching for an account that exists" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"

    expect(page).to have_h1("Search for an account")

    fill_in "Enter a search term", with: search_user2.name
    click_on "Search"

    expect(page).to have_text(search_user2.name)
    expect(page).to have_text(search_user2.email)
    expect(page).not_to have_text(search_user1.name)
    expect(page).not_to have_text(search_user1.email)
    expect(page).not_to have_text(search_user3.name)
    expect(page).not_to have_text(search_user3.email)
  end

  scenario "Searching for an account that exists with multiple results" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"

    expect(page).to have_h1("Search for an account")

    fill_in "Enter a search term", with: search_user1.name
    click_on "Search"

    expect(page).to have_text(search_user1.name)
    expect(page).to have_text(search_user1.email)
    expect(page).to have_text(search_user3.name)
    expect(page).to have_text(search_user3.email)
    expect(page).not_to have_text(search_user2.name)
    expect(page).not_to have_text(search_user2.email)
  end

  scenario "Searching for a user that doesn't exist" do
    expect(page).to have_h1("Dashboard")

    click_link "Account administration"

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

    expect(page).to have_h1("Search for an account")

    click_on "Search"

    expect(page).to have_text("Enter a search term")
  end

  scenario "Viewing account details" do
    visit "/account-admin/#{search_user2.id}"

    expect(page).to have_h1(search_user2.name)

    expect(page).to have_text(search_user2.name)
    expect(page).to have_text(search_user2.email)
  end

  scenario "Changing the name on an account" do
    existing_name = search_user2.name

    visit "/account-admin/#{search_user2.id}"

    expect(page).to have_h1(search_user2.name)

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
    existing_email = search_user3.email

    visit "/account-admin/#{search_user3.id}"

    expect(page).to have_h1(search_user3.name)

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

  scenario "Removing a Responsible Person from an account" do
    visit "/account-admin/#{submit_user2.id}"

    expect(page).to have_h1(submit_user2.name)

    click_link "Change Responsible Person accounts"

    expect(page).to have_h1("#{submit_user2.name} - Responsible Person accounts")

    expect(page).to have_css("th", text: responsible_person_user2.responsible_person.name)
    expect(page).to have_css("th", text: responsible_person_user4.responsible_person.name)

    click_link "Remove access", href: "/account-admin/#{submit_user2.id}/delete-responsible-person-user/#{responsible_person_user2.id}/confirm"

    expect(page).to have_h1("#{submit_user2.name} - Remove access")
    expect(page).to have_text("Removing #{submit_user2.name} from #{responsible_person_user2.responsible_person.name} means that #{submit_user2.name} will no longer have access to #{responsible_person_user2.responsible_person.name} when logging back in to SCPN.")

    click_on "Remove access"

    expect(page).to have_css("div.govuk-notification-banner", text: "#{submit_user2.name} has been removed from #{responsible_person_user2.responsible_person.name}")
  end

  scenario "Attempting to remove a Responsible Person from an account when it is the only account with access" do
    visit "/account-admin/#{submit_user2.id}"

    expect(page).to have_h1(submit_user2.name)

    click_link "Change Responsible Person accounts"

    expect(page).to have_h1("#{submit_user2.name} - Responsible Person accounts")

    expect(page).to have_css("th", text: responsible_person_user2.responsible_person.name)
    expect(page).to have_css("th", text: responsible_person_user4.responsible_person.name)

    click_link "Remove access", href: "/account-admin/#{submit_user2.id}/delete-responsible-person-user/#{responsible_person_user4.id}/confirm"

    expect(page).to have_h1("#{submit_user2.name} - Remove access")
    expect(page).to have_text("#{submit_user2.name} cannot be removed from the Responsible Person because #{responsible_person_user4.responsible_person.name} does not have any other user accounts with access.")
  end

  scenario "Resetting an account" do
    visit "/account-admin/#{submit_user2.id}"

    travel_to(30.seconds.from_now)

    expect(page).to have_h1(submit_user2.name)

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
end
