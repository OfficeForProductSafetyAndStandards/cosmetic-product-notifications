require "test_helper"
require "rspec/mocks/standalone"

class ProductHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include ProductsHelper

  setup do
    @iphone = products(:iphone)
    @iphone_3g = products(:iphone_3g)
    @pixel = products(:pixel)
    @chromecast = products(:chromecast)
  end

  test "product search matches by name (fuzzy)" do
    # Act
    search_model = Product.new name: "iphon"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, @iphone)
    assert_includes(results, @iphone_3g)
    assert_not_includes(results, @pixel)
    assert_not_includes(results, @chromecast)
  end

  test "product search matches by product type (fuzzy)" do
    # Act
    search_model = Product.new product_type: "phoRne"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, @iphone)
    assert_includes(results, @iphone_3g)
    assert_includes(results, @pixel)
    assert_not_includes(results, @chromecast)
  end

  test "product search matches by brand (fuzzy)" do
    # Act
    search_model = Product.new brand: "oogle"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, @pixel)
    assert_includes(results, @chromecast)
    assert_not_includes(results, @iphone)
    assert_not_includes(results, @iphone_3g)
  end

  test "product search matches if at least one field matches, prioritising higher scores" do
    # Act
    search_model = Product.new brand: "google", name: "chromecast"
    results = advanced_product_search(search_model)

    # Assert
    assert_includes(results, @chromecast)
    assert_includes(results, @pixel)
    results.find_index(@chromecast) < results.find_index(@pixel)
  end

  test "product search doesn't match between fields" do
    # Act
    search_model = Product.new brand: "iphone"
    results = advanced_product_search(search_model)

    # Assert
    assert_not_includes(results, @iphone)
    assert_not_includes(results, @iphone_3g)
  end

  test "product search excludes specified ids" do
    # Act
    search_model = Product.new brand: "google"
    results = advanced_product_search(search_model, [@pixel.id])

    # Assert
    assert_not_includes(results, @pixel)
    assert_includes(results, @chromecast)
  end
end
