require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Checking correct status - when updating nano after multi-item kit completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product with nano and two items", items_count: 2, nano_materials_count: 2)

    expect_task_not_started "Nanomaterial #1"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano one", nano_material_number: 1)

    expect_task_completed "Nano one"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano two", nano_material_number: 2)

    expect_multi_item_kit_task_not_started

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    click_on "Add another nanomaterial"
    complete_nano_material_wizard("Nano three", purposes: %w[Preservative], from_add: true)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_multi_item_kit_task_completed

    click_on "Add another nanomaterial"

    complete_nano_material_wizard("Nano four", purposes: %w[Preservative], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_task_completed "Cream one"

    click_on "Add another nanomaterial"
    complete_nano_material_wizard("Nano five", purposes: %w[Preservative], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream two", item_number: 2, nanos: ["Nano two"])

    expect_accept_and_submit_not_started

    click_on "Add another nanomaterial"

    complete_nano_material_wizard("Nano six", purposes: %w[Preservative], from_add: true)

    expect_accept_and_submit_not_started

    complete_item_wizard("Cream one", nanos: ["Nano three", "Nano four", "Nano five", "Nano six"])

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when updating nano after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items", nano_materials_count: 1)

    expect_progress(1, 4)

    expect_product_details_task_blocked

    complete_nano_material_wizard("Nano one", purposes: %w[Preservative], nano_material_number: 1)

    expect_progress(2, 4)

    complete_product_details(nanos: ["Nano one"])

    expect_progress(3, 4)

    expect_product_details_task_completed

    click_on "Add another nanomaterial"

    complete_nano_material_wizard("Nano two", purposes: %w[Preservative], from_add: true)

    click_link "Accept and submit"

    expect(page).to have_css("li", text: "Nano two is not included in any items")

    click_link "Return to the tasks list page"

    complete_product_details(nanos: ["Nano two"])

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when adding first nano after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1, 3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2, 3)

    expect_product_details_task_completed

    complete_product_wizard(name: "Product no nano no items", nano_materials_count: 1)

    expect_progress(1, 4)

    expect_product_details_task_blocked

    complete_nano_material_wizard("Nano one", purposes: %w[Preservative], nano_material_number: 1)

    expect_product_details_task_completed

    complete_product_details(nanos: ["Nano one"])

    expect_progress(3, 4)

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when adding extra item after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1, 3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2, 3)

    expect_product_details_task_completed

    complete_product_wizard(name: "Product no nano no items", items_count: 2)

    expect_progress(1, 4)

    expect_multi_item_kit_task_not_started

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_multi_item_kit_wizard

    expect_progress(2, 4)

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1)

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2)

    expect_progress(3, 4)

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when adding extra item after two items product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano two items", items_count: 2)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_item_task_not_started "Item #1"
    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1)

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2)

    expect_accept_and_submit_not_started

    # Does not create the item until the name is added.
    click_on "Add another item"
    click_on "Back"

    expect(page).to have_current_path(/\/draft/)
    expect(page).not_to have_link("Item #3")
    expect_accept_and_submit_not_started

    click_on "Add another item"
    answer_item_name_with "Cream three"
    click_link "Back"
    expect(page).to have_current_path(/\/add_component_name/)

    click_link "Back"
    expect(page).to have_current_path(/\/draft/)
    expect_item_task_not_started "Cream three"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream three")

    expect_accept_and_submit_not_started

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when changing formulation type in a completed component" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano two items", items_count: 2)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_item_task_not_started "Item #1"
    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, formulation_type: :exact)
    expect_item_task_completed "Cream one"
    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2)
    expect_item_task_completed "Cream two"
    expect_accept_and_submit_not_started

    # Go though the already completed item wizard steps
    name = "Cream one"
    click_on name
    answer_item_name_with(name)
    answer_is_item_available_in_shades_with "No", item_name: name
    answer_what_is_physical_form_of_item_with "Liquid", item_name: name
    answer_what_is_product_contained_in_with "A typical non-pressurised bottle, jar, sachet or other package", item_name: name
    answer_does_item_contain_cmrs_with "No", item_name: name
    answer_item_category_with "Hair and scalp products"
    answer_item_subcategory_with "Hair and scalp care and cleansing products"
    answer_item_sub_subcategory_with "Shampoo"

    # Change the formulation type from exact to range.
    answer_how_do_you_want_to_give_formulation_with "List ingredients and their concentration range", item_name: name

    # Leaves the item wizard without completing it.
    visit "/responsible_persons/#{responsible_person.id}/notifications"
    click_link "Continue"
    expect(page).to have_h1("Product notification draft for: Product no nano two items")
    expect_item_task_completed "Cream two"

    # Now the item status has been moved back and the submission is blocked.
    expect_item_task_not_started "Cream one"
    expect_accept_and_submit_blocked
  end

  scenario "Checking correct status - when adding items after adding nanos" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Some product")

    expect_progress(1, 3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2, 3)

    expect_product_details_task_completed

    expect_accept_and_submit_not_started

    complete_product_wizard(name: "Some product", nano_materials_count: 1)

    expect_progress(1, 4)

    expect_task_not_started "Nanomaterial #1"

    expect_product_details_task_blocked

    expect_accept_and_submit_blocked

    complete_nano_material_wizard("Nano one", purposes: %w[Preservative], nano_material_number: 1)

    expect_progress(3, 4)

    expect_product_details_task_completed

    expect_accept_and_submit_not_started

    complete_product_wizard(name: "Some product", items_count: 2, continue_on_nano: true)

    expect_progress(2, 5)

    expect_multi_item_kit_task_not_started

    expect_accept_and_submit_blocked

    expect_task_blocked "Item #1"

    expect_task_blocked "Item #2"

    complete_multi_item_kit_wizard

    expect_progress(3, 5)

    expect_accept_and_submit_blocked

    expect_item_task_not_started "Item #1"

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_accept_and_submit_blocked

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2, nanos: [nil])

    expect_progress(4, 5)

    expect_accept_and_submit_not_started

    accept_and_submit_flow

    expect_successful_submission
  end

  scenario "Checking correct status - when adding items after interrupted nano wizard" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product with nano and two items", items_count: 2, nano_materials_count: 2)

    expect_progress(1, 5)

    expect_task_not_started "Nanomaterial #1"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano one", nano_material_number: 1)

    expect_progress(1, 5)

    expect_task_completed "Nano one"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano two", nano_material_number: 2)

    expect_progress(2, 5)

    expect_multi_item_kit_task_not_started

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    click_on "Add another nanomaterial"
    complete_nano_material_wizard("Nano three", purposes: %w[Preservative], from_add: true)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_multi_item_kit_task_completed

    # Does not create the nanomaterial until the purposes are choosen.
    click_on "Add another nanomaterial"
    click_link "Back"
    expect(page).to have_current_path(/\/draft/)
    expect(page).not_to have_link "Nanomaterial #4"
    expect_multi_item_kit_task_completed

    click_on "Add another nanomaterial"
    answer_what_is_purpose_of_nanomaterial_with(%w[Preservative])
    click_link "Back"
    expect(page).to have_current_path(/\/select_purposes/)

    click_link "Back"
    expect(page).to have_current_path(/\/draft/)
    expect_task_not_started "Nanomaterial #4"
    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano four", nano_material_number: 4, purposes: %w[Preservative])

    expect_multi_item_kit_task_completed

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_task_completed "Cream one"

    click_on "Add another nanomaterial"
    complete_nano_material_wizard("Nano five", purposes: %w[Preservative], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream two", item_number: 2, nanos: ["Nano two"])

    click_on "Add another item"
    complete_item_wizard("Cream three", item_number: 3, nanos: ["Nano three"], from_add: true)

    expect_accept_and_submit_not_started

    click_on "Add another nanomaterial"

    complete_nano_material_wizard("Nano six", purposes: %w[Preservative], from_add: true)

    expect_accept_and_submit_not_started

    complete_item_wizard("Cream one", nanos: ["Nano four", "Nano five", "Nano six"])

    accept_and_submit_flow

    expect_successful_submission
  end
end
