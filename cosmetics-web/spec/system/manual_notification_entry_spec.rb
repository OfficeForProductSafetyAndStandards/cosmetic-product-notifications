require 'rails_helper'

RSpec.describe "Manually enter product details", type: :system do
  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
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

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "N/A")
    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_confirmation_page
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

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "Yes")
    expect_check_your_answers_value("Imported from", "New Zealand")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "N/A")
    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_confirmation_page
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

    # Check your answers page
    expect_check_your_answers_value("Product name", "Super Shampoo")
    expect_check_your_answers_value("Imported", "No")
    expect_check_your_answers_value("Number of components", "1")
    expect_check_your_answers_value("Shades", "Red, Blue, Yellow")

    click_button "Accept and register the cosmetics product"

    # Check notification was completed
    notification = get_notification_from_confirmation_page
    expect(notification.state).to eq("notification_complete")
  end

private

  def expect_check_your_answers_value(attribute_name, value)
    row = first('tr', text: attribute_name)
    expect(row).to have_text(value)
  end

  def get_notification_from_confirmation_page
    if (match = current_url.match(%r!/notifications/(\d+)/confirmation!))
      notification_id = match.captures[0].to_i
    else
      throw "Page URL does not match /notifications/:id/confirmation"
    end

    Notification.find(notification_id)
  end
end
