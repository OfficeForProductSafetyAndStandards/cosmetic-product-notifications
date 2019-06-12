require 'rails_helper'

RSpec.describe "Service domain", type: :system do
  after do
    reset_domain_request_mocking
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

      assert_text "Find cosmetic product information"
    end

    it "shows invalid account page for Responsible Person user" do
      sign_in_as_member_of_responsible_person(create(:responsible_person))
      configure_requests_for_search_domain
      visit root_path

      assert_current_path invalid_account_path
      assert_text "Your account doesn’t allow you to use this service"
    end
  end

private

  def configure_requests_for_submit_domain
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_return(true)

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_return(false)
  end

  def configure_requests_for_search_domain
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_return(true)

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_return(false)
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_return(true)
  end

  def reset_domain_request_mocking
    allow_any_instance_of(DomainConstraint).to receive(:matches?).and_call_original

    allow_any_instance_of(ApplicationController).to receive(:submit_domain?).and_call_original
    allow_any_instance_of(ApplicationController).to receive(:search_domain?).and_call_original
  end
end
