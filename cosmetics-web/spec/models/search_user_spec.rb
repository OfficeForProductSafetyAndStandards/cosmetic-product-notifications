require "rails_helper"

RSpec.describe SearchUser, type: :model do
  subject(:user) { build_stubbed(:search_user) }

  include_examples "common user tests"

  it "validates the format of new_email" do
    user.new_email = "wrongformat"
    expect(user).not_to be_valid
    expect(user.errors[:new_email])
      .to include("Enter an email address in the correct format, like name@example.com")
  end

  describe "#can_view_product_ingredients?" do
    it "is false for OPSS General users" do
      user.role = :opss_general
      expect(user).not_to be_can_view_product_ingredients
    end

    it "is true for OPSS Enforcement users" do
      user.role = :opss_enforcement
      expect(user).to be_can_view_product_ingredients
    end

    it "is true for OPSS IMT users" do
      user.role = :opss_imt
      expect(user).to be_can_view_product_ingredients
    end

    it "is false for Trading Standards users" do
      user.role = :trading_standards
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

  describe "#can_search_for_ingredients?" do
    it "is false for OPSS General users" do
      user.role = :opss_general
      expect(user).not_to be_can_search_for_ingredients
    end

    it "is true for OPSS Enforcement users" do
      user.role = :opss_enforcement
      expect(user).to be_can_search_for_ingredients
    end

    it "is true for OPSS IMT users" do
      user.role = :opss_imt
      expect(user).to be_can_search_for_ingredients
    end

    it "is true for Trading Standards users" do
      user.role = :trading_standards
      expect(user).to be_can_search_for_ingredients
    end

    it "is true for Poison Centre users" do
      user.role = :poison_centre
      expect(user).to be_can_search_for_ingredients
    end

    it "is true for OPSS Science users" do
      user.role = :opss_science
      expect(user).to be_can_search_for_ingredients
    end
  end

  describe "#can_view_nanomaterial_notification_files?" do
    it "is false for OPSS General users" do
      user.role = :opss_general
      expect(user).not_to be_can_view_nanomaterial_notification_files
    end

    it "is false for OPSS Enforcement users" do
      user.role = :opss_enforcement
      expect(user).not_to be_can_view_nanomaterial_notification_files
    end

    it "is false for OPSS IMT users" do
      user.role = :opss_imt
      expect(user).not_to be_can_view_nanomaterial_notification_files
    end

    it "is false for Trading Standards users" do
      user.role = :trading_standards
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
    it "is true for OPSS General users" do
      user.role = :opss_general
      expect(user).to be_can_view_nanomaterial_review_period_end_date
    end

    it "is true for OPSS Enforcement users" do
      user.role = :opss_enforcement
      expect(user).to be_can_view_nanomaterial_review_period_end_date
    end

    it "is true for OPSS IMT users" do
      user.role = :opss_imt
      expect(user).to be_can_view_nanomaterial_review_period_end_date
    end

    it "is true for Trading Standards users" do
      user.role = :trading_standards
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

  describe "#can_view_notification_history?" do
    it "is false for OPSS General users" do
      user.role = :opss_general
      expect(user).not_to be_can_view_notification_history
    end

    it "is true for OPSS Enforcement users" do
      user.role = :opss_enforcement
      expect(user).to be_can_view_notification_history
    end

    it "is true for OPSS IMT users" do
      user.role = :opss_imt
      expect(user).to be_can_view_notification_history
    end

    it "is true for Trading Standards users" do
      user.role = :trading_standards
      expect(user).to be_can_view_notification_history
    end

    it "is false for Poison Centre users" do
      user.role = :poison_centre
      expect(user).not_to be_can_view_notification_history
    end

    it "is false for OPSS Science users" do
      user.role = :opss_science
      expect(user).not_to be_can_view_notification_history
    end
  end
end
