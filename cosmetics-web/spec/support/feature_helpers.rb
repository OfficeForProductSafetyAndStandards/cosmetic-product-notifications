require "support/matchers/capybara_matchers"

RSpec.configure do |config|
  config.include PageMatchers
end

# --- Page expectations -----

module Fspec
  YES = "Yes".freeze
  NO  = "No".freeze
end

def recovery_codes_to_string(recovery_codes)
  recovery_codes.map { |code| ActiveSupport::NumberHelper.number_to_delimited(code, delimiter: " ", delimiter_pattern: /(\d{4})(?=\d)/) }.join("\n")
end

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
    hash_including(phone_number: current_user.mobile_number, personalisation: { code: }),
  ).once
end

def expect_user_not_to_have_received_sms_code(code, current_user = nil)
  if current_user.nil?
    current_user = user
  end
  expect(notify_stub).not_to have_received(:send_sms).with(
    hash_including(phone_number: current_user.mobile_number, personalisation: { code: }),
  )
end

def complete_secondary_authentication_sms_with(security_code)
  fill_in "Enter security code", with: security_code
  click_on "Continue"
end

def complete_secondary_authentication_app(access_code = nil)
  fill_in "Access code", with: access_code.presence || correct_app_code
  click_on "Continue"
end

def complete_secondary_authentication_recovery_code(recovery_code = nil)
  # Allow empty recovery codes for testing
  fill_in "Recovery code", with: recovery_code.nil? ? correct_recovery_code : recovery_code
  click_on "Continue"
end

def select_secondary_authentication_sms
  expect(page).to have_css("h1", text: "How do you want to get an access code?")
  choose "Text message"
  click_on "Continue"
end

def select_secondary_authentication_app
  expect(page).to have_css("h1", text: "How do you want to get an access code?")
  choose "Authenticator app for smartphone or tablet"
  click_on "Continue"
end

def select_secondary_authentication_recovery_code
  expect(page).to have_css("h1", text: "How do you want to get an access code?")
  choose "Authenticator app for smartphone or tablet"
  click_on "Continue"
  click_on "Use recovery code"
end

def expect_to_be_on_secondary_authentication_method_selection_page
  expect(page).to have_current_path("/two-factor/method")
  expect(page).to have_css("h1", text: "How do you want to get an access code?")
end

def expect_to_be_on_secondary_authentication_sms_page
  expect(page).to have_current_path("/two-factor/sms")
  expect(page).to have_h1("Check your phone")
end

def expect_to_be_on_secondary_authentication_app_page
  expect(page).to have_current_path("/two-factor/app")
  expect(page).to have_h1("Enter the access code")
end

def expect_to_be_on_resend_secondary_authentication_page
  expect(page).to have_current_path("/two-factor/sms/not-received")
  expect(page).to have_h1("Resend security code")
end

def expect_to_be_on_secondary_authentication_recovery_code_page(back_to: nil)
  back_to = back_to.present? ? "?back_to=#{back_to}" : ""
  expect(page).to have_current_path("/two-factor/recovery-code#{back_to}")
  expect(page).to have_h1("Enter a recovery code")
end

def expect_to_be_on_secondary_authentication_recovery_codes_setup_page
  expect(page).to have_current_path("/two-factor/recovery-codes/setup")
  expect(page).to have_h1("Recovery codes")
end

def expect_to_be_on_signed_in_as_another_user_page
  expect(page).to have_h1("You are already signed in")
end

def expect_to_be_on_complete_registration_page
  expect(page).to have_current_path(/\/complete-registration?.+$/)
  expect(page).to have_h1("Setup your account")
  expect(page).to have_field("username", type: "email", with: invited_user.email, disabled: true)
end

def expect_back_link_to_complete_registration_page
  expect(page).to have_button("Back")
end

def expect_to_be_on_password_changed_page
  expect(page).to have_current_path("/password-changed")
  expect(page).to have_css("h1", text: "You have changed your password successfully")
end

def expect_to_be_on_reset_password_page
  expect(page).to have_current_path("/password/new")
end

