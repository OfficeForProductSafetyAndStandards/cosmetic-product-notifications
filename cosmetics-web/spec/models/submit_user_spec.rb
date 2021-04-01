require "rails_helper"

RSpec.describe SubmitUser, type: :model do
  subject(:user) { build_stubbed(:submit_user) }

  include_examples "common user tests"

  describe ".confirm_by_token" do
    it "returns nil if no user is found" do
      expect(described_class.confirm_by_token("foobar")).to be_nil
    end
  end
end
