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

def expect_to_be_on_is_product_available_in_shades_page
  expect(page.current_path).to end_with("/build/number_of_shades")
  expect(page).to have_h1("Is the the product available in different shades?")
end

def expect_to_be_on_physical_form_of_product_page
  expect(page.current_path).to end_with("/build/add_physical_form")
  expect(page).to have_h1("What is the physical form of the the product?")
end

def expect_to_be_on_does_product_contain_cmrs_page
  expect(page.current_path).to end_with("/build/contains_cmrs")
  expect(page).to have_h1("Substances known or presumed to cause cancer, mutations or are toxic for reproduction (CMRs)")
end

def expect_to_be_on_does_product_contain_nanomaterial_page
  expect(page.current_path).to end_with("/build/contains_nanomaterials")
  expect(page).to have_h1("Nanomaterials")
end

def expect_to_be_on_product_category_page
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of cosmetic product is it?")
end

def expect_to_be_on_product_subcategoy_page(category:)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{category} is the product?")
end

def expect_to_be_on_product_sub_subcategory_page(subcategory:)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{subcategory} is the product?")
end

def expect_to_be_on_formulation_method_page
  expect(page.current_path).to end_with("/build/select_formulation_type")
  expect(page).to have_h1("How do you want to give the formulation of the product?")
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

def expect_check_your_answers_page_to_contain(product_name:, imported:, number_of_components:, shades:, contains_cmrs:, nanomaterials:, category:, subcategory:, sub_subcategory:, formulation_given_as:, physical_form:, ph:)

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


def answer_is_product_available_in_shades_with(answer)
  within_fieldset("Is the the product available in different shades?") do
    page.choose(answer)
  end
  click_button "Continue"
end


def answer_what_is_physical_form_of_product_with(answer)
  within_fieldset("What is the physical form of the the product?") do
    page.choose(answer)
  end
  click_button "Continue"
end


def answer_does_product_contain_cmrs_with(answer)
  within_fieldset("Does the product contain category 1A or 1B CMRs?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_does_product_contain_nanomaterials_with(answer)
  within_fieldset("Does the product contain nanomaterials?") do
    page.choose(answer)
  end
  click_button "Continue"
end


def answer_product_category_with(answer)
  within_fieldset("What category of cosmetic product is it?") do
    page.choose(answer)
  end
  click_button "Continue"
end


def answer_product_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end


def answer_product_sub_subcategory_with(answer)
  page.choose(answer)
  click_button "Continue"
end


def answer_how_do_you_want_to_give_formulation_with(answer)
  within_fieldset("How do you want to give the formulation of the product?") do
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