def expect_to_be_on_account_overview_page
  expect(page).to have_current_path("/responsible_persons/account/overview", ignore_query: true)
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
  expect(page).to have_css("p#email-error", text: "Error: Enter correct email address and password")
  expect(page).to have_css("p#password-error", text: "")

  expect(page).not_to have_link("Cases")
end

def expect_success_banner_with_text(text)
  expect(page).to have_css("div.govuk-notification-banner--success", text:)
end

def expect_confirmation_banner_with_text(text)
  expect(page).to have_css("div.govuk-panel--confirmation", text:)
end

def otp_code(email = nil)
  user_with_code = User.find_by(email:) || user
  user_with_code.reload.direct_otp
end

def expect_to_be_on_my_account_page
  expect(page).to have_current_path(/\/my_account/)
end

def expect_back_link_to_my_account_page
  expect_back_link_to("/my_account")
end

def expect_back_link_to(path)
  expect(page).to have_link("Back", href: path)
end

def expect_back_link_to_notifications_page
  expect_back_link_to("/responsible_persons/#{responsible_person.id}/notifications")
end

def expect_to_be_on__responsible_person_page
  expect(page.current_path).to eql("/responsible_persons/#{responsible_person.id}")
  expect(page).to have_h1("Responsible Person")
end

def expect_back_link_to_responsible_person_page
  expect(page).to have_link("Back", href: "/responsible_persons/#{responsible_person.id}")
end

def expect_to_be_on__what_is_product_name_page
  expect(page.current_path).to match(/.*notifications\/new|.*add_product_name/)
  expect(page).to have_h1("What is the product name?")
end

def expect_back_link_to_what_is_product_called_page
  expect_back_link_to(/\/build\/add_product_name$/)
end

def expect_to_be_on__internal_reference_page
  expect(page.current_path).to end_with("/build/add_internal_reference")
  expect(page).to have_h1("Internal reference")
end

def expect_back_link_to_internal_reference_page
  expect_back_link_to(/\/build\/add_internal_reference$/)
end

def expect_to_be_on__is_product_for_under_threes_page
  expect(page.current_path).to end_with("/for_children_under_three")
  expect(page).to have_h1("Is the product intended to be used on children under 3 years old?")
end

def expect_back_link_to_is_product_for_under_threes_page
  expect_back_link_to(/\/build\/for_children_under_three$/)
end

def expect_to_be_on__multi_item_kits_page
  expect(page.current_path).to end_with("/build/single_or_multi_component")
  expect(page).to have_h1("Multi-item kits")
end

def expect_back_link_to_multi_item_kits_page
  expect_back_link_to(/\/build\/single_or_multi_component$/)
end

def expect_to_be_on__kit_items_page
  expect(page.current_path).to end_with("/build/add_new_component")
  expect(page).to have_h1("Kit items")
end

def expect_back_link_to_kit_items_page
  expect_back_link_to(/\/build\/add_new_component$/)
end

def expect_to_be_on__what_is_item_called_page
  expect(page.current_path).to end_with("/build/add_component_name")
  expect(page).to have_h1("What is the item name?")
end

def expect_back_link_to_what_is_item_called_page
  expect_back_link_to(/\/build\/add_component_name$/)
end

def expect_to_be_on__is_item_available_in_shades_page(item_name: nil)
  expect(page.current_path).to end_with("/build/number_of_shades")
  expected_title = "Is #{item_name || 'the product'} available in different shades?"
  expect(page).to have_h1(expected_title)
end

def expect_back_link_to_is_item_available_in_shades_page
  expect_back_link_to(/\/build\/number_of_shades$/)
end

def expect_to_be_on__physical_form_of_item_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_physical_form")
  expect(page).to have_h1("What is the physical form of #{item_name || 'the product'}?")
end

def expect_back_link_to_add_shades_page
  expect_back_link_to(/\/build\/add_shades$/)
end

def expect_back_link_to_number_of_shades_page
  expect_back_link_to(/\/build\/number_of_shades$/)
end

def expect_back_link_to_add_ingredient_exact_concentration_page
  expect_back_link_to(/\/build\/add_ingredient_exact_concentration$/)
end

def expect_back_link_to_add_ingredient_range_concentration_page
  expect_back_link_to(/\/build\/add_ingredient_range_concentration$/)
