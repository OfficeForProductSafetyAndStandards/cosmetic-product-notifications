require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user
    @product = products(:one)
    @product.source = sources(:product_one)
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
        product_type: @product.product_type,
        description: @product.description,
        gtin: @product.gtin,
        model: @product.model,
        name: @product.name
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
      product_type: @product.product_type,
      description: @product.description,
      gtin: @product.gtin,
      model: @product.model,
      name: @product.name
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
