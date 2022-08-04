require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::IngredientConcentrationForm do
  subject(:form) do
    described_class.new(component: component,
                        type: type,
                        name: name,
                        cas_number: cas_number,
                        exact_concentration: exact_concentration,
                        range_concentration: range_concentration,
                        poisonous: poisonous,
                        updating_ingredient: updating_ingredient,
                        ingredient_number: nil)
  end

  let(:component) { create(:exact_component) }
  let(:name) { "Ingredient Name" }
  let(:cas_number) { "111-11-1" }
  let(:exact_concentration) { "4.2" }
  let(:range_concentration) { "greater_than_10_less_than_25_percent" }
  let(:poisonous) { "true" }
  let(:type) { "exact" }
  let(:updating_ingredient) { nil }

  describe "#initialize" do
    context "with a 'range' type" do
      let(:type) { "range" }

      context "with a poisonous ingredient" do
        let(:poisonous) { "true" }

        it "changes the type to 'exact'" do
          expect(form.type).to eq("exact")
        end

        it "deletes any given range concentration value" do
          expect(form.range_concentration).to eq nil
        end
      end

      context "with a non poisonous ingredient" do
        let(:poisonous) { "false" }

        it { expect(form.type).to eq("range") }

        it "deletes any given exact concentration value" do
          expect(form.exact_concentration).to eq nil
        end
      end
    end

    context "with an 'exact' type" do
      let(:type) { "exact" }

      context "with a poisonous ingredient" do
        let(:poisonous) { "true" }

        it { expect(form.type).to eq("exact") }

        it "deletes any given range concentration value" do
          expect(form.range_concentration).to eq nil
        end
      end

      context "with a non poisonous ingredient" do
        let(:poisonous) { "false" }

        it { expect(form.type).to eq("exact") }

        it "deletes any given range concentration value" do
          expect(form.range_concentration).to eq nil
        end
      end
    end

    context "without a type" do
      let(:type) { nil }

      context "with a poisonous ingredient" do
        let(:poisonous) { "true" }

        it { expect(form.type).to eq(nil) }

        it "keeps the given exact concentration value" do
          expect(form.exact_concentration).to eq exact_concentration
        end

        it "keeps the given range concentration value" do
          expect(form.range_concentration).to eq range_concentration
        end
      end

      context "with a non poisonous ingredient" do
        let(:poisonous) { "false" }

        it { expect(form.type).to eq(nil) }

        it "keeps the given exact concentration value" do
          expect(form.exact_concentration).to eq exact_concentration
        end

        it "keeps the given range concentration value" do
          expect(form.range_concentration).to eq range_concentration
        end
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

    it "is valid when cas number is not present" do
      form.cas_number = nil
      expect(form).to be_valid
    end

    it "is not valid for cas number with wrong formatting" do
      form.cas_number = "111111-11-11"
      expect(form).not_to be_valid
      expect(form.errors[:cas_number]).to eq ["CAS number is invalid"]
    end

    describe "poisonous validation" do
      context "when the poisonous value is not present" do
        let(:poisonous) { nil }

        context "with an 'exact' type" do
          let(:type) { "exact" }

          it { expect(form).to be_valid }
        end

        context "with a 'range' type" do
          let(:type) { "range" }
          let(:component) { create(:ranges_component) }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:poisonous]).to eq ["Select yes if the ingredient is poisonous"]
          end
        end
      end
    end

    describe "exact concentration validation" do
      context "with an 'exact' type" do
        let(:type) { "exact" }

        it "is valid with 0.1 as concentration" do
          form.exact_concentration = "0.1"
          expect(form).to be_valid
        end

        it "is valid with 100 as concentration" do
          form.exact_concentration = "100"
          expect(form).to be_valid
        end

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

        it "is not valid when the concentration contains extra characters mixed with a number" do
          form.exact_concentration = "58:0887"
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a number for the concentration"]
        end

        it "is not valid when the concentration is 0" do
          form.exact_concentration = "0.0"
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a concentration greater than 0"]
        end

        it "is not valid when the concentration is a negative number" do
          form.exact_concentration = "-3.5"
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a concentration greater than 0"]
        end

        it "is not valid when the concentration is greater than 100" do
          form.exact_concentration = "100.1"
          expect(form).not_to be_valid
          expect(form.errors[:exact_concentration]).to eq ["Enter a concentration less than or equal to 100"]
        end
      end

      context "with a 'range' type" do
        let(:type) { "range" }
        let(:component) { create(:ranges_component) }
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

      context "with a 'range' type" do
        let(:type) { "range" }
        let(:component) { create(:ranges_component) }
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
        let(:ingredient_factory) { type == "exact" ? :exact_ingredient : :range_ingredient }

        context "when updgrading an existing ingredient keeping the same name" do
          let(:updating_ingredient) { create(ingredient_factory, inci_name: name, component: component) }

          it { expect(form).to be_valid }
        end

        context "when updgrading an existing ingredient name to different capitalisation" do
          let(:updating_ingredient) { create(ingredient_factory, inci_name: name.upcase, component: component) }

          it { expect(form).to be_valid }
        end

        it "is valid when the ingredient already exists for a different component in the same notification" do
          component_factory = type == "exact" ? :exact_component : :ranges_component
          different_component = create(component_factory, notification: component.notification)
          create(ingredient_factory, component: different_component, inci_name: name)
          expect(form).to be_valid
        end

        it "is invalid when the ingredient already exists for the component" do
          create(ingredient_factory, component: component, inci_name: name)
          expect(form).not_to be_valid
          expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
        end

        it "is invalid when the ingredient differs only in capitalisation from an existing component ingredient" do
          create(ingredient_factory, component: component, inci_name: name.downcase)
          expect(form).not_to be_valid
          expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
        end

        it "is invalid when the ingredient differs only in leading/trailing espaces from an existing component ingredient" do
          create(ingredient_factory, component: component, inci_name: name)
          form.name = " #{name} "
          expect(form).not_to be_valid
          expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
        end

        it "shows a specific error message for already existing name for ingredient in the multicomponent notification" do
          allow(component.notification).to receive(:is_multicomponent?).and_return(true)
          create(ingredient_factory, component: component, inci_name: name)
          expect(form).not_to be_valid
          expect(form.errors[:name]).to eq ["Enter a name which is unique to this item"]
        end
      end

      context "with an 'exact' type" do
        let(:type) { "exact" }

        include_examples "name taken validations"
      end

      context "with a 'range' type" do
        let(:type) { "range" }
        let(:component) { create(:ranges_component) }

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
        expect { form.save }.to not_change(Ingredient, :count)
      end
    end

    context "when the form is invalid" do
      let(:name) { "" }

      it "returns false" do
        expect(form.save).to eq false
      end

      it "does not create an ingredient record" do
        expect { form.save }.to not_change(Ingredient, :count)
      end
    end

    context "with an exact type form" do
      let(:type) { "exact" }

      it "creates an ingredient" do
        expect { form.save }.to change(Ingredient, :count).by(1)
      end

      # rubocop:disable RSpec/ExampleLength
      it "returns the created ingredient" do
        expect(form.save).to be_an_instance_of(Ingredient).and have_attributes(
          component_id: component.id,
          inci_name: name,
          exact_concentration: exact_concentration.to_f,
          range_concentration: nil,
          cas_number: "111111",
          poisonous: true,
        )
      end
      # rubocop:enable RSpec/ExampleLength

      context "when updating an exact ingredient" do
        let!(:updating_ingredient) do
          create(:ingredient, inci_name: "Ingredient pre-update", exact_concentration: 2.0, poisonous: false, component: component)
        end

        it "does not create a new ingredient" do
          expect { form.save }.to not_change(Ingredient, :count)
        end

        it "updates the existing ingredient values" do
          expect { form.save }
            .to change(updating_ingredient, :inci_name).from("Ingredient pre-update").to(name)
            .and change(updating_ingredient, :exact_concentration).from(2.0).to(exact_concentration.to_f)
            .and change(updating_ingredient, :poisonous).from(false).to(true)
            .and change(updating_ingredient, :cas_number).from(nil).to("111111")
        end
      end

      context "when updating a range ingredient" do
        let(:component) { create(:ranges_component) }
        let!(:updating_ingredient) do
          create(:ingredient,
                 inci_name: "Ingredient pre-update",
                 range_concentration: "greater_than_5_less_than_10_percent",
                 component: component)
        end

        it "does not create a new ingredient" do
          expect { form.save }.to not_change(Ingredient, :count)
        end

        it "updates the ingredient" do
          expect { form.save }
            .to change(updating_ingredient, :inci_name).from("Ingredient pre-update").to(name)
            .and change(updating_ingredient, :exact_concentration).from(nil).to(exact_concentration.to_f)
            .and change(updating_ingredient, :range_concentration).from("greater_than_5_less_than_10_percent").to(nil)
            .and change(updating_ingredient, :poisonous).from(false).to(true)
            .and change(updating_ingredient, :cas_number).from(nil).to("111111")
        end
      end
    end

    context "with a range type form" do
      let(:type) { "range" }
      let(:component) { create(:ranges_component) }
      let(:poisonous) { "false" }
      let(:range_concentration) { "greater_than_10_less_than_25_percent" }

      it "creates an ingredient" do
        expect { form.save }.to change(Ingredient, :count).by(1)
      end

      # rubocop:disable RSpec/ExampleLength
      it "returns the created ingredient" do
        expect(form.save).to be_an_instance_of(Ingredient).and have_attributes(
          component_id: component.id,
          inci_name: name,
          range_concentration: range_concentration,
          exact_concentration: nil,
          cas_number: "111111",
          poisonous: false,
        )
      end
      # rubocop:enable RSpec/ExampleLength

      context "when updating a range ingredient" do
        let!(:updating_ingredient) do
          create(:ingredient,
                 inci_name: "Ingredient pre-update",
                 range_concentration: "greater_than_5_less_than_10_percent",
                 component: component)
        end

        it "does not create a new ingredient" do
          expect { form.save }.to not_change(Ingredient, :count)
        end

        it "updates the ingredient" do
          expect { form.save }
            .to change(updating_ingredient, :inci_name).from("Ingredient pre-update").to(name)
            .and change(updating_ingredient, :range_concentration).from("greater_than_5_less_than_10_percent").to(range_concentration)
            .and change(updating_ingredient, :cas_number).from(nil).to("111111")
        end
      end

      context "when updating an exact ingredient" do
        let!(:updating_ingredient) do
          create(:ingredient, inci_name: "Ingredient pre-update", exact_concentration: 3.0, poisonous: true, component: component)
        end

        it "does not create a new ingredient" do
          expect { form.save }.to not_change(Ingredient, :count)
        end

        it "updates the ingredient" do
          expect { form.save }
            .to change(updating_ingredient, :inci_name).from("Ingredient pre-update").to(name)
            .and change(updating_ingredient, :range_concentration).from(nil).to(range_concentration)
            .and change(updating_ingredient, :exact_concentration).from(3.0).to(nil)
            .and change(updating_ingredient, :poisonous).from(true).to(false)
            .and change(updating_ingredient, :cas_number).from(nil).to("111111")
        end
      end
    end
  end
end