end

def expect_back_link_to_physical_form_of_item_page
  expect_back_link_to(/\/build\/add_physical_form$/)
end

def expect_to_be_on__what_is_product_contained_in_page(item_name: nil)
  expect(page.current_path).to end_with("/contains_special_applicator")
  expect(page).to have_h1("What is #{item_name || 'the product'} contained in?")
end

def expect_back_link_to_what_is_product_contained_in_page
  expect_back_link_to(/\/build\/contains_special_applicator$/)
end

def expect_to_be_on__what_type_of_applicator_page
  expect(page.current_path).to end_with("/select_special_applicator_type")
  expect(page).to have_h1("What type of applicator?")
end

def expect_back_link_to_what_type_of_applicator_page
  expect_back_link_to(/\/build\/select_special_applicator_type$/)
end

def expect_to_be_on__does_item_contain_cmrs_page
  expect(page.current_path).to end_with("/build/contains_cmrs")
  expect(page).to have_h1("Carcinogenic, mutagenic or reprotoxic substances")
end

def expect_back_link_to_does_item_contain_cmrs_page
  expect_back_link_to(/\/build\/contains_cmrs$/)
end

def expect_back_link_to_add_cmrs_page
  expect_back_link_to(/\/build\/add_cmrs$/)
end

def expect_to_be_on__does_item_contain_nanomaterial_page
  expect(page.current_path).to end_with("/build/contains_nanomaterials")
  expect(page).to have_h1("Nanomaterials")
end

def expect_back_link_to_does_item_contain_nanomaterial_page
  expect_back_link_to(/\/build\/contains_nanomaterials$/)
end

def expect_to_be_on__is_item_intended_to_be_rinsed_off_or_left_on_page(item_name: nil)
  expect(page.current_path).to end_with("/build/add_exposure_condition")
  expect(page).to have_h1("Is #{item_name || 'the product'} intended to be rinsed off or left on?")
end

def expect_back_link_to_is_item_intended_to_be_rinsed_off_or_left_on_page
  expect_back_link_to(/\/build\/add_exposure_condition$/)
end

def expect_to_be_on__how_is_user_exposed_to_nanomaterials_page
  expect(page.current_path).to end_with("/build/add_exposure_routes")
  expect(page).to have_h1("How is the user likely to be exposed to the nanomaterials?")
end

def expect_back_link_to_how_is_user_exposed_to_nanomaterials_page
  expect_back_link_to(/\/build\/add_exposure_routes$/)
end

def expect_to_be_on__list_the_nanomaterials_page(item_name: nil)
  expect(page.current_path).to end_with("/build/list_nanomaterials")
  expect(page).to have_h1("List the nanomaterials in #{item_name || 'the product'}")
end

def expect_back_link_to_list_the_nanomaterials_page
  expect_back_link_to(/\/build\/list_nanomaterials$/)
end

def expect_to_be_on__what_is_the_purpose_of_nanomaterial_page
  expect(page.current_path).to end_with("/build/select_purposes")
  expect(page).to have_h1("What is the purpose of this nanomaterial?")
end

def expect_back_link_to_what_is_the_purpose_of_nanomaterial_page
  expect_back_link_to(/\/build\/select_purposes$/)
end

def expect_to_be_on__what_is_the_nanomaterial_inci_name_page
  expect(page.current_path).to end_with("/build/add_nanomaterial_name")
  expect(page).to have_h1("What is the nanomaterial INCI name?")
end

def expect_back_link_to_what_is_the_nanomaterial_inci_name_page
  expect_back_link_to(/\/build\/add_nanomaterial_name$/)
end

def expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_restrictions")
  expect(page).to have_h1("Is #{nanomaterial_name} listed in EC regulation 1223/2009, Annexes 4 and 5?")
end

def expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page
  expect_back_link_to(/\/build\/confirm_restrictions$/)
end

def expect_to_be_on__does_nanomaterial_conform_to_restrictions_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/confirm_usage")
  expect(page).to have_h1("Does the #{nanomaterial_name} conform to the restrictions set out in Annexes 4 and 5?")
end

