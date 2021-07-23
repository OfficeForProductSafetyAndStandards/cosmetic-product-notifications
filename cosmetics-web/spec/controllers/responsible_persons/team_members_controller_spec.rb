require "rails_helper"

RSpec.describe ResponsiblePersons::TeamMembersController, :with_stubbed_mailer, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }
  let(:email_address) { "user@example.com" }
  let(:params) { { responsible_person_id: responsible_person.id, invitation_token: pending_responsible_person_user.invitation_token } }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #index" do
    let(:params) { { responsible_person_id: responsible_person.id } }

    it "assigns @responsible_person" do
      get :index, params: params
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: params
      expect(response).to render_template("responsible_persons/team_members/index")
    end
  end

  describe "POST #create" do
    let(:params) { { responsible_person_id: responsible_person.id } }
    let(:name) { "John Doe" }

    it "render back to add team member form if no email is provided" do
      post(:create, params: params.merge(invite_member_form: { email: "", name: name }))
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if no name is provided" do
      post(:create, params: params.merge(invite_member_form: { email: email_address, name: "" }))
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user is already a member of the team" do
      post(:create, params: params.merge(invite_member_form: {
        email: user.email,
        name: name,
      }))
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user has already been invited to the team" do
      create(:pending_responsible_person_user, responsible_person: responsible_person, email_address: email_address)

      post(:create, params: params.merge(invite_member_form: { email: email_address, name: name }))
      expect(response).to render_template(:new)
    end

    it "creates an invitation with the given data plus the user that created the invitation" do
      expect {
        post(:create, params: params.merge(invite_member_form: { email: email_address, name: name }))
      }.to change(PendingResponsiblePersonUser, :count).by(1)
      expect(PendingResponsiblePersonUser.last)
        .to have_attributes(inviting_user: user, email_address: email_address, name: name)
    end

    it "uses the existing user name for the invitation when inviting an email belonging to an existing user" do
      create(:submit_user, email: email_address, name: "John Original Name")
      expect {
        post(:create, params: params.merge(invite_member_form: { email: email_address, name: name }))
      }.to change(PendingResponsiblePersonUser, :count).by(1)
      expect(PendingResponsiblePersonUser.last.name).to eq("John Original Name")
    end

    it "sends responsible person invite email" do
      stub_notify_mailer

      post(:create, params: params.merge(invite_member_form: { email: email_address, name: name }))

      expect(SubmitNotifyMailer).to have_received(:send_responsible_person_invite_email)
    end

    it "redirects to the responsible person team members page" do
      post(:create, params: params.merge(invite_member_form: { email: email_address, name: name }))
      expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
    end
  end

  describe "GET #join" do
    let(:pending_responsible_person_user) { create(:pending_responsible_person_user, responsible_person: responsible_person, inviting_user: user) }
    let(:params) { { responsible_person_id: responsible_person.id, invitation_token: pending_responsible_person_user.invitation_token } }

    context "when signed in as the invited user" do
      before do
        invited_user = create(:submit_user, email: pending_responsible_person_user.email_address)
        sign_in(invited_user)
      end

      it "adds user with a pending invite to the responsible person" do
        expect { get(:join, params: params) }
          .to change { responsible_person.reload.responsible_person_users.size }.from(1).to(2)
      end

      it "deletes any existing invites to the responsible person for this user" do
        expect { get(:join, params: params) }
          .to change { responsible_person.pending_responsible_person_users.size }
          .from(1).to(0)
      end

      it "redirects to the responsible person notifications page" do
        get(:join, params: params)
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end
    end
  end
end

def stub_notify_mailer
  result = double
  allow(result).to receive(:deliver_later)
  allow(SubmitNotifyMailer).to receive(:send_responsible_person_invite_email) { result }
end
