require "rails_helper"

RSpec.describe ExactFormula, type: :model do
  it "normalises cas number on saving" do
    exact_formula = build(:exact_formula, cas_number: "123-45-6")
    expect { exact_formula.save! }.to change(exact_formula, :cas_number).from("123-45-6").to("123456")
  end

  it "doesn't save empty cas number" do
    exact_formula = build(:exact_formula, cas_number: "")
    expect { exact_formula.save! }.to change(exact_formula, :cas_number).from("").to(nil)
  end

  describe ".for_list" do
    context "when asked to order by date" do
      let(:formula1) { create(:exact_formula, inci_name: "Aqua", created_at: 1.week.ago) }
      let(:formula2) { create(:exact_formula, inci_name: "Sodium", created_at: 2.weeks.ago) }
      let(:formula3) { create(:exact_formula, inci_name: "Aqua", created_at: 3.weeks.ago) }

      before do
        formula1
        formula2
        formula3
      end

      it "displays correct data" do
        result = described_class.for_list(order: "date")
        expect(result.map(&:inci_name)).to eq(%w[Sodium Aqua])
      end
    end
  end
end
