require "rails_helper"

RSpec.describe ExactFormula, type: :model do
  it "normalises cas number on saving" do
    exact_formula = build(:exact_formula, cas_number: "123-45-6")
    expect { exact_formula.save! }.to change(exact_formula, :cas_number).from("123-45-6").to("123456")
  end
end
