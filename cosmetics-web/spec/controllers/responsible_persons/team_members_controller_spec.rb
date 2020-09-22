require "rails_helper"

RSpec.describe ResponsiblePersons::TeamMembersController, :with_stubbed_mailer, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }
  let(:email_address) { "user@example.com" }
  let(:pending_responsible_person_user) { create(:pending_responsible_person_user, responsible_person: responsible_person) }
  let(:params) { { responsible_person_id: responsible_person.id, id: pending_responsible_person_user.id } }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      get :index, params: params
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: params
      expect(response).to render_template("responsible_persons/team_members/index")
    end
  end

  describe "PUT #create" do
    it "render back to add team member form if no email address added" do
      put(:create, params: params.merge(team_member: { email_address: "" }))
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user already a member of the team" do
      put(:create, params: params.merge(team_member: { email_address: responsible_person.responsible_person_users.first.email_address }))
      expect(response).to render_template(:new)
    end

    it "sends responsible person invite email" do
      stub_notify_mailer
      put(:create, params: params.merge(team_member: { email_address: email_address }))
      expect(NotifyMailer).to have_received(:send_responsible_person_invite_email)
    end

    it "redirects to the responsible person team members page" do
      put(:create, params: params.merge(team_member: { email_address: email_address }))
      expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
    end
  end

  describe "GET #join" do
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

    context "when signed in as the inviting user" do
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
    # TODO: Add the rest of contexts. Turn into a request spec?
  end
end
