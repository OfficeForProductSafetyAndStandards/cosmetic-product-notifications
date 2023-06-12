require "rails_helper"

RSpec.describe "Notifications archiving", type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:notification) { create(:registered_notification, responsible_person:) }
  let(:archived_notification) { create(:archived_notification, responsible_person:) }

  before do
    configure_requests_for_submit_domain
    sign_in user
  end

  scenario "archiving a notification from the notifications dashboard", versioning: true do
    notification
    Notification.import_to_opensearch(force: true)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_link("Archive #{notification.product_name}")

    choose "Significant change to the formulation"
    click_button "Continue"

    expect_to_be_on__your_cosmetic_products_page
    within("div.govuk-notification-banner--success") do
      expect(page).to have_css("h2", text: "Success")
      expect(page).to have_css("h3", text: "#{notification.product_name} (#{notification.reference_number_for_display}) has been archived.")
    end
    expect(page).not_to have_link("View #{notification.product_name}")
  end

  scenario "archiving a notification from the notification page", versioning: true do
    notification
    Notification.import_to_opensearch(force: true)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_link "View #{notification.product_name}"

    expect(page).to have_h1("Notified product: #{notification.product_name}")
    click_link "Archive this notification"

    choose "Significant change to the formulation"
    click_button "Continue"

    expect_to_be_on__your_cosmetic_products_page
    within("div.govuk-notification-banner--success") do
      expect(page).to have_css("h2", text: "Success")
      expect(page).to have_css("h3", text: "#{notification.product_name} (#{notification.reference_number_for_display}) has been archived.")
    end
    expect(page).not_to have_link("View #{notification.product_name}")

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}"
    expect(page).to have_css("h2", text: "History")
    expect(page).to have_css("td.govuk-table__cell", text: "Archived: Significant change to the formulation")
  end

  scenario "unarchiving a notification from the notifications archive dashboard", versioning: true do
    travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
      archived_notification
    end
    visit "/responsible_persons/#{responsible_person.id}/archived-notifications"
    click_link("Unarchive #{archived_notification.product_name}")

    expect_to_be_on__your_cosmetic_products_page
    within("div.govuk-notification-banner--success") do
      expect(page).to have_css("h2", text: "Success")
      expect(page).to have_css(
        "h3",
        text: "#{archived_notification.product_name} (#{archived_notification.reference_number_for_display}) has been unarchived.",
      )
    end
    expect(page).to have_link("View #{archived_notification.product_name}")
    # Notification can be archived again
    expect(page).to have_link("Archive #{archived_notification.product_name}")
    # Notification original 'UK notified' date is kept
    title = page.find("th", text: archived_notification.product_name, exact_text: true)
    expect(title).to have_sibling("td", text: "1 January 2020", exact_text: true)
  end

  scenario "unarchiving a notification from the notification page", versioning: true do
    travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
      archived_notification
    end
    visit "/responsible_persons/#{responsible_person.id}/archived-notifications"
    click_link "View #{archived_notification.product_name}"

    expect(page).to have_h1("Notified product: #{archived_notification.product_name} Archived")
    click_link("Unarchive this notification")

    expect_to_be_on__your_cosmetic_products_page
    within("div.govuk-notification-banner--success") do
      expect(page).to have_css("h2", text: "Success")
      expect(page).to have_css(
        "h3",
        text: "#{archived_notification.product_name} (#{archived_notification.reference_number_for_display}) has been unarchived.",
      )
    end
    expect(page).to have_link("View #{archived_notification.product_name}")
    # Notification can be archived again
    expect(page).to have_link("Archive #{archived_notification.product_name}")
    # Notification original 'UK notified' date is kept
    title = page.find("th", text: archived_notification.product_name, exact_text: true)
    expect(title).to have_sibling("td", text: "1 January 2020", exact_text: true)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{archived_notification.reference_number}"
    expect(page).to have_css("h2", text: "History")
    expect(page).to have_css("td.govuk-table__cell", text: "Unarchived")
  end
end
