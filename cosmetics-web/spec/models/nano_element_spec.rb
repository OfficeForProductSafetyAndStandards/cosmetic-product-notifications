require "rails_helper"

RSpec.describe NanoElement, type: :model do
  subject(:nano_element) { build(:nano_element) }

  describe "Validation" do
    it "is valid" do
      expect(nano_element).to be_valid
    end

    context "when without validation context" do
      describe "inci_name" do
        subject(:nano_element) { build(:nano_element, inci_name: "") }

        it "is valid without name" do
          expect(nano_element).to be_valid
        end
      end
    end

    context "with validation context" do
      describe "inci_name" do
        subject(:nano_element) { build(:nano_element, inci_name: "") }

        it "is valid without name" do
          nano_element.valid?(:add_nanomaterial_name)
          expect(nano_element.errors).to be_present
        end
      end
    end

    context "when using same name in same notification" do
      let(:notification) { create(:notification) }
      let(:existing_name) { "Nanomaterial" }
      let(:new_name) { existing_name }

      let(:nano_material1) { create(:nano_material, notification:) }
      let(:nano_material2) { create(:nano_material, notification:) }

      let(:nano_element1) { create(:nano_element, inci_name: existing_name, nano_material: nano_material1) }
      let(:nano_element) { build(:nano_element, inci_name: new_name, nano_material: nano_material2) }

      before do
        nano_element1
      end

      it "is valid with same name without context" do
        expect(nano_element).to be_valid
      end

      it "is invalid with same name with context" do
        expect(nano_element.valid?(:add_nanomaterial_name)).to be(false)
      end

      context "when saving" do
        it "does not cause error on self" do
          expect(nano_element1.valid?(:add_nanomaterial_name)).to be(true)
        end
      end

      context "when names are similar" do
        context "when new name differs only by whitespaces" do
          let(:new_name) { "#{existing_name} " }

          it "is invalid with same name with context" do
            expect(nano_element.valid?(:add_nanomaterial_name)).to be(false)
          end
        end

        context "when new name differs only by case" do
          let(:new_name) { existing_name.upcase }

          it "is invalid with same name with context" do
            expect(nano_element.valid?(:add_nanomaterial_name)).to be(false)
          end
        end
      end
    end
  end

  describe "#attributes" do
    it "confirms purposes" do
      expect(nano_element).to have_attributes(purposes: nil)
    end

    it "confirms restrictions" do
      expect(nano_element).to have_attributes(confirm_restrictions: nil)
    end

    it "confirms usage" do
      expect(nano_element).to have_attributes(confirm_usage: nil)
    end

    it "confirms toxicology has been notified" do
      expect(nano_element).to have_attributes(confirm_toxicology_notified: nil)
    end
  end

  describe "updating purposes" do
    it "allows multiple purposes to be specified" do
      purposes = %w[preservative uv_filter]
      nano_element.purposes = purposes

      expect(nano_element.save(context: :select_purposes)).to be true
      expect(nano_element.purposes).to eq(purposes)
    end

    it "adds error if invalid purpose is specified" do
      invalid_purpose = "invalid_purpose"
      nano_element.purposes = %w[invalid_purpose]

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
      nano_element.purposes = %w[colorant other]

      expect(nano_element).to be_non_standard
    end

    it "is false when purposes do not include 'other'" do
      nano_element.purposes = %w[colorant preservative uv_filter]

      expect(nano_element).not_to be_non_standard
    end
  end

  describe "#standard?" do
    it "is true when purposes does not include 'other'" do
      nano_element.purposes = %w[colorant]

      expect(nano_element).to be_standard
    end

    it "is false when purposes includes 'other'" do
      nano_element.purposes = %w[other]

      expect(nano_element).not_to be_standard
    end
  end
end
