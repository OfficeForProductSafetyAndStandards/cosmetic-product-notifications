require "rails_helper"

describe IngredientHelper do
  describe "#ingredient_concentration_range" do
    {
      "less_than_01_percent" => [nil, "0.1"],
      "greater_than_01_less_than_1_percent" => %w[0.1 1],
      "greater_than_1_less_than_5_percent" => %w[1 5],
      "greater_than_5_less_than_10_percent" => %w[5 10],
      "greater_than_10_less_than_25_percent" => %w[10 25],
      "greater_than_25_less_than_50_percent" => %w[25 50],
      "greater_than_50_less_than_75_percent" => %w[50 75],
      "greater_than_75_less_than_100_percent" => %w[75 100],
      "greater_than_whatever" => [nil, nil],
      "wrong_format" => [nil, nil],
      "less_than_foo_percent" => [nil, nil],
      "" => [nil, nil],
      nil => [nil, nil],
    }.each do |range, results|
      above, upto = results

      it "transforms '#{range}' to a struct with 'above: #{above}' and 'upto: #{upto}'" do
        result = helper.ingredient_concentration_range(range)
        expect(result.above).to eq(above)
        expect(result.upto).to eq(upto)
      end
    end
  end

  describe "#csv_file_type" do
    subject(:csv_file_type) { helper.csv_file_type(component) }

    let(:shades) { nil }
    let(:component) do
      build(:component, notification_type:, shades:)
    end

    context "with exact concentration" do
      let(:notification_type) { "exact" }

      it { expect(csv_file_type).to eq("exact") }
    end

    context "with exact concentration and shades" do
      let(:notification_type) { "exact" }
      let(:shades) { :foo }

      it { expect(csv_file_type).to eq("exact-with-multiple-shades") }
    end

    context "with range concentration" do
      let(:notification_type) { "range" }

      it { expect(csv_file_type).to eq("range") }
    end
  end
end
