require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::IngredientConcentrationForm do
  subject(:form) do
    described_class.new(component: component,
                        type: type,
                        name: name,
                        cas_number: cas_number,
                        exact_concentration: exact_concentration,
                        range_concentration: range_concentration,
                        poisonous: poisonous)
  end

  let(:component) { create(:component) }
  let(:name) { "Ingredient Name" }
  let(:cas_number) { "111-11-1" }
  let(:exact_concentration) { "4.2" }
  let(:range_concentration) { nil }
  let(:poisonous) { "1" }
  let(:type) { "exact" }

  describe "#initialize" do
    context "with a 'range' type" do
      let(:type) { "range" }

      context "with a poisonous ingredient" do
        let(:poisonous) { "true" }

        it "changes the type to 'exact'" do
          expect(form.type).to eq("exact")
        end
      end

      context "with a non poisonous ingredient" do
        let(:poisonous) { "false" }

        it { expect(form.type).to eq("range") }
      end
    end

    context "with an 'exact' type" do
      let(:type) { "exact" }

      context "with a poisonous ingredient" do
        let(:poisonous) { "true" }

        it { expect(form.type).to eq("exact") }
      end

      context "with a non poisonous ingredient" do
        let(:poisonous) { "false" }

        it { expect(form.type).to eq("exact") }
      end
    end
  end

  describe "validation" do
    it "is invalid without a component" do
      form.component = ""
      expect(form).not_to be_valid
      expect(form.errors[:component]).to eq ["Provide a component to associate the ingredient to"]
    end

    it "is invalid without a type" do
      form.type = ""
      expect(form).not_to be_valid
      expect(form.errors[:type]).to eq ["Type must be 'exact' or 'range'"]
    end

    it "is invalid with a non approved type" do
      form.type = "foo"
      expect(form).not_to be_valid
      expect(form.errors[:type]).to eq ["Type must be 'exact' or 'range'"]
    end

    it "is invalid without a name" do
      form.name = ""
      expect(form).not_to be_valid
      expect(form.errors[:name]).to eq ["Enter a name"]
    end

    it "is valid when poisonous is not present" do
      form.poisonous = nil
      expect(form).to be_valid
    end

    it "is valid when cas number is not present" do
      form.cas_number = nil
      expect(form).to be_valid
    end

    it "is not valid for cas number with wrong formatting" do
      form.cas_number = "111111-11-11"
      expect(form).not_to be_valid
      expect(form.errors[:cas_number]).to eq ["CAS number is invalid"]
    end

    describe "exact concentration validation" do
      context "with an 'exact' type" do
        let(:type) { "exact" }

        it "is invalid without an exact concentration" do
          form.exact_concentration = ""
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter the concentration"]
        end

        it "is not valid when the concentration is not a number" do
          form.exact_concentration = "not a number"
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a number for the concentration"]
        end

        it "is not valid when the concentration is 0" do
          form.exact_concentration = 0.0
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a number for the concentration"]
        end
      end

      context "with an 'range' type" do
        let(:type) { "range" }
        let(:poisonous) { "false" }
        let(:range_concentration) { "greater_than_10_less_than_25_percent" }

        it "is valid without an exact concentration" do
          form.exact_concentration = ""
          expect(form).to be_valid
        end

        it "is valid when the concentration is not a number" do
          form.exact_concentration = "not a number"
          expect(form).to be_valid
        end

        it "is valid when the concentration is 0" do
          form.exact_concentration = 0.0
          expect(form).to be_valid
        end
      end
    end

    describe "range concentration validation" do
      context "with an 'exact' type" do
        let(:type) { "exact" }

        it "is valid without a range concentration" do
          form.range_concentration = ""
          expect(form).to be_valid
        end
      end

      context "with an 'range' type" do
        let(:type) { "range" }
        let(:poisonous) { "false" }

        it "is valid without an exact concentration" do
          form.range_concentration = ""
          expect(form).not_to be_valid
          expect(form.errors[:range_concentration]).to eq ["Select a concentration range"]
        end
      end
    end

    describe "name taken validation" do
      RSpec.shared_examples "name taken validations" do
        %i[exact_formula range_formula].each do |ingredient_type|
          it "is invalid when the ingredient already exists as #{ingredient_type} for the component" do
            create(ingredient_type, component: component, inci_name: name)
            expect(form).not_to be_valid
            expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
          end

          it "is valid when the ingredient already exists as #{ingredient_type} for a different component in the same notification" do
            component2 = create(:component, notification: component.notification)
            create(ingredient_type, component: component2, inci_name: name)
          end

          it "is invalid when the ingredient differs only in capitalisation from an existing component #{ingredient_type} ingredient" do
            create(ingredient_type, component: component, inci_name: name.downcase)
            expect(form).not_to be_valid
            expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
          end

          it "is invalid when the ingredient differs only in leading/trailing espaces from an existing component #{ingredient_type} ingredient" do
            create(ingredient_type, component: component, inci_name: name)
            form.name = " #{name} "
            expect(form).not_to be_valid
            expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
          end

          it "shows a specific error message for already existing name for #{ingredient_type} ingredient in the multicomponent notification" do
            allow(component.notification).to receive(:is_multicomponent?).and_return(true)
            create(ingredient_type, component: component, inci_name: name)
            expect(form).not_to be_valid
            expect(form.errors[:name]).to eq ["Enter a name which is unique to this item"]
          end
        end
      end

      context "with an 'exact' type" do
        let(:type) { "exact" }

        include_examples "name taken validations"
      end

      context "with a 'range' type" do
        let(:type) { "range" }

        include_examples "name taken validations"
      end
    end
  end

  describe "#range?" do
    it "returns true when the type is 'range'" do
      form.type = "range"
      expect(form.range?).to eq true
    end

    it "returns false when the type is 'exact'" do
      form.type = "exact"
      expect(form.range?).to eq false
    end
  end

  describe "#exact?" do
    it "returns true when the type is 'exact'" do
      form.type = "exact"
      expect(form.exact?).to eq true
    end

    it "returns false when the type is 'range'" do
      form.type = "range"
      expect(form.exact?).to eq false
    end
  end

  describe "#save" do
    context "when the form has no component" do
      let(:component) { nil }

      it "returns false" do
        expect(form.save).to be false
      end

      it "does not create an ingredient record" do
        expect { form.save }.to not_change(ExactFormula, :count)
                            .and not_change(RangeFormula, :count)
      end
    end

    context "when the form is invalid" do
      let(:name) { "" }

      it "returns false" do
        expect(form.save).to eq false
      end

      it "does not create an ingredient record" do
        expect { form.save }.to not_change(ExactFormula, :count)
                            .and not_change(RangeFormula, :count)
      end
    end

    context "with an exact type form" do
      let(:type) { "exact" }

      it "creates an exact formula" do
        expect { form.save }.to change(ExactFormula, :count).by(1)
      end

      it "does not create a range formula" do
        expect { form.save }.not_to change(RangeFormula, :count)
      end

      # rubocop :disable RSpec/ExampleLength
      it "returns the created exact formula" do
        expect(form.save).to be_an_instance_of(ExactFormula).and have_attributes(
          component_id: component.id,
          inci_name: name,
          quantity: exact_concentration.to_f,
          cas_number: "111111",
          poisonous: true,
        )
      end
      # rubocop :enable RSpec/ExampleLength
    end

    context "with a range type form" do
      let(:type) { "range" }
      let(:poisonous) { "false" }
      let(:range_concentration) { "greater_than_10_less_than_25_percent" }

      it "creates an range formula" do
        expect { form.save }.to change(RangeFormula, :count).by(1)
      end

      it "does not create an exact formula" do
        expect { form.save }.not_to change(ExactFormula, :count)
      end

      it "returns the created exact formula" do
        expect(form.save).to be_an_instance_of(RangeFormula).and have_attributes(
          component_id: component.id,
          inci_name: name,
          range: range_concentration,
          cas_number: "111111",
        )
      end
    end
  end
end
