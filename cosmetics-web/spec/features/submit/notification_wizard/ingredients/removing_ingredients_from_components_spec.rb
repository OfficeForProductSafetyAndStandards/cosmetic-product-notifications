require "rails_helper"

RSpec.describe "Removing ingredients from components", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:notification) { create(:notification, :draft_complete, responsible_person:) }
  let(:component) { create(:exact_component, :completed, notification:) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  def navigate_to_edit_ingredients_page
    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Go to question - product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"
  end

  scenario "Removing the last ingredient from a component with multiple ingredients" do
    create(:exact_ingredient, inci_name: "Ingredient A", exact_concentration: 4.0, component:)
    create(:poisonous_ingredient, inci_name: "Ingredient B", exact_concentration: 3.0, component:)

    navigate_to_edit_ingredients_page
    expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["Ingredient A", "Ingredient B"])

    within("#ingredient-0") do
      expect(page).to have_field("What is the name?", with: "Ingredient A")
      click_on "Remove ingredient"
    end

    # Adding a wait to ensure the page updates
    expect(page).to have_no_field("What is the name?", with: "Ingredient A")

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).not_to have_button("Remove ingredient")
  end

  scenario "Adding an ingredient, then immediately removing it" do
    create(:exact_ingredient, inci_name: "Ingredient A", exact_concentration: 4.0, component:)
    navigate_to_edit_ingredients_page
    click_on "Add another ingredient"

    within("#ingredient-1") do
      click_on "Remove ingredient"
    end
    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient A"])

    click_on "Save and continue"
    expect_to_be_on_what_is_ph_range_of_product_page
  end
end
