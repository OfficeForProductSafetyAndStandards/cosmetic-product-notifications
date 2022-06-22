require "rails_helper"

RSpec.describe "Adding ingredients to components", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_on "Add a cosmetic product"
    complete_product_wizard(name: "FooProduct")
    expect_progress(1, 3)
    expect_product_details_task_not_started

    click_link "Product details"
    answer_is_item_available_in_shades_with "No"
    answer_what_is_physical_form_of_item_with "Liquid"
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"
    answer_does_item_contain_cmrs_with "No"
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"
  end

  scenario "Adding exact concentration ingredients to a product" do
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 1")

    # First attempt with validation errors
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a name", href: "#name")

    expect(page).to have_link("Enter the concentration", href: "#exact_concentration")
    expect(page).to have_css("span#name-error", text: "Enter a name")
    expect(page).to have_css("span#exact_concentration-error", text: "Enter the concentration")

    # Successfully adds the first ingredient
    fill_in "name", with: "FooBar ingredient"
    fill_in "exact_concentration", with: "10.1"
    fill_in "cas_number", with: "123456-78-9"
    click_on "Save and continue"

    # Chooses to add a second ingredient
    expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
    expect(page).to have_css("p", text: "The ingredient was successfully added to the product.")
    page.choose "Yes"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 2")
    expect(page).to have_css("h2", text: "Already added")
    expect(page).to have_css("ol.govuk-list--number li", text: "FooBar ingredient")

    # Attempts to add the same ingredient again
    fill_in "name", with: "foobar ingredient"
    fill_in "exact_concentration", with: "2.0"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a name which is unique to this product", href: "#name")
    expect(page).to have_css("span#name-error", text: "Enter a name which is unique to this product")

    # Adds a new poisonous ingredient
    fill_in "name", with: "newfoo poisonous"
    check "Is it poisonous?"
    fill_in "exact_concentration", with: "7.0"
    click_on "Save and continue"

    # Chooses to add a third ingredient
    expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
    expect(page).to have_css("p", text: "The ingredient was successfully added to the product.")
    page.choose "Yes"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 3")
    expect(page).to have_css("h2", text: "Already added")
    expect(page).to have_css("ol.govuk-list--number li", text: "FooBar ingredient")
    expect(page).to have_css("ol.govuk-list--number li", text: "newfoo poisonous")

    # Skips adding the ingredient
    click_link "Skip"
    expect(page).to have_h1("What is the pH range of the product?")
  end

  scenario "Adding range concentration ingredients to a product" do
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their concentration range"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 1")

    # First attempt failing due not indicating if ingredient is poisonous
    fill_in "name", with: "FooBar ingredient"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select yes if the ingredient is poisonous", href: "#poisonous_true")
    expect(page).to have_css("span#ingredient_concentration_form_poisonous-error", text: "Select yes if the ingredient is poisonous")

    # Second attempt failing due to not selecting a concentration range for a non poisonous ingredient
    page.choose "No"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Select a concentration range", href: "#greater_than_75_less_than_100_percent")
    expect(page).to have_css("span#ingredient_concentration_form_range_concentration-error", text: "Select a concentration range")

    # Successfully adding the first ingredient by its concentration range
    page.choose("Above 5% w/w up to 10% w/w")
    click_on "Save and continue"

    # Aks to add a second ingredient
    expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
    expect(page).to have_css("p", text: "The ingredient was successfully added to the product.")
    page.choose "Yes"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 2")
    expect(page).to have_css("h2", text: "Already added")
    expect(page).to have_css("ol.govuk-list--number li", text: "FooBar ingredient")

    # Attempt to add a poisonous ingredient with wrong value for concentration
    fill_in "name", with: "New ingredient"
    page.choose "Yes"
    fill_in "exact_concentration", with: "Not Valid"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a number for the concentration", href: "#exact_concentration")
    expect(page).to have_css("span#exact_concentration-error", text: "Enter a number for the concentration")

    # Adds the second ingredient after entering a valid exact concentration
    fill_in "exact_concentration", with: "5.2"
    click_on "Save and continue"

    # Decides not to add a third ingredient
    expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
    expect(page).to have_css("p", text: "The ingredient was successfully added to the product.")
    page.choose "No"
    click_button "Continue"

    expect(page).to have_h1("What is the pH range of the product?")
  end

  scenario "Adding poisonous ingredients for a product with predefined formulation" do
    answer_how_do_you_want_to_give_formulation_with "Choose a predefined frame formulation"

    expect_to_be_on__frame_formulation_select_page
    page.select "Skin Care Cream, Lotion, Gel", from: "component_frame_formulation"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Does the product contain poisonous ingredients?")
    page.choose "Yes"
    click_button "Continue"

    expect(page).to have_css("h1", text: "Add the poisonous ingredients")
    expect(page).to have_css("legend.govuk-fieldset__legend--s", text: "Ingredient 1")
    # Poisonous checkbox is pre-selected and disabled
    expect(page).to have_checked_field("ingredient_concentration_form_poisonous", disabled: true)

    # First attempt with validation errors
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Add the poisonous ingredients")
    expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).to have_link("Enter a name", href: "#name")

    expect(page).to have_link("Enter the concentration", href: "#exact_concentration")
    expect(page).to have_css("span#name-error", text: "Enter a name")
    expect(page).to have_css("span#exact_concentration-error", text: "Enter the concentration")

    # Successfully adds the first ingredient
    fill_in "name", with: "FooBar ingredient"
    fill_in "exact_concentration", with: "10.1"
    fill_in "cas_number", with: "123456-78-9"
    click_on "Save and continue"

    # Chooses not to add a second ingredient
    expect(page).to have_css("h1", text: "Do you want to add another ingredient?")
    expect(page).to have_css("p", text: "The ingredient was successfully added to the product.")
    page.choose "No"
    click_button "Continue"

    expect(page).to have_h1("What is the pH range of the product?")
  end
end
