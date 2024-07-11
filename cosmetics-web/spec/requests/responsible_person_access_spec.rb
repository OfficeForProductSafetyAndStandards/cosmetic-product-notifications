require "rails_helper"

describe "Access control for actions related to responsible person" do
  let(:rp_a) { create(:responsible_person, :with_a_contact_person) }
  let(:user_a) { create(:submit_user) }
  let(:rp_b) { create(:responsible_person, :with_a_contact_person) }
  let(:user_b) { create(:submit_user) }

  before do
    create(:responsible_person_user, user: user_a, responsible_person: rp_a)
    create(:responsible_person_user, user: user_b, responsible_person: rp_b)

    configure_requests_for_submit_domain
  end

  shared_examples_for "proper authorization" do
    it "authorizes users belonging to the visited responsible person page" do
      sign_in user_a

      get url

      expect(response.status).to eq 200
    end

    it "blocks users not belonging to the visited responsible person page" do
      sign_in user_b

      expect { get(url) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when visiting the responsible person page" do
    let(:url) { "/responsible_persons/#{rp_a.id}" }

    include_examples "proper authorization"
  end

  context "when visiting the responsible person notifications page" do
    let(:url) { "/responsible_persons/#{rp_a.id}/notifications" }

    include_examples "proper authorization"
  end

  context "when visiting the responsible person nanomaterials page" do
    let(:url) { "/responsible_persons/#{rp_a.id}/nanomaterials" }

    include_examples "proper authorization"
  end

  context "when visiting the responsible person members page" do
    let(:url) { "/responsible_persons/#{rp_a.id}/team_members" }

    include_examples "proper authorization"
  end

  context "when visiting the responsible person add a member page" do
    let(:url) { "/responsible_persons/#{rp_a.id}/invitations/new" }

    include_examples "proper authorization"
  end
end
