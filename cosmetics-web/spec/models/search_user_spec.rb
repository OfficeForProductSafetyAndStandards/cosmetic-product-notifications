require "rails_helper"

RSpec.describe SearchUser, type: :model do
  subject(:user) { create(:search_user) }

  include_examples "common user tests"

  describe "validations" do
    it "validates the format of new_email" do
      user.new_email = "wrongformat"
      expect(user).not_to be_valid
      expect(user.errors[:new_email])
        .to include("Enter an email address in the correct format, like name@example.com")
    end
  end

  describe "#can_view_product_ingredients?" do
    context "when the user has specific roles" do
      it "is false for OPSS General users" do
        user.add_role(:opss_general)
        expect(user.can_view_product_ingredients?).to be false
      end

      it "is true for OPSS Enforcement users" do
        user.add_role(:opss_enforcement)
        expect(user.can_view_product_ingredients?).to be true
      end

      it "is true for OPSS IMT users" do
        user.add_role(:opss_imt)
        expect(user.can_view_product_ingredients?).to be true
      end

      it "is false for Trading Standards users" do
        user.add_role(:trading_standards)
        expect(user.can_view_product_ingredients?).to be false
      end

      it "is true for Poison Centre users" do
        user.add_role(:poison_centre)
        expect(user.can_view_product_ingredients?).to be true
      end

      it "is true for OPSS Science users" do
        user.add_role(:opss_science)
        expect(user.can_view_product_ingredients?).to be true
      end
    end
  end

  describe "#can_search_for_ingredients?" do
    it "is false for OPSS General users" do
      user.add_role(:opss_general)
      expect(user.can_search_for_ingredients?).to be false
    end

    context "when the user has other roles" do
      %i[opss_enforcement opss_imt trading_standards poison_centre opss_science].each do |role|
        it "is true for #{role} role" do
          user.add_role(role)
          expect(user.can_search_for_ingredients?).to be true
          user.roles.destroy_all
        end
      end
    end
  end

  describe "#can_view_nanomaterial_notification_files?" do
    context "when the user does not have OPSS Science role" do
      %i[opss_general opss_enforcement opss_imt trading_standards poison_centre].each do |role|
        it "is false for #{role} role" do
          user.add_role(role)
          expect(user.can_view_nanomaterial_notification_files?).to be false
          user.roles.destroy_all
        end
      end
    end

    it "is true for OPSS Science users" do
      user.add_role(:opss_science)
      expect(user.can_view_nanomaterial_notification_files?).to be true
    end
  end

  describe "#can_view_nanomaterial_review_period_end_date?" do
    context "when the user has certain roles" do
      %i[opss_general opss_enforcement opss_imt trading_standards opss_science].each do |role|
        it "is true for #{role} role" do
          user.add_role(role)
          expect(user.can_view_nanomaterial_review_period_end_date?).to be true
          user.roles.destroy_all
        end
      end
    end

    it "is false for Poison Centre users" do
      user.add_role(:poison_centre)
      expect(user.can_view_nanomaterial_review_period_end_date?).to be false
    end
  end

  describe "#can_view_notification_history?" do
    context "when the user has roles that can view history" do
      %i[opss_enforcement opss_imt trading_standards].each do |role|
        it "is true for #{role} role" do
          user.add_role(role)
          expect(user.can_view_notification_history?).to be true
          user.roles.destroy_all
        end
      end
    end

    context "when the user has other roles" do
      %i[opss_general poison_centre opss_science].each do |role|
        it "is false for #{role} role" do
          user.add_role(role)
          expect(user.can_view_notification_history?).to be false
          user.roles.destroy_all
        end
      end
    end
  end
end
