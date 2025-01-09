require "rails_helper"

RSpec.describe OneOff::SearchUserBulkInviter, :with_stubbed_mailer do
  subject(:bulk_inviter) { described_class.new(file, :opss_general) }

  let(:file) { "spec/fixtures/bulk_inviter/users.csv" }

  it "creates the correct number of users" do
    expect {
      bulk_inviter.call
    }.to change(SearchUser, :count).by(2)
  end

  it "creates users with correct names" do
    bulk_inviter.call
    expect(SearchUser.pluck(:name)).to contain_exactly("User", "User One")
  end

  it "creates users with correct emails" do
    bulk_inviter.call
    expect(SearchUser.pluck(:email)).to contain_exactly("user@example.com", "user.one@example.com")
  end

  it "assigns the correct role to the created users" do
    bulk_inviter.call
    SearchUser.all.find_each do |user|
      expect(user.has_role?(:opss_general)).to be true
    end
  end

  it "sends invitation emails for the users" do
    bulk_inviter.call
    expect(delivered_emails.map(&:recipient))
      .to contain_exactly("user@example.com", "user.one@example.com")
  end

  context "when one of the emails already belongs to a user" do
    before do
      create(:search_user, email: "user@example.com").tap do |user|
        user.add_role(:opss_general)
      end
    end

    it "does not create a new user for this email" do
      expect {
        bulk_inviter.call
      }.to change(SearchUser, :count).by(1)
    end

    it "does not send an invitation for this email" do
      bulk_inviter.call
      expect(delivered_emails.map(&:recipient)).to contain_exactly("user.one@example.com")
    end
  end
end
