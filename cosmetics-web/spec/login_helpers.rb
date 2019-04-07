module LoginHelpers
  RSpec::Matchers.define :any_of do |items_to_match|
    match { |actual| items_to_match.include? actual }
  end

  def sign_in(as_user: build(:user), with_roles: [])
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(format_user_for_get_userinfo(as_user))

    allow(Keycloak::Client).to receive(:has_role?).and_return(false)
    allow(Keycloak::Client).to receive(:has_role?).with(any_of(with_roles)).and_return(true)
  end

  def sign_in_as_poison_centre_user(user: build(:user))
    sign_in(as_user: user, with_roles: [:poison_centre_user])
  end

  def sign_in_as_msa_user(user: build(:user))
    sign_in(as_user: user, with_roles: [:msa_user])
  end

  def sign_out
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
    allow(Keycloak::Client).to receive(:get_userinfo).and_call_original
    allow(Keycloak::Client).to receive(:has_role?).and_call_original
  end

  def format_user_for_get_userinfo(user, groups: [])
    { sub: user[:id], email: user[:email], groups: groups, given_name: user[:name] }.to_json
  end
end
