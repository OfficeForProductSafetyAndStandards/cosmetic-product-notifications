require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Notification changing from single to multi item" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Create a new product notification"

    complete_product_wizard(name: "Product single to multi item")

    expect_progress(1, 3)

    complete_product_details

    expect_progress(2, 3)

    complete_product_wizard(name: "Product single to multi item", items_count: 3)

    expect_progress(1, 4)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_progress(2, 4)

    complete_item_wizard("Cream one", item_number: 1)

    complete_item_wizard("Cream two", item_number: 2)

    complete_item_wizard("Cream three", item_number: 3)

    expect_progress(3, 4)

    accept_and_submit_flow

    expect_successful_submission
  end
end
