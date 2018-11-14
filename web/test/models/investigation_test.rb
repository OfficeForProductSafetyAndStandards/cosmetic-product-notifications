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
end
