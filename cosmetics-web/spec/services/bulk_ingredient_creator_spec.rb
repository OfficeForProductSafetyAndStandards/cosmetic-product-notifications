require "rails_helper"

RSpec.describe BulkIngredientCreator do
  let(:component) do
    create(:ranges_component)
  end

  before do
    component
  end

  context "when using ranges CSV" do
    let(:csv) do
      <<~CSV
        Sodium,greater_than_50_less_than_75_percent,497-19-8,non_poisonous
        Aqua,greater_than_50_less_than_75_percent,497-19-8,non_poisonous
      CSV
    end

    it "is valid" do
      creator = described_class.new(csv, component)
      creator.create
      expect(creator).to be_valid
    end

    it "creates records" do
      creator = described_class.new(csv, component)
      expect {
        creator.create
      }.to change(Ingredient, :count).by(2)
    end
  end

  context "when using exact CSV" do
    let(:csv) do
      <<~CSV
        Sodium,35,497-19-8,non_poisonous
        Aqua,65,497-19-8,non_poisonous
      CSV
    end

    context "when using CSV for poisonous ingredients in frame formulation" do
      let(:component) { create(:predefined_component, contains_poisonous_ingredients: true) }

      it "is valid" do
        creator = described_class.new(csv, component)
        creator.create
        expect(creator).to be_valid
      end

      it "creates records" do
        creator = described_class.new(csv, component)
        expect {
          creator.create
        }.to change(Ingredient, :count).by(2)
      end
    end
  end

  context "when using invalid CSV" do
    let(:csv) do
      <<~CSV
        Camphor,28,497-19-8,poisonous
      CSV
    end

    it "is valid" do
      creator = described_class.new(csv, component)
      creator.create
      expect(creator).not_to be_valid
    end
  end

  context "when using different files" do
    let(:csv) do
      File.read("spec/fixtures/files/Ingredients_ concentrationrange.csv")
    end

    it "creates records" do
      creator = described_class.new(csv, component)
      expect {
        creator.create
      }.to change(Ingredient, :count).by(2)
    end
  end
end
