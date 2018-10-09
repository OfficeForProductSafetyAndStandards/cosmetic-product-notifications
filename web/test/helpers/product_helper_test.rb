require "test_helper"
require "rspec/mocks/standalone"

class ProductHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include ProductsHelper

  setup do
    Product.import refresh: true
  end

  test "product search matches by name (fuzzy)" do
    # Act
    search_model = Product.new name: "iphon"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, products(:iphone))
    assert_includes(results, products(:iphone_3g))
    assert_not_includes(results, products(:pixel))
    assert_not_includes(results, products(:chromecast))
  end

  test "product search matches by product type (fuzzy)" do
    # Act
    search_model = Product.new product_type: "phoRne"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, products(:iphone))
    assert_includes(results, products(:iphone_3g))
    assert_includes(results, products(:pixel))
    assert_not_includes(results, products(:chromecast))
  end

  test "product search matches by brand (fuzzy)" do
    # Act
    search_model = Product.new brand: "oogle"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, products(:pixel))
    assert_includes(results, products(:chromecast))
    assert_not_includes(results, products(:iphone))
    assert_not_includes(results, products(:iphone_3g))
  end

  test "product search matches if at least one field matches, prioritising higher scores" do
    # Act
    search_model = Product.new brand: "google", name: "chromecast"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, products(:chromecast))
    assert_includes(results, products(:pixel))
    results.find_index(products(:chromecast)) < results.find_index(products(:pixel))
  end

  test "product search doesn't match between fields" do
    # Act
    search_model = Product.new brand: "iphone"
    results = advanced_product_search(search_model)

    # Assert
    assert_not_includes(results, products(:iphone))
    assert_not_includes(results, products(:iphone_3g))
  end

  test "product search excludes specified ids" do
    # Act
    search_model = Product.new brand: "google"
    results = advanced_product_search(search_model, [products(:pixel).id])

    # Assert
    assert_not_includes(results, products(:pixel))
    assert_includes(results, products(:chromecast))
  end
end
