require "rails_helper"

RSpec.describe "Edit Responsible Person Details", type: :request do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:other_responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { responsible_person.users.first }
  let(:other_user) { other_responsible_person.users.first }

  def create_invitation
    user = responsible_person.users.first
    create(:pending_responsible_person_user,
           email_address: user.email,
           name: user.name,
           responsible_person: other_responsible_person,
           inviting_user: other_responsible_person.users.first)
  end

  before do
    configure_requests_for_submit_domain

    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "Access edit page" do
    it "doesn't allow users not belonging to the RP to access the page" do
      expect {
        get edit_responsible_person_path(other_responsible_person)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "doesn't allow users invited to the RP to access the page" do
      create_invitation
      expect {
        get edit_responsible_person_path(other_responsible_person)
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "allows users belonging to the RP to access the page" do
      get edit_responsible_person_path(responsible_person)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Update details" do
    let(:params) do
      {
        account_type: "business",
        address_line_1: "11",
        address_line_2: "Fake St",
        city: "Fake City",
        county: "County",
        postal_code: "FA1 1FA",
      }
    end

    it "does not allow updates from users not belonging to the responsible person" do
      expect {
        put "/responsible_persons/#{other_responsible_person.id}", params: { responsible_person: params }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not allow updates from users invited to the responsible person" do
      create_invitation
      expect {
        put "/responsible_persons/#{other_responsible_person.id}", params: { responsible_person: params }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    context "when providing the needed data" do
      let(:update_request) { put "/responsible_persons/#{responsible_person.id}", params: { responsible_person: params } }
      let(:expected_attributes) do
        {
          account_type: "business",
          address_line_1: "11",
          address_line_2: "Fake St",
          city: "Fake City",
          county: "County",
          postal_code: "FA1 1FA",
        }
      end

      it "redirects to the responsible person page" do
        update_request
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
      end

      it "updates the responsible person's details" do
        update_request
        expect(responsible_person.reload).to have_attributes(expected_attributes)
      end

      it "response includes a confirmation message" do
        update_request
        follow_redirect!
        expect(response.body).to include("The Responsible Person details were changed")
      end

      it "records the previous responsible person address into DB" do
        expect { update_request }.to change { responsible_person.reload.address_logs.count }.from(0).to(1)
      end
    end

    context "when missing some required data" do
      let(:params) do
        {
          account_type: "",
          address_line_1: "",
          address_line_2: "Fake St",
          city: "",
          county: "County",
          postal_code: "FA1 1FA",
        }
      end

      before do
        put "/responsible_persons/#{responsible_person.id}", params: { responsible_person: params }
      end

      it "renders the edit page instead of redirecting" do
        expect(response.status).to be 200
        expect(response).to render_template(:edit)
      end

      it "includes a validation error message in the response" do
        expect(response.body).to include("There is a problem")
      end

      it "does not update the responsible person’s details" do
        expect(responsible_person.reload).to have_attributes(
          account_type: "individual",
          address_line_1: "Street address",
          city: "City",
          postal_code: "AB12 3CD",
        )
      end
    end
  end
end
