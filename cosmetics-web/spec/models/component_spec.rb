require 'rails_helper'

RSpec.describe Component, type: :model do
  let(:predefined_component) { create(:component) }
  let(:ranges_component) { create(:ranges_component) }
  let(:exact_component) { create(:exact_component) }
  let(:text_file) { fixture_file_upload('/testText.txt', 'application/text') }

  describe "attributes" do
    subject(:component) { described_class.new }

    it "has a contains_poisonous_ingredients boolean" do
      expect(component).to have_attributes(contains_poisonous_ingredients: nil)
    end
  end

  describe "formulation_required" do
    it "returns false for predefined formulation even if no file attached" do
      expect(predefined_component.formulation_required?).to be false
    end

    it "returns true for ranges formulation if no file attached" do
      expect(ranges_component.formulation_required?).to be true
    end

    it "returns false for ranges formulation if file is attached" do
      ranges_component.formulation_file.attach text_file
      expect(ranges_component.formulation_required?).to be false
    end

    it "returns false for ranges formulation if manually entered data present" do
      ranges_component.range_formulas.create
      expect(ranges_component.formulation_required?).to be false
    end

    it "returns true for exact formulation if no file attached" do
      expect(exact_component.formulation_required?).to be true
    end

    it "returns false for exact formulation if file is attached" do
      exact_component.formulation_file.attach text_file
      expect(exact_component.formulation_required?).to be false
    end

    it "returns false for exact formulation if manually entered data present" do
      exact_component.exact_formulas.create
      expect(exact_component.formulation_required?).to be false
    end
  end


  describe "updating special_applicator" do
    it "adds errors if special_applicator updated to be blank" do
      predefined_component.special_applicator = nil
      predefined_component.save(context: :select_special_applicator_type)

      expect(predefined_component.errors[:special_applicator]).to include("Choose an option")
    end

    it "adds errors if other_special_applicator updated to be blank and it contains other applicator" do
      predefined_component.special_applicator = "other"
      predefined_component.other_special_applicator = nil
      predefined_component.save(context: :select_special_applicator_type)

      expect(predefined_component.errors[:other_special_applicator]).to include("Enter the type of applicator")
    end

    it "removes other_special_applicator if the applicator type is not other" do
      predefined_component.special_applicator = "encapsulated products"
      predefined_component.other_special_applicator = "a package"
      predefined_component.save

      expect(predefined_component.other_special_applicator).to be_nil
    end
  end
end
