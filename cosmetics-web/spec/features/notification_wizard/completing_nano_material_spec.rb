require "rails_helper"

RSpec.describe "Submit notifications", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.responsible_person_users.first.user }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  scenario "Completing a standard nanomaterial for a product notification" do
    visit "/responsible_persons/#{responsible_person.id}/notifications"

    click_on "Add a cosmetic product"

    complete_product_wizard(name: "Product one nano one item", items_count: 1, nano_materials_count: 1)
    expect_progress(1, 4)

    click_on "Nanomaterial #1"
    expect_to_be_on__what_is_the_purpose_of_nanomaterial_page
    click_button "Continue"
    expect_form_to_have_errors(purposes_form_purpose_type_standard: { message: "Select the purpose of this nanomaterial",
                                                                      id: "purposes_form_purpose_type" })

    page.choose "Colourant, Preservative or UV filter"
    click_button "Continue"
    expect_form_to_have_errors(purposes_form_colorant: { message: "Select the purpose", id: "purposes_form_purposes" })

    page.check("Colourant")
    page.check("Preservative")
    click_button "Continue"
    expect_to_be_on__what_is_the_nanomaterial_inci_name_page
    expect_back_link_to_what_is_the_purpose_of_nanomaterial_page

    click_button "Save and continue"
    expect_form_to_have_errors(nano_material_inci_name: { message: "Enter a name", id: "nano_material_inci_name" })

    answer_inci_name_with "Nano material one"
    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page(nanomaterial_name: "Nano material one")
    expect_back_link_to_what_is_the_purpose_of_nanomaterial_page

    click_button "Continue"
    expect_form_to_have_errors(nano_material_confirm_restrictions_yes: { message: "Select an option",
                                                                         id: "nano_material_confirm_restrictions" })
    page.choose "No"
    click_button "Continue"
    expect_to_be_on__must_be_listed_page(nanomaterial_name: "Nano material one")
    expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page

    click_link "Back"
    expect_to_be_on__is_nanomaterial_listed_in_ec_regulation_page(nanomaterial_name: "Nano material one")

    page.choose "Yes"
    click_button "Continue"
    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page(nanomaterial_name: "Nano material one")
    expect_back_link_to_is_nanomaterial_listed_in_ec_regulation_page

    click_button "Continue"
    expect_form_to_have_errors(nano_material_confirm_usage_yes: { message: "Select an option",
                                                                  id: "nano_material_confirm_usage" })

    page.choose "No"
    click_button "Continue"
    expect_to_be_on__must_conform_to_restrictions_page(nanomaterial_name: "Nano material one")
    expect_back_link_to_does_nanomaterial_conform_to_restrictions_page

    click_link "Back"
    expect_to_be_on__does_nanomaterial_conform_to_restrictions_page(nanomaterial_name: "Nano material one")

    page.choose "Yes"
    click_button "Continue"
    expect_task_has_been_completed_page

    return_to_tasks_list_page
    expect_task_completed "Nano material one"
  end
end
