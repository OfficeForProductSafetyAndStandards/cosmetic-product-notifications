require "rails_helper"

RSpec.describe "Editing ingredients on components", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }
  let(:notification) { create(:notification, :draft_complete, responsible_person: responsible_person) }
  let(:component) { create(:component, notification: notification) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Editing ingredients on a exact concentration notification" do
    component = create(:exact_component, :completed, notification: notification)
    create(:exact_formula, inci_name: "Ingredient A", quantity: 4.0, poisonous: false, component: component)
    create(:exact_formula, inci_name: "Ingredient B", quantity: 3.0, poisonous: true, component: component)

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
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration"

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient A", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient A")
    expect(page).to have_field("What is the exact concentration?", with: "4.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_unchecked_field("Is it poisonous?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient A poisonous"
    fill_in "exact_concentration", with: "5.1"
    check "Is it poisonous?"

    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["Ingredient A poisonous", "Ingredient B"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).to have_field("What is the exact concentration?", with: "3.0")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("Is it poisonous?")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient B non poisonous"
    uncheck "Is it poisonous?"
    fill_in "What is the CAS number?", with: "123456-78-9"

    click_on "Save and continue"
    answer_add_another_ingredient_with("No", success_banner: false)

    expect_to_be_on__what_is_ph_range_of_product_page

    # Updated the values in Database.
    expect(component.exact_formulas).to have(2).items
    expect(component.exact_formulas.first).to have_attributes(
      inci_name: "Ingredient A poisonous",
      quantity: 5.1,
      poisonous: true,
      cas_number: nil,
    )
    expect(component.exact_formulas.second).to have_attributes(
      inci_name: "Ingredient B non poisonous",
      quantity: 3.0,
      poisonous: false,
      cas_number: "123456789",
    )
  end

  scenario "Editing ingredients on a range concentration notification" do
    component = create(:ranges_component, :completed, notification: notification)
    create(:range_formula, inci_name: "Ingredient A", range: "greater_than_75_less_than_100_percent", component: component)
    create(:range_formula, inci_name: "Ingredient B", range: "greater_than_10_less_than_25_percent", component: component)
    create(:exact_formula, inci_name: "Ingredient C", quantity: 3.0, poisonous: true, component: component) # Poisonous ingredient on Range component

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
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their concentration range"

    expect_to_be_on_add_ingredients_page(ingredient_number: 1, already_added: ["Ingredient A", "Ingredient B", "Ingredient C"])
    expect(page).to have_field("What is the name?", with: "Ingredient A")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("No")
    expect(page).to have_checked_field("Above 75% w/w up to 100% w/w")
    expect(page).not_to have_link("Skip", exact: true)
    click_on "Save and continue"

    expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["Ingredient A", "Ingredient B", "Ingredient C"])
    expect(page).to have_field("What is the name?", with: "Ingredient B")
    expect(page).to have_field("What is the CAS number?")
    expect(page).to have_checked_field("No")
    expect(page).to have_checked_field("Above 10% w/w up to 25% w/w")
    expect(page).not_to have_link("Skip", exact: true)

    fill_in "What is the name?", with: "Ingredient B modified"
    page.choose("Above 5% w/w up to 10% w/w")
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
    page.choose("Above 25% w/w up to 50% w/w")

    click_on "Save and continue"
    answer_add_another_ingredient_with("No", success_banner: false)

    expect_to_be_on__what_is_ph_range_of_product_page

    # Updated the values in Database.
    expect(component.range_formulas).to have(3).items
    expect(component.range_formulas.first).to have_attributes(
      inci_name: "Ingredient A",
      range: "greater_than_75_less_than_100_percent",
      cas_number: nil,
    )
    expect(component.range_formulas.second).to have_attributes(
      inci_name: "Ingredient B modified",
      range: "greater_than_5_less_than_10_percent",
      cas_number: nil,
    )
    expect(component.range_formulas.third).to have_attributes(
      inci_name: "Ingredient C non poisonous",
      range: "greater_than_25_less_than_50_percent",
      cas_number: "123456789",
    )
  end
end