def expect_back_link_to_does_nanomaterial_conform_to_restrictions_page
  expect_back_link_to(/\/build\/confirm_usage$/)
end

def expect_to_be_on__have_you_submitted_a_notification_page
  expect(page.current_path).to end_with("/build/non_standard_nanomaterial_notified")
  expect(page).to have_h1("Have you submitted a notification about this nanomaterial in GB since 1 January 2021?")
end

def expect_back_link_to_have_you_submitted_a_notification_page
  expect_back_link_to(/\/build\/non_standard_nanomaterial_notified$/)
end

def expect_to_be_on__when_products_containing_nanomaterial_can_be_placed_page
  expect(page.current_path).to end_with("/build/when_products_containing_nanomaterial_can_be_placed_on_market")
  expect(page).to have_h1("When can you place products containing this nanomaterial on the market?")
end

def expect_back_link_to_when_products_containing_nanomaterial_can_be_placed_page
  expect_back_link_to(/\/build\/when_products_containing_nanomaterial_can_be_placed_on_market$/)
end

def expect_to_be_on__select_notified_nanomaterial_page
  expect(page.current_path).to end_with("/build/select_notified_nanomaterial")
  expect(page).to have_h1("Select a notified nanomaterial")
end

def expect_back_link_to_select_notified_nanomaterial_page
  expect_back_link_to(/\/build\/select_notified_nanomaterial$/)
end

def expect_to_be_on__cannot_place_until_review_period_ended_page
  expect(page.current_path).to end_with("/build/cannot_place_until_review_period_ended")
  expect(page).to have_h1("You cannot place this cosmetic onto the GB market until the 6 month review period has ended")
end

def expect_to_be_on__must_notify_your_nanomaterial
  expect(page.current_path).to end_with("/build/notify_your_nanomaterial")
  expect(page).to have_h1("You cannot notify this product until you have notified the nanomaterial you want to use")
end

def expect_to_be_on__must_be_listed_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/must_be_listed")
  expect(page).to have_h1("You cannot notify products containing #{nanomaterial_name}")
end

def expect_to_be_on__must_conform_to_restrictions_page(nanomaterial_name:)
  expect(page.current_path).to end_with("/build/must_conform_to_restrictions")
  expect(page).to have_h1("You cannot notify products containing #{nanomaterial_name}")
end

def expect_to_be_on__item_category_page
  expect(page.current_path).to end_with("/build/select_category")
  expect(page).to have_h1("What category of cosmetic product is it?")
end

