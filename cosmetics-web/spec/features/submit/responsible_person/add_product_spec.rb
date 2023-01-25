require "rails_helper"

RSpec.describe "Add product", type: :feature do
  let(:user) { create(:submit_user, :with_responsible_person) }

  before do
    configure_requests_for_submit_domain
    sign_in user
  end

  it "has the correct heading" do
    click_on "Add a cosmetic product"
    click_on "Create the product"

    expect_to_be_on__what_is_product_name_page
  end
end
