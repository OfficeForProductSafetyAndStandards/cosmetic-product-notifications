require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Simple notification cloning" do
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

    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Product no nano no items"
    click_on "Create a draft notification using this notification as a template"

    fill_in "What is the product name?", with: "Product no nano no items copy"
    click_button "Save"

    expect(page).to have_css("h3", text: "You have created the draft notification")
    click_on "task list page"

    click_on "Create the product"
    2.times { click_button "Continue" }
    choose "No" # children under 3
    3.times { click_button "Continue" }
    click_button "Save and continue" # images page
    expect_task_has_been_completed_page
    click_on "task list page"
    expect_progress(1, 3)
    click_on "Product details"
    3.times { click_button "Continue" }
    choose "No" # contains CMRs
    5.times { click_button "Continue" }
    click_button "Save and continue" # ingredient page
    choose "No"
    2.times { click_button "Continue" }

    expect_task_has_been_completed_page
    click_on "task list page"

    expect_progress(2, 3)
    click_link "Accept and submit"

    expect_check_your_answers_page_to_contain(
      product_name: "Product no nano no items copy",
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
