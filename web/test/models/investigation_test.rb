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
      create_investigation
    end
  end

  test "should create an activity when business is added to investigation" do
    create_investigation
    assert_difference"Activity.count" do
      create_business
      @investigation.businesses << @business
    end
  end

  test "should create an activity when business is removed from investigation" do
    create_investigation
    create_business
    @investigation.businesses << @business
    assert_difference"Activity.count" do
      @investigation.businesses.delete(@business)
    end
  end

  test "should create an activity when product is added to investigation" do
    create_investigation
    assert_difference"Activity.count" do
      create_product
      @investigation.products << @product
    end
  end

  test "should create an activity when product is removed from investigation" do
    create_investigation
    create_product
    @investigation.products << @product
    assert_difference"Activity.count" do
      @investigation.products.delete(@product)
    end
  end

  def create_investigation
    @investigation = Investigation.create
  end

  def create_business
    @business = Business.new
    @business.company_name = 'TestCompany'
  end

  def create_product
    @product = Product.new
    @product.name = 'TestProduct'
  end
end
