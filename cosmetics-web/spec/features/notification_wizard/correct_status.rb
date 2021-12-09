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

    complete_product_wizard(name: "Product no nano two items", items_count: 2, nano_materials_count: 2)

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

    complete_multi_item_kit_wizard

    expect_multi_item_kit_task_completed

    click_link "Add another nanomaterial"
    complete_nano_material_wizard("Nano three", purposes: ["Preservative"], nano_material_number: 3)

    expect_multi_item_kit_task_completed

    expect_task_not_started "Item #1"
    expect_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_task_completed "Cream one"

    click_link "Add another nanomaterial"
    complete_nano_material_wizard("Nano four", purposes: ["Preservative"], nano_material_number: 4)

    expect_multi_item_kit_task_completed

    expect_task_completed "Cream one"

    expect_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2, nanos: ["Nano two"])

    click_link "Accept and submit"
  end
end
