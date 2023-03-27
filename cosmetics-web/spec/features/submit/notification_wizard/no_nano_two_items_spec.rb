require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Notification with two items" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano two items", items_count: 2)

    expect_progress(1, 4)

    expect_multi_item_kit_task_not_started

    complete_multi_item_kit_wizard

    expect_progress(2, 4)

    expect_item_task_not_started "Item #1"
    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream one", item_number: 1)

    expect_progress(2, 4)

    expect_item_task_not_started "Item #2"

    complete_item_wizard("Cream two", item_number: 2)

    expect_progress(3, 4)

    click_link "Accept and submit"

    expect_check_your_answers_page_for_kit_items_to_contain(
      product_name: "Product no nano two items",
      number_of_components: "2",
      components_mixed: "No",
      kit_items: [
        {
          name: "Cream one",
          shades: "None",
          nanomaterials: "None",
          category: "Hair and scalp products",
          subcategory: "Hair and scalp care and cleansing products",
          sub_subcategory: "Shampoo",
          formulation_given_as: "Exact concentration",
          ingredients: { "FooBar ingredient" => "0.5% w/w" },
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
        {
          name: "Cream two",
          shades: "None",
          nanomaterials: "None",
          category: "Hair and scalp products",
          subcategory: "Hair and scalp care and cleansing products",
          sub_subcategory: "Shampoo",
          formulation_given_as: "Exact concentration",
          ingredients: { "FooBar ingredient" => "0.5% w/w" },
          physical_form: "Liquid",
          ph: "No pH",
          poisonous_ingredients: "No",
        },
      ],
    )

    click_link "Continue"
    click_button "Accept and submit"

    expect_successful_submission
  end
end
