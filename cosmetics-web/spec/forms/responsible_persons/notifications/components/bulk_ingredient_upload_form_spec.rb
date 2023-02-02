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
    describe "error messages" do
      context "when one ingredient in csv is invalid" do
        let(:csv) do
          <<~CSV
            Sodium,35,497-19-8,true
            Aqua,65,497-19-8,false
            Acid,50-75,497-19-8,false
          CSV
        end

        it "does not create any ingredients" do
          expect {
            form.save_ingredients
          }.not_to change(Ingredient, :count)
        end

        it "is invalid" do
          form.valid?

          expect(form).not_to be_valid
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The file could not be uploaded because of error in line 3: Enter a number for the concentration"]
        end

        it "save_ingredients will be falsey" do
          expect(form.save_ingredients).to be_falsey
        end
      end

      context "when file has more invalid lines" do
        let(:csv) do
          <<~CSV
            Sodium,thirtyfive,497-19-8,true
            Aqua,65,497-19-8,false
            Acid,50-75,497-19-8,false
          CSV
        end

        it "has proper error message" do
          form.valid?
          messages = ["The file could not be uploaded because of error in line 1: Enter a number for the concentration",
                      "The file could not be uploaded because of error in line 3: Enter a number for the concentration"]
          expect(form.errors.full_messages).to eq messages
        end
      end

      context "when file is not a proper file" do
        let(:file) do
          f = File.open("spec/fixtures/files/ingredients.xlsx")
          Rack::Test::UploadedFile.new(f, "text/csv")
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The selected file must be a CSV file", "The selected file is empty"]
        end
      end

      context "when file is nil" do
        let(:file) { nil }

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The selected file must be a CSV file", "The selected file is empty"]
        end
      end

      # TODO: implement
      context "when ingredient with that name already exists" do
        let(:csv) do
          <<~CSV
            Aqua,65,497-19-8,false
            Acid,50,497-19-8,false
          CSV
        end

        before do
          create(:exact_ingredient, inci_name: "Aqua", component:)
        end

        it "is invalid" do
          form.valid?

          expect(form).not_to be_valid
        end

        it "does not create any ingredients" do
          expect {
            form.save_ingredients
          }.not_to change(Ingredient, :count)
        end

        it "is falsey" do
          expect(form.save_ingredients).to be_falsey
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The file could not be uploaded because of error in line 1: Ingredient name already exists in this component"]
        end
      end

      context "when ingredients repeat withing file" do
        let(:csv) do
          <<~CSV
            Aqua,65,497-19-8,false
            Aqua,50,497-19-8,false
          CSV
        end

        it "is invalid" do
          form.save_ingredients

          expect(form).not_to be_valid
        end

        it "is falsey" do
          expect(form.save_ingredients).to be_falsey
        end

        it "does not create any ingredients" do
          expect {
            form.save_ingredients
          }.not_to change(Ingredient, :count)
        end

        it "has proper error message" do
          form.save_ingredients

          expect(form.errors.full_messages).to eq ["The file cound not be uploaded because of errors in line 2: Ingredient name already exists in this component"]
        end
      end

      context "when the file is too large" do
        let(:file) do
          f = Tempfile.new
          120.times { f.write("#{'X' * 110},777-77-77,55,true") }
          f.rewind
          Rack::Test::UploadedFile.new(f, "text/csv")
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The selected file must be smaller than 15KB"]
        end
      end

      context "when ingredient file is empty" do
        let(:csv) do
          <<~CSV
          CSV
        end

        it "has proper error message" do
          form.valid?

          expect(form.errors.full_messages).to eq ["The selected file is empty"]
        end
      end
    end

    context "when using CSV for adding ingredients" do
      let(:component) do
        create(:exact_component)
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
  end
end
