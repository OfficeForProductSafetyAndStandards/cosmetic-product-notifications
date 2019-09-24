require 'rails_helper'

RSpec.describe NanoElement, type: :model do
  subject(:nano_element) { described_class.new }

  it "stores whether toxicology has been notified" do
    expect(nano_element).to respond_to(:confirm_toxicology_notified)
  end

  describe "updating purposes" do
    it "allows multiple purposes to be specified" do
      purposes = %w(preservative uv_filter)
      nano_element.purposes = purposes

      expect(nano_element.save(context: :select_purposes)).to be true
      expect(nano_element.purposes).to eq(purposes)
    end

    it "adds error if invalid purpose is specified" do
      invalid_purpose = "invalid_purpose"
      nano_element.purposes = [invalid_purpose]

      expect(nano_element.save(context: :select_purposes)).to be false
      expect(nano_element.errors[:purposes]).to include("#{invalid_purpose} is not a valid purpose")
    end

    it "adds error if no purpose is specified" do
      nano_element.purposes = []

      expect(nano_element.save(context: :select_purposes)).to be false
      expect(nano_element.errors[:purposes]).to include("Choose an option")
    end
  end

  describe "#non_standard?" do
    it "is true when purposes includes 'other'" do
      nano_element.purposes = %w(colorant other)

      expect(nano_element.non_standard?).to be true
    end

    it "is false when purposes do not include 'other'" do
      expect(nano_element.non_standard?).to be false
      nano_element.purposes = %w(colorant preservative uv_filter)
      expect(nano_element.non_standard?).to be false
    end
  end
end
