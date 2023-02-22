require "rails_helper"

describe PoisonCentres::IngredientNameMatcher do
  let(:query) { "aqua sodium acrylate" }
  let(:ingredient_names) { ["Aqua", "Foo bar", "Sodium Acetone"] }
  let(:ingredients) { ingredient_names.map { |name| OpenStruct.new(inci_name: name) } }
  let(:notification) { instance_double("Notification", ingredients:) }

  it "returns matched ingredients" do
    result = described_class.match(query, notification)
    expect(result).to eq ["Aqua", "Sodium Acetone"]
  end
end
