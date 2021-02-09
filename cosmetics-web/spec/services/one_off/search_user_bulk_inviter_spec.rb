require "rails_helper"

RSpec.describe OneOff::SearchUserBulkInviter, :with_stubbed_mailer do
  let(:file) { "spec/fixtures/bulk_inviter/users.csv" }

  before do
    described_class.new(file, :msa).call
  end

  it "creates correct amount of users" do
    expect(SearchUser.count).to eq(2)
  end

  it "creates users with correct names" do
    expect(SearchUser.pluck(:name)).to contain_exactly("User", "User One")
  end

  it "creates users with correct emails" do
    expect(SearchUser.pluck(:email)).to contain_exactly("user@example.com", "user.one@example.com")
  end
end
