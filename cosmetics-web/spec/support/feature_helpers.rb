require "support/matchers/capybara_matchers"

RSpec.configure do |config|
  config.include PageMatchers
end



# --- Page expections -----

def expect_to_be_on_was_eu_notified_about_products_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/have_products_been_notified_in_eu")

  expect(page).to have_h1("Has the EU been notified about these products using CPNP?")
end

def expect_to_be_on_do_you_have_the_zip_files_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/do_you_have_files_from_eu_notification")

  expect(page).to have_h1("EU notification ZIP files")
end

def expect_to_be_on_was_product_notified_before_brexit_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/was_product_on_sale_before_eu_exit")
  expect(page).to have_h1("Was this product notified in the EU before 1 February 2020?")
end

def expect_to_be_on_what_is_product_called_page
  expect(page.current_path).to end_with("/build/add_product_name")
  expect(page).to have_h1("What’s the product called?")
end

def expect_to_be_on_internal_reference_page
  expect(page.current_path).to end_with("/build/add_internal_reference")
  expect(page).to have_h1("Internal reference")
end

def expect_to_be_on_was_product_imported_page
  expect(page.current_path).to end_with("/build/is_imported")
  expect(page).to have_h1("Is the product imported into the UK?")
end

def expect_to_be_on_multi_item_kits_page
  expect(page.current_path).to end_with("/build/single_or_multi_component")
  expect(page).to have_h1("Multi-item kits")
end

def expect_to_be_on_kit_items_page
  expect(page.current_path).to end_with("/build/add_new_component")
  expect(page).to have_h1("Kit items")
end

def expect_to_be_on_what_is_item_called_page
  expect(page.current_path).to end_with("/build/add_component_name")
  expect(page).to have_h1("What’s the item called?")
end

def expect_to_be_on_is_item_available_in_shades_page(item_name: nil)
  expect(page.current_path).to end_with("/build/number_of_shades")
  expected_title = "Is the #{item_name || 'the product'} available in different shades?"
  expect(page).to have_h1(expected_title)
end

def expect_to_be_on_physical_form_of_item_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_physical_form")
  expect(page).to have_h1("What is the physical form of the #{item_name || 'the product'}?")
end

def expect_to_be_on_does_item_contain_cmrs_page
  expect(page.current_path).to end_with("/build/contains_cmrs")
  expect(page).to have_h1("Substances known or presumed to cause cancer, mutations or are toxic for reproduction (CMRs)")
end

def expect_to_be_on_does_item_contain_nanomaterial_page
  expect(page.current_path).to end_with("/build/contains_nanomaterials")
  expect(page).to have_h1("Nanomaterials")
end

def expect_to_be_on_is_item_intended_to_be_rinsed_off_or_left_on_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_exposure_condition")
  expect(page).to have_h1("Is #{item_name || "the product"} intended to be rinsed off or left on?")
end

def expect_to_be_on_how_is_user_exposed_to_nanomaterials_page
  expect(page.current_path).to end_with("/build/add_exposure_routes")
  expect(page).to have_h1("How is the user likely to be exposed to the nanomaterials?")
end

def expect_to_be_on_list_the_nanomaterials_page(item_name: nil)
  expect(page.current_path).to end_with("/build/list_nanomaterials")
  expect(page).to have_h1("List the nanomaterials in #{item_name || "the product"}")
end

def expect_to_be_on_what_is_the_purpose_of_nanomaterial_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/select_purposes")
  expect(page).to have_h1("What is the purpose of #{nanomaterial_name}")
end

def expect_to_be_on_is_nanomaterial_listed_in_ec_regulation_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_restrictions")
  expect(page).to have_h1("Is #{nanomaterial_name} listed in EC regulation 1223/2009, Annex 4?")
end

def expect_to_be_on_does_nanomaterial_conform_to_restrictions_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_usage")
  expect(page).to have_h1("Does the #{nanomaterial_name} conform to the restrictions set out in Annex 4?")
end

def expect_to_be_on_item_category_page
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of cosmetic product is it?")
end

def expect_to_be_on_item_subcategoy_page(category:, item_name: nil)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{category} is #{item_name || 'the product'}?")
end

def expect_to_be_on_item_sub_subcategory_page(subcategory:, item_name: nil)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{subcategory} is #{item_name || 'the product'}?")
end

