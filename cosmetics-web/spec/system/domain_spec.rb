require "rails_helper"

RSpec.describe "Service domain", type: :system do
  after do
    sign_out
  end

  describe "to submit notifications" do
    before do
      configure_requests_for_submit_domain
    end

    it "shows relevant landing page content for submitting notifications" do
      visit root_path

      assert_text "Submit cosmetic product notifications"
    end

    it "shows invalid account page for Poison Centre user" do
      sign_in_as_poison_centre_user
      configure_requests_for_submit_domain
      visit root_path

      assert_current_path invalid_account_path
      assert_text "You cannot submit notifications with this account"
    end
  end

  describe "to search notifications" do
    before do
      configure_requests_for_search_domain
    end

    it "shows relevant landing page content for finding product information" do
      visit root_path

      assert_text "Search for cosmetic products"
    end

    it "shows invalid account page for Responsible Person user" do
      sign_in_as_member_of_responsible_person(create(:responsible_person))
      configure_requests_for_search_domain
      visit root_path

      assert_current_path invalid_account_path
      assert_text "Your account doesn’t allow you to use this service"
    end
  end
end
