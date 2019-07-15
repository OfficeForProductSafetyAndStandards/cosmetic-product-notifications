module LoginHelpers
  RSpec::Matchers.define :any_of do |items_to_match|
    match { |actual| items_to_match.include? actual }
  end

  # rubocop:disable RSpec/AnyInstance
  def sign_in(as_user: build(:user), with_roles: [])
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(format_user_for_get_userinfo(as_user))

    allow(Keycloak::Client).to receive(:has_role?).and_return(false)
    allow(Keycloak::Client).to receive(:has_role?).with(any_of(with_roles), anything).and_return(true)

    allow(Keycloak::Client).to receive(:url_user_account).and_return(nil)

    allow_any_instance_of(ApplicationController).to receive(:access_token).and_return("access_token")
  end
  # rubocop:enable RSpec/AnyInstance

  def sign_in_as_poison_centre_user(user: build(:user))
    sign_in(as_user: user, with_roles: [:poison_centre_user])
    configure_requests_for_search_domain
  end

  def sign_in_as_msa_user(user: build(:user))
    sign_in(as_user: user, with_roles: [:msa_user])
    configure_requests_for_search_domain
  end

  # rubocop:disable RSpec/AnyInstance
  def sign_out
    allow(Keycloak::Client).to receive(:url_user_account).and_call_original
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
    allow(Keycloak::Client).to receive(:get_userinfo).and_call_original
    allow(Keycloak::Client).to receive(:has_role?).and_call_original

    allow_any_instance_of(ApplicationController).to receive(:access_token).and_call_original

    reset_domain_request_mocking
  end
  # rubocop:enable RSpec/AnyInstance

private

  def format_user_for_get_userinfo(user, groups: [])
    { sub: user[:id], email: user[:email], groups: groups, given_name: user[:name], family_name: "n/a" }.to_json
  end
end
