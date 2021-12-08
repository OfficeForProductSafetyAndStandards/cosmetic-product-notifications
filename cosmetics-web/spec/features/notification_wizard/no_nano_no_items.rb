require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Manual, exact ingredients, single item, with CMRS, no nanomaterials" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    click_on "Create the product"

    answer_product_name_with "Product no nano no items"

    answer_do_you_want_to_give_an_internal_reference_with "No"

    answer_is_product_for_under_threes_with "No"

    answer_does_product_contains_nanomaterials_with "No"

    answer_is_product_multi_item_kit_with "No, this is a single product"

    upload_product_label

    expect_task_has_been_completed_page

    return_to_tasks_list_page

    expect_product_task_completed

    # 2. Complete product details
    click_on "Product details"

    answer_is_item_available_in_shades_with "No"

    answer_what_is_physical_form_of_item_with "Liquid"

    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package"

    answer_does_item_contain_cmrs_with "No"

    answer_item_category_with "Hair and scalp products"

    answer_item_subcategory_with "Hair and scalp care and cleansing products"

    answer_item_sub_subcategory_with "Shampoo"

    answer_how_do_you_want_to_give_formulation_with "List ingredients and their exact concentration"

    upload_ingredients_pdf

    answer_what_is_ph_range_of_product_with "The minimum pH is 3 or higher, and the maximum pH is 10 or lower"
    expect_task_has_been_completed_page

    return_to_tasks_list_page
    expect_product_details_task_completed

    click_link "Accept and submit"

    expect_check_your_answers_page_to_contain(
      product_name: "Product no nano no items",
      number_of_components: "1",
      shades: "None",
      nanomaterials: "None",
      contains_cmrs: "No",
      category: "Hair and scalp products",
      subcategory: "Hair and scalp care and cleansing products",
      sub_subcategory: "Shampoo",
      formulation_given_as: "Exact concentration",
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )
  end
end
