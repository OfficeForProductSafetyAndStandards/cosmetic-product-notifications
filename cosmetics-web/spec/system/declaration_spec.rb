require 'rails_helper'

RSpec.describe "Declaration page", type: :system do
  let(:first_time_user) { build(:user, first_login: true) }

  before do
    sign_in(as_user: first_time_user)
  end

  after do
    sign_out
  end

  it "is displayed on first login" do
    visit root_path

    assert_current_path declaration_path
  end

  it "requires acceptance before continuing" do
    visit root_path

    click_on "Confirm"

    assert_current_path accept_declaration_path
    assert_text "You must agree to the declaration"
  end

  it "records acceptance and redirects to account page" do
    visit root_path

    check "I agree"
    click_on "Confirm"

    assert_current_path account_path(:overview)
  end
end
