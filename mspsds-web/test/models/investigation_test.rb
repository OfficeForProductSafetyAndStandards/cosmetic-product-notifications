require "test_helper"

class InvestigationTest < ActiveSupport::TestCase
  include Pundit
  # Pundit requires this method to be able to call policies
  def pundit_user
    User.current
  end

  setup do
    mock_out_keycloak_and_notify
    accept_declaration
    @investigation = investigations(:one)

    @investigation_with_product = investigations(:search_related_products)
    @product = products(:iphone)

    @investigation_with_correspondence = investigations(:search_related_correspondence)
    @correspondence = correspondences(:one)

    @investigation_with_complainant = investigations(:search_related_complainant)
    @complainant = complainants(:one)

    @investigation_with_business = investigations(:search_related_businesses)
    @business = businesses(:biscuit_base)
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should create activity when investigation is created" do
    assert_difference "Activity.count" do
      @investigation = Investigation::Allegation.create
    end
  end

  test "should create an activity when business is added to investigation" do
    @investigation = Investigation::Allegation.create
    assert_difference"Activity.count" do
      @business = businesses :new_business
      @investigation.add_business @business, "manufacturer"
    end
  end

  test "should create an activity when business is removed from investigation" do
    @investigation = Investigation::Allegation.create
    @business = businesses :new_business
    @investigation.add_business @business, "retailer"
    assert_difference"Activity.count" do
      @investigation.businesses.delete(@business)
    end
  end

  test "should create an activity when product is added to investigation" do
    @investigation = Investigation::Allegation.create
    assert_difference"Activity.count" do
      @product = Product.new(name: 'Test Product', product_type: "test product type", category: "test product category")
      @investigation.products << @product
    end
  end

  test "should create an activity when product is removed from investigation" do
    @investigation = Investigation::Allegation.create
    @product = Product.new(name: 'Test Product', product_type: "test product type", category: "test product category")
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
    investigation = investigations(:no_products_case_title)
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

  test "elasticsearch should find complainant name" do
    query = ElasticsearchQuery.new(@complainant.name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_complainant.id)
  end

  test "elasticsearch should find complainant phone number" do
    query = ElasticsearchQuery.new(@complainant.phone_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_complainant.id)
  end

  test "elasticsearch should find complainant email address" do
    query = ElasticsearchQuery.new(@complainant.email_address, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_complainant.id)
  end

  test "elasticsearch should find complainant other details" do
    query = ElasticsearchQuery.new(@complainant.other_details, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_complainant.id)
  end

  test "elasticsearch should find business name" do
    query = ElasticsearchQuery.new(@business.trading_name, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "elasticsearch should find business number" do
    query = ElasticsearchQuery.new(@business.company_number, {}, {})
    assert_includes(Investigation.full_search(query).records.map(&:id), @investigation_with_business.id)
  end

  test "visible to creator organisation" do
    create_new_private_case
    creator = User.find_by(last_name: "User_one")
    mock_user_as_non_opss(creator)
    user = User.find_by(last_name: "User_two")
    mock_user_as_non_opss(user)
    assert_equal(policy(@new_investigation).show?(user: user), true)
  end

  test "visible to assignee organisation" do
    create_new_private_case
    assignee = User.find_by(last_name: "User_two")
    mock_user_as_opss(assignee)
    user = User.find_by(last_name: "User_three")
    mock_user_as_opss(user)
    @new_investigation.assignee = assignee
    assert(policy(@new_investigation).show?(user: user))
  end

  test "not visible to no-source, no-assignee organisation" do
    create_new_private_case
    sign_in_as User.find_by(last_name: "User_two")
    mock_user_as_non_opss(User.current)
    assert_not(policy(@new_investigation).show?(user: User.current))
  end

  test "past assignees should be computed" do
    user = User.find_by(last_name: "User_one")
    @investigation.update(assignee: user)
    assert_includes @investigation.past_assignees, user
  end

  test "past assignee teams should be computed" do
    team = Team.first
    @investigation.update(assignee: team)
    assert_includes @investigation.past_teams, team
  end

  test "people out of current assignee's team should not be able to re-assign case" do
    investigation = Investigation::Allegation.create(description: "new_investigation_description")
    investigation.assignee = User.find_by(last_name: "User_one")
    assert_not policy(investigation).assign?(user: User.find_by(last_name: "User_three"))
  end

  test "people in current assignee's team should be able to re-assign case" do
    investigation = Investigation::Allegation.create(description: "new_investigation_description")
    investigation.assignee = User.find_by(last_name: "User_one")
    assert policy(investigation).assign?(user: User.find_by(last_name: "User_two"))
  end

  test "people out of currently assigned team should not be able to re-assign case" do
    investigation = Investigation::Allegation.create(description: "new_investigation_description")
    investigation.assignee = Team.find_by(name: "Team 1")
    assert_not policy(investigation).assign?(user: User.find_by(last_name: "User_three"))
  end

  test "people in currently assigned team should be able to re-assign case" do
    investigation = Investigation::Allegation.create(description: "new_investigation_description")
    investigation.assignee = Team.find_by(name: "Team 1")
    assert policy(investigation).assign?(user: User.find_by(last_name: "User_four"))
  end

  test "pretty_id should contain YYMM" do
    investigation = Investigation.create
    assert_includes investigation.pretty_id, Time.zone.now.strftime('%y').to_s
    assert_includes investigation.pretty_id, Time.zone.now.strftime('%m').to_s
  end

  test "pretty_id should be unique" do
    10.times do
      Investigation.create
    end
    investigation = Investigation.create
    assert_equal Investigation.where(pretty_id: investigation.pretty_id).count, 1
  end

  test "assigns to current user by default" do
    investigation = Investigation.create
    assert_equal User.current, investigation.assignee
  end

  def create_new_private_case
    description = "new_investigation_description"
    @new_investigation = Investigation::Allegation.create(description: description, is_private: true)
  end
end
