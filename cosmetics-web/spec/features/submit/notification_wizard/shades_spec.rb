require "rails_helper"

RSpec.describe "Adding and removing shades", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "Create a new product notification"
    complete_product_wizard(name: "FooProduct")
    click_link "Product details"
  end

  scenario "Adding Red, Orange, Yellow, Blue shades, Removing Yellow" do
    answer_is_item_available_in_shades_with "Yes"
    fill_in "component_shades-0", with: "Red"
    fill_in "component_shades-1", with: "Orange"
    click_on "Add another shade"

    expect(page).to have_field("component_shades-0", with: "Red")
    expect(page).to have_field("component_shades-1", with: "Orange")
    fill_in "component_shades-2", with: "Yellow"
    click_on "Add another shade"

    expect(page).to have_field("component_shades-0", with: "Red")
    expect(page).to have_field("component_shades-1", with: "Orange")
    expect(page).to have_field("component_shades-2", with: "Yellow")
    fill_in "component_shades-3", with: "Blue"

    within "#shade-2" do
      click_on "Remove shade"
    end

    expect(page).to have_field("component_shades-0", with: "Red")
    expect(page).to have_field("component_shades-1", with: "Orange")
    expect(page).to have_field("component_shades-2", with: "Blue")

    click_on "Add another shade" # attempt to add a blank shade

    click_on "Continue"

    expect(page).to have_css("h1", text: "What is the physical form of the product?")
    expect(Component.last.shades).to eq(%w[Red Orange Blue])
    expect_back_link_to_add_shades_page
  end

  scenario "No shades" do
    answer_is_item_available_in_shades_with "No"
    click_on "Continue"

    expect(page).to have_css("h1", text: "What is the physical form of the product?")
    expect_back_link_to_number_of_shades_page
  end
end
