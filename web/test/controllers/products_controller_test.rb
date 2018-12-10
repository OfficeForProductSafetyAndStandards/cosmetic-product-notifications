require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user
    @product_one = products(:one)
    @product_one.source = sources(:product_one)
    @product_iphone = products(:iphone)
    @product_iphone.source = sources(:product_iphone)

    test_image1 = Rails.root.join('test', 'fixtures', 'files', 'testImage.png')
    test_image2 = Rails.root.join('test', 'fixtures', 'files', 'testImage2.png')
    @product_one.documents.attach(io: File.open(test_image1), filename: 'testImage.png')
    @product_one.documents.attach(io: File.open(test_image2), filename: 'testImage2.png')
  end

  teardown do
    logout
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
        batch_number: @product_one.batch_number,
        brand: @product_one.brand,
        product_type: @product_one.product_type,
        description: @product_one.description,
        gtin: @product_one.gtin,
        model: @product_one.model,
        name: @product_one.name
      } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product_one)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product_one)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product_one), params: { product: {
      batch_number: @product_one.batch_number,
      brand: @product_one.brand,
      product_type: @product_one.product_type,
      description: @product_one.description,
      gtin: @product_one.gtin,
      model: @product_one.model,
      name: @product_one.name
    } }
    assert_redirected_to product_url(@product_one)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product_one)
    end

    assert_redirected_to products_url
  end
end
