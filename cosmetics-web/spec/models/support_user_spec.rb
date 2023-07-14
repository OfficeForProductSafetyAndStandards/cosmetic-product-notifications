require "rails_helper"

RSpec.describe SupportUser, type: :model do
  subject(:user) { build_stubbed(:support_user, role:) }

  let(:role) { "opss_enforcement" }

  include_examples "common user tests"

  describe ".opss?" do
    context "for an opss user" do
      it "returns true" do
        expect(subject.opss?).to be true
      end
    end

    context "for a non-opss user" do
      let(:role) { "trading_standards" }

      it "returns false" do
        expect(subject.opss?).to be false
      end
    end
  end
end
