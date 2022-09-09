require "rails_helper"

RSpec.describe SearchUser, type: :model do
  subject(:user) { build_stubbed(:search_user) }

  include_examples "common user tests"

  describe "#can_view_product_ingredients?" do
    subject(:user) { build_stubbed(:search_user, id: 123, role:) }

    context "when MSA user" do
      let(:role) { :msa }

      it "returns false" do
        expect(user).not_to be_can_view_product_ingredients
      end
    end

    context "when not an MSA user" do
      let(:role) { :poison_centre }

      it "returns true" do
        expect(user).to be_can_view_product_ingredients
      end
    end
  end
end
