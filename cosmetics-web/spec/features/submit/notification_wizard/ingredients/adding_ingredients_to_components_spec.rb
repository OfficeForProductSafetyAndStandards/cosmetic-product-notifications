require "rails_helper"

RSpec.describe "Adding ingredients to components", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "Create a new product notification"
    complete_product_wizard(name: "FooProduct")
    expect_progress(1, 3)
    expect_product_details_task_not_started

    click_link "Product details"
  end

  context "when the item is not available in multiple shades" do
    before do
      answer_is_item_available_in_shades_with "No"
      answer_what_is_physical_form_of_item_with "Liquid"
      answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
      answer_does_item_contain_cmrs_with "No"
      answer_item_category_with "Hair and scalp products"
      answer_item_subcategory_with "Hair and scalp care and cleansing products"
      answer_item_sub_subcategory_with "Shampoo"
    end

    scenario "Adding exact concentration ingredients to a product" do
      answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"
      expect_to_be_on_add_ingredients_page

      # First attempt with validation errors
      click_on "Save and continue"

      expect_to_be_on_add_ingredients_page
      expect_form_to_have_errors(
        component_ingredients_attributes_0_inci_name:
          { message: "Enter a name", id: "component_ingredients_attributes_0_inci_name" },
        component_ingredients_attributes_0_exact_concentration:
          { message: "Enter the exact concentration", id: "component_ingredients_attributes_0_exact_concentration" },
      )

      # Successfully adds the first ingredient
      fill_in "What is the name?", with: "FooBar ingredient"
      fill_in "What is the exact concentration?", with: "10.1"
      fill_in "What is the CAS number?", with: "123456-78-9"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["FooBar ingredient"])

      # Attempts to add the same ingredient again
      within("#ingredient-1") do
        fill_in "What is the name?", with: "foobar ingredient"
        fill_in "What is the exact concentration?", with: "2.0"
      end
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["FooBar ingredient"])
      expect_form_to_have_errors(
        component_ingredients_attributes_1_inci_name:
          { message: "Enter a name which is unique to this component",
            id: "component_ingredients_attributes_1_inci_name" },
      )

      # Adds a new poisonous ingredient
      within("#ingredient-1") do
        fill_in "What is the name?", with: "newfoo poisonous"
        fill_in "What is the exact concentration?", with: "7.0"
        check "The NPIS must be notified about this ingredient"
      end
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end

    scenario "Adding range concentration ingredients to a product" do
      answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their concentration range manually"

      expect_to_be_on_add_ingredients_page

      # First attempt failing due not indicating if ingredient is poisonous
      fill_in "What is the name?", with: "FooBar ingredient"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page
      expect_form_to_have_errors(
        component_ingredients_attributes_0_poisonous_true: {
          message: "Select yes if the ingredient is poisonous",
          id: "component_ingredients_attributes_0_poisonous",
        },
      )

      page.choose "No"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page
      expect_form_to_have_errors(
        component_ingredients_attributes_0_minimum_concentration: {
          message: "Enter the minimum concentration",
          id: "component_ingredients_attributes_0_minimum_concentration",
        },
      )
      expect_form_to_have_errors(
        component_ingredients_attributes_0_maximum_concentration: {
          message: "Enter the maximum concentration",
          id: "component_ingredients_attributes_0_maximum_concentration",
        },
      )

      within("#ingredient-0") do
        fill_in("Minimum", with: "1")
        fill_in("Maximum", with: "2")
      end
      click_on "Add another ingredient"

      within("#ingredient-1") do
        fill_in "What is the name?", with: "New ingredient"
        page.choose "Yes"
        fill_in "What is the exact concentration?", with: "Not Valid"
      end
      click_on "Save and continue"

      expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["FooBar ingredient"])
      expect_form_to_have_errors(
        component_ingredients_attributes_1_exact_concentration: {
          message: "Enter a number for the exact concentration",
          id: "component_ingredients_attributes_1_exact_concentration",
        },
      )

      within("#ingredient-1") do
        fill_in "What is the exact concentration?", with: "5.2"
      end
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end

    scenario "Adding poisonous ingredients for a product with predefined formulation" do
      answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

      expect_to_be_on__frame_formulation_select_page
      answer_select_formulation_with "Shampoo plus conditioner"

      answer_contains_ingredients_npis_needs_to_know_about_with("Yes")
      expect_to_be_on_add_ingredients_page(forced_poisonous: true)

      # First attempt with validation errors
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Add an ingredient the NPIS needs to know about")
      expect_form_to_have_errors(
        component_ingredients_attributes_0_inci_name: {
          message: "Enter a name",
          id: "component_ingredients_attributes_0_inci_name",
        },
        component_ingredients_attributes_0_exact_concentration: {
          message: "Enter the exact concentration",
          id: "component_ingredients_attributes_0_exact_concentration",
        },
      )

      # Successfully adds the first ingredient
      fill_in "What is the name?", with: "FooBar ingredient"
      fill_in "What is the exact concentration?", with: "10.1"
      fill_in "What is the CAS number? ", with: "123456-78-9"
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end
  end

  context "when the item is available in multiple shades" do
    before do
      answer_is_item_available_in_shades_with "Yes"
      all("input#component_shades").first.fill_in with: "Blue"
      all("input#component_shades").last.fill_in with: "Red"
      click_button "Continue"

      answer_what_is_physical_form_of_item_with "Liquid"
      answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
      answer_does_item_contain_cmrs_with "No"
      answer_item_category_with "Hair and scalp products"
      answer_item_subcategory_with "Hair and scalp care and cleansing products"
      answer_item_sub_subcategory_with "Shampoo"
    end

    scenario "Adding exact concentration ingredients to a product" do
      answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their exact concentration manually"
      expect_to_be_on_add_ingredients_page

      # First attempt without answering if the ingredient is used for multiple shades
      fill_in "name", with: "non-poisonous multi"
      click_on "Save and continue"

      expect_to_be_on_add_ingredients_page
      expect_form_to_have_errors(
        component_ingredients_attributes_0_used_for_multiple_shades_true: {
          message: "Select yes if the ingredient is used for different shades",
          id: "component_ingredients_attributes_0_used_for_multiple_shades",
        },
      )

      # Selecting the ingredient is used for multiple shades but not filling the max concentration field
      choose "Yes"
      click_on "Save and continue"

      expect_form_to_have_errors(
        component_ingredients_attributes_0_maximum_exact_concentration: {
          message: "Enter the maximum concentration",
          id: "component_ingredients_attributes_0_maximum_exact_concentration",
        },
      )

      # Adds a non poisonous ingredient used for multiple shades
      fill_in "What is the maximum concentration?", with: "10.1"
      fill_in "What is the CAS number?", with: "123456-78-9"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: ["non-poisonous multi"])

      # Adds a poisonous ingredient used for multiple shades
      within("#ingredient-1") do
        fill_in "What is the name?", with: "poisonous multi"
        choose "Yes"
        fill_in "What is the maximum concentration?", with: "7.0"
        check "The NPIS must be notified about this ingredient"
      end
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(ingredient_number: 3, already_added: ["non-poisonous multi", "poisonous multi"])

      # Adds a non poisonous ingredient not used for multiple shades
      within("#ingredient-2") do
        fill_in "What is the name?", with: "non-poisonous no-multi"
        choose "No"
        fill_in "What is the exact concentration?", with: "2.3"
      end
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(
        ingredient_number: 3, already_added: ["non-poisonous multi", "poisonous multi", "non-poisonous no-multi"],
      )

      # Adds a poisonous ingredient not used for multiple shades
      within("#ingredient-3") do
        fill_in "What is the name?", with: "poisonous no-multi"
        check "The NPIS must be notified about this ingredient"
        choose "No"
        fill_in "What is the exact concentration?", with: "3.1"
      end
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end

    scenario "Adding range concentration ingredients to a product" do
      answer_how_do_you_want_to_give_formulation_with "Enter ingredients and their concentration range manually"

      expect_to_be_on_add_ingredients_page

      # Adding a non-poisonous ingredient
      fill_in "What is the name?", with: "non-poisonous"
      page.choose "No"
      fill_in "Minimum", with: "6"
      fill_in "Maximum", with: "6.1"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(ingredient_number: 2, already_added: %w[non-poisonous])

      # Adding a poisonous ingredient
      within("#ingredient-1") do
        fill_in "What is the name?", with: "poisonous"
        page.choose "Yes"
        fill_in "What is the exact concentration?", with: "5.2"
      end
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end

    scenario "Adding poisonous ingredients for a product with predefined formulation" do
      answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

      expect_to_be_on__frame_formulation_select_page
      answer_select_formulation_with "Shampoo plus conditioner"

      answer_contains_ingredients_npis_needs_to_know_about_with("Yes")
      expect_to_be_on_add_ingredients_page(forced_poisonous: true)

      # Adds a poisonous ingredient used for multiple shades
      fill_in "What is the name?", with: "poisonous multi"
      choose "Yes"
      fill_in "What is the maximum concentration?", with: "7.0"
      click_on "Add another ingredient"

      expect_to_be_on_add_ingredients_page(forced_poisonous: true, ingredient_number: 2, already_added: ["poisonous multi"])

      # Adds a poisonous ingredient not used for multiple shades
      within("#ingredient-1") do
        fill_in "What is the name?", with: "poisonous no-multi"
        choose "No"
        fill_in "What is the exact concentration?", with: "10.1"
        fill_in "What is the CAS number", with: "123456-78-9"
      end
      click_on "Save and continue"

      expect_to_be_on_what_is_ph_range_of_product_page
    end
  end
end
