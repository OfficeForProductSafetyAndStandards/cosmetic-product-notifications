require "rails_helper"

RSpec.describe Component, type: :model do
  let(:notification) { create(:notification) }
  let(:predefined_component) { create(:component) }
  let(:ranges_component) { create(:ranges_component) }
  let(:exact_component) { create(:exact_component) }
  let(:text_file) { fixture_file_upload("/testText.txt", "application/text") }

  describe "attributes" do
    subject(:component) { described_class.new }

    it "has a contains_poisonous_ingredients boolean" do
      expect(component).to have_attributes(contains_poisonous_ingredients: nil)
    end
  end

  describe "Notification Validation" do
    context "when notification is missing" do
      specify do
        component = described_class.new(name: "component x", notification: nil)
        expect { component.valid? }.to raise_error NoMethodError
      end
    end
  end

  describe "name validation" do
    context "when there is already a component with the same name for the same notification" do
      let(:component) { described_class.new(name: "Component X", notification: notification) }

      before do
        create(:component, name: "Component X", notification: notification)
      end

      it "is not valid" do
        expect(component).not_to be_valid
      end

      it "has an error message" do
        component.valid?
        expect(component.errors[:name]).to eql(["Enter an item name which has not been used for this notification"])
      end
    end

    context "when there is already a component with the same name but using uppercase for the same notification" do
      let(:component) { described_class.new(name: "Component X", notification: notification) }

      before do
        create(:component, name: "COMPONENT X", notification: notification)
      end

      it "is not valid" do
        expect(component).not_to be_valid
      end

      it "has an error message" do
        component.valid?
        expect(component.errors[:name]).to eql(["Enter an item name which has not been used for this notification"])
      end
    end

    context "when there is already a component with no name for the same notification" do
      let(:component) { described_class.new(name: nil, notification: notification) }

      before do
        create(:component, name: nil, notification: notification)
      end

      it "is valid" do
        expect(component).to be_valid
      end
    end

    context "when component belongs to single component notification" do
      let(:component) { described_class.new(name: "", notification: notification) }

      it "is valid" do
        expect(component).to be_valid
      end

      context "when component already exists" do
        before { component.save! }

        it "is valid" do
          expect(component).to be_valid
        end
      end
    end

    context "when component belongs to multi component notification" do
      let(:component) { described_class.new(name: "", notification: notification) }

      before do
        create(:component, name: "COMPONENT X", notification: notification)
      end

      context "when context is provided" do
        it "is not valid" do
          expect(component).not_to be_valid(:add_component_name)
        end

        it "has errors on name" do
          component.valid?(:add_component_name)
          expect(component.errors[:name]).to eql(["Name can not be blank"])
        end
      end

      context "when no context is provided" do
        it "is valid" do
          expect(component).to be_valid
        end
      end
    end
  end

  describe "formulation_required", :with_stubbed_antivirus do
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
      before { predefined_component.ph = "not_applicable" }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when lower than 3" do
      before { predefined_component.ph = "lower_than_3" }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when between 3 and 10" do
      before { predefined_component.ph = "between_3_and_10" }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when above 10" do
      before { predefined_component.ph = "above_10" }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when explicitly set to not given" do
      before { predefined_component.ph = "not_given" }

      it "is valid" do
        expect(predefined_component).to be_valid
      end
    end

    context "when set to any other value" do
      it "raises an argument error" do
        expect { predefined_component.ph = "zzzzzz" }.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#ph_range_not_required?" do
    subject { predefined_component.ph_range_not_required? }

    context "when not specified" do
      before { predefined_component.ph = nil }

      it { is_expected.to be false }
    end

    context "when not applicable" do
      before { predefined_component.ph = "not_applicable" }

      it { is_expected.to be true }
    end

    context "when lower than 3" do
      before { predefined_component.ph = "lower_than_3" }

      it { is_expected.to be false }
    end

    context "when between 3 and 10" do
      before { predefined_component.ph = "between_3_and_10" }

      it { is_expected.to be true }
    end

    context "when above 10" do
      before { predefined_component.ph = "above_10" }

      it { is_expected.to be false }
    end

    context "when explicitly set to not given" do
      before { predefined_component.ph = "not_given" }

      it { is_expected.to be false }
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

    context "when changing the pH answer after giving an explicit range" do
      before do
        # Explicit pH range given
        predefined_component.ph = "lower_than_3"
        predefined_component.minimum_ph = 2.0
        predefined_component.maximum_ph = 3.0

        # Answer changed to 'no pH'
        predefined_component.ph = "not_applicable"
      end

      it "removes the previous minimum pH" do
        expect(predefined_component.minimum_ph).to be_nil
      end

      it "removes the previous maximum pH" do
        expect(predefined_component.maximum_ph).to be_nil
      end
    end
  end

  describe "#poisonous_ingredients_answer" do
    let(:component) { build(:component) }

    it "returns nil if contains_poisonous_ingredients is nil" do
      expect(component.poisonous_ingredients_answer).to eq nil
    end

    it "returns 'Yes' if contains_poisonous_ingredients is true" do
      component.update(contains_poisonous_ingredients: true)
      expect(component.poisonous_ingredients_answer).to eq "Yes"
    end

    it "returns 'No' if contains_poisonous_ingredients is false" do
      component.update(contains_poisonous_ingredients: false)
      expect(component.poisonous_ingredients_answer).to eq "No"
    end
  end

  describe "select formulation", :with_stubbed_antivirus do
    context "when no formulation was selected before" do
      let(:component) { create(:component, notification_type: nil) }

      it "sets proper formulation" do
        component.update_formulation_type("range")

        expect(component.notification_type).to eq("range")
      end
    end

    context "when different then formulation was selected before frame formulation" do
      let(:component) { create(:component, :using_exact, :with_formulation_file) }

      before { component }

      it "sets proper formulation" do
        component.update_formulation_type("predefined")

        expect(component.notification_type).to eq("predefined")
      end

      it "deletes the file" do
        component.update_formulation_type("predefined")

        expect(component.reload.formulation_file).to be_blank
      end
    end

    context "when exact formulation was reselected" do
      let(:component) { create(:component, :using_exact, :with_formulation_file) }

      before { component }

      it "leaves the file" do
        component.update_formulation_type("range")

        expect(component.reload.formulation_file).to be_present
      end
    end

    context "when changing from frame formulation" do
      let(:component) { create(:component, :using_frame_formulation, contains_poisonous_ingredients: true) }

      it "removes frame formulation" do
        component.update_formulation_type("range")

        expect(component.reload.frame_formulation).to be_blank
      end

      it "removes information about poisonus ingredients" do
        component.update_formulation_type("range")

        expect(component.reload.contains_poisonous_ingredients).to eq nil
      end
    end

    describe "validation" do
      let(:component) { create(:component) }

      it "is invalid without value" do
        component.update_formulation_type(nil)

        expect(component.errors).to be_present
      end
    end
  end
end
