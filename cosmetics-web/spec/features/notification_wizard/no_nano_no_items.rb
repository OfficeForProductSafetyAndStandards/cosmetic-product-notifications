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

    screenshot_and_save_page

    expect_product_task_completed
  end
end
