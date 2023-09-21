require "rails_helper"
require "support/feature_helpers"

RSpec.feature "Search", :with_stubbed_mailer, :with_stubbed_notify, :with_2fa, :with_2fa_app, type: :feature do
  let(:user) { create(:opss_science_user, :with_sms_secondary_authentication) }

  let(:responsible_person_name) { "Responsible Person" }

  let(:responsible_person) { create(:responsible_person, name: responsible_person_name) }
  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }
  let(:shower_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles", responsible_person: other_responsible_person) }
  let(:bath_bubbles) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask) }
  let(:powder) { create(:archived_notification, :with_component, notification_complete_at: 1.day.ago, product_name: "Bath Bubbles Powder", responsible_person:) }

  before do
    configure_requests_for_search_domain

    cream
    shower_bubbles
    bath_bubbles
    powder

    sign_in user
    visit "/notifications"
    expect(page).to have_h1("Cosmetic products search")
  end

  scenario "Searching for notifications" do
    click_on "Search"

    expect(page).to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")

    click_on "Edit your search"
    fill_in "notification_search_form_q", with: "Bubbles"
    click_on "Search"

    expect(page).not_to have_link("Cream")
    expect(page).to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
    expect(page).not_to have_link("Bath Bubbles Powder")

    click_on "Edit your search"
    choose "Skin products"
    click_on "Search"

    expect(page).to have_text("1 notification using the current filters was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
    expect(page).not_to have_link("Bath Bubbles Powder")
  end

  scenario "Searching for archived notifications" do
    fill_in "notification_search_form_q", with: "Bubbles"
    choose "Archived"
    click_on "Search"

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).not_to have_link("Bath Bubbles", exact: true)
    expect(page).to have_link("Bath Bubbles Powder")
  end


  scenario "Sorting search results" do
    fill_in "notification_search_form_q", with: "Bubbles"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["View Shower Bubbles", "View Bath Bubbles"]

    click_on "Edit your search"
    choose "Oldest"
    click_on "Search"

    links = page.all("table#table-items .govuk-link").map(&:text)
    expect(links).to eq ["View Bath Bubbles", "View Shower Bubbles"]
  end

  scenario "Searching for notifications with date filter" do
    click_on "Search"

    expect(page).to have_link("View Cream")
    expect(page).to have_link("View Shower Bubbles")
    expect(page).to have_link("View Bath Bubbles")
    expect(page).not_to have_link("View Bath Bubbles Powder")

    click_on "Edit your search"
    fill_in "date_from_day",   with: bath_bubbles.notification_complete_at.day
    fill_in "date_from_month", with: bath_bubbles.notification_complete_at.month
    fill_in "date_from_year",  with: bath_bubbles.notification_complete_at.year

    fill_in "date_to_day",   with: bath_bubbles.notification_complete_at.day
    fill_in "date_to_month", with: bath_bubbles.notification_complete_at.month
    fill_in "date_to_year",  with: bath_bubbles.notification_complete_at.year

    click_on "Search"

    expect(page).to have_text("1 notification using the current filters was found.")

    expect(page).not_to have_link("Cream")
    expect(page).not_to have_link("Shower Bubbles")
    expect(page).to have_link("Bath Bubbles")
    expect(page).not_to have_link("Bath Bubbles Powder")
  end

  describe "Reference number search" do
    scenario "Searching by whole number" do
      click_on "Search"
      expect(page).to have_link("View Cream")
      expect(page).to have_link("View Shower Bubbles")
      expect(page).to have_link("View Bath Bubbles")
      expect(page).not_to have_link("View Bath Bubbles Powder")

      click_on "Edit your search"
      fill_in "notification_search_form_q", with: cream.reference_number

      click_on "Search"

      expect(page).to have_text("1 notification using the current filters was found.")

      expect(page).to have_link("View Cream")
      expect(page).not_to have_link("View Shower Bubbles")
      expect(page).not_to have_link("View Bath Bubbles")
      expect(page).not_to have_link("View Bath Bubbles Powder")
    end

    scenario "Searching by partial number" do
      click_on "Search"
      expect(page).to have_link("View Cream")
      expect(page).to have_link("View Shower Bubbles")
      expect(page).to have_link("View Bath Bubbles")
      expect(page).not_to have_link("View Bath Bubbles Powder")

      click_on "Edit your search"
      fill_in "notification_search_form_q", with: cream.reference_number.to_s[0..5]

      click_on "Search"

      expect(page).to have_text("0 notifications using the current filters were found.")

      expect(page).not_to have_link("View Cream")
      expect(page).not_to have_link("View Shower Bubbles")
      expect(page).not_to have_link("View Bath Bubbles")
      expect(page).not_to have_link("View Bath Bubbles Powder")
    end

    context "when reference number is small" do
      let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", reference_number: 12_345) }

      scenario "Searching by partial number" do
        click_on "Search"
        expect(page).to have_link("View Cream")
        expect(page).to have_link("View Shower Bubbles")
        expect(page).to have_link("View Bath Bubbles")
        expect(page).not_to have_link("View Bath Bubbles Powder")

        click_on "Edit your search"
        fill_in "notification_search_form_q", with: cream.reference_number_for_display

        click_on "Search"

        expect(page).to have_text("1 notification using the current filters was found.")

        expect(page).to have_link("View Cream")
      end
    end
  end

  scenario "show the total number of results" do
    20.times do |i|
      create(:notification, :registered, :with_component, notification_complete_at: 5.days.ago, product_name: "Sun Lotion #{i}")
    end
    Notification.import_to_opensearch(force: true)
    click_on "Search"
    expect(page).to have_text("23 notifications using the current filters were found.")
    expect(page).to have_link("View Sun Lotion 0")
    expect(page).not_to have_link("View Sun Lotion 19")

    click_link("Next page")
    expect(page).to have_text("23 notifications using the current filters were found.")
    expect(page).to have_h1("Cosmetic products search - results")
    expect(page).not_to have_link("View Sun Lotion 0")
    expect(page).to have_link("View Sun Lotion 19")
  end

  scenario "Editing the search" do
    choose "Notification name"
    choose "Archived"
    choose "Skin products"
    choose "Newest"
    check "Include similar words"
    click_on "Search"

    # expect(page).to have_text("1 notification using the current filters was found.")

    click_button("Edit your search")
    expect(page).to have_h1("Cosmetic products search")

    expect(page).to have_checked_field("Notification name")
    expect(page).to have_checked_field("Archived")
    expect(page).to have_checked_field("Skin products")
    expect(page).to have_checked_field("Newest")
    expect(page).to have_checked_field("Include similar words")
  end

  scenario "Does not display pagination until has more than 20 results" do
    17.times do |i|
      create(:notification, :registered, :with_component, notification_complete_at: 5.days.ago, product_name: "Sun Lotion #{i}")
    end
    Notification.import_to_opensearch(force: true)

    click_on "Search"
    expect(page).to have_link("View Cream")
    expect(page).to have_link("View Shower Bubbles")
    expect(page).to have_link("View Bath Bubbles")
    17.times do |i|
      expect(page).to have_link("View Sun Lotion #{i}")
    end

    expect(page).not_to have_text("Page 1")
    expect(page).not_to have_link("Next page")

    # With 21 results, we should see the pagination
    create(:notification, :registered, :with_component, notification_complete_at: 5.days.ago, product_name: "Sun Lotion 17")
    Notification.import_to_opensearch(force: true)

    visit "/notifications"
    expect(page).to have_h1("Cosmetic products search")
    click_on "Search"
    expect(page).to have_link("View Cream")
    expect(page).to have_link("View Shower Bubbles")
    expect(page).to have_link("View Bath Bubbles")
    (1..16).each do |i|
      expect(page).to have_link("Sun Lotion #{i}")
    end
    expect(page).not_to have_link("View Sun Lotion 17")
    expect(page).to have_text("Page 1")
    expect(page).to have_link("Next page")

    click_link("Next page")
    expect(page).to have_h1("Cosmetic products search - results")
    expect(page).to have_link("View Sun Lotion 17")
    expect(page).to have_text("Page 2")
    expect(page).to have_link("Previous page")
  end

  scenario "Back link" do
    click_on "Search"
    click_link "View Shower Bubbles"
    click_link "Back"
    expect(page).to have_h1("Cosmetic products search - results")
  end

  context "when using advanced search" do
    scenario "Searching by partial number number" do
      click_on "Search"
      expect(page).to have_link("View Cream")
      expect(page).to have_link("View Shower Bubbles")
      expect(page).to have_link("View Bath Bubbles")

      click_on "Edit your search"
      fill_in "notification_search_form_q", with: cream.reference_number.to_s[0..5]
      check "Include similar words"

      click_on "Search"

      expect(page).to have_text("1 notification using the current filters was found.")

      expect(page).to have_link("View Cream")
      expect(page).not_to have_link("View Shower Bubbles")
      expect(page).not_to have_link("View Bath Bubbles")
    end

    context "when choosing fields to search" do
      let(:responsible_person_name) { "Bubbles RP" }

      scenario "Searching for notifications" do
        fill_in "notification_search_form_q", with: "Bubbles"
        click_on "Search"

        expect(page).to have_link("Cream")

        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        click_on "Edit your search"
        choose "Notification name"
        click_on "Search"

        expect(page).not_to have_link("Cream")
        expect(page).to have_link("Shower Bubbles")
        expect(page).to have_link("Bath Bubbles")

        click_on "Edit your search"
        choose "Responsible Person name&sol;address"
        click_on "Search"

        expect(page).to have_link("Cream")
        expect(page).not_to have_link("Shower Bubbles")
        expect(page).not_to have_link("Bath Bubbles")
      end
    end
  end
end
