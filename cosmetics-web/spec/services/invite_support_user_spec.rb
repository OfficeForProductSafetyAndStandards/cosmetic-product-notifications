require "rails_helper"

RSpec.describe InviteSupportUser, :with_stubbed_mailer do
  RSpec.shared_examples "existing user" do
    before { user }

    it "does not create a new user" do
      expect { inviter.call }.not_to change(SupportUser, :count)
    end

    it "sends invitation email for the user" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq user.email
    end

    it "sets an invitation token and updates the invitation time when user hasn't invitation token set" do
      user.update_column(:invitation_token, nil)
      expect {
        inviter.call
        user.reload
      }.to change(user, :invitation_token).from(nil).and change(user, :invited_at)
    end

    it "does not update the invitation time when user was invited less than an hour ago" do
      user.update_column(:invited_at, 2.minutes.ago)
      expect {
        inviter.call
        user.reload
      }.to not_change { user.invited_at.round }.and not_change(user, :invitation_token)
    end

    it "updates the invitation time when user was invited more than an hour ago" do
      user.update_column(:invited_at, 61.minutes.ago)
      expect {
        inviter.call
        user.reload
      }.to change { user.invited_at.round }.and not_change(user, :invitation_token)
    end

    context "when user has already set its account security" do
      before do
        user.update_columns(account_security_completed: true, invited_at: 1.week.ago)
      end

      it "does not send an invitation email for the user" do
        inviter.call
        expect(delivered_emails).to be_empty
      end

      it "does not update the invitation token or its timestamp" do
        expect {
          inviter.call
          user.reload
        }.to not_change { user.invited_at.round }.and not_change(user, :invitation_token)
      end

      it "registers the issue in the log" do
        allow(Rails.logger).to receive(:info)
        inviter.call
        expect(Rails.logger).to have_received(:info).with("[InviteSupportUser] User with id: #{user.id} is already registered in the service and cannot be re-invited.")
      end
    end
  end

  context "when the email address provided is already in use by a non-support user" do
    let(:user) do
      create(:submit_user, email: "existinguser@example.com")
    end

    it "fails" do
      expect { described_class.new(email: "existinguser@example.com").call }
        .to raise_error(Interactor::Failure)
    end
  end

  it "fails when no user name is provided" do
    expect { described_class.new(email: "user@example.gov.uk").call }
      .to raise_error(Interactor::Failure)
  end

  it "fails when no user or user email is provided" do
    expect { described_class.new(name: "John Doe").call }
      .to raise_error(Interactor::Failure)
  end

  it "fails when a non-gov.uk email is provided" do
    expect { described_class.new(name: "John Doe", email: "user@example.com").call }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  context "when an user is provided" do
    subject(:inviter) { described_class.new(name: "John Doe", user:) }

    let(:user) do
      create(:support_user, :registration_incomplete, email: "existinguser@example.gov.uk")
    end

    include_examples "existing user"
  end

  context "when an email is provided" do
    subject(:inviter) do
      described_class.new(name: "John Doe", email: "inviteduser@example.gov.uk")
    end

    context "when the provided email belongs to an existing user" do
      let(:user) do
        create(:support_user, :registration_incomplete, email: "inviteduser@example.gov.uk")
      end

      include_examples "existing user"
    end

    it "creates a new user" do
      expect { inviter.call }.to change(SupportUser, :count).by(1)
    end

    it "sets the user's role to OPSS General" do
      inviter.call
      expect(User.last.role).to eq("opss_general")
    end

    it "sets an invitation token and timestamp for the new user" do
      freeze_time do
        inviter.call
        user = User.last
        expect(user.invitation_token).not_to be_nil
        expect(user.invited_at).to eq Time.zone.now
      end
    end

    it "sends invitation email for the created user with the given email" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq "inviteduser@example.gov.uk"
    end
  end

  context "when a deactivated user is invited" do
    subject(:inviter) { described_class.new(name: "John Doe", user:) }

    let(:user) do
      create(:support_user, :registration_incomplete, email: "deactivatedtuser@example.com", deactivated_at: 1.week.ago)
    end

    include_examples "existing user"
  end
end
