require "rails_helper"

RSpec.describe OneOff::SearchUserBulkInviter, :with_stubbed_mailer do
  let(:file) { 'spec/fixtures/bulk_inviter/users.csv' }

  before do
    OneOff::SearchUserBulkInviter.new(file, :msa).call
  end

  it 'should create correct amount of users' do
    expect(SearchUser.count).to eq(2)

  end

  it 'should create users with correct names' do
    expect(SearchUser.pluck(:name)).to eq(['User', 'User One'])
  end

  it 'should create users with correct emails' do
    expect(SearchUser.pluck(:email)).to eq(['user@example.com', 'user.one@example.com'])
  end
end
