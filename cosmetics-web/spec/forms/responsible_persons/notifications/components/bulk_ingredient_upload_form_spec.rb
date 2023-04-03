require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::Components::BulkIngredientUploadForm do
  let(:form) do
    described_class.new(component:, file:)
  end

  let(:component) do
    create(:exact_component)
  end

  let(:csv) do
    <<~CSV
      Name,Concentration,CAS, Is poisonous?
      Sodium,35,497-19-8,true
      Aqua,65,497-19-8,false
    CSV
  end

  let(:file) do
    f = Tempfile.new
    f.write(csv)
    f.rewind
    Rack::Test::UploadedFile.new(f, "text/csv")
  end

  before do
    component
  end

  context "when using exact CSV" do
    shared_examples "validation" do
      describe "#save_ingredients" do
        it "does not create any ingredients" do
          expect {
            form.save_ingredients
          }.not_to change(Ingredient, :count)
        end

        it "does have proper message after saving attempt" do
          form.save_ingredients

          expect(form.errors.full_messages).to eq error_messages
        end

        it "does return proper value" do
          expect(form.save_ingredients).to be false
        end
      end

      describe "#valid?" do
        it "is invalid" do
          form.valid?

          expect(form).not_to be_valid
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq error_messages
        end
      end
    end

    context "when name is empty" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          ,35,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when header is missing" do
      let(:csv) do
        <<~CSV
          Sodium,35,497-19-8,true
          Aqua,65,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The supplied header row must be included in the file"] }
      end
    end

    context "when concentration number is empty" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Foo,,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when values for concentration are incorrect" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Sodium,abc,497-19-8,foo
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when values for toxicity are incorrect" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Sodium,32,497-19-8,foo
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when name is too long" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,32,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when file with invalid characters is used" do
      let(:file) do
        f = File.open("spec/fixtures/files/Exact_ingredients_long_name.csv")
        Rack::Test::UploadedFile.new(f, "text/csv")
      end

      let(:error_messages) { ["File has incorrect characters. Please check and try again"] }

      it "does have proper message after saving attempt" do
        form.save_ingredients

        expect(form.errors.full_messages).to eq error_messages
      end

      it "does return proper value" do
        expect(form.save_ingredients).to be false
      end

      it "is invalid" do
        form.valid?

        expect(form).not_to be_valid
      end

      it "has proper error message" do
        form.valid?

        expect(form.errors.full_messages).to eq error_messages
      end
    end

    context "when values for toxicity are empty" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Aqua,65,497-19-8,
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when one ingredient in csv is invalid" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Sodium,35,497-19-8,true
          Aqua,65,497-19-8,false
          Acid,50-75,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 4"] }
      end
    end

    context "when file has more invalid lines" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Sodium,thirtyfive,497-19-8,true
          Aqua,65,497-19-8,false
          Acid,50-75,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) do
          ["The file has error in rows: 2,4"]
        end
      end
    end

    context "when file is not a proper file" do
      let(:file) do
        f = File.open("spec/fixtures/files/ingredients.xlsx")
        Rack::Test::UploadedFile.new(f, "text/csv")
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file must be a CSV file", "The selected file is empty"] }
      end
    end

    context "when file is nil" do
      let(:file) { nil }

      include_examples "validation" do
        let(:error_messages) { ["The selected file must be a CSV file", "The selected file is empty"] }
      end
    end

    context "when ingredients repeat withing file" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Aqua,65,497-19-8,false
          Aqua,50,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 3"] }
      end
    end

    context "when the file is too large" do
      let(:file) do
        f = Tempfile.new
        120.times { f.write("#{'X' * 110},777-77-77,55,true") }
        f.rewind
        Rack::Test::UploadedFile.new(f, "text/csv")
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file must be smaller than 15KB"] }
      end
    end

    context "when ingredient file is empty" do
      context "when only header is present" do
        let(:csv) do
          <<~CSV
            Name,Concentration,CAS, Is poisonous?
          CSV
        end

        include_examples "validation" do
          let(:error_messages) { ["The selected file is empty"] }
        end
      end

      context "when file doesn't have even header" do
        let(:csv) do
          <<~CSV
          CSV
        end

        include_examples "validation" do
          let(:error_messages) { ["The selected file is empty"] }
        end
      end
    end

    context "when the file has too many columns in the header but right row values" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?,Foo
          Aqua,65,497-19-8,false
        CSV
      end

      it { expect(form).to be_valid }
    end

    context "when the file has an extra empty column in the header but right row values" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?,
          Aqua,65,497-19-8,false
        CSV
      end

      it { expect(form).to be_valid }
    end

    context "when the file has an extra empty column" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Aqua,65,497-19-8,false,
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end

    context "when a row has an extra column" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Aqua,65,497-19-8,false,bar
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The file has error in row: 2"] }
      end
    end
  end

  context "when using CSV for adding ingredients" do
    let(:component) do
      create(:exact_component)
    end

    context "when using upper case for toxicity" do
      let(:csv) do
        <<~CSV
          Name,Concentration,CAS, Is poisonous?
          Foo,12,497-19-8,TRUE
        CSV
      end

      it "is valid" do
        form.valid?

        expect(form).to be_valid
      end
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(2)
    end

    it "creates poisonous/non poisoning ingredients accordingly" do
      form.save_ingredients
      expect(Ingredient.pluck(:poisonous)).to eq [true, false]
    end

    it "is truthy" do
      expect(form.save_ingredients).to be_truthy
    end
  end

  context "when using CSV for poisonous ingredients in frame formulation" do
    let(:component) { create(:predefined_component, contains_poisonous_ingredients: true) }

    it "is valid" do
      form.save_ingredients
      expect(form).to be_valid
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(2)
    end
  end

  context "when header is not very meaningful" do
    let(:csv) do
      <<~CSV
        Foo
        Sodium,35,497-19-8,true
        Aqua,65,497-19-8,false
      CSV
    end

    let(:component) { create(:predefined_component, contains_poisonous_ingredients: true) }

    it "is valid" do
      form.save_ingredients
      expect(form).to be_valid
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(2)
    end
  end

  context "when ingredients are already present in product" do
    let(:csv) do
      <<~CSV
        Foo
        Sodium,35,497-19-8,true
        Aqua,65,497-19-8,false
      CSV
    end

    let(:component) { create(:predefined_component, contains_poisonous_ingredients: true) }
    let(:ingredient) { create(:exact_ingredient, inci_name: "Existing ingredient") }

    let(:component2) { create(:predefined_component, contains_poisonous_ingredients: true) }
    let(:ingredient2) { create(:exact_ingredient, inci_name: "Existing ingredient") }

    before do
      ingredient
      ingredient2
    end

    it "is valid" do
      form.save_ingredients
      expect(form).to be_valid
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(2)
    end

    it "removes proper ingredient" do
      form.save_ingredients

      expect(component.reload.ingredients.pluck(:inci_name)).to eq(%w[Sodium Aqua])
    end
  end
end
