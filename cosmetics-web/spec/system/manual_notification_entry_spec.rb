require 'rails_helper'

RSpec.describe "Manually enter product details", type: :system do
  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
    mock_antivirus
  end

  after do
    sign_out
    unmock_antivirus
  end

  it "allows user to complete notification" do
    visit new_notification_path

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # is_imported
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("Yes")
    click_button "Continue"

    # number_of_shades
    choose("No")
    click_button "Continue"

    # add_product_image
    attach_file(
      :image_upload,
      Rails.root + 'spec/fixtures/testImage.png'
)
    click_button "Continue"

    mark_images_as_safe

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "N/A")
    expect_check_your_answers_value("Label image", "testImage.png")
    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_url
    expect(notification.state).to eq("notification_complete")
  end

  it "allows user to complete notification for imported cosmetics" do
    visit new_notification_path

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # is_imported
    choose("Yes")
    click_button "Continue"

    # add_import_country
    fill_autocomplete "location-autocomplete", with: "New Zealand"
    click_button "Continue"

    # single_or_multi_component
    choose("Yes")
    click_button "Continue"

    # number_of_shades
    choose("No")
    click_button "Continue"

    # add_product_image
    attach_file(
      :image_upload,
      Rails.root + 'spec/fixtures/testImage.png'
)
    click_button "Continue"

    mark_images_as_safe

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "Yes")
    expect_check_your_answers_value("Imported from", "New Zealand")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "N/A")
    expect_check_your_answers_value("Label image", "testImage.png")
    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_url
    expect(notification.state).to eq("notification_complete")
  end

  it "allows user to complete notification for cosmetics with multiple shades" do
    visit new_notification_path

    # add_product_name
    fill_in :notification_product_name, with: "Super Shampoo"
    click_button "Continue"

    # is_imported
    choose("No")
    click_button "Continue"

    # single_or_multi_component
    choose("Yes")
    click_button "Continue"

    # number_of_shades
    choose("Yes")
    click_button "Continue"

    # add_shades
    click_button "Add another"
    inputs = find_all(class: 'govuk-input')
    shades = %w[Red Blue Yellow]
    inputs.each_with_index do |input, i|
      input.set shades[i]
    end
    click_button "Continue"

    # add_product_image
    attach_file(
      :image_upload,
      Rails.root + 'spec/fixtures/testImage.png'
)
    click_button "Continue"

    mark_images_as_safe

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "Red, Blue, Yellow")
    expect_check_your_answers_value("Label image", "testImage.png")

    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_url
    expect(notification.state).to eq("notification_complete")
  end

private

  def expect_check_your_answers_value(attribute_name, value)
    row = first('tr', text: attribute_name)
    expect(row).to have_text(value)
  end

  def get_notification_from_url
    if (match = current_url.match(%r!/notifications/(\d+)/!))
      reference_number = match.captures[0].to_i
    end

    Notification.find_by reference_number: reference_number
  end

  # The worker doesn't mark system test images as safe, so we have to do it
  # manually to allow the manual journey to finish.
  def mark_images_as_safe
    notification = get_notification_from_url

    notification.image_uploads.each do |image_upload|
      blob = image_upload.file.blob
      blob.metadata = { safe: true }
      blob.save
    end
  end
end
