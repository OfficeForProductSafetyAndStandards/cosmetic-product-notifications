require "rails_helper"

RSpec.describe InviteSupportUser, :with_stubbed_mailer do
  RSpec.shared_examples "existing user" do
    before { user }

    it "does not create a new user" do
      expect { inviter.call }.not_to change(SupportUser, :count)
    end

    it "sends an invitation email to the user" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq user.email
    end

    it "sets an invitation token and updates the invitation time when not already set" do
      user.update_column(:invitation_token, nil)
      expect {
        inviter.call
        user.reload
      }.to change(user, :invitation_token).from(nil).and change(user, :invited_at)
    end
  end

  context "when the email address provided is already in use by a non-support user" do
    let(:user) { create(:submit_user, email: "existinguser@example.com") }

    it "fails" do
      expect { described_class.new(email: "existinguser@example.com").call }
        .to raise_error(Interactor::Failure)
    end
  end

  it "fails when no user name is provided" do
    expect { described_class.new(email: "user@example.gov.uk").call }
      .to raise_error(Interactor::Failure)
  end

  it "fails when a non-gov.uk email is provided" do
    expect { described_class.new(name: "John Doe", email: "user@example.com").call }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  context "when an email is provided" do
    subject(:inviter) { described_class.new(name: "John Doe", email: "inviteduser@example.gov.uk") }

    it "creates a new user" do
      expect { inviter.call }.to change(SupportUser, :count).by(1)
    end

    it "sets the user's role to OPSS General" do
      inviter.call
      user = SupportUser.last
      expect(user.has_role?(:opss_general)).to be true
    end

    it "sets an invitation token and timestamp for the new user" do
      freeze_time do
        inviter.call
        user = SupportUser.last
        expect(user.invitation_token).not_to be_nil
        expect(user.invited_at).to eq Time.zone.now
      end
    end

    it "sends an invitation email to the new user" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq "inviteduser@example.gov.uk"
    end
  end

  context "when a deactivated user is invited" do
    subject(:inviter) { described_class.new(name: "John Doe", user:) }

    let(:user) { create(:support_user, :registration_incomplete, deactivated_at: 1.week.ago) }

    it "reactivates the user" do
      inviter.call
      user.reload
      expect(user.deactivated_at).to be_nil
    end

    include_examples "existing user"
  end
end
