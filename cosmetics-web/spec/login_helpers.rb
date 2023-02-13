module LoginHelpers
  RSpec::Matchers.define :any_of do |items_to_match|
    match { |actual| items_to_match.include? actual }
  end

  def sign_in_as_poison_centre_user(user: create(:poison_centre_user))
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_general_user(user: create(:opss_general_user))
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_enforcement_user(user: create(:opss_enforcement_user))
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_science_user(user: create(:opss_science_user))
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_trading_standards_user(user: create(:trading_standards_user))
    configure_requests_for_search_domain
    sign_in(user)
  end
end
