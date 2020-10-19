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
        expect do
          get responsible_person_team_members_path(other_responsible_person)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "Resending invitation" do
    context "when invitation does not belongs to responsible person" do
      let(:invitation) { create(:pending_responsible_person_user, responsible_person: other_responsible_person) }

      it "returns 404" do
        get resend_invitation_responsible_person_team_member_path(responsible_person, invitation)
        expect(response.status).to eq(404)
      end
    end
  end
end
