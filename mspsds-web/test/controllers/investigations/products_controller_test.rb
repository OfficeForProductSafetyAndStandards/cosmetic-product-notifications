require "test_helper"

class Investigations::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    mock_out_keycloak_and_notify
    @investigation = investigations(:one)
    @investigation.source = sources(:investigation_one)
    @product = products(:iphone)
    @product.source = sources(:product_iphone)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should get new" do
    get new_investigation_product_url(@investigation)
    assert_response :success
  end

  test "should create and link product" do
    assert_difference ["InvestigationProduct.count", "Product.count"] do
      post investigation_products_url(@investigation), params: {
        product: {
          name: @product.name,
          batch_number: @product.batch_number,
          product_type: @product.product_type,
          category: @product.category,
          webpage: @product.webpage,
          description: @product.description,
          product_code: @product.product_code,
        }
      }
    end
    assert_redirected_to investigation_path(@investigation, anchor: "products")
  end

  test "should not create product if name is missing" do
    assert_no_difference ["InvestigationProduct.count", "Product.count"] do
      post investigation_products_url(@investigation), params: {
        product: {
          name: '',
          batch_number: @product.batch_number,
          product_type: @product.product_type,
          category: @product.category,
          description: @product.description,
          webpage: @product.webpage,
          product_code: @product.product_code
        }
      }
    end
  end

  test "should link product and investigation" do
    assert_difference "InvestigationProduct.count" do
      put link_investigation_product_url(@investigation, @product)
    end
    assert_redirected_to investigation_path(@investigation, anchor: "products")
  end

  test "should unlink product and investigation" do
    @investigation.products << @product
    assert_difference "InvestigationProduct.count", -1 do
      delete unlink_investigation_product_url(@investigation, @product)
    end

    assert_redirected_to investigation_path(@investigation, anchor: "products")
  end
end
