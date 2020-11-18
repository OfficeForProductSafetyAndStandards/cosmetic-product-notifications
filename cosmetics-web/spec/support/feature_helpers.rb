require "support/matchers/capybara_matchers"

RSpec.configure do |config|
  config.include PageMatchers
end

# --- Page expections -----

def fill_in_credentials(password_override: nil)
  fill_in "Email address", with: user.email
  if password_override
    fill_in "Password", with: password_override
  else
    fill_in "Password", with: user.password
  end
  click_on "Continue"
end

def expect_user_to_have_received_sms_code(code, current_user = nil)
  if current_user.nil?
    current_user = user
  end
  expect(notify_stub).to have_received(:send_sms).with(
    hash_including(phone_number: current_user.mobile_number, personalisation: { code: code }),
  ).at_least(:once)
end

def complete_secondary_authentication_with(security_code)
  fill_in "Enter security code", with: security_code
  click_on "Continue"
end

def expect_to_be_on_secondary_authentication_page
  expect(page).to have_current_path(/\/two-factor/)
  expect(page).to have_h1("Check your phone")
end

def expect_to_be_on_resend_secondary_authentication_page
  expect(page).to have_current_path("/text-not-received")
  expect(page).to have_h1("Resend security code")
end

def expect_to_be_on_signed_in_as_another_user_page
  expect(page).to have_h1("You are already signed in")
end

def expect_to_be_on_complete_registration_page
  expect(page).to have_current_path(/\/complete-registration?.+$/)
  expect(page).to have_h1("Create an account")
  expect(page).to have_field("username", type: "email", with: invited_user.email, disabled: true)
end

def expect_to_be_on_password_changed_page
  expect(page).to have_current_path("/password-changed")
  expect(page).to have_css("h1", text: "You have changed your password successfully")
end

def expect_to_be_on_reset_password_page
  expect(page).to have_current_path("/password/new")
end

def expect_to_be_on_declaration_page
  expect(page).to have_current_path("/declaration", ignore_query: true)
end

def expect_to_be_on_check_your_email_page
  expect(page).to have_css("h1", text: "Check your email")
end

def expect_to_be_on_edit_user_password_page
  expect(page).to have_current_path("/password/edit", ignore_query: true)
end

def expect_incorrect_email_or_password
  expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
  expect(page).to have_link("Enter correct email address and password", href: "#email")
  expect(page).to have_css("span#email-error", text: "Error: Enter correct email address and password")
  expect(page).to have_css("span#password-error", text: "")

  expect(page).not_to have_link("Cases")
end

def otp_code(email = nil)
  user_with_code = User.find_by(email: email) || user
  user_with_code.reload.direct_otp
end

def expect_to_be_on_my_account_page
  expect(page).to have_current_path(/\/my_account/)
end

def expect_to_be_on__was_eu_notified_about_products_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/have_products_been_notified_in_eu")

  expect(page).to have_h1("Has the EU been notified about these products using CPNP?")
end

def expect_to_be_on__are_you_likely_to_notify_eu_page
  expect(page.current_path).to end_with("/will_products_be_notified_in_eu")
  expect(page).to have_h1("Are you likely to notify the EU about these products?")
end

def expect_to_be_on__do_you_have_the_zip_files_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/do_you_have_files_from_eu_notification")

  expect(page).to have_h1("EU notification ZIP files")
end

def expect_to_be_on__upload_eu_notification_files_page
  expect(page.current_path).to end_with("/notification_files/new")
  expect(page).to have_h1("Upload your EU notification files")
end

def expect_to_be_on__was_product_notified_before_brexit_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}/add_notification/was_product_on_sale_before_eu_exit")
  expect(page).to have_h1("Was this product notified in the EU before 1 January 2021?")
end

def expect_to_be_on__what_is_product_called_page
  expect(page.current_path).to end_with("/build/add_product_name")
  expect(page).to have_h1("What’s the product called?")
end

def expect_to_be_on__internal_reference_page
  expect(page.current_path).to end_with("/build/add_internal_reference")
  expect(page).to have_h1("Internal reference")
end

