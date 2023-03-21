require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Completing one item of two for a product notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Create a new product notification"

    complete_product_wizard(name: "Product no nano two items", items_count: 2)
    expect_progress(1, 4)

    complete_multi_item_kit_wizard
    complete_item_wizard("Cream one", item_number: 1)
    complete_item_wizard("Cream two", item_number: 2)

    # Check continue button on task completed page
    click_link "Cream one"
    click_button "Save and continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Save and continue"
    choose "No"
    click_button "Continue"
    click_button "Continue"
    click_link "Continue"
    expect_item_name_page
  end

  scenario "Completing a single item for a product notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Create a new product notification"

    complete_product_wizard(name: "Product no nano two items", items_count: 1)
    expect_progress(1, 3)

    complete_product_details

    # Check continue button on task completed page
    click_link "Product details"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Save and continue"
    choose "No"
    click_button "Continue"
    click_button "Continue"
    click_link "Continue"
    expect_accept_and_submit_page
  end
end
