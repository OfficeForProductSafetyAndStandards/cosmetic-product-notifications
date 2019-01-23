require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
    @investigation = investigations(:one)

    @investigation_with_product = investigations(:search_related_products)
    @product = products(:iphone)

    @investigation_with_correspondence = investigations(:search_related_correspondence)
    @correspondence = correspondences(:one)

    @investigation_with_reporter = investigations(:search_related_reporter)
    @reporter = reporters(:one)

    @investigation_with_business = investigations(:search_related_businesses)
    @business = businesses(:biscuit_base)
  end

  teardown do
    logout
  end

  test "should create activities when investigation is created" do
    assert_difference"Activity.count" do
      @investigation = Investigation::Allegation.create
    end
  end

  test "should create an activity when business is added to investigation" do
    @investigation = Investigation::Allegation.create
    assert_difference"Activity.count" do
      @business = Business.new(company_name: 'Test Company')
      @investigation.businesses << @business
    end
  end

  test "should create an activity when business is removed from investigation" do
    @investigation = Investigation::Allegation.create
    @business = Business.new(company_name: 'Test Company')
    @investigation.businesses << @business
    assert_difference"Activity.count" do
      @investigation.businesses.delete(@business)
    end
  end

  test "should create an activity when product is added to investigation" do
    @investigation = Investigation::Allegation.create
    assert_difference"Activity.count" do
      @product = Product.new(name: 'Test Product')
      @investigation.products << @product
    end
  end

  test "should create an activity when product is removed from investigation" do
    @investigation = Investigation::Allegation.create
    @product = Product.new(name: 'Test Product')
    @investigation.products << @product
    assert_difference"Activity.count" do
      @investigation.products.delete(@product)
    end
  end

  test "should create an activity when status is updated on investigation" do
    @investigation = Investigation::Allegation.create
    assert_difference "Activity.count" do
      @investigation.is_closed = !@investigation.is_closed
      @investigation.save
    end
  end

  test "case title should match when no products are present on the case" do
    investigation = investigations(:no_products_case_titles)
    assert_equal "Alarms – Asphyxiation (no product specified)", investigation.title
  end

  test "case title should match when one product is added" do
    investigation = investigations(:one_product)
    assert_equal "iPhone XS MAX, phone – Asphyxiation", investigation.title
  end

  test "case title should match when two products with two common fields are added to the case" do
    investigation = investigations(:two_products_with_common_values)
    assert_equal "2 Products, phone – Asphyxiation", investigation.title
  end

  test "case title should match when two products with no common fields are added to the case" do
    investigation = investigations(:two_products_with_no_common_values)
    assert_equal "2 Products – Asphyxiation", investigation.title
  end

  test "elasticsearch should find product product_code" do
    query = ElasticsearchQuery.new(@product.product_code, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_product.id)
  end

  test "elasticsearch should find product name" do
    query = ElasticsearchQuery.new(@product.name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_product.id)
  end

  test "elasticsearch should find product batch" do
    query = ElasticsearchQuery.new(@product.batch_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_product.id)
  end

  test "elasticsearch should find product description" do
    query = ElasticsearchQuery.new(@product.description, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_product.id)
  end

  test "elasticsearch should not find product country" do
    query = ElasticsearchQuery.new(@product.country_of_origin, {}, {})
    assert_not_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_product.id)
  end

  test "elasticsearch should find correspondence overview" do
    query = ElasticsearchQuery.new(@correspondence.overview, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find correspondence details" do
    query = ElasticsearchQuery.new(@correspondence.details, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find correspondent name" do
    query = ElasticsearchQuery.new(@correspondence.correspondent_name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find correspondence email address" do
    query = ElasticsearchQuery.new(@correspondence.email_address, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find correspondence email subject" do
    query = ElasticsearchQuery.new(@correspondence.email_subject, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find correspondence phone number" do
    query = ElasticsearchQuery.new(@correspondence.phone_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_correspondence.id)
  end

  test "elasticsearch should find reporter name" do
    query = ElasticsearchQuery.new(@reporter.name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_reporter.id)
  end

  test "elasticsearch should find reporter phone number" do
    query = ElasticsearchQuery.new(@reporter.phone_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_reporter.id)
  end

  test "elasticsearch should find reporter email address" do
    query = ElasticsearchQuery.new(@reporter.email_address, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_reporter.id)
  end

  test "elasticsearch should find reporter other details" do
    query = ElasticsearchQuery.new(@reporter.other_details, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_reporter.id)
  end

  test "elasticsearch should find business name" do
    query = ElasticsearchQuery.new(@business.company_name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "elasticsearch should find business number" do
    query = ElasticsearchQuery.new(@business.company_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "elasticsearch should not find business type code" do
    query = ElasticsearchQuery.new(@business.company_type_code, {}, {})
    assert_not_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "elasticsearch should not find business status code" do
    query = ElasticsearchQuery.new(@business.company_status_code, {}, {})
    assert_not_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "visible to creator organisation" do
    create_new_private_case
    creator = User.find_by(last_name: "User_one")
    creator.organisation = organisations[0]
    user = User.find_by(last_name: "User_two")
    user.organisation = organisations[0]
    assert_equal(@new_investigation.visible_to(user), true)
  end

  test "visible to admin" do
    create_new_private_case
    logout
    sign_in_as_admin
    user = User.find_by(last_name: "Admin")
    assert(@new_investigation.visible_to(user))
  end

  test "visible to assignee organisation" do
    create_new_private_case
    assignee = User.find_by(last_name: "User_two")
    assignee.organisation = organisations[1]
    user = User.find_by(last_name: "User_three")
    user.organisation = organisations[1]
    @new_investigation.assignee = assignee
    assert(@new_investigation.visible_to(user))
  end

  test "not visible to no-admin, no-source, no-assignee organisation" do
    create_new_private_case
    logout
    sign_in_as_non_opss_user
    user = User.find_by(last_name: "User_one")
    user.organisation = organisations[1]
    assert_not(@new_investigation.visible_to(user))
  end

  def create_new_private_case
    description = "new_investigation_description"
    @new_investigation = Investigation::Allegation.create(description: description, is_private: true)
  end
end
