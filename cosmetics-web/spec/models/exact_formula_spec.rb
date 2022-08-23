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

  describe "quantity validations" do
    let(:exact_formula) { build_stubbed(:exact_formula) }

    it "is valid with 0.1 as quantity" do
      exact_formula.quantity = "0.1"
      expect(exact_formula).to be_valid
    end

    it "is valid with 100 as quantity" do
      exact_formula.quantity = "100"
      expect(exact_formula).to be_valid
    end

    it "is invalid without a quantity" do
      exact_formula.quantity = ""
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter the concentration"]
    end

    it "is not valid when the quantity is not a number" do
      exact_formula.quantity = "not a number"
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter a number for the concentration"]
    end

    it "is not valid when the quantity contains extra characters mixed with a number" do
      exact_formula.quantity = "58:0887"
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter a number for the concentration"]
    end

    it "is not valid when the quantity is 0" do
      exact_formula.quantity = "0.0"
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter a concentration greater than 0"]
    end

    it "is not valid when the quantity is a negative number" do
      exact_formula.quantity = "-3.5"
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter a concentration greater than 0"]
    end

    it "is not valid when the quantity is greater than 100" do
      exact_formula.quantity = "101"
      expect(exact_formula).not_to be_valid
      expect(exact_formula.errors[:quantity]).to eq ["Enter a concentration less than or equal to 100"]
    end
  end
end
