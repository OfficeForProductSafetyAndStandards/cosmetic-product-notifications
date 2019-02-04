module LoginHelpers

  def sign_in(as_user: test_user)
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
    allow(Keycloak::Client).to receive(:get_userinfo).and_return(format_user_for_get_userinfo(as_user))
  end

  def sign_out
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
    allow(Keycloak::Client).to receive(:get_userinfo).and_call_original
    allow(Keycloak::Client).to receive(:has_role?).and_call_original
  end

  def test_user(name: "Test User")
    User.new(id: SecureRandom.uuid, email: "test.user@example.com", first_name: name)
  end

  def format_user_for_get_userinfo(user, groups: [])
    { sub: user[:id], email: user[:email], groups: groups, given_name: user[:first_name], family_name: user[:last_name] }.to_json
  end
end
