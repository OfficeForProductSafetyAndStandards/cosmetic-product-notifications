require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
    @investigation = investigations(:search_related_products)
    @product = products(:iphone)
    Investigation.import
  end

  teardown do
    logout
  end

  test "should create activities when investigation is created" do
    assert_difference"Activity.count" do
      @investigation = Investigation.create
    end
  end

  test "should create an activity when business is added to investigation" do
    @investigation = Investigation.create
    assert_difference"Activity.count" do
      @business = Business.new(company_name: 'Test Company')
      @investigation.businesses << @business
    end
  end

  test "should create an activity when business is removed from investigation" do
    @investigation = Investigation.create
    @business = Business.new(company_name: 'Test Company')
    @investigation.businesses << @business
    assert_difference"Activity.count" do
      @investigation.businesses.delete(@business)
    end
  end

  test "should create an activity when product is added to investigation" do
    @investigation = Investigation.create
    assert_difference"Activity.count" do
      @product = Product.new(name: 'Test Product')
      @investigation.products << @product
    end
  end

  test "should create an activity when product is removed from investigation" do
    @investigation = Investigation.create
    @product = Product.new(name: 'Test Product')
    @investigation.products << @product
    assert_difference"Activity.count" do
      @investigation.products.delete(@product)
    end
  end

  test "should create an activity when status is updated on investigation" do
    @investigation = Investigation.create
    assert_difference "Activity.count" do
      @investigation.is_closed = !@investigation.is_closed
      @investigation.save
    end
  end

  test "elasticsearch should find product gtin" do
    query = ElasticsearchQuery.new(@product.gtin, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should find product name" do
    query = ElasticsearchQuery.new(@product.name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should find product batch" do
    query = ElasticsearchQuery.new(@product.batch_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should find product brand" do
    query = ElasticsearchQuery.new(@product.brand, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should find product description" do
    query = ElasticsearchQuery.new(@product.description, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should find product model" do
    query = ElasticsearchQuery.new(@product.model, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end

  test "elasticsearch should not find product country" do
    query = ElasticsearchQuery.new(@product.country_of_origin, {}, {})
    assert_not_includes(Investigation.full_search(query).records.map(&:id), @investigation.id)
  end
end
