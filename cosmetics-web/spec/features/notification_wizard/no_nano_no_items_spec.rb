require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Simple notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product no nano no items")

    expect_progress(1, 3)

    complete_product_details

    expect_progress(2, 3)

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
      ingredients: { "FooBar ingredient" => "0.5% w/w" },
      physical_form: "Liquid",
      ph: "Between 3 and 10",
    )

    click_link "Continue"
    click_button "Accept and submit"

    expect_successful_submission
  end
end
