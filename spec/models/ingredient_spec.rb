require "rails_helper"

RSpec.describe Ingredient, type: :model do
  describe "validations" do
    describe "name length validation" do
      it "is not valid when name is too long" do
        ingredient = build(:range_ingredient, inci_name: "A" * 2 * Ingredient::NAME_LENGTH_LIMIT)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Ingredient name must be 100 characters or less"])
      end

      it "is valid when name is too long on update" do
        ingredient = build(:range_ingredient, inci_name: "A" * 2 * Ingredient::NAME_LENGTH_LIMIT)
        ingredient.save(validate: false)
        expect(ingredient).to be_valid
      end
    end

    describe "name validations" do
      it "is not valid without name" do
        ingredient = build_stubbed(:exact_ingredient, inci_name: nil)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a name"])
      end

      it "is invalid when name includes 'http'" do
        ingredient = build_stubbed(:exact_ingredient, inci_name: "Soap http://example.com")
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a valid ingredient name"])
      end

      it "is invalid when name includes 'www'" do
        ingredient = build_stubbed(:exact_ingredient, inci_name: "Soap www.example.com")
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a valid ingredient name"])
      end

      it "is invalid when name includes '</'" do
        ingredient = build_stubbed(:exact_ingredient, inci_name: "<script>Soap</script>")
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a valid ingredient name"])
      end

      it "is invalid when an ingredient with the same name exists in the same component" do
        component = create(:ranges_component)
        create(:range_ingredient, inci_name: "A", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "A", component:)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a name which is unique to this component"])
      end

      it "is invalid when an ingredient with name differing in capitalisation exists in the same component" do
        component = create(:ranges_component)
        create(:range_ingredient, inci_name: "a", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "A", component:)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter a name which is unique to this component"])
      end

      it "is valid when an ingredient with name differing in spacing exists in the same component" do
        component = create(:ranges_component)
        create(:range_ingredient, inci_name: "Ingredient A", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "Ingredient  A", component:)
        expect(ingredient).to be_valid
      end

      it "is valid when an ingredient with same name exists in different component" do
        create(:range_ingredient, inci_name: "Ingredient A")
        ingredient = build(:poisonous_ingredient, inci_name: "Ingredient  A")
        expect(ingredient).to be_valid
      end

      it "is valid when an ingredient with the same name exists in the same component for a deleted notification" do
        component = build(:ranges_component, notification: build(:notification, :deleted))
        create(:range_ingredient, inci_name: "A", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "A", component:)
        expect(ingredient).to be_valid
      end

      it "is valid when an ingredient with the same name exists in the same component for a legacy zip imported notification" do
        component = create(:ranges_component, notification: create(:notification, cpnp_reference: "3796528"))
        create(:range_ingredient, inci_name: "A", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "A", component:)
        expect(ingredient).to be_valid
      end
    end

    describe "validate range concentrations" do
      let(:ingredient) do
        build(:range_ingredient,
              minimum_concentration:, maximum_concentration:, poisonous: false)
      end

      context "when the maximum concentration is equal to the minimum concentration" do
        let(:minimum_concentration) { 1 }
        let(:maximum_concentration) { 1 }

        it "is valid" do
          ingredient.valid?
          expect(ingredient).to be_valid
        end
      end

      context "when the maximum concentration is less than the minimum concentration" do
        let(:minimum_concentration) { 1 }
        let(:maximum_concentration) { 0.1 }

        it "is not valid" do
          ingredient.valid?
          expect(ingredient.errors[:maximum_concentration]).to include("Maximum concentration must be greater than the minimum concentration")
        end
      end

      context "when the maximum concentration is greater than the minimum concentration" do
        let(:minimum_concentration) { 1 }
        let(:maximum_concentration) { 1.1 }

        it "is valid" do
          ingredient.valid?
          expect(ingredient).to be_valid
        end
      end

      context "when the minimum concentration is negative" do
        let(:minimum_concentration) { -0.1 }
        let(:maximum_concentration) { 1 }

        it "is not valid" do
          ingredient.valid?
          expect(ingredient.errors[:minimum_concentration]).to include("Enter a minimum concentration greater than or equal to 0")
        end
      end

      context "when the maximum concentration is zero" do
        let(:minimum_concentration) { 0 }
        let(:maximum_concentration) { 0 }

        it "is not valid" do
          ingredient.valid?
          expect(ingredient.errors[:maximum_concentration]).to include("Enter a maximum concentration greater than 0")
        end
      end
    end

    describe "used for multiple shades validation" do
      RSpec.shared_examples "valid with a value" do
        context "when the ingredient is used for multiple shades" do
          let(:used_for_multiple_shades) { true }

          it { expect(ingredient).to be_valid }
        end

        context "when the ingredient is not used for multiple shades" do
          let(:used_for_multiple_shades) { false }

          it { expect(ingredient).to be_valid }
        end
      end

      RSpec.shared_examples "valid without a value" do
        context "when not specifying if the ingredient is used for multiple shades" do
          let(:used_for_multiple_shades) { nil }

          it { expect(ingredient).to be_valid }
        end
      end

      RSpec.shared_examples "invalid without a value" do
        context "when not specifying if the ingredient is used for multiple shades" do
          let(:used_for_multiple_shades) { nil }

          it "is not valid" do
            expect(ingredient).not_to be_valid
            expect(ingredient.errors[:used_for_multiple_shades])
              .to eq(["Select yes if the ingredient is used for different shades"])
          end
        end
      end

      context "with a range ingredient" do
        let(:component) { build_stubbed(:ranges_component, :with_multiple_shades) }
        let(:ingredient) { build_stubbed(:range_ingredient, component:, used_for_multiple_shades:) }

        include_examples "valid with a value"
        include_examples "valid without a value"
      end

      context "with an exact ingredient" do
        let(:ingredient) { build_stubbed(:exact_ingredient, :poisonous, component:, used_for_multiple_shades:) }

        context "with a multi-shade exact component" do
          let(:component) { build_stubbed(:exact_component, :with_multiple_shades, notification_type: "exact") }

          include_examples "valid with a value"
          include_examples "invalid without a value"
        end

        context "with a multi-shade range component" do
          let(:component) { build_stubbed(:exact_component, :with_multiple_shades, notification_type: "range") }

          include_examples "valid with a value"
          include_examples "valid without a value"
        end

        context "with a multi-shade predefined component" do
          let(:component) { build_stubbed(:exact_component, :with_multiple_shades, notification_type: "predefined") }

          include_examples "valid with a value"
          include_examples "invalid without a value"
        end

        context "with a non multi-shade exact component" do
          let(:component) { build_stubbed(:exact_component) }

          include_examples "valid with a value"
          include_examples "valid without a value"
        end

        context "with a non multi-shade range component" do
          let(:component) { build_stubbed(:ranges_component) }

          include_examples "valid with a value"
          include_examples "valid without a value"
        end

        context "with a non multi-shade predefined component" do
          let(:component) { build_stubbed(:predefined_component) }

          include_examples "valid with a value"
          include_examples "valid without a value"
        end
      end
    end
  end
end
