require "rails_helper"

RSpec.describe SecondaryAuthentication::RecoveryCode do
  let(:user) { create(:submit_user) }
  let(:secondary_authentication) { described_class.new(user) }

  describe "#valid_recovery_code?" do
    context "when the recovery code is valid" do
      it "returns true" do
        expect(secondary_authentication).to be_valid_recovery_code(user.secondary_authentication_recovery_codes.sample)
      end
    end

    context "when the recovery code is not valid" do
      it "returns false" do
        expect(secondary_authentication).not_to be_valid_recovery_code("1234")
      end
    end

    context "when the recovery code is blank" do
      it "returns false" do
        expect(secondary_authentication).not_to be_valid_recovery_code("")
      end
    end
  end

  describe "#used_recovery_code?" do
    before do
      user.secondary_authentication_recovery_codes_used = %w[01234567]
    end

    context "when the recovery code has been used" do
      it "returns true" do
        expect(secondary_authentication).to be_used_recovery_code(user.secondary_authentication_recovery_codes_used.sample)
      end
    end

    context "when the recovery code has not been used" do
      it "returns false" do
        expect(secondary_authentication).not_to be_used_recovery_code("1234")
      end
    end

    context "when the recovery code is blank" do
      it "returns false" do
        expect(secondary_authentication).not_to be_used_recovery_code("")
      end
    end
  end
end
