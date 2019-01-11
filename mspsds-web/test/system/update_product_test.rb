require "application_system_test_case"

class UpdateProductTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
    sign_in_as_user
  end

  teardown do
    logout
  end

  test "edit page fields should be populated with product attributes" do
    visit edit_product_path(@product)

    assert_field with: @product.name
    assert_field with: @product.brand
    assert_field with: @product.model

    assert_field with: @product.product_code
    assert_field with: @product.batch_number
    assert_field with: @product.webpage
    assert_field with: @product.description

    assert_field with: @product.date_placed_on_market.day
    assert_field with: @product.date_placed_on_market.month
    assert_field with: @product.date_placed_on_market.year
  end

  test "should update product attributes" do
    updated_product = Product.new(
      name: "Updated product name",
      product_type: "White Goods type",
      category: "White Goods",
      description: "Updated description",
      country_of_origin: "United States",
      date_placed_on_market: Date.new(2018, 10, 15)
    )

    visit edit_product_path(@product)
    fill_in_product_details(updated_product)
    click_on "Save product"

    assert_current_path(/products\/\d+/)
    assert_text updated_product.name
    assert_text updated_product.description
    assert_text updated_product.product_type
    assert_text updated_product.category
    assert_text updated_product.country_of_origin
    assert_text updated_product.date_placed_on_market.strftime("%d/%m/%Y")
  end

  test "should create new product" do
    visit new_product_path
    fill_in_product_details(@product)
    click_on "Save product"

    assert_current_path(/products\/\d+/)

    assert_text @product.name
    assert_text @product.brand
    assert_text @product.model
    assert_text @product.product_code
    assert_text @product.batch_number
    assert_text @product.product_type
    assert_text @product.category
    assert_text @product.webpage
    assert_text @product.description
    assert_text @product.country_of_origin
    assert_text @product.date_placed_on_market.strftime("%d/%m/%Y")
  end

  def fill_in_product_details(product)
    fill_in "product[name]", with: product.name
    fill_in "product[brand]", with: product.brand
    fill_in "product[model]", with: product.model
    fill_in "product[product_code]", with: product.product_code
    fill_in "product[batch_number]", with: product.batch_number
    fill_in "product[webpage]", with: product.webpage
    fill_in "product[description]", with: product.description
    fill_in "product[day]", with: product.date_placed_on_market.day
    fill_in "product[month]", with: product.date_placed_on_market.month
    fill_in "product[year]", with: product.date_placed_on_market.year
    fill_autocomplete "product-type-picker", with: product.product_type
    fill_autocomplete "location-autocomplete", with: product.country_of_origin
  end
end
