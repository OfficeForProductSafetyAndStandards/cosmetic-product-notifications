require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Simple notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1, 3)

    complete_product_details

    expect_progress(2, 3)

    click_on "Create the product"
    click_button "Continue" # product name
    click_button "Continue" # internal reference
    click_button "Continue" # children under 3 years
    click_button "Continue" # nanomaterials
    answer_is_product_multi_item_kit_with "No, this is a single product"
    click_link "Remove"

    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_link "Continue"

    click_link "Accept and submit"

    click_link "Continue"
    click_button "Accept and submit"

    expect(page).to have_current_path(/\/responsible_persons\/#{responsible_person.id}\/notifications\/\d+\/edit/)
    expect(page).to have_css("h2", text: "Notification could not be submitted")
  end
end