def expect_back_link_to_item_category_page(category = nil)
  if category
    expect_back_link_to(/\/build\/select_category\?category=#{category}/)
  else
    expect_back_link_to(/\/build\/select_category/)
  end
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

def expect_back_link_to_formulation_method_page
  expect_back_link_to(/\/build\/select_formulation_type$/)
end

def expect_to_be_on__poisonous_ingredients_page
  expect(page.current_path).to end_with("/contains_poisonous_ingredients")
  expect(page).to have_h1("Ingredients the National Poisons Information Service needs to know about")
end

def expect_back_link_to_poisonous_ingredients_page
  expect_back_link_to(/\/build\/contains_poisonous_ingredients$/)
end

def expect_to_be_on_what_is_ph_range_of_product_page
  expect(page.current_path).to end_with("/build/select_ph_option")
  expect(page).to have_h1("What is the pH range of the product?")
end

def expect_back_link_to_what_is_ph_range_of_product_page
  expect_back_link_to(/\/trigger_question\/select_ph_range$/)
end

def expect_to_be_on__check_your_answers_page(product_name:)
  expect(page.current_path).to end_with("/edit")
  expect(page).to have_h1("Draft notification for: #{product_name}")
end

def expect_back_link_to_check_your_answers_page
  expect_back_link_to(/\/responsible_persons\/#{responsible_person.id}\/notifications\/\d+\/edit$/)
end

def expect_to_be_on__how_are_items_used_together_page
  expect(page.current_path).to end_with("/is_mixed")
  expect(page).to have_h1("Does the kit contain items that need to be mixed?")
end

def expect_back_link_to_how_are_items_used_together_page
  expect_back_link_to(/is_mixed$/)
end

def expect_to_be_on_upload_product_label_page
  expect(page.current_path).to end_with("/add_product_image")
  expect(page).to have_h1("Upload an image of the product label")
end

def expect_back_link_to_upload_product_label_page
  expect_back_link_to(/\/build\/add_product_image$/)
end

def expect_to_be_on_upload_item_label_page
  expect(page.current_path).to end_with("/add_product_image")
  expect(page).to have_h1("Upload images of the item labels")
end

def expect_back_link_to_upload_item_label_page
  expect_back_link_to_upload_product_label_page
end

def expect_to_be_on__your_cosmetic_products_page
  expect(page.current_path).to end_with("/responsible_persons/#{responsible_person.id}/notifications")
  expect(page).to have_h1("Product notifications")
end

def expect_to_see_message(message)
  expect(page).to have_text(message)
end

def expect_to_be_on__frame_formulation_select_page
  expect(page.current_path).to end_with("/build/select_frame_formulation")
  expect(page).to have_h1("Choose frame formulation")
end

def expect_back_link_to_frame_formulation_select_page
  expect_back_link_to(/\/build\/select_frame_formulation$/)
end

def expect_to_see_incomplete_notification_with_reference_number(reference_number)
  within("#incomplete-notifications") do
    expect(page).to have_text(reference_number)
  end
end

def expect_to_see_notification_error(error_message)
  within("#upload-errors") do
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

def expect_form_to_have_errors(errors)
  expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
  errors.each do |attribute, error|
    expect(page).to have_link(error[:message], href: "##{error[:href] || attribute}")
    expect(page).to have_css("p##{error[:id]}-error", text: error[:message])
  end
end

# ---- Page interactions ----

def answer_does_item_contain_nanomaterials_with(answer, item_name: nil)
  within_fieldset("Does #{item_name || 'the product'} contain nanomaterials?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def answer_nanomaterial_names_with(nanomaterial_names)
  if nanomaterial_names.is_a?(String)
    # TODO: replace with label once these are unambiguous
    fill_in "nano_material_attributes_0_inci_name", with: nanomaterial_names
  end

  click_button "Continue"
end

def give_frame_formulation_as(frame_formulation_name)
  page.select(frame_formulation_name, from: "Frame formulation name")
  click_button "Continue"
end

def answer_does_product_contain_poisonous_ingredients_with(answer)
  within_fieldset("Does the product contain any ingredients NPIS needs to know about?") do
    page.choose(answer)
  end
  click_button "Continue"
end

def add_an_item
  click_button "Add an item"
end

def select_options_to_create_rp_account
  click_on "Continue"
  expect(page).to have_h1("Has your Responsible Person account already been set up?")
  choose "No, I need to create an account"
  click_on "Continue"
  expect(page).to have_h1("Add a Responsible Person")
end

def fill_in_rp_details(name:)
  fill_in "Name", with: name
  fill_in "Building and street", with: "Auto-test-address1", id: "address_line_1"
  fill_in "Town or city", with: "Auto-test city"
  fill_in "County", with: "auto-test-county"
  fill_in "Postcode", with: "b28 9un"
  click_on "Save and continue"
end

def fill_in_rp_business_details(name: "Auto-test rpuser")
  choose "Limited company or Limited Liability Partnership (LLP)"
  fill_in_rp_details(name:)
end

def fill_in_rp_sole_trader_details(name: "Auto-test rpuser")
  choose "Individual or sole trader"
  fill_in_rp_details(name:)
end

def fill_in_rp_contact_details
  expect(page).to have_h1(/Contact person for/)
  fill_in "Full name", with: "Auto-test contact person"
  fill_in "Email", with: "auto-test@foo"
  fill_in "Telephone", with: "wowowow"
  click_on "Continue"
  expect(page).to have_text("Enter an email in the correct format")
  expect(page).to have_text("Enter a valid telephone, like 0344 411 1444 or +44 7700 900 982")
  fill_in "Full name", with: "Auto-test contact person"
  fill_in "Email", with: "auto-test@exaple.com"
  fill_in "Telephone", with: "07984563072"
  click_on "Continue"
end
