require "rails_helper"

RSpec.describe SearchUser, type: :model do
  subject(:user) { build_stubbed(:search_user) }

  include_examples "common user tests"

  describe "#can_view_product_ingredients?" do
    it "is false for MSA users" do
      user.role = :msa
      expect(user).not_to be_can_view_product_ingredients
    end

    it "is true for Poison Centre users" do
      user.role = :poison_centre
      expect(user).to be_can_view_product_ingredients
    end

    it "is true for OPSS Science users" do
      user.role = :opss_science
      expect(user).to be_can_view_product_ingredients
    end
  end

  describe "#can_view_ingredients_list?" do
    it "is false for MSA users" do
      user.role = :msa
      expect(user).not_to be_can_view_ingredients_list
    end

    it "is true for Poison Centre users" do
      user.role = :poison_centre
      expect(user).to be_can_view_ingredients_list
    end

    it "is false for OPSS Science users" do
      user.role = :opss_science
      expect(user).not_to be_can_view_ingredients_list
    end
  end

  describe "#can_view_nanomaterial_notification_files?" do
    it "is false for MSA users" do
      user.role = :msa
      expect(user).not_to be_can_view_nanomaterial_notification_files
    end

    it "is false for Poison Centre users" do
      user.role = :poison_centre
      expect(user).not_to be_can_view_nanomaterial_notification_files
    end

    it "is true for OPSS Science users" do
      user.role = :opss_science
      expect(user).to be_can_view_nanomaterial_notification_files
    end
  end

  describe "#can_view_nanomaterial_review_period_end_date?" do
    it "is true for MSA users" do
      user.role = :msa
      expect(user).to be_can_view_nanomaterial_review_period_end_date
    end

    it "is false for Poison Centre users" do
      user.role = :poison_centre
      expect(user).not_to be_can_view_nanomaterial_review_period_end_date
    end

    it "is true for OPSS Science users" do
      user.role = :opss_science
      expect(user).to be_can_view_nanomaterial_review_period_end_date
    end
  end
end