def expect_to_be_on__was_product_imported_page
  expect(page.current_path).to end_with("/build/is_imported")
  expect(page).to have_h1("Is the product imported into the UK?")
end

def expect_to_be_on__is_product_for_under_threes_page
  expect(page.current_path).to end_with("/for_children_under_three")
  expect(page).to have_h1("Is the product intended to be used on children under 3 years old?")
end

def expect_to_be_on__multi_item_kits_page
  expect(page.current_path).to end_with("/build/single_or_multi_component")
  expect(page).to have_h1("Multi-item kits")
end

def expect_to_be_on__kit_items_page
  expect(page.current_path).to end_with("/build/add_new_component")
  expect(page).to have_h1("Kit items")
end

def expect_to_be_on__what_is_item_called_page
  expect(page.current_path).to end_with("/build/add_component_name")
  expect(page).to have_h1("What’s the item called?")
end

def expect_to_be_on__is_item_available_in_shades_page(item_name: nil)
  expect(page.current_path).to end_with("/build/number_of_shades")
  expected_title = "Is the #{item_name || 'the product'} available in different shades?"
  expect(page).to have_h1(expected_title)
end

def expect_to_be_on__physical_form_of_item_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_physical_form")
  expect(page).to have_h1("What is the physical form of the #{item_name || 'the product'}?")
end

def expect_to_be_on__what_is_product_contained_in_page(item_name: nil)
  expect(page.current_path).to end_with("/contains_special_applicator")
  expect(page).to have_h1("What is the #{item_name || 'the product'} contained in?")
end

def expect_to_be_on__what_type_of_applicator_page
  expect(page.current_path).to end_with("/select_special_applicator_type")
  expect(page).to have_h1("What type of applicator?")
end

def expect_to_be_on__does_item_contain_cmrs_page
  expect(page.current_path).to end_with("/build/contains_cmrs")
  expect(page).to have_h1("Carcinogenic, mutagenic or reprotoxic substances")
end

def expect_to_be_on__does_item_contain_nanomaterial_page
  expect(page.current_path).to end_with("/build/contains_nanomaterials")
  expect(page).to have_h1("Nanomaterials")
end

def expect_to_be_on__is_item_intended_to_be_rinsed_off_or_left_on_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_exposure_condition")
  expect(page).to have_h1("Is #{item_name || 'the product'} intended to be rinsed off or left on?")
end

def expect_to_be_on__how_is_user_exposed_to_nanomaterials_page
  expect(page.current_path).to end_with("/build/add_exposure_routes")
  expect(page).to have_h1("How is the user likely to be exposed to the nanomaterials?")
end

def expect_to_be_on__list_the_nanomaterials_page(item_name: nil)
  expect(page.current_path).to end_with("/build/list_nanomaterials")
  expect(page).to have_h1("List the nanomaterials in #{item_name || 'the product'}")
end

def expect_to_be_on__what_is_the_purpose_of_nanomaterial_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/select_purposes")
  expect(page).to have_h1("What is the purpose of #{nanomaterial_name}")
end

def expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_restrictions")
  expect(page).to have_h1("Is #{nanomaterial_name} listed in EC regulation 1223/2009, Annex 4?")
end

def expect_to_be_on__does_nanomaterial_conform_to_restrictions_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_usage")
  expect(page).to have_h1("Does the #{nanomaterial_name} conform to the restrictions set out in Annex 4?")
end

def expect_to_be_on__item_category_page
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of cosmetic product is it?")
end

def expect_to_be_on__item_subcategoy_page(category:, item_name: nil)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{category} is #{item_name || 'the product'}?")
end

def expect_to_be_on__item_sub_subcategory_page(subcategory:, item_name: nil)
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of #{subcategory} is #{item_name || 'the product'}?")
end

def expect_to_be_on__formulation_method_page(item_name: nil)
  expect(page.current_path).to end_with("/build/select_formulation_type")
  expect(page).to have_h1("How do you want to give the formulation of #{item_name || 'the product'}?")
end

