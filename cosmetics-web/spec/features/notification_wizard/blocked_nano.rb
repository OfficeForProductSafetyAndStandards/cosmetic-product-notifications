require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Notification with one nano materials and two items" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product one nano two items", items_count: 2, nano_materials_count: 1)

    expect_progress(1,5)

    complete_nano_material_wizard("Nano one", nano_material_number: 1)

    expect_progress(2,5)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_progress(3,5)

    expect_item_task_not_started "Item #1"
    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1, nanos: ["Nano one"])

    expect_progress(3,5)

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2, nanos: [nil])

    # Perform steps to block nano
    click_on "Nano one"
    click_on "Save and Continue" # Name page
    click_on "Continue" # Purpose page
    answer_is_nanomaterial_listed_in_ec_regulation_with("No", nanomaterial_name: "Nano one")
    click_link "the task list page"

    expect_multi_item_kit_task_blocked

    expect_task_blocked "Cream one"
    expect_task_blocked "Cream two"

    expect_progress(1,5)
  end
end
