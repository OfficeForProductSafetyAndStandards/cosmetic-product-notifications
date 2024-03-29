require "rails_helper"

RSpec.describe "Responsible Person user invitations", :with_stubbed_notify, type: :request do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:other_responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:user) { create(:submit_user) }

  before do
    configure_requests_for_submit_domain
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "Creating an invitation" do
    let(:params) { { responsible_person_id: responsible_person.id } }
    let(:name) { "John Doe" }
    let(:email_address) { "user@example.com" }

    it "render back to add team member form if no email is provided" do
      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: { email: "", name: })
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if no name is provided" do
      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: { email: email_address, name: "" })
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user is already a member of the team" do
      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: {
             email: user.email,
             name:,
           })
      expect(response).to render_template(:new)
    end

    it "render back to add team member form if user has already been invited to the team" do
      create(:pending_responsible_person_user, responsible_person:, email_address:)

      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: { email: email_address, name: })
      expect(response).to render_template(:new)
    end

    it "creates an invitation with the given data plus the user that created the invitation" do
      expect {
        post responsible_person_invitations_path(responsible_person),
             params: params.merge(invite_member_form: { email: email_address, name: })
      }.to change(PendingResponsiblePersonUser, :count).by(1)
      expect(PendingResponsiblePersonUser.last)
        .to have_attributes(inviting_user: user, email_address:, name:)
    end

    it "uses the existing user name for the invitation when inviting an email belonging to an existing user" do
      create(:submit_user, email: email_address, name: "John Original Name")
      expect {
        post responsible_person_invitations_path(responsible_person),
             params: params.merge(invite_member_form: { email: email_address, name: })
      }.to change(PendingResponsiblePersonUser, :count).by(1)
      expect(PendingResponsiblePersonUser.last.name).to eq("John Original Name")
    end

    it "sends responsible person invite email" do
      allow(SubmitNotifyMailer).to receive(:send_responsible_person_invite_email)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: { email: email_address, name: })

      expect(SubmitNotifyMailer).to have_received(:send_responsible_person_invite_email)
    end

    it "redirects to the responsible person team members page" do
      post responsible_person_invitations_path(responsible_person),
           params: params.merge(invite_member_form: { email: email_address, name: })
      expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
    end
  end

  describe "Resending an invitation" do
    let(:invitation) do
      create(:pending_responsible_person_user, responsible_person:, inviting_user: user)
    end

    it "does not change the invitation token" do
      expect {
        get resend_responsible_person_invitation_path(responsible_person, invitation)
        invitation.reload
      }.not_to change(invitation, :invitation_token)
    end

    it "extends the invitation token expiration" do
      expect {
        get resend_responsible_person_invitation_path(responsible_person, invitation)
        invitation.reload
      }.to change(invitation, :invitation_token_expires_at)
    end

    it "resends the invitation email" do
      allow(SubmitNotifyMailer).to receive(:send_responsible_person_invite_email)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      get resend_responsible_person_invitation_path(responsible_person, invitation)

      expect(SubmitNotifyMailer).to have_received(:send_responsible_person_invite_email)
    end

    context "when a different user resends the invitation" do
      let(:other_user) { create(:submit_user, name: "Claire OtherUser") }

      before do
        sign_in_as_member_of_responsible_person(responsible_person, other_user)
      end

      it "changes the inviting user in the invitation" do
        expect {
          get resend_responsible_person_invitation_path(responsible_person, invitation)
          invitation.reload
        }.to change(invitation, :inviting_user).from(user).to(other_user)
      end
    end

    it "redirects the user to the team members page" do
      get resend_responsible_person_invitation_path(responsible_person, invitation)
      expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
    end

    context "when invitation does not belongs to responsible person" do
      let(:invitation) { create(:pending_responsible_person_user, responsible_person: other_responsible_person) }

      it "returns 404" do
        get resend_responsible_person_invitation_path(responsible_person, invitation)
        expect(response).to redirect_to("/404")
      end
    end
  end

  describe "Visiting invitation cancellation page" do
    let(:invitation) { create(:pending_responsible_person_user, responsible_person:) }

    it "renders the cancellation page" do
      get cancel_responsible_person_invitation_path(responsible_person, invitation)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:cancel)
    end

    context "when invitation does not belongs to responsible person" do
      let(:invitation) { create(:pending_responsible_person_user, responsible_person: other_responsible_person) }

      it "returns 404" do
        get cancel_responsible_person_invitation_path(responsible_person, invitation)
        expect(response).to redirect_to("/404")
      end
    end
  end

  describe "Cancelling an invitation" do
    let!(:invitation) { create(:pending_responsible_person_user, responsible_person:) }

    context "when the invitation cancelation is confirmed" do
      let(:params) { { cancel_invitation: "yes" } }

      it "destroys the invitation" do
        expect {
          delete responsible_person_invitation_path(responsible_person, invitation), params:
        }.to change(PendingResponsiblePersonUser, :count).from(1).to(0)
      end

      it "redirects to the team members page" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
      end

      it "adds a confirmation message to the response" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        follow_redirect!
        expect(response.body).to include("The invitation was cancelled")
      end
    end

    context "when the invitation cancelation is not confirmed" do
      let(:params) { { cancel_invitation: "no" } }

      it "does not destroy the invitation" do
        expect {
          delete responsible_person_invitation_path(responsible_person, invitation), params:
        }.not_to change(PendingResponsiblePersonUser, :count)
      end

      it "redirects to the team members page" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        expect(response).to redirect_to(responsible_person_team_members_path(responsible_person))
      end

      it "does not add a confirmation message to the response" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        expect(response.body).not_to include("The invitation was cancelled")
      end
    end

    context "when the invitation cancelation confirmation is not provided" do
      let(:params) { {} }

      it "does not destroy the invitation" do
        expect {
          delete responsible_person_invitation_path(responsible_person, invitation), params:
        }.not_to change(PendingResponsiblePersonUser, :count)
      end

      it "render the cancellation page" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        expect(response).to render_template(:cancel)
      end

      it "includes an error message" do
        delete(responsible_person_invitation_path(responsible_person, invitation), params:)
        expect(response.body).to include("Select yes if you want to cancel the invitation")
      end
    end

    context "when invitation does not belongs to responsible person" do
      let(:invitation) { create(:pending_responsible_person_user, responsible_person: other_responsible_person) }

      it "returns 404" do
        delete responsible_person_invitation_path(responsible_person, invitation)
        expect(response).to redirect_to("/404")
      end
    end
  end
end
