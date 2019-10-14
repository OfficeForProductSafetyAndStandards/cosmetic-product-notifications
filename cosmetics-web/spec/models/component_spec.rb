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

  describe "#ph" do
    context "when not specified" do
      before { predefined_component.ph = nil }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when not specified but with the :ph context" do
      before { predefined_component.ph = nil }

      it "is not valid" do
        expect(predefined_component.valid?(:ph)).to be false
      end
    end

    context "when not applicable" do
      before { predefined_component.ph = 'not_applicable' }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when lower than 3" do
      before { predefined_component.ph = 'lower_than_3' }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when between 3 and 10" do
      before { predefined_component.ph = 'between_3_and_10' }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when above 10" do
      before { predefined_component.ph = 'above_10' }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when explicitly set to not given" do
      before { predefined_component.ph = 'not_given' }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when set to any other value" do
      it "raises an argument error" do
        expect { predefined_component.ph = 'zzzzzz' }.to raise_exception(ArgumentError)
      end
    end
  end

  describe "adding PH ranges" do
    context "with integers within strings" do
      before do
        predefined_component.minimum_ph = " 2 "
        predefined_component.maximum_ph = " 3 "
      end

      it "is valid" do
        expect(predefined_component).to be_valid
      end

      it "sets the minimum pH" do
        expect(predefined_component.minimum_ph).to be(2.0)
      end

      it "sets the maximum pH" do
        expect(predefined_component.maximum_ph).to be(3.0)
      end
    end

    context "with decimals within strings" do
      before do
        predefined_component.minimum_ph = " 1.1 "
        predefined_component.maximum_ph = " 2.03 "
      end

      it "is valid" do
        expect(predefined_component).to be_valid
      end

      it "sets the minimum pH" do
        expect(predefined_component.minimum_ph).to be(1.1)
      end

      it "sets the maximum pH" do
        expect(predefined_component.maximum_ph).to be(2.03)
      end
    end

    it "adds an error if only minimum PH is present" do
      predefined_component.minimum_ph = 2.1

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:maximum_ph]).to include("Enter a maximum pH")
    end

    it "adds an error if only maximum PH is present" do
      predefined_component.maximum_ph = 11.2

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:minimum_ph]).to include("Enter a minimum pH")
    end

    it "adds an error if maximum PH is below minimum PH" do
      predefined_component.minimum_ph = 3.2
      predefined_component.maximum_ph = 3.1

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:maximum_ph]).to include("The maximum pH must be the same or higher than the minimum pH")
    end

    it "adds an error if minimum PH is below 0" do
      predefined_component.minimum_ph = -0.1

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:minimum_ph]).to include("Enter a value of 0 or higher for minimum pH")
    end

    it "adds an error if minimum PH is above 14" do
      predefined_component.minimum_ph = 14.01

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:minimum_ph]).to include("Enter a value of 14 or lower for minimum pH")
    end

    it "adds an error if maximum PH is below 0  " do
      predefined_component.maximum_ph = -0.1

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:maximum_ph]).to include("Enter a value of 0 or higher for maximum pH")
    end

    it "adds an error if maximum PH is above 14" do
      predefined_component.maximum_ph = 14.01

      expect(predefined_component).not_to be_valid
      expect(predefined_component.errors[:maximum_ph]).to include("Enter a value of 14 or lower for maximum pH")
    end


    it "adds an error if minimum_ph is missing when valid? called with ph_range" do
      predefined_component.minimum_ph = nil

      expect(predefined_component).not_to be_valid(:ph_range)
      expect(predefined_component.errors[:minimum_ph]).to include("Enter a minimum pH")
    end

    it "adds an error if maximum_ph is missing when valid? called with ph_range" do
      predefined_component.maximum_ph = nil

      expect(predefined_component).not_to be_valid(:ph_range)
      expect(predefined_component.errors[:maximum_ph]).to include("Enter a maximum pH")
    end

    it "adds an error if minimum_ph is unparseable string" do
      predefined_component.minimum_ph = "N/A"

      expect(predefined_component).not_to be_valid(:ph_range)
      expect(predefined_component.errors[:minimum_ph]).to include("Enter a minimum pH")
    end

    it "adds an error if maximum_ph is unparseable string" do
      predefined_component.maximum_ph = "N/A"

      expect(predefined_component).not_to be_valid(:ph_range)
      expect(predefined_component.errors[:maximum_ph]).to include("Enter a maximum pH")
    end

    it "adds an error if difference between minimum and maximum pH is more than 1" do
      predefined_component.minimum_ph = 2.0
      predefined_component.maximum_ph = 3.01

      expect(predefined_component).not_to be_valid(:ph_range)
      expect(predefined_component.errors[:maximum_ph]).to include("The maximum pH cannot be more than 1 higher than the minimum pH")
    end
  end
end
