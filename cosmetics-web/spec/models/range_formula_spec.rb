require "rails_helper"

RSpec.describe RangeFormula, type: :model do
  it "normalises cas number on saving" do
    range_formula = build(:range_formula, cas_number: "123-45-6")
    expect { range_formula.save! }.to change(range_formula, :cas_number).from("123-45-6").to("123456")
  end

  it "doesn't save empty cas number" do
    range_formula = build(:range_formula, cas_number: "")
    expect { range_formula.save! }.to change(range_formula, :cas_number).from("").to(nil)
  end
end
