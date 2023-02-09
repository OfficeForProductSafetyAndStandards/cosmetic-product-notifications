require "rails_helper"

RSpec.describe Ingredient, type: :model do
  describe "validations" do
    describe "name length validation" do
      it "is not valid when name is too long" do
        ingredient = build(:range_ingredient, inci_name: "A" * 2 * Ingredient::NAME_LENGTH_LIMIT)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Inci name is too long (maximum is 100 characters)"])
      end

      it "is valid when name is too long on update" do
        ingredient = build(:range_ingredient, inci_name: "A" * 2 * Ingredient::NAME_LENGTH_LIMIT)
        ingredient.save(validate: false)
        expect(ingredient).to be_valid
      end
    end

    describe "range or exact concentration validation" do
      # rubocop:disable RSpec/MultipleExpectations
      it "is not valid when both exact and range concentrations are set" do
        ingredient = build_stubbed(:range_ingredient, exact_concentration: 5.0)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:range_concentration]).to eq(["Cannot have both exact and range concentrations"])
        expect(ingredient.errors[:exact_concentration]).to eq(["Cannot have both exact and range concentrations"])
      end

      it "is not valid when neither exact or range concentration are set" do
        ingredient = build_stubbed(:ingredient, exact_concentration: nil, range_concentration: nil)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:exact_concentration]).to eq(["Enter the concentration"])
        expect(ingredient.errors[:range_concentration]).to eq(["Enter the concentration"])
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    describe "poisonous ingredient validations" do
      it "is not valid when a poisonous ingredient has a range concentration" do
        ingredient = build_stubbed(:range_ingredient, poisonous: true)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:poisonous]).to eq(["ingredients with range concentration cannot be poisonous"])
      end

      it "is valid when a poisonous ingredient has an exact concentration" do
        ingredient = build_stubbed(:poisonous_ingredient, exact_concentration: 2)
        expect(ingredient).to be_valid
      end
    end

    describe "ingredient/component types validations" do
      it "is valid when a range ingredient belongs to a range component" do
        ingredient = build_stubbed(:range_ingredient, component: build_stubbed(:ranges_component))
        expect(ingredient).to be_valid
      end

      it "is valid when a poisonous exact ingredient belongs to a range component" do
        ingredient = build_stubbed(:poisonous_ingredient, component: build_stubbed(:ranges_component))
        expect(ingredient).to be_valid
      end

      it "is valid when a poisonous exact ingredient belongs to a predefined component" do
        ingredient = build_stubbed(:poisonous_ingredient, component: build_stubbed(:predefined_component))
        expect(ingredient).to be_valid
      end

      it "is not valid when a range ingredient belongs to an exact component" do
        ingredient = build_stubbed(:range_ingredient, component: build_stubbed(:exact_component))
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:range_concentration])
          .to eq(["ingredient with range concentration must belong to a range component"])
      end

      it "is not valid when a range ingredient belongs to a predefined component" do
        ingredient = build_stubbed(:range_ingredient, component: build_stubbed(:predefined_component))
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:range_concentration])
          .to eq(["ingredient with range concentration must belong to a range component"])
      end

      it "is not valid when a non poisonous exact ingredient belongs to a range component" do
        ingredient = build_stubbed(:exact_ingredient, poisonous: false, component: build_stubbed(:ranges_component))
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:exact_concentration])
          .to eq(["non poisonous exact ingredients must belong to a exact component"])
      end

      it "is not valid when a non poisonous exact ingredient belongs to a predefined component" do
        ingredient = build_stubbed(:exact_ingredient, poisonous: false, component: build_stubbed(:predefined_component))
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:exact_concentration])
          .to eq(["non poisonous exact ingredients must belong to a exact component"])
      end
    end

    describe "name validations" do
      it "is not valid without name" do
        ingredient = build_stubbed(:exact_ingredient, inci_name: nil)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Enter an ingredient name"])
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
        expect(ingredient.errors[:inci_name]).to eq(["Ingredient name already exists in this component"])
      end

      it "is invalid when an ingredient with name differing in capitalisation exists in the same component" do
        component = create(:ranges_component)
        create(:range_ingredient, inci_name: "a", component:)
        ingredient = build(:poisonous_ingredient, inci_name: "A", component:)
        expect(ingredient).not_to be_valid
        expect(ingredient.errors[:inci_name]).to eq(["Ingredient name already exists in this component"])
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
  end

  describe ".unique_names_by_created_last" do
    let(:ingredient1) { create(:exact_ingredient, inci_name: "NaCl", created_at: 2.days.ago) }
    let(:ingredient2) { create(:exact_ingredient, inci_name: "Aqua", created_at: 1.week.ago) }
    let(:ingredient3) { create(:exact_ingredient, inci_name: "Sodium", created_at: 2.weeks.ago) }
    let(:ingredient4) { create(:exact_ingredient, inci_name: "Aqua", created_at: 3.weeks.ago) }

    before do
      ingredient1
      ingredient2
      ingredient3
      ingredient4
    end

    it "returns unique ingredients from newest to oldest creation" do
      expect(described_class.unique_names_by_created_last.map(&:id))
        .to eq([ingredient1.id, ingredient3.id, ingredient4.id])
    end
  end
end
