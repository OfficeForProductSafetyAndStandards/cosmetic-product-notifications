require "rails_helper"

RSpec.describe InviteSearchUser, :with_stubbed_mailer do
  RSpec.shared_examples "existing user" do
    before { user }

    it "does not create a new user" do
      expect { inviter.call }.not_to change(SearchUser, :count)
    end

    it "sends invitation email for the user" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq user.email
    end

    it "sets an invitation token and updates the invitation time when user hasn't invitation token set" do
      user.update(invitation_token: nil)
      expect {
        inviter.call
        user.reload
      }.to change(user, :invitation_token).from(nil).and change(user, :invited_at)
    end

    it "does not update the invitation time when user was invited less than an hour ago" do
      user.update(invited_at: 2.minutes.ago)
      expect {
        inviter.call
        user.reload
      }.to not_change { user.invited_at.round }.and not_change(user, :invitation_token)
    end

    it "updates the invitation time when user was invited more than an hour ago" do
      user.update(invited_at: 61.minutes.ago)
      expect {
        inviter.call
        user.reload
      }.to change { user.invited_at.round }.and not_change(user, :invitation_token)
    end

    it "does not change the user role when the inviter is called for a different role" do
      user.update(role: (inviter.role == "msa" ? "poison_centre" : "msa"))
      expect {
        inviter.call
        user.reload
      }.not_to change(user, :role)
    end
  end

  it "fails when no user name is provided" do
    expect { described_class.new(email: "user@example.com", role: "msa").call }
      .to raise_error(Interactor::Failure)
  end

  it "fails when no user role is provided" do
    expect { described_class.new(name: "John Doe", email: "user@example.com").call }
      .to raise_error(Interactor::Failure)
  end

  it "fails when no user or user email is provided" do
    expect { described_class.new(name: "John Doe", role: "poison_centre").call }
      .to raise_error(Interactor::Failure)
  end

  context "when an user is provided" do
    subject(:inviter) { described_class.new(name: "John Doe", role: "msa", user: user) }

    let(:user) { create(:search_user, email: "existentuser@example.com") }

    include_examples "existing user"
  end

  context "when an email is provided" do
    subject(:inviter) do
      described_class.new(name: "John Doe", role: "msa", email: "inviteduser@example.com")
    end

    context "when the provided email belongs to an existing user" do
      let(:user) { create(:search_user, email: "inviteduser@example.com") }

      include_examples "existing user"
    end

    it "does create a new user" do
      expect { inviter.call }.to change(SearchUser, :count).by(1)
    end

    # rubocop:disable RSpec/ExampleLength
    it "sets an invitation token and timestamp for the new user" do
      freeze_time do
        inviter.call
        user = User.last
        expect(user.invitation_token).not_to be_nil
        expect(user.invited_at).to eq Time.zone.now
      end
    end
    # rubocop:enable RSpec/ExampleLength

    it "sends invitation email for the created user with the given email" do
      inviter.call
      expect(delivered_emails.size).to eq 1
      expect(delivered_emails.last.recipient).to eq "inviteduser@example.com"
    end
  end
end
