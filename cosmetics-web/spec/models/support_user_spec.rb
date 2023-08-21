require "rails_helper"

RSpec.describe SupportUser, type: :model do
  subject(:user) { build_stubbed(:support_user, role:) }

  let(:role) { "opss_general" }

  include_examples "common user tests"

  it "validates the format of new_email" do
    user.new_email = "wrongformat"
    expect(user).not_to be_valid
    expect(user.errors[:new_email])
      .to include("Enter an email address in the correct format and ending in gov.uk")
  end

  it "validates that the new email is a gov.uk address" do
    user.new_email = "new@example.com"
    expect(user).not_to be_valid
    expect(user.errors[:new_email])
      .to include("Enter an email address in the correct format and ending in gov.uk")
  end

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
