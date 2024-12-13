module LoginHelpers
  RSpec::Matchers.define :any_of do |items_to_match|
    match { |actual| items_to_match.include? actual }
  end

  def sign_in_as_poison_centre_user(user: create(:poison_centre_user))
    ensure_user_has_role(user, :poison_centre)
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_general_user(user: create(:opss_general_user))
    ensure_user_has_role(user, :opss_general)
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_enforcement_user(user: create(:opss_enforcement_user))
    ensure_user_has_role(user, :opss_enforcement)
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_imt_user(user: create(:opss_imt_user))
    ensure_user_has_role(user, :opss_imt)
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_opss_science_user(user: create(:opss_science_user))
    ensure_user_has_role(user, :opss_science)
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_trading_standards_user(user: create(:trading_standards_user))
    ensure_user_has_role(user, :trading_standards)
    configure_requests_for_search_domain
    sign_in(user)
  end

private

  def ensure_user_has_role(user, role)
    unless user.has_role?(role)
      user.add_role(role)
      Rails.logger.warn("User #{user.id} was missing the #{role} role, so it was added.")
    end
  end
end
