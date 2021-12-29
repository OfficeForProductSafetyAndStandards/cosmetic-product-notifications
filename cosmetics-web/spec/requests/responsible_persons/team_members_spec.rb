require "rails_helper"

RSpec.describe "Team members management", type: :request, with_stubbed_notify: true do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:other_responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    configure_requests_for_submit_domain

    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "Access" do
    context "when user that belongs to different responsible person tries to access" do
      it "returns 404" do
        expect {
          get responsible_person_team_members_path(other_responsible_person)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
