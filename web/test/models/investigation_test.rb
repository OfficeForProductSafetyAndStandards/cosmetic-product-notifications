require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
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

  test "elasticsearch should find exactly batch_number, brand, description, gtin, model, name of a product" do
    assert_includes(Investigation.full_search(search_for_product_gtin).records.map(&:id),
                    investigations(:search_related_products).id)
    assert_includes(Investigation.full_search(search_for_product_name).records.map(&:id),
                    investigations(:search_related_products).id)
    assert_includes(Investigation.full_search(search_for_product_batch).records.map(&:id),
                    investigations(:search_related_products).id)
    assert_includes(Investigation.full_search(search_for_product_brand).records.map(&:id),
                    investigations(:search_related_products).id)
    assert_includes(Investigation.full_search(search_for_product_description).records.map(&:id),
                    investigations(:search_related_products).id)
    assert_includes(Investigation.full_search(search_for_product_model).records.map(&:id),
                    investigations(:search_related_products).id)

    assert_not_includes(Investigation.full_search(search_for_product_country).records.map(&:id),
                    investigations(:search_related_products).id)
  end

  def search_for_product_gtin
    query = products(:iphone).gtin
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_name
    query = products(:iphone).name
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_batch
    query = products(:iphone).batch_number
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_brand
    query = products(:iphone).brand
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_description
    query = products(:iphone).description
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_model
    query = products(:iphone).model
    ElasticsearchQuery.new(query, {}, {})
  end

  def search_for_product_country
    query = products(:iphone).country_of_origin
    ElasticsearchQuery.new(query, {}, {})
  end
end
