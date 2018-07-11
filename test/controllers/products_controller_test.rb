require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    @product = products(:one)
    Product.import
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: {
        batch_number: @product.batch_number,
        brand: @product.brand,
        description: @product.description,
        gtin: @product.gtin,
        model: @product.model,
        mpn: @product.mpn,
        name: @product.name,
        purchase_url: @product.purchase_url
      } }
    end

    assert_redirected_to product_url(Product.first)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: {
      batch_number: @product.batch_number,
      brand: @product.brand,
      description: @product.description,
      gtin: @product.gtin,
      model: @product.model,
      mpn: @product.mpn,
      name: @product.name,
      purchase_url: @product.purchase_url,
    } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
