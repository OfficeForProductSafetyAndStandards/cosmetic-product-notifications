module LoginHelpers
  RSpec::Matchers.define :any_of do |items_to_match|
    match { |actual| items_to_match.include? actual }
  end

  def sign_in_as_poison_centre_user(user: create(:poison_centre_user))
    configure_requests_for_search_domain
    sign_in(user)
  end

  def sign_in_as_msa_user(user: create(:msa_user))
    configure_requests_for_search_domain
    sign_in(user)
  end
end
