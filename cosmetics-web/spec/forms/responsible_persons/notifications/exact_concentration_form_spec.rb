require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::ExactConcentrationForm do
  subject(:form) do
    described_class.new(component: component,
                        name: name,
                        cas_number: cas_number,
                        exact_concentration: exact_concentration,
                        poisonous: poisonous)
  end

  let(:component) { create(:component) }
  let(:name) { "Ingredient Name" }
  let(:cas_number) { "111-11-1" }
  let(:exact_concentration) { "4.2" }
  let(:poisonous) { "1" }

  describe "validation" do
    it "is invalid without a name" do
      form.name = ""
      expect(form).not_to be_valid
      expect(form.errors[:name]).to eq ["Enter a name"]
    end

    it "is invalid without an exact concentration" do
      form.exact_concentration = ""
      expect(form).not_to be_valid
      expect(form.errors[:exact_concentration]).to eq ["Enter the concentration"]
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

    describe "name taken validation" do
      it "is invalid when the ingredient already exists for the component" do
        create(:exact_formula, component: component, inci_name: name)
        expect(form).not_to be_valid
        expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
      end

      it "is valid when the ingredient already exists for a different component in the same notification" do
        component2 = create(:component, notification: component.notification)
        create(:exact_formula, component: component2, inci_name: name)
      end

      it "is invalid when the ingredient differs only in capitalisation from an existing component ingredient" do
        create(:exact_formula, component: component, inci_name: name.downcase)
        expect(form).not_to be_valid
        expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
      end

      it "is invalid when the ingredient differs only in leading/trailing espaces from an existing component ingredient" do
        create(:exact_formula, component: component, inci_name: name)
        form.name = " #{name} "
        expect(form).not_to be_valid
        expect(form.errors[:name]).to eq ["Enter a name which is unique to this product"]
      end

      it "shows a specific error message for already existing name in the multicomponent notification" do
        allow(component.notification).to receive(:is_multicomponent?).and_return(true)
        create(:exact_formula, component: component, inci_name: name)
        expect(form).not_to be_valid
        expect(form.errors[:name]).to eq ["Enter a name which is unique to this item"]
      end
    end
  end

  describe "#save" do
    context "when the form has no component" do
      let(:component) { nil }

      it "returns false" do
        expect(form.save).to be false
      end

      it "does not create an exact formula" do
        expect { form.save }.not_to change(ExactFormula, :count)
      end
    end

    context "when the form is invalid" do
      let(:name) { "" }

      it "returns false" do
        expect(form.save).to eq false
      end

      it "does not create an exact formula" do
        expect { form.save }.not_to change(ExactFormula, :count)
      end
    end

    context "when the form is valid" do
      it "creates an exact formula" do
        expect { form.save }.to change(ExactFormula, :count).by(1)
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
  end
end
