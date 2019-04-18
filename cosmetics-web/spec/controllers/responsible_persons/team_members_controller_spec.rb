require 'rails_helper'

RSpec.describe ResponsiblePersons::TeamMembersController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:user) { create(:user) }
  let(:email_address) { "user@example.com" }
  let(:pending_responsible_person_user) { create(:pending_responsible_person_user, responsible_person: responsible_person, email_address: "pending@example.com") }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template('responsible_persons/team_members/index')
    end
  end

  describe "PUT #create" do
    it "render back to add team member form if no email address added" do
      put(:create, params: { team_member: { email_address: "" },
        responsible_person_id: responsible_person.id })
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user already a member of the team" do
      put(:create, params: { team_member: { email_address: responsible_person.responsible_person_users.first.email_address },
        responsible_person_id: responsible_person.id })
      expect(response).to render_template(:new)
    end

    it "sends responsible person invite email" do
      stub_notify_mailer
      put(:create, params: { team_member: { email_address: email_address },
        responsible_person_id: responsible_person.id })
      expect(NotifyMailer).to have_received(:send_responsible_person_invite_email)
    end

    it "redirects to the responsible person team members page" do
      put(:create, params: { team_member: { email_address: email_address },
        responsible_person_id: responsible_person.id })
      expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
    end
  end

  describe "GET #join" do
    it "adds user with a pending invite to the responsible person" do
      get(:join, params: { responsible_person_id: responsible_person.id })
      expect(responsible_person.reload.responsible_person_users.size).to eq(1)
    end

    it "deletes any existing invites to the responsible person for this user" do
      get(:join, params: { responsible_person_id: responsible_person.id })
      expect(responsible_person.reload.pending_responsible_person_users.size).to eq(0)
    end

    it "redirects to the responsible person team members page" do
      get(:join, params: { responsible_person_id: responsible_person.id })
      expect(response).to redirect_to(responsible_person_path(responsible_person))
    end
  end
end
