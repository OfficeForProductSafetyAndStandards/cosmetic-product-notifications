require "rails_helper"

RSpec.describe "Categories", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Create a new product notification"

    complete_product_wizard
    complete_product_details
    click_link "Product details"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
    click_button "Continue"
  end

  scenario "When there is more than one sub_sub_category" do
    choose "Oral hygiene products"
    click_button "Continue"

    choose "Tooth care products"
    click_button "Continue"

    # we display the select_sub_sub_category page
    choose "Toothpaste"
    click_button "Continue"

    expect(page.current_path).to end_with("/build/select_formulation_type")
    click_link "Back"

    # and go back to the sub_sub_category page
    expect(page.current_path).to end_with("/select_sub_sub_category")
  end

  scenario "When there is only one sub_sub_category and we don't want to display that page" do
    choose "Oral hygiene products"
    click_button "Continue"

    choose "Other oral hygiene products"
    click_button "Continue"

    # we skip the select_sub_sub_category page
    expect(page.current_path).to end_with("/build/select_formulation_type")
    click_link "Back"

    # and go back to the sub_category page
    expect(page.current_path).to end_with("/select_sub_category")
  end
end