def expect_to_be_on_formulation_method_page(item_name: nil)
  expect(page.current_path).to end_with("/build/select_formulation_type")
  expect(page).to have_h1("How do you want to give the formulation of #{item_name || 'the product'}?")
end

def expect_to_be_on_upload_ingredients_page
  expect(page.current_path).to end_with("/build/upload_formulation")
  expect(page).to have_h1("Upload list of ingredients")
end

def expect_to_be_on_what_is_ph_range_of_product_page
  expect(page.current_path).to end_with("/trigger_question/select_ph_range")
  expect(page).to have_h1("What is the pH range of the product?")
end

def expect_to_be_on_check_your_answers_page(product_name:)
  expect(page.current_path).to end_with("/edit")
  expect(page).to have_h1(product_name)
end

def expect_to_be_on_how_are_items_used_together_page
  expect(page.current_path).to end_with("/is_mixed")
  expect(page).to have_h1("How are the items in the kit used?")
end

# rubocop:disable Naming/UncommunicativeMethodParamName
def expect_check_your_answers_page_to_contain(product_name:, imported:, number_of_components:, shades:, contains_cmrs:, nanomaterials:, category:, subcategory:, sub_subcategory:, formulation_given_as:, physical_form:, ph:, application_instruction: nil, exposure_condition: nil)
  within("#product-table") do
    expect(page).to have_summary_item(key: "Name", value: product_name)
    expect(page).to have_summary_item(key: "Imported", value: imported)
    expect(page).to have_summary_item(key: "Number of components", value: number_of_components)
    expect(page).to have_summary_item(key: "Shades", value: shades)
    expect(page).to have_summary_item(key: "Contains CMR substances", value: contains_cmrs)
    expect(page).to have_summary_item(key: "Nanomaterials", value: nanomaterials)
    expect(page).to have_summary_item(key: "Category of product", value: category)
    expect(page).to have_summary_item(key: "Category of #{category.downcase.singularize}", value: subcategory)
    expect(page).to have_summary_item(key: "Category of #{subcategory.downcase.singularize}", value: sub_subcategory)
    expect(page).to have_summary_item(key: "Formulation given as", value: formulation_given_as)
    expect(page).to have_summary_item(key: "Physical form", value: physical_form)
    expect(page).to have_summary_item(key: "pH", value: ph)

    if application_instruction
      expect(page).to have_summary_item(key: "Application instruction", value: application_instruction)
    end

    if exposure_condition
      expect(page).to have_summary_item(key: "Exposure condition", value: exposure_condition)
    end
  end
end
# rubocop:enable Naming/UncommunicativeMethodParamName

def expect_check_your_answers_page_for_kit_items_to_contain(product_name:, imported:, number_of_components:, components_mixed:, kit_items:)
  within_table("Product") do
    expect(page).to have_summary_item(key: "Name", value: product_name)
    expect(page).to have_summary_item(key: "Imported", value: imported)
    expect(page).to have_summary_item(key: "Number of components", value: number_of_components)
    expect(page).to have_summary_item(key: "Are the components mixed?", value: components_mixed)
  end

  kit_items.each do |kit_item|
    expect(page).to have_selector("caption", text: kit_item[:name])

    within_table(kit_item[:name]) do
      expect(page).to have_summary_item(key: "Shades", value: kit_item[:shades])
      expect(page).to have_summary_item(key: "Contains CMR substances", value: kit_item[:contains_cmrs])
      expect(page).to have_summary_item(key: "Nanomaterials", value: kit_item[:nanomaterials])

      if kit_item[:application_instruction]
        expect(page).to have_summary_item(key: "Application instruction", value: kit_item[:application_instruction])
      end

      if kit_item[:exposure_condition]
        expect(page).to have_summary_item(key: "Exposure condition", value: kit_item[:exposure_condition])
      end

      expect(page).to have_summary_item(key: "Category of product", value: kit_item[:category])
      expect(page).to have_summary_item(key: "Category of #{kit_item[:category].downcase.singularize}", value: kit_item[:subcategory])
      expect(page).to have_summary_item(key: "Category of #{kit_item[:subcategory].downcase.singularize}", value: kit_item[:sub_subcategory])
      expect(page).to have_summary_item(key: "Formulation given as", value: kit_item[:formulation_given_as])
      expect(page).to have_summary_item(key: "Physical form", value: kit_item[:physical_form])
      expect(page).to have_summary_item(key: "pH", value: kit_item[:ph])
    end
  end
