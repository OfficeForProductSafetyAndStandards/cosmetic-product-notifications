require 'rails_helper'

RSpec.describe "Manually enter product details", type: :system do
  let(:responsible_person) { create(:responsible_person) }

  before do
    mock_antivirus_api
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
    unmock_antivirus_api
  end

  it "allows user to complete notification" do
    visit new_responsible_person_notification_path(responsible_person)

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # add_internal_reference
    choose("No")
    click_button "Continue"

    # is_imported
    choose("No")
    click_button "Continue"

    # for_children_under_three
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("The cosmetic product is a single item")
    click_button "Continue"

    # number_of_shades
    choose("No")
    click_button "Continue"

    # physical-form
    choose("Foam")
    click_button "Continue"

    # special-applicator
    choose("No")
    click_button "Continue"

    # contains_cmrs
    choose("No")
    click_button "Continue"

    # nano_materials
    choose("No")
    click_button "Continue"

    # select_category
    select_default_category

    # select_formulation_type
    choose("Choose a predefined frame formulation")
    click_button "Continue"

    # select_frame_formulation
    fill_autocomplete "component_frame_formulation", with: "Skin Care Cream, Lotion, Gel"
    click_button "Continue"

    # Contains poisonous ingredients?
    choose "No"
    click_button "Continue"

    # trigger_questions
    skip_trigger_questions

    # add_product_image
    attach_file(:image_upload, Rails.root + 'spec/fixtures/testImage.png')
    click_button "Continue"

    # Check your answers page
    notification = get_notification_from_edit_page_url
    expect_check_your_answer(get_product_table, "Name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("For children under 3", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "None")
    expect_check_your_answers_value("Special applicator", "No")
    expect_check_your_answers_value("Label image", "testImage.png")
    click_button "Accept and submit the cosmetic product notification"

    # Check notification was completed
    expect(notification.reload.state).to eq("notification_complete")
  end

  it "associates responsible person with notification" do
    visit new_responsible_person_notification_path(responsible_person)

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # add_internal_reference
    choose("No")
    click_button "Continue"

    # is_imported
    choose("No")
    click_button "Continue"

    # for_children_under_three
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("The cosmetic product is a single item")
    click_button "Continue"

    # number_of_shades
    choose("No")
    click_button "Continue"

    # physical-form
    choose("Foam")
    click_button "Continue"

    # special-applicator
    choose("No")
    click_button "Continue"

    # contains_cmrs
    choose("No")
    click_button "Continue"

    # nano_materials
    choose("No")
    click_button "Continue"

    # select_category
    select_default_category

    # select_formulation_type
    choose("Choose a predefined frame formulation")
    click_button "Continue"

    # select_frame_formulation
    fill_autocomplete "component_frame_formulation", with: "Skin Care Cream, Lotion, Gel"
    click_button "Continue"

    # Contains poisonous ingredients?
    choose "No"
    click_button "Continue"

    # trigger_questions
    skip_trigger_questions

    # add_product_image
    attach_file(:image_upload, Rails.root + 'spec/fixtures/testImage.png')
    click_button "Continue"

    # Check your answers page
    expect_check_your_answers_value("Name", responsible_person.name)
  end

  it "allows user to complete notification for imported cosmetics" do
    visit new_responsible_person_notification_path(responsible_person)

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # add_internal_reference
    choose("No")
    click_button "Continue"

    # is_imported
    choose("Yes")
    click_button "Continue"

    # add_import_country
    fill_autocomplete "location-autocomplete", with: "New Zealand"
    click_button "Continue"

    # for_children_under_three
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("The cosmetic product is a single item")
    click_button "Continue"

    # number_of_shades
    choose("No")
    click_button "Continue"

    # physical-form
    choose("Foam")
    click_button "Continue"

    # special-applicator
    choose("No")
    click_button "Continue"

    # contains_cmrs
    choose("No")
    click_button "Continue"

    # nano_materials
    choose("No")
    click_button "Continue"

    # select_category
    select_default_category

    # select_formulation_type
    choose("Choose a predefined frame formulation")
    click_button "Continue"

    # select_frame_formulation
    fill_autocomplete "component_frame_formulation", with: "Skin Care Cream, Lotion, Gel"
    click_button "Continue"

    # Contains poisonous ingredients?
    choose "No"
    click_button "Continue"

    # trigger_questions
    skip_trigger_questions

    # add_product_image
    attach_file(:image_upload, Rails.root + 'spec/fixtures/testImage.png')
    click_button "Continue"

    # Check your answers page
    notification = get_notification_from_edit_page_url
    expect_check_your_answer(get_product_table, "Name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "Yes")
    expect_check_your_answers_value("Imported from", "New Zealand")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "None")
    expect_check_your_answers_value("Special applicator", "No")
    expect_check_your_answers_value("Label image", "testImage.png")
    click_button "Accept and submit the cosmetic product notification"

    # Check notification was completed
    expect(notification.reload.state).to eq("notification_complete")
  end

  it "allows user to complete notification for cosmetic with multiple shades" do
    visit new_responsible_person_notification_path(responsible_person)

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # add_internal_reference
    choose("No")
    click_button "Continue"

    # is_imported
    choose("No")
    click_button "Continue"

    # for_children_under_three
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("The cosmetic product is a single item")
    click_button "Continue"

    # number_of_shades
    choose("Yes, the cosmetic product is available in more than 1 shade and all other aspects of the notification are the same")
    click_button "Continue"

    # add_shades
    click_button "Add another"
    inputs = find_all(class: 'govuk-input')
    shades = %w[Red Blue Yellow]
    inputs.each_with_index do |input, i|
      input.set shades[i]
    end
    click_button "Continue"

    # physical-form
    choose("Foam")
    click_button "Continue"

    # special-applicator
    choose("No")
    click_button "Continue"

    # contains_cmrs
    choose("No")
    click_button "Continue"

    # nano_materials
    choose("No")
    click_button "Continue"

    # select_category
    select_default_category

    # select_formulation_type
    choose("Choose a predefined frame formulation")
    click_button "Continue"

    # select_frame_formulation
    fill_autocomplete "component_frame_formulation", with: "Skin Care Cream, Lotion, Gel"
    click_button "Continue"

    # Contains poisonous ingredients?
    choose "No"
    click_button "Continue"

    # trigger_questions
    skip_trigger_questions

    # add_product_image
    attach_file(:image_upload, Rails.root + 'spec/fixtures/testImage.png')
    click_button "Continue"

    # Check your answers page
    notification = get_notification_from_edit_page_url
    expect_check_your_answer(get_product_table, "Name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "RedBlueYellow")
    expect_check_your_answers_value("Special applicator", "No")
    expect_check_your_answers_value("Label image", "testImage.png")

    click_button "Accept and submit the cosmetic product notification"

    # Check notification was completed
    expect(notification.reload.state).to eq("notification_complete")
  end

private

  def expect_check_your_answers_value(attribute_name, value)
    row = find('tr', text: attribute_name, match: :first)
    expect(row).to have_text(value)
  end

  def expect_check_your_answer(table, attribute_name, value)
    row = table.find('tr', text: attribute_name)
    expect(row).to have_text(value)
  end

  def get_product_table
    find("#product-table")
  end

  def get_notification_from_edit_page_url
    if (match = current_url.match(%r!/notifications/(\d+)/edit!))
      reference_number = match.captures[0].to_i
    end

    Notification.find_by reference_number: reference_number
  end

  def select_default_category
    # category
    choose("Skin products")
    click_button "Continue"

    # sub-category
    choose("Skin care products")
    click_button "Continue"

    # sub-sub-category
    choose("Face mask")
    click_button "Continue"
  end

  def skip_trigger_questions
    # select_ph_range
    choose("It does not have a pH")
    click_button "Continue"
  end
end
