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
      Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
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

        it "has error messages" do
          form.save_ingredients

          expect(form.errors.full_messages).to eq(error_messages)
        end

        it "collates all row-based error messages" do
          form.save_ingredients

          expect(form.error_rows).to eq(error_rows)
        end

        it "returns false" do
          expect(form.save_ingredients).to be false
        end
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
        let(:error_rows) { {} }
      end
    end

    context "when the file is not a CSV" do
      let(:file) do
        f = File.open("spec/fixtures/files/ingredients.xlsx")
        Rack::Test::UploadedFile.new(f, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file must be a CSV"] }
        let(:error_rows) { {} }
      end
    end

    context "when the file is nil" do
      let(:file) { nil }

      include_examples "validation" do
        let(:error_messages) { ["The selected file must be a CSV"] }
        let(:error_rows) { {} }
      end
    end

    context "when the file is empty" do
      let(:csv) do
        <<~CSV
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file is empty"] }
        let(:error_rows) { {} }
      end
    end

    context "when the file contains invalid characters" do
      let(:file) do
        f = File.open("spec/fixtures/files/exact_ingredients_long_name.csv")
        Rack::Test::UploadedFile.new(f, "text/csv")
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file contains invalid characters"] }
        let(:error_rows) { {} }
      end
    end

    context "when only a header row is present" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file is empty"] }
        let(:error_rows) { {} }
      end
    end

    context "when the header is missing" do
      let(:csv) do
        <<~CSV
          Sodium,35,497-19-8,true
          Aqua,65,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The header row must be included in the selected file"] }
        let(:error_rows) { {} }
      end
    end

    context "when the file has too many columns in the header row but correct ingredient row values" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?,Foo
          Aqua,65,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The header row must be included in the selected file"] }
        let(:error_rows) { {} }
      end
    end

    context "when the file has an extra empty column in the header row but correct ingredient row values" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?,
          Aqua,65,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The header row must be included in the selected file"] }
        let(:error_rows) { {} }
      end
    end

    context "when there are duplicate ingredients" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Aqua,65,497-19-8,false
          Aqua,50,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file contains ingredients that are duplicated"] }
        let(:error_rows) { {} }
      end
    end

    context "when an ingredient row has an extra empty column" do
      # rubocop:disable Layout/HeredocIndentation
      let(:csv) do
        <<~CSV
         Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Aqua,65,497-19-8,false,
        CSV
      end
      # rubocop:enable Layout/HeredocIndentation

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { base: ["The ingredient row contains extra columns"] } } }
      end
    end

    context "when an ingredient row has an extra column" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Aqua,65,497-19-8,false,bar
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { base: ["The ingredient row contains extra columns"] } } }
      end
    end

    context "when the ingredient name is empty" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          ,35,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { inci_name: ["Enter a name"] } } }
      end
    end

    context "when the ingredient name is too long" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA,32,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { inci_name: ["Ingredient name must be 100 characters or less"] } } }
      end
    end

    context "when the ingredient concentration is empty" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Foo,,497-19-8,true
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { exact_concentration: ["Enter the exact concentration"] } } }
      end
    end

    context "when the ingredient concentration value is incorrect" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Sodium,abc,497-19-8,foo
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { exact_concentration: ["Enter a number for the exact concentration"], poisonous: ["The selected file must provide `true` or `false` values to the NPIS column"] } } }
      end
    end

    context "when the ingredient NPIS column is empty" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Aqua,65,497-19-8,
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { poisonous: ["The selected file must provide `true` or `false` values to the NPIS column"] } } }
      end
    end

    context "when the ingredient NPIS column is incorrect" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Sodium,32,497-19-8,foo
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { poisonous: ["The selected file must provide `true` or `false` values to the NPIS column"] } } }
      end
    end

    context "when one ingredient row is invalid" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Sodium,35,497-19-8,true
          Aqua,65,497-19-8,false
          Acid,50-75,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 4 => { exact_concentration: ["Enter a number for the exact concentration"] } } }
      end
    end

    context "when multiple ingredient rows are invalid" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
          Sodium,thirtyfive,497-19-8,true
          Aqua,65,497-19-8,false
          Acid,50-75,497-19-8,false
        CSV
      end

      include_examples "validation" do
        let(:error_messages) { ["The selected file could not be uploaded - try again"] }
        let(:error_rows) { { 2 => { exact_concentration: ["Enter a number for the exact concentration"] }, 4 => { exact_concentration: ["Enter a number for the exact concentration"] } } }
      end
    end
  end

  context "when using range CSV" do
    let(:component) { create(:ranges_component) }

    let(:csv) do
      <<~CSV
        Ingredient name,Minimum % w/w,Maximum % w/w,Exact % w/w,CAS number,Does NPIS need to know about it?
        Sodium carbonate,10,30,,497-19-8,false
        Water,35,65,,7732-18-5,false
        Eucalyptol,,,12,,true
      CSV
    end

    it "creates 3 ingredients" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(3)
    end
  end

  context "when using CSV for adding ingredients" do
    let(:component) do
      create(:exact_component)
    end

    context "when using upper case for toxicity" do
      let(:csv) do
        <<~CSV
          Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
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

    it "creates poisonous/non poisonous ingredients accordingly" do
      form.save_ingredients
      expect(Ingredient.pluck(:poisonous)).to eq [true, false]
    end

    it "is truthy" do
      expect(form.save_ingredients).to be_truthy
    end
  end

  context "when the fields start or end with extra spaces" do
    let(:csv) do
      <<~CSV
        Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
         Foo,12 ,  497-19-8 , TRUE
      CSV
    end

    it "is valid" do
      form.valid?

      expect(form).to be_valid
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(1)
    end
  end

  context "when the file contains blank rows" do
    let(:csv) do
      <<~CSV
        Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
        ,,,
        Foo,12 ,497-19-8,TRUE
      CSV
    end

    it "is valid" do
      form.valid?

      expect(form).to be_valid
    end

    it "creates records" do
      expect {
        form.save_ingredients
      }.to change(Ingredient, :count).by(1)
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

  context "when ingredients are already present in product" do
    let(:csv) do
      <<~CSV
        Ingredient name,% w/w,CAS number,Does NPIS need to know about it?
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
