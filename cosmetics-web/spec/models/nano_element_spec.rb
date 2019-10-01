require 'rails_helper'

RSpec.describe NanoElement, type: :model do
  subject(:nano_element) { described_class.new }

  describe "updating purposes" do
    it "allows multiple purposes to be specified" do
      purposes = %w(preservative uv_filter)
      nano_element.purposes = purposes

      expect(nano_element.save(context: :select_purposes)).to be true
      expect(nano_element.purposes).to eq(purposes)
    end

    it "adds error if invalid purpose is specified" do
      invalid_purpose = "invalid_purpose"
      nano_element.purposes = %w(invalid_purpose)

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

      expect(nano_element).to be_non_standard
    end

    it "is false when purposes do not include 'other'" do
      nano_element.purposes = %w(colorant preservative uv_filter)

      expect(nano_element).not_to be_non_standard
    end
  end

  describe "#standard?" do
    it "is true when purposes includes 'other'" do
      nano_element.purposes = %w(colorant)

      expect(nano_element).to be_standard
    end
  end

  describe "#incomplete?" do
    context "when a nonstandard nanomaterial notification is incomplete" do
      it "purposes is not set" do
        nano_element.purposes = nil

        expect(nano_element).to be_incomplete
      end

      it "purpose is empty" do
        nano_element.purposes = []

        expect(nano_element).to be_incomplete
      end

      it "has not confirmed that toxicology notified" do
        nano_element.purposes = %w(other)
        nano_element.confirm_toxicology_notified = nil

        expect(nano_element).to be_incomplete
      end
    end

    context "when a standard nanomaterial notification is incomplete" do
      it "has not confirmed restrictions" do
        nano_element.purposes = %w(colorant)
        nano_element.confirm_restrictions = nil

        expect(nano_element).to be_incomplete
      end

      context "when restrictions is set to 'no'" do
        it "must have set #confirm_toxicology_notified" do
          nano_element.purposes = %w(colorant)
          nano_element.confirm_restrictions = "no"
          nano_element.confirm_toxicology_notified = nil

          expect(nano_element).to be_incomplete
        end
      end

      context "when restrictions is set to 'yes'" do
        it "must have set #confirm_toxicology_notified" do
          nano_element.purposes = %w(colorant)
          nano_element.confirm_restrictions = "yes"
          nano_element.confirm_usage = nil

          expect(nano_element).to be_incomplete
        end
      end

      it "has not confirmed usage" do
        nano_element.purposes = %w(colorant)
        nano_element.confirm_restrictions = "yes"
        nano_element.confirm_usage = nil

        expect(nano_element).to be_incomplete
      end
    end
  end
end
