require "rails_helper"

RSpec.describe GenerateRecoveryCodes do
  describe ".call" do
    let(:user) { create(:submit_user, :without_secondary_authentication) }

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
    it "generates and saves new recovery codes for the user" do
      described_class.call(user:)
      user.reload

      expect(user.secondary_authentication_recovery_codes_generated_at).not_to be_nil
      expect(user.secondary_authentication_recovery_codes.length).to eq(10)
      expect(user.secondary_authentication_recovery_codes.sample.length).to eq(8)
      expect(user.secondary_authentication_recovery_codes_used).to be_empty
      expect(user.last_recovery_code_at).to be_nil
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end
end