# Exact concentrations of the ingredients
# Concentration ranges of the ingredients
def expect_to_be_on__upload_ingredients_page(header_text)
  expect(page.current_path).to end_with("/build/upload_formulation")
  expect(page).to have_h1(header_text)
end

def expect_to_be_on__upload_poisonous_ingredients_page
  expect(page.current_path).to end_with("/build/upload_formulation")
  expect(page).to have_h1("Upload list of poisonous ingredients")
end

def expect_to_be_on__poisonous_ingredients_page
  expect(page.current_path).to end_with("/contains_poisonous_ingredients")
  expect(page).to have_h1("Ingredients the National Poison Information Service needs to know about")
end

def expect_to_be_on__what_is_ph_range_of_product_page
  expect(page.current_path).to end_with("/trigger_question/select_ph_range")
  expect(page).to have_h1("What is the pH range of the product?")
end

def expect_to_be_on__check_your_answers_page(product_name:)
  expect(page.current_path).to end_with("/edit")
  expect(page).to have_h1(product_name)
end

def expect_to_be_on__how_are_items_used_together_page
  expect(page.current_path).to end_with("/is_mixed")
  expect(page).to have_h1("How are the items in the kit used?")
end

def exepct_to_be_on_upload_product_label_page
  expect(page.current_path).to end_with("/add_product_image")
  expect(page).to have_h1("Upload an image of the product label")
end

def expect_to_be_on__upload_formulation_document_page
  expect(page.current_path).to end_with("/formulation/new")
  expect(page).to have_h1("Upload formulation document")
end

# rubocop:disable Naming/MethodParameterName
def expect_check_your_answers_page_to_contain(product_name:, imported:, imported_from: nil, number_of_components:, shades:, contains_cmrs:, nanomaterials:, category:, subcategory:, sub_subcategory:, formulation_given_as:, frame_formulation: nil, physical_form:, ph: nil, application_instruction: nil, exposure_condition: nil, eu_notification_date: nil)
  within("#product-table") do
    expect(page).to have_summary_item(key: "Name", value: product_name)
    expect(page).to have_summary_item(key: "Shades", value: shades)

    expect(page).to have_summary_item(key: "Imported", value: imported)

    if imported_from
      expect(page).to have_summary_item(key: "Imported from", value: imported_from)
    end

    expect(page).to have_summary_item(key: "Number of components", value: number_of_components)
    expect(page).to have_summary_item(key: "Contains CMR substances", value: contains_cmrs)
    expect(page).to have_summary_item(key: "Nanomaterials", value: nanomaterials)
    expect(page).to have_summary_item(key: "Category of product", value: category)
    expect(page).to have_summary_item(key: "Category of #{category.downcase.singularize}", value: subcategory)
    expect(page).to have_summary_item(key: "Category of #{subcategory.downcase.singularize}", value: sub_subcategory)
    expect(page).to have_summary_item(key: "Formulation given as", value: formulation_given_as)

    if eu_notification_date
      expect(page).to have_summary_item(key: "EU notification date", value: eu_notification_date)
    end

    if frame_formulation
      expect(page).to have_summary_item(key: "Frame formulation", value: frame_formulation)
    end

    expect(page).to have_summary_item(key: "Physical form", value: physical_form)

    if ph
      expect(page).to have_summary_item(key: "pH", value: ph)
    end

    if application_instruction
      expect(page).to have_summary_item(key: "Application instruction", value: application_instruction)
    end

    if exposure_condition
      expect(page).to have_summary_item(key: "Exposure condition", value: exposure_condition)
    end
  end
end
# rubocop:enable Naming/MethodParameterName

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
      # expect(page).to have_summary_item(key: "pH", value: kit_item[:ph])
    end
  end
end

def expect_to_be_on__your_cosmetic_products_page
  expect(page.current_path).to end_with("/responsible_persons/#{responsible_person.id}/notifications")
  expect(page).to have_h1("Your cosmetic products")
end

def expect_to_see_message(message)
  expect(page).to have_text(message)
end

def expect_to_be_on__frame_formulation_select_page
  expect(page.current_path).to end_with("/build/select_frame_formulation")
  expect(page).to have_h1("Choose frame formulation")
end

