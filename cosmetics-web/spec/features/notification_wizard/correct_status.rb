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

    click_on"Add another nanomaterial"
    complete_nano_material_wizard("Nano three", purposes: ["Preservative"], from_add: true)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_multi_item_kit_task_completed

    click_on"Add another nanomaterial"

    complete_nano_material_wizard("Nano four", purposes: ["Preservative"], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_task_completed "Cream one"

    click_on"Add another nanomaterial"
    complete_nano_material_wizard("Nano five", purposes: ["Preservative"], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream two", item_number: 2, nanos: ["Nano two"])

    expect_accept_and_submit_not_started

    click_on"Add another nanomaterial"

    complete_nano_material_wizard("Nano six", purposes: ["Preservative"], from_add: true)

    expect_accept_and_submit_not_started

    # TODO: in future, newly created nano will have to be added to item

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product with nano and two items notification submitted"
  end

  scenario "Checking correct status - when updating nano after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items", nano_materials_count: 1)

    expect_progress(1,4)

    expect_product_details_task_blocked

    complete_nano_material_wizard("Nano one", purposes: ["Preservative"], nano_material_number: 1)

    expect_progress(2,4)

    complete_product_details(nanos: ["Nano one"])

    expect_progress(3,4)

    expect_product_details_task_completed

    click_on"Add another nanomaterial"

    complete_nano_material_wizard("Nano two", purposes: ["Preservative"], from_add: true)

    # TODO: in future, newly created nano will have to be added to item

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product no nano no items notification submitted"
  end

  scenario "Checking correct status - when adding first nano after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1,3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2,3)

    expect_product_details_task_completed

    complete_product_wizard(name: "Product no nano no items", nano_materials_count: 1)

    expect_progress(1,4)

    expect_product_details_task_blocked

    complete_nano_material_wizard("Nano one", purposes: ["Preservative"], nano_material_number: 1)

    expect_product_details_task_completed

    expect_progress(3,4)

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product no nano no items notification submitted"
  end

  scenario "Checking correct status - when adding extra item after single item product completed" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1,3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2,3)

    expect_product_details_task_completed

    complete_product_wizard(name: "Product no nano no items", items_count: 2)

    expect_progress(1,4)

    expect_multi_item_kit_task_not_started

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_multi_item_kit_wizard

    expect_progress(2,4)

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1)

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2)

    expect_progress(3,4)

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product no nano no items notification submitted"
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

    click_on"Add another item"

    click_on "Back"

    expect_item_task_not_started "Item #3"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream three", item_number: 3)

    expect_accept_and_submit_not_started

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product no nano two items notification submitted"
  end

  scenario "Checking correct status - when adding items after adding nanos" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Some product")

    expect_progress(1,3)

    expect_product_details_task_not_started

    complete_product_details

    expect_progress(2,3)

    expect_product_details_task_completed

    expect_accept_and_submit_not_started

    complete_product_wizard(name: "Some product", nano_materials_count: 1)

    expect_progress(1,4)

    expect_task_not_started "Nanomaterial #1"

    expect_product_details_task_blocked

    expect_accept_and_submit_blocked

    complete_nano_material_wizard("Nano one", purposes: ["Preservative"], nano_material_number: 1)

    expect_progress(3,4)

    expect_product_details_task_completed

    expect_accept_and_submit_not_started

    complete_product_wizard(name: "Some product", items_count: 2, continue_on_nano: true)

    expect_progress(2,5)

    expect_multi_item_kit_task_not_started

    expect_accept_and_submit_blocked

    expect_task_blocked "Item #1"

    expect_task_blocked "Item #2"

    complete_multi_item_kit_wizard

    expect_progress(3,5)

    expect_accept_and_submit_blocked

    expect_item_task_not_started "Item #1"

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_accept_and_submit_blocked

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2, nanos: [nil])

    expect_progress(4,5)

    expect_accept_and_submit_not_started

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Some product"
  end

  scenario "Checking correct status - when adding items after interrupted nano wizard" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product with nano and two items", items_count: 2, nano_materials_count: 2)

    expect_progress(1,5)

    expect_task_not_started "Nanomaterial #1"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano one", nano_material_number: 1)

    expect_progress(1,5)

    expect_task_completed "Nano one"
    expect_task_not_started "Nanomaterial #2"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano two", nano_material_number: 2)

    expect_progress(2,5)

    expect_multi_item_kit_task_not_started

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    click_on "Add another nanomaterial"
    complete_nano_material_wizard("Nano three", purposes: ["Preservative"], from_add: true)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_multi_item_kit_task_completed

    click_on"Add another nanomaterial"
    click_link 'Back'

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Item #1"
    expect_task_blocked "Item #2"

    complete_nano_material_wizard("Nano four", purposes: ["Preservative"], nano_material_number: 4)

    expect_multi_item_kit_task_completed

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_task_completed "Cream one"

    click_on"Add another nanomaterial"
    complete_nano_material_wizard("Nano five", purposes: ["Preservative"], from_add: true)

    expect_multi_item_kit_task_completed

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    expect_accept_and_submit_blocked

    complete_item_wizard("Cream two", item_number: 2, nanos: ["Nano two"])

    click_on "Add another item"
    complete_item_wizard("Cream three", item_number: 3, nanos: ["Nano three"], from_add: true)

    expect_accept_and_submit_not_started

    click_on "Add another nanomaterial"

    complete_nano_material_wizard("Nano six", purposes: ["Preservative"], from_add: true)

    expect_accept_and_submit_not_started

    # TODO: in future, newly created nano will have to be added to item

    click_link "Accept and submit"

    click_button "Accept and submit"

    expect_to_be_on__your_cosmetic_products_page
    expect_to_see_message "Product with nano and two items notification submitted"
  end
end
