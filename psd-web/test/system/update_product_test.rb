require "application_system_test_case"

class UpdateProductTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
    mock_out_keycloak_and_notify
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "edit page fields should be populated with product attributes" do
    visit edit_product_path(@product)

    assert_field "product[name]", with: @product.name
    assert_field "product[product_code]", with: @product.product_code
    assert_field "product[batch_number]", with: @product.batch_number
    assert_field "product[webpage]", with: @product.webpage
    assert_field "product[description]", with: @product.description
    assert_field "product_category", with: @product.category
    assert_field "product[product_type]", with: @product.product_type
  end

  test "should update product attributes" do
    updated_product = Product.new(
      name: "Updated product name",
      product_type: "White Goods type",
      category: "White Goods",
      description: "Updated description",
      country_of_origin: "United States"
    )

    visit edit_product_path(@product)
    fill_in_product_details(updated_product)
    click_on "Save product"

    assert_current_path(/products\/\d+/)
    assert_text updated_product.name
    assert_text updated_product.description
    assert_text updated_product.product_type
    assert_text updated_product.category
    assert_text updated_product.country_of_origin_for_display
  end

  def fill_in_product_details(product)
    fill_in "product[name]", with: product.name
    fill_in "product[product_code]", with: product.product_code
    fill_in "product[batch_number]", with: product.batch_number
    fill_in "product[product_type]", with: product.product_type
    fill_in "product[webpage]", with: product.webpage
    fill_in "product[description]", with: product.description
    fill_in "product[batch_number]", with: product.batch_number
    fill_autocomplete "location-autocomplete", with: product.country_of_origin
    fill_autocomplete "product_category", with: product.category
  end
end
