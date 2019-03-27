require "application_system_test_case"

class BreadcrumbTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    accept_declaration
    @investigation_products = load_case(:search_related_products)
    @product = @investigation_products.products.first
    @investigation_businesses = load_case(:search_related_businesses)
    @business = @investigation_businesses.businesses.first
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "when accessing product page from case page navigation should let you go back to the case" do
    visit investigation_path(@investigation_products)

    click_on "Products"
    click_on "View product"
    assert_text "Back to #{@investigation_products.pretty_description}"
  end

  test "when accessing product page from list page navigation should let you go back to the list" do
    visit product_path(@product)
    assert_text "Products\n#{@product.name}"
  end

  test "when accessing business page from case page navigation should let you go back to the case" do
    visit investigation_path(@investigation_businesses)

    click_on "Businesses"
    click_on "View business"
    assert_text "Back to #{@investigation_businesses.pretty_description}"
  end

  test "when accessing business page from list page navigation should let you go back to the list" do
    visit business_path(@business)
    assert_text "Businesses\n#{@business.trading_name}"
  end
end
