require "rails_helper"

RSpec.describe "Adding ingredients to components using a CSV file", :with_stubbed_antivirus, type: :feature do
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

  scenario "Adding exact concentration ingredients to a product using a CSV file" do
    answer_how_do_you_want_to_give_formulation_with "Provide ingredients and their exact concentration using a CSV file"
    expect_to_be_on_add_csv_ingredients_page

    # First attempt with validation errors
    click_on "Continue"

    expect_to_be_on_add_csv_ingredients_page
    expect_form_to_have_errors(file: { message: "The selected file must be a CSV file", id: "file", href: "responsible_persons_notifications_components_bulk_ingredient_upload_form_file" })

    page.attach_file "spec/fixtures/files/Exact_ingredients_duplicate_row.csv"
    click_on "Continue"

    expect_form_to_have_errors(file: { message: "The file could not be uploaded because of error in line 4: Ingredient name already exists in this CSV file", id: "file", href: "responsible_persons_notifications_components_bulk_ingredient_upload_form_file" })

    page.attach_file "spec/fixtures/files/Exact_ingredients.csv"
    click_on "Continue"

    # TODO: Change success banner
    # expect_success_banner_with_text "The ingredients were successfully added to the product."
    click_on "Continue"

    expect_to_be_on__what_is_ph_range_of_product_page

    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"
    expect_task_has_been_completed_page

    return_to_tasks_list_page

    click_link "Accept and submit"

    expect(page).to have_css("dt", text: "Sodium")
    expect(page).to have_css("dt", text: "Aqua")
    expect(page).to have_css("dt", text: "ethanol")
  end
end