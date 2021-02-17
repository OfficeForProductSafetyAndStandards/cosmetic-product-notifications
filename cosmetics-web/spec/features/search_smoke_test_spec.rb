require "rails_helper"

RSpec.describe "Poison center user to be able to search notifications", type: :feature do
	let(:user) { responsible_person.responsible_person_users.first.user }
	let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  before do
    configure_requests_for_search_domain
    sign_in user
  end

   scenario "search notification" do
   end
end
