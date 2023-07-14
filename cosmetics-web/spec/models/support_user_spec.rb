require "rails_helper"

RSpec.describe SupportUser, type: :model do
  subject(:user) { build_stubbed(:support_user, role:) }

  let(:role) { "opss_enforcement" }

  include_examples "common user tests"

  describe ".opss?" do
    context "when user is part of opss" do
      it "returns true" do
        expect(user.opss?).to be true
      end
    end

    context "when user is not part of opss" do
      let(:role) { "trading_standards" }

      it "returns false" do
        expect(user.opss?).to be false
      end
    end
  end
end
