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
    assert_results_include(results, @iphone)
    assert_results_include(results, @iphone_3g)
    assert_results_do_not_include(results, @pixel)
    assert_results_do_not_include(results, @chromecast)
  end

  test "product search matches by product type (fuzzy)" do
    # Act
    search_model = Product.new product_type: "phoRne"
    results = advanced_product_search(search_model)

    # Assert
    assert_results_include(results, @iphone)
    assert_results_include(results, @iphone_3g)
    assert_results_include(results, @pixel)
    assert_results_do_not_include(results, @chromecast)
  end

  test "product search matches by brand (fuzzy)" do
    # Act
    search_model = Product.new brand: "oogle"
    results = advanced_product_search(search_model)

    # Assert
    assert_results_include(results, @pixel)
    assert_results_include(results, @chromecast)
    assert_results_do_not_include(results, @iphone)
    assert_results_do_not_include(results, @iphone_3g)
  end

  test "product search matches if at least one field matches, prioritising higher scores" do
    # Act
    search_model = Product.new brand: "google", name: "chromecast"
    results = advanced_product_search(search_model)

    # Assert
    assert_results_include(results, @chromecast)
    assert_results_include(results, @pixel)
    results.find_index(@chromecast) < results.find_index(@pixel)
  end

  test "product search doesn't match between fields" do
    # Act
    search_model = Product.new brand: "iphone"
    results = advanced_product_search(search_model)

    # Assert
    assert_results_do_not_include(results, @iphone)
    assert_results_do_not_include(results, @iphone_3g)
  end

  test "product search excludes specified ids" do
    # Act
    search_model = Product.new brand: "google"
    results = advanced_product_search(search_model, [@pixel.id])

    # Assert
    assert_results_do_not_include(results, @pixel)
    assert_results_include(results, @chromecast)
  end

  def assert_results_include(results, product)
    assert_includes(results.map(&:name), product.name)
  end

  def assert_results_do_not_include(results, product)
    assert_not_includes(results.map(&:name), product.name)
  end
end
