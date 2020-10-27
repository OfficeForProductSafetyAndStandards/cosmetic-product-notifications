require "rails_helper"

describe "Access control for actions related to responsible person" do
  let(:rp1) { create(:responsible_person, :with_a_contact_person) }
  let(:user1) { create(:submit_user) }
  let(:rp2) { create(:responsible_person, :with_a_contact_person) }
  let(:user2) { create(:submit_user) }

  before do
    create(:responsible_person_user, user: user1, responsible_person: rp1)
    create(:responsible_person_user, user: user2, responsible_person: rp2)

    configure_requests_for_submit_domain
  end

  shared_examples_for "proper authorization" do
    it "authorizes users belonging to the visited responsible person page" do
      sign_in user1

      get url

      expect(response.status).to eq 200
    end

    it "blocks users not belonging to the visited responsible person page" do
      sign_in user2

      expect { get(url) }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when visiting the responsible person page" do
    let(:url) { "/responsible_persons/#{rp1.id}" }

    include_examples "proper authorization"
  end

  context "when visiting the responsible person notifications page" do
    let(:url) { "/responsible_persons/#{rp1.id}/notifications" }

    include_examples "proper authorization"
  end

  context "visiting the responsible person nanomaterials page" do
    let(:url) { "/responsible_persons/#{rp1.id}/nanomaterials" }

    include_examples "proper authorization"
  end

  context "visiting the responsible person members page" do
    let(:url) { "/responsible_persons/#{rp1.id}/team_members" }

    include_examples "proper authorization"
  end

  context "visiting the responsible person add a member page" do
    let(:url) { "/responsible_persons/#{rp1.id}/team_members/new" }

    include_examples "proper authorization"
  end
end
