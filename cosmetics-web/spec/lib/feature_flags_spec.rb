require "rails_helper"
require "feature_flags"

RSpec.describe FeatureFlags do
  describe ".two_factor_authentication_enabled?" do
    context "when the feature flag is enabled" do
      before do
        Flipper.enable(:two_factor_authentication)
      end

      it "returns true" do
        expect(described_class.two_factor_authentication_enabled?).to be true
      end
    end

    context "when the feature flag is disabled" do
      before do
        Flipper.disable(:two_factor_authentication)
      end

      it "returns false" do
        expect(described_class.two_factor_authentication_enabled?).to be false
      end
    end
  end
end
