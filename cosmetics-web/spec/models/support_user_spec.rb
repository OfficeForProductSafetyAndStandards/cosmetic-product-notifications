require "rails_helper"

RSpec.describe SupportUser, type: :model do
  subject(:user) { create(:support_user) }

  let(:role) { :opss_general }

  before do
    user.add_role(role)
  end

  include_examples "common user tests"

  describe "validations" do
    context "when validating the format of new_email" do
      it "is invalid with an incorrectly formatted email" do
        user.new_email = "wrongformat"
        expect(user).not_to be_valid
        expect(user.errors[:new_email])
          .to include("Enter an email address in the correct format and ending in gov.uk")
      end

      it "is invalid with a non-gov.uk email" do
        user.new_email = "new@example.com"
        expect(user).not_to be_valid
        expect(user.errors[:new_email])
          .to include("Enter an email address in the correct format and ending in gov.uk")
      end
    end
  end

  describe ".opss?" do
    context "when user is part of OPSS" do
      it "returns true" do
        expect(user.opss?).to be true
      end
    end

    context "when user is not part of OPSS" do
      let(:role) { :trading_standards }

      it "returns false" do
        expect(user.opss?).to be false
      end
    end
  end
end