def expect_to_see_incomplete_notification_with_eu_reference_number(eu_reference_number)
  within("#incomplete") do
    expect(page).to have_text("EU reference number: #{eu_reference_number}")
  end
end

def expect_to_see_notification_error(error_message)
  within("#errors") do
    expect(page).to have_text(error_message)
  end
end

def expect_not_to_see_any_notification_errors
  within("#errors") do
    expect(page).not_to have_selector("table")
  end
end

def expect_to_be_on__responsible_person_declaration_page
  expect(page).to have_h1("Responsible Person Declaration")
end

# ---- Page interactions ----

def go_to_upload_notification_page
  expect_to_be_on__was_eu_notified_about_products_page
  page.choose("Yes")
  click_button "Continue"
  expect_to_be_on__do_you_have_the_zip_files_page
  page.choose("Yes")
  click_button "Continue"
  expect_to_be_on__upload_eu_notification_files_page
end

def answer_was_eu_notified_with(answer)
  within_fieldset("Has the EU been notified about these products using CPNP?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_are_you_likely_to_notify_eu_with(answer)
  within_fieldset("Are you likely to notify the EU about these products?") do
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
  within_fieldset("Was this product notified in the EU before 1 January 2021?") do
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

def answer_is_product_for_under_threes_with(answer)
  within_fieldset("Is the product intended to be used on children under 3 years old?") do
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
  within_fieldset("Does #{item_name || 'the product'} contain category 1A or 1B CMR substances?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_what_is_product_contained_in_with(answer, item_name: nil)
  within_fieldset("What is the #{item_name || 'the product'} contained in?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_what_type_of_applicator_with(answer)
  within_fieldset("What type of applicator?") do
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
  within_fieldset("Is #{item_name || 'the product'} intended to be rinsed off or left on?") do
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
  if nanomaterial_names.is_a?(String)
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

def upload_formulation_file
  page.attach_file "spec/fixtures/testPdf.pdf"
  click_button "Continue"
end

def upload_product_label
  page.attach_file "spec/fixtures/testImage.png"
  click_button "Continue"
end

def upload_zip_file(zip_file_name)
  page.attach_file "spec/fixtures/#{zip_file_name}"
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

def answer_does_product_contain_poisonous_ingredients_with(answer)
  within_fieldset("Does the product contain any poisonous ingredients?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def add_an_item
  click_button "Add item"
end

def select_options_to_create_account
  click_on "Continue"
  expect(page).to have_h1("Does anyone in your organisation have an account to submit cosmetic product notifications in the UK?")
  choose "No, I need to create an account"
  click_on "Continue"
  expect(page).to have_h1("Is the UK Responsible Person a business or an individual?")
end

def fill_in_new_rp_details
  fill_in_rp_business_details
  fill_in_rp_contact_details
end

def fill_in_rp_business_details
  fill_in "Building and street", with: "Auto-test-address1"
  fill_in "Town or city", with: "Auto-test city"
  fill_in "County", with: "auto-test-county"
  fill_in "Postcode", with: "b28 9un"
  click_on "Continue"
end

def fill_in_rp_contact_details
  expect(page).to have_h1(/Contact person for/)
  fill_in "Full name", with: "Auto-test contact person"
  fill_in "Email address", with: "auto-test@foo"
  fill_in "Phone number", with: "07984563072"
  click_on "Continue"
  expect(page).to have_text("Enter your email address in the correct format")
  fill_in "Full name", with: "Auto-test contact person"
  fill_in "Email address", with: "auto-test@exaple.com"
  fill_in "Phone number", with: "07984563072"
  click_on "Continue"
end

def create_another_business_responsible_person
  select_options_to_create_account
  select_individual_account_type
  fill_in "Name", with: "Auto-test rpuser"
  fill_in_new_rp_details
end

def select_business_account_type
  assert_text "Is the UK Responsible Person a business or an individual?"
  choose "Limited company or Limited Liability Partnership (LLP)"
  click_on "Continue"
end

def select_individual_account_type
  assert_text "Is the UK Responsible Person a business or an individual?"
  choose "Individual or sole trader"
  click_on "Continue"
end