end

def expect_to_be_on_your_cosmetic_products_page
  expect(page.current_path).to end_with("/responsible_persons/#{responsible_person.id}/notifications")
  expect(page).to have_h1("Your cosmetic products")
end

def expect_to_see_message(message)
  expect(page).to have_text(message)
end

def expect_to_be_on_frame_formulation_select_page
  expect(page.current_path).to end_with("/build/select_frame_formulation")
  expect(page).to have_h1("Choose frame formulation")
end

# ---- Page interactions ----

def answer_was_eu_notified_with(answer)
  within_fieldset("Has the EU been notified about these products using CPNP?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_do_you_have_zip_files_with(answer)
  within_fieldset("Do you have the ZIP files from your EU notification?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_was_product_notified_before_brexit_with(answer)
  within_fieldset("Was this product notified in the EU before 1 February 2020?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_product_name_with(product_name)
  fill_in "Product name", with: product_name
  click_button "Continue"
end

def answer_do_you_want_to_give_an_internal_reference_with(answer)
  within_fieldset("Do you want to add an internal reference?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_was_product_imported_with(answer)
  within_fieldset("Is the product imported into the UK?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_is_product_multi_item_kit_with(answer)
  within_fieldset("Is the product a multi-item kit?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_how_are_items_used_together_with(answer)
  within_fieldset("How are the items in the kit used?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_item_name_with(item_name)
  fill_in "Item name", with: item_name
  click_button "Continue"
end

def answer_is_item_available_in_shades_with(answer, item_name: nil)
  within_fieldset("Is the #{item_name || 'the product'} available in different shades?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_what_is_physical_form_of_item_with(answer, item_name: nil)
  within_fieldset("What is the physical form of the #{item_name || 'the product'}?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_item_contain_cmrs_with(answer, item_name: nil)
  within_fieldset("Does #{item_name || 'the product'} contain category 1A or 1B CMRs?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_item_contain_nanomaterials_with(answer, item_name: nil)
  within_fieldset("Does #{item_name || 'the product'} contain nanomaterials?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_is_item_intended_to_be_rinsed_off_or_left_on_with(answer, item_name: nil)
  within_fieldset("Is #{item_name || "the product"} intended to be rinsed off or left on?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_how_user_is_exposed_to_nanomaterials_with(answer)
  within_fieldset("How is the user likely to be exposed to the nanomaterials?") do
    page.check(answer)
  end
  click_button "Continue"
end

def answer_nanomaterial_names_with(nanomaterial_names)
  if String === nanomaterial_names
    # TODO: replace with label once these are unambiguous
    fill_in "nano_material_nano_elements_attributes_0_inci_name", with: nanomaterial_names
  end

  click_button "Continue"
end

def answer_what_is_purpose_of_nanomaterial_with(purpose, nanomaterial_name:)
  within_fieldset("What is the purpose of #{nanomaterial_name}?") do
    page.check(purpose)
  end
  click_button "Continue"
end

def answer_is_nanomaterial_listed_in_ec_regulation_with(answer, nanomaterial_name:)
  within_fieldset("Is #{nanomaterial_name} listed in EC regulation 1223/2009, Annex 4?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_nanomaterial_conform_to_restrictions_with(answer, nanomaterial_name:)
  within_fieldset("Does the #{nanomaterial_name} conform to the restrictions set out in Annex 4?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_item_category_with(answer)
  within_fieldset("What category of cosmetic product is it?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_item_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end

def answer_item_sub_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end

def answer_how_do_you_want_to_give_formulation_with(answer, item_name: nil)
  within_fieldset("How do you want to give the formulation of #{item_name || 'the product'}?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def upload_ingredients_pdf
  page.attach_file "spec/fixtures/testPdf.pdf"
  click_button "Continue"
end

def answer_what_is_ph_range_of_product_with(answer)
  within_fieldset("What is the pH range of the product?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def give_frame_formulation_as(frame_formulation_name)
  page.select(frame_formulation_name, from: "Frame formulation name")
  click_button "Continue"
end

def add_an_item
  click_button "Add item"
end
