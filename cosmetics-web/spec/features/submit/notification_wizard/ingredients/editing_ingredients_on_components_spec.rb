require "rails_helper"

RSpec.describe "Editing ingredients on components", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:notification) { create(:notification, :draft_complete, responsible_person:) }
  let(:component) { create(:component, notification:) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Editing ingredients on a exact concentration notification" do
    component = create(:exact_component, :completed, notification:)
    create(:exact_ingredient, inci_name: "Ingredient A", exact_concentration: 4.0, component:)
    create(:poisonous_ingredient, inci_name: "Ingredient B", exact_concentration: 3.0, component:)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient A", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient A")
    expect(page).to have_field("What is the exact concentration?", with: "4.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_unchecked_field("Is it listed in the NPIS tables and does the NPIS need to know about it?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient A poisonous"
    fill_in "exact_concentration", with: "5.1"
    check "Is it listed in the NPIS tables and does the NPIS need to know about it?"

    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["Ingredient A poisonous", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).to have_field("What is the exact concentration?", with: "3.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("Is it listed in the NPIS tables and does the NPIS need to know about it?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient B non poisonous"
    uncheck "Is it listed in the NPIS tables and does the NPIS need to know about it?"
    fill_in "What is the CAS number?", with: "123456-78-9"

    click_on "Save and continue"
    answer_add_another_ingredient_with("No", success_banner: false)

    expect_to_be_on__what_is_ph_range_of_product_page

    # Updated the values in Database.
    expect(component.ingredients.exact).to have(2).items
    expect(component.ingredients.exact.first).to have_attributes(
      inci_name: "Ingredient A poisonous",
      exact_concentration: 5.1,
      poisonous: true,
      cas_number: nil,
    )
    expect(component.ingredients.exact.second).to have_attributes(
      inci_name: "Ingredient B non poisonous",
      exact_concentration: 3.0,
      poisonous: false,
      cas_number: "123456789",
    )
  end

  scenario "Editing ingredients on a range concentration notification" do
    component = create(:ranges_component, :completed, notification:)
    create(:range_ingredient, inci_name: "Ingredient A", range_concentration: "greater_than_75_less_than_100_percent", component:)
    create(:range_ingredient, inci_name: "Ingredient B", range_concentration: "greater_than_10_less_than_25_percent", component:)
    # Poisonous ingredient on Range component
    create(:poisonous_ingredient, inci_name: "Ingredient C", exact_concentration: 3.0, component:)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their concentration range manually"

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient A", "Ingredient B", "Ingredient C"])
    expect(page).to have_field("What is the name?", with: "Ingredient A")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("No")
    expect(page).to have_checked_field("greater_than_75_less_than_100_percent")
    expect(page).not_to have_link("Skip", exact: true)
    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["Ingredient A", "Ingredient B", "Ingredient C"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("No")
    expect(page).to have_checked_field("greater_than_10_less_than_25_percent")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient B modified"
    page.choose("greater_than_5_less_than_10_percent")
    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 3, already_added: ["Ingredient A", "Ingredient B modified", "Ingredient C"])
    expect(page).to have_field("What is the name?", with: "Ingredient C")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("Yes")
    expect(page).to have_field("What is the exact concentration?", with: "3.0")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient C non poisonous"
    fill_in "What is the CAS number?", with: "123456-78-9"
    page.choose("No")
    page.choose("greater_than_25_less_than_50_percent")

    click_on "Save and continue"
    answer_add_another_ingredient_with("No", success_banner: false)

    expect_to_be_on__what_is_ph_range_of_product_page

    # Updated the values in Database.
    expect(component.ingredients.range).to have(3).items
    expect(component.ingredients.range.first).to have_attributes(
      inci_name: "Ingredient A",
      range_concentration: "greater_than_75_less_than_100_percent",
      cas_number: nil,
    )
    expect(component.ingredients.range.second).to have_attributes(
      inci_name: "Ingredient B modified",
      range_concentration: "greater_than_5_less_than_10_percent",
      cas_number: nil,
    )
    expect(component.ingredients.range.third).to have_attributes(
      inci_name: "Ingredient C non poisonous",
      range_concentration: "greater_than_25_less_than_50_percent",
      cas_number: "123456789",
    )
  end

  scenario "Editing ingredients on a predefined formulation notification" do
    component = create(:predefined_component, :completed, notification:)
    create(:poisonous_ingredient, inci_name: "Ingredient A", exact_concentration: 4.0, component:)
    create(:poisonous_ingredient, inci_name: "Ingredient B", exact_concentration: 3.0, component:)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

    expect_to_be_on__frame_formulation_select_page
    answer_select_formulation_with "Shampoo plus conditioner"
    answer_contains_ingredients_npis_needs_to_know_about_with("Yes")

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, forced_poisonous: true, already_added: ["Ingredient A", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient A")
    expect(page).to have_field("What is the exact concentration?", with: "4.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient A poisonous"
    fill_in "exact_concentration", with: "5.1"
    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 2, forced_poisonous: true, already_added: ["Ingredient A poisonous", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).to have_field("What is the exact concentration?", with: "3.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient B poisonous"
    fill_in "What is the CAS number?", with: "123456-78-9"
    click_on "Save and continue"

    answer_add_another_ingredient_with("No", success_banner: false)
    expect_to_be_on__what_is_ph_range_of_product_page

    # Updated the values in Database.
    expect(component.ingredients.exact).to have(2).items
    expect(component.ingredients.exact.first).to have_attributes(
      inci_name: "Ingredient A poisonous",
      exact_concentration: 5.1,
      poisonous: true,
      cas_number: nil,
    )
    expect(component.ingredients.exact.second).to have_attributes(
      inci_name: "Ingredient B poisonous",
      exact_concentration: 3.0,
      poisonous: true,
      cas_number: "123456789",
    )
  end

  scenario "Changing the formulation type from range to exact for a component with existing ingredients" do
    component = create(:ranges_component, :completed, notification:)
    create(:range_ingredient, inci_name: "Ingredient A", component:)
    create(:poisonous_ingredient, inci_name: "Ingredient B", component:)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    # Change component from exact concentration to range
    expect(page).to have_text("Changing this selection will remove all previously added ingredients.")
    answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"

    # Starts from scratch without ingredients
    expect(component.ingredients).to eq []
    expect_to_be_on_add_ingredients_page
    expect(page).to have_field("What is the name?")
    expect(page).not_to have_field("What is the name?", with: "Ingredient A")
    expect(page).not_to have_css("h2", text: "Already added")
    expect(page).not_to have_css("ol.govuk-list--number li", text: "Ingredient A")
    expect(page).not_to have_css("ol.govuk-list--number li", text: "Ingredient B")
  end

  scenario "Changing the formulation type from predefined formulation to exact for a component with existing poisonous ingredients" do
    component = create(:predefined_component, :using_frame_formulation, :completed, notification:)
    create(:poisonous_ingredient, inci_name: "Ingredient A", component:)
    create(:poisonous_ingredient, inci_name: "Ingredient B", component:)

    visit "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/draft"

    expect_product_details_task_completed

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Foam"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
    # Change component from exact concentration to range
    expect(page).to have_text("Changing this selection will remove all previously added ingredients.")
    answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"

    # Starts from scratch without ingredients
    expect(component.ingredients).to eq []
    expect_to_be_on_add_ingredients_page
    expect(page).to have_field("What is the name?")
    expect(page).not_to have_field("What is the name?", with: "Ingredient A")
    expect(page).not_to have_css("h2", text: "Already added")
    expect(page).not_to have_css("ol.govuk-list--number li", text: "Ingredient A")
    expect(page).not_to have_css("ol.govuk-list--number li", text: "Ingredient B")
  end
end
