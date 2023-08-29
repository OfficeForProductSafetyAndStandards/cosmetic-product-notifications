require "rails_helper"
require "support/feature_helpers"

RSpec.feature "History", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:support_user, :with_sms_secondary_authentication) }
  let(:other_support_user) { create(:support_user, name: "Max Mustermann") }
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification) }
  let(:search_user) { create(:search_user) }
  let(:notification_version) do
    create(:version,
           event: "delete",
           item: notification,
           whodunnit: user.id,
           object: notification.attributes,
           created_at: Time.zone.local(2022, 3, 1))
  end

  let(:responsible_person_version) do
    create(:version,
           event: "update",
           item: responsible_person,
           whodunnit: other_support_user.id,
           object_changes: { "name" => ["Company A", "Company B"] },
           object: responsible_person.attributes,
           created_at: Time.zone.local(2023, 3, 1))
  end

  let(:search_user_version_1) do
    create(:version,
           event: "update",
           item: search_user,
           whodunnit: user.id,
           object_changes: { "role" => %w[opss_science opss_general] },
           object: search_user.attributes,
           created_at: Time.zone.local(2023, 3, 1))
  end

  let(:search_user_version_2) do
    create(:version,
           event: "update",
           item: search_user,
           whodunnit: user.id,
           object_changes: { "deactivated_at" => [nil, Time.zone.local(2023, 3, 2)] },
           object: search_user.attributes,
           created_at: Time.zone.local(2023, 3, 2))
  end

  let(:search_user_version_3) do
    create(:version,
           event: "update",
           item: search_user,
           whodunnit: other_support_user.id,
           object_changes: { "deactivated_at" => [Time.zone.local(2023, 3, 3), nil] },
           object: search_user.attributes,
           created_at: Time.zone.local(2023, 3, 3))
  end

  before do
    configure_requests_for_support_domain
    notification_version
    responsible_person_version
    search_user_version_1
    search_user_version_2
    search_user_version_3
    sign_in user
  end

  scenario "Searching for changes made by support users using a search term" do
    expect(page).to have_h1("Dashboard")

    click_link "Change history log"

    expect(page).to have_h1("Change history log")

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")

    fill_in "Enter a search term", with: user.name
    click_on "Search"

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).not_to have_text(other_support_user.name)
    expect(page).not_to have_text("Change from: Company A")

    fill_in "Enter a search term", with: notification.reference_number
    click_on "Search"

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).not_to have_text(other_support_user.name)
    expect(page).not_to have_text("Change from: Company A")

    fill_in "Enter a search term", with: other_support_user.name
    click_on "Search"

    expect(page).not_to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")
  end

  scenario "Searching for changes made by support users using a date range" do
    expect(page).to have_h1("Dashboard")

    click_link "Change history log"

    expect(page).to have_h1("Change history log")

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")

    fill_in "history_search_date_from_3i", with: 1
    fill_in "history_search_date_from_2i", with: 1
    fill_in "history_search_date_from_1i", with: 2023
    fill_in "history_search_date_to_3i", with: 1
    fill_in "history_search_date_to_2i", with: 4
    fill_in "history_search_date_to_1i", with: 2023
    click_on "Search"

    expect(page).not_to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")

    fill_in "history_search_date_from_3i", with: 1
    fill_in "history_search_date_from_2i", with: 1
    fill_in "history_search_date_from_1i", with: 2022
    fill_in "history_search_date_to_3i", with: 1
    fill_in "history_search_date_to_2i", with: 4
    fill_in "history_search_date_to_1i", with: 2022
    click_on "Search"

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).not_to have_text(other_support_user.name)
    expect(page).not_to have_text("Change from: Company A")
  end

  scenario "Searching for changes made by support users using an action" do
    expect(page).to have_h1("Dashboard")

    click_link "Change history log"

    expect(page).to have_h1("Change history log")

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")

    select "Change to Notification", from: "Display by action"
    click_on "Search"

    expect(page).to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).not_to have_text(other_support_user.name)
    expect(page).not_to have_text("Change from: Company A")

    select "Change to Responsible Person Name", from: "Display by action"
    click_on "Search"

    expect(page).not_to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).to have_text(other_support_user.name)
    expect(page).to have_text("Change from: Company A")

    select "Change to Responsible Person Address", from: "Display by action"
    click_on "Search"

    expect(page).not_to have_text("UKCP number (#{notification.reference_number}) deletion")
    expect(page).not_to have_text(other_support_user.name)
    expect(page).not_to have_text("Change from: Company A")

    select "Deactivate account", from: "Display by action"
    click_on "Search"

    expect(page).to have_css("td", text: "User (#{search_user.email}) deactivation")
    expect(page).to have_css("td", text: "#{user.name} deactivated user #{search_user.email}")

    select "Reactivate account", from: "Display by action"
    click_on "Search"

    expect(page).to have_css("td", text: "User (#{search_user.email}) reactivation")
    expect(page).to have_css("td", text: "#{other_support_user.name} reactivated user #{search_user.email}")

    select "User role change", from: "Display by action"
    click_on "Search"

    expect(page).to have_css("td", text: "User (#{search_user.email}) role change")
    expect(page).to have_css("td", text: "Change from: OPSS ScienceTo: OPSS General")
  end
end
