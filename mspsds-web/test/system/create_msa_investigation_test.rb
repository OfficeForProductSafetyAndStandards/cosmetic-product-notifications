require "application_system_test_case"

class CreateMsaInvestigationTest < ApplicationSystemTestCase
  setup do
    sign_in_as_non_opss_user

    @product = products(:one)
    @investigation = investigations(:one)
  end

  teardown do
    logout
  end

  test "can complete the flow without no busineses, corrective actions, or other files " do
    visit new_msa_investigation_path

    assert_selector "h1", text: "What product are you reporting?"
    fill_in_product_page

    assert_text "Why are you reporting this product?"
    fill_in_why_reporting

    assert_selector "h1", text: "Supply chain information"
    choose_no_businesses

    assert_selector "h1", text: "Has any corrective action been agreed or taken?"
    choose_no_corrective_action

    assert_selector "h1", text: "Other information and files"
    choose_no_other_info

    assert_selector "h1", text: "Find this in your system"
    fill_in_reporter_reference

    click_link "tab_products"

    assert_text @product.name
    assert_text @product.product_code
    assert_text @product.product_type
    assert_text @product.category
    assert_text @product.webpage
    assert_text @product.description
    assert_text @product.country_of_origin
  end

  def fill_in_product_page
    fill_autocomplete "product-category-picker", with: @product.category
    fill_in "Product type", with: @product.product_type
    fill_in "Product name", with: @product.name
    fill_in "product_product_code", with: @product.product_code
    fill_in "Webpage", with: @product.webpage
    fill_autocomplete "location-autocomplete", with: @product.country_of_origin
    fill_in "Description", with: @product.description

    click_button "Continue"
  end

  def fill_in_why_reporting
    page.check :investigation_unsafe, visible: false
    fill_autocomplete "hazard-type-picker", with: @investigation.hazard_type, visible: false
    fill_in "allegation-hazard–detail", with: @investigation.hazard_description, visible: false
    page.check :investigation_non_compliant, visible: false
    fill_in "allegation-compliance-detail", with: @investigation.non_compliant_reason, visible: false

    click_button "Continue"
  end

  def choose_no_businesses
    page.check "businesses_none", visible: false

    click_button "Continue"
  end

  def choose_no_corrective_action
    choose "has_corrective_action_has_action_no", visible: false

    click_button "Continue"
  end

  def choose_no_other_info
    click_button "Continue"
  end

  def fill_in_reporter_reference
    fill_in "investigation_reporter_reference", with: @investigation.reporter_reference
    click_button "Save"
  end
end
