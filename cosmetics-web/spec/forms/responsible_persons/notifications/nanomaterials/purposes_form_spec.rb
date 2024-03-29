require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::Nanomaterials::PurposesForm do
  let(:standard_type) { described_class::STANDARD_TYPE }
  let(:other_type) { described_class::OTHER_TYPE }
  let(:allowed_purposes) { described_class::ALLOWED_PURPOSES }
  let(:standard_purposes) { allowed_purposes - [other_type] }

  describe "#initialize" do
    it "sets the given purposes" do
      purposes = allowed_purposes.sample(2)
      form = described_class.new(purposes:)
      expect(form.purposes).to eq(purposes)
    end

    it "sets the given purpose_type" do
      form = described_class.new(purpose_type: standard_type)
      expect(form.purpose_type).to eq(standard_type)
    end

    it "defaults the purpose_type to 'nil' if no purpose_type is given" do
      form = described_class.new
      expect(form.purpose_type).to be_nil
    end

    it "defaults the purposes to '[]' if no purposes are given" do
      form = described_class.new
      expect(form.purposes).to eq([])
    end

    it "does not accept other attributes" do
      expect { described_class.new(foo: "bar") }.to raise_error(ArgumentError)
    end

    it "defaults the purpose_type to 'other' if the given purposes include 'other'" do
      form = described_class.new(purposes: [other_type])
      expect(form.purpose_type).to eq(other_type)
    end

    it "defaults the purpose_type to 'standard' if the given purposes do not include 'other'" do
      form = described_class.new(purposes: [standard_purposes.sample])
      expect(form.purpose_type).to eq(standard_type)
    end

    context "when the provided purpose_type is 'other'" do
      let(:purpose_type) { other_type }

      it "defaults the purposes to 'other'" do
        form = described_class.new(purpose_type:)
        expect(form.purposes).to eq([other_type])
      end

      it "overrides any standard purposes with 'other'" do
        form = described_class.new(purpose_type:, purposes: standard_purposes)
        expect(form.purposes).to eq([other_type])
      end
    end
  end

  describe "validations" do
    let(:purpose_type) { standard_type }
    let(:purposes) { standard_purposes }

    it "is valid with a standard purpose type and a single standard purpose" do
      form = described_class.new(purpose_type:, purposes: [purposes.first])
      expect(form).to be_valid
    end

    it "is valid with a standard purpose type and multiple standard purposes" do
      form = described_class.new(purpose_type:, purposes:)
      expect(form).to be_valid
    end

    it "is valid with other purpose type and no standard purposes" do
      form = described_class.new(purpose_type: "other", purposes: [])
      expect(form).to be_valid
    end

    it "does not allow an invalid purpose type" do
      form = described_class.new(purpose_type: "fooType", purposes:)
      expect(form).not_to be_valid
      expect(form.errors[:purpose_type]).to include("fooType is not a valid purpose type")
    end

    it "does not need a purpose type when purposes are present" do
      form = described_class.new(purpose_type: nil, purposes:)
      expect(form).to be_valid
    end

    it "requires a purpose type when no purposes are present" do
      form = described_class.new(purpose_type: nil, purposes: [])
      expect(form).not_to be_valid
      expect(form.errors[:purpose_type]).to include("Select the purpose of this nanomaterial")
    end

    it "requires a purpose if the purpose type is standard" do
      form = described_class.new(purpose_type:, purposes: [])
      expect(form).not_to be_valid
      expect(form.errors[:purposes]).to include("Select the purpose")
    end

    it "does not allow invalid purposes" do
      form = described_class.new(purpose_type:, purposes: purposes + %w[fooPurpose barPurpose])
      expect(form).not_to be_valid
      expect(form.errors[:purposes]).to eq(["fooPurpose is not a valid purpose", "barPurpose is not a valid purpose"])
    end

    it "does not allow to combine both standard and other purposes" do
      form = described_class.new(purpose_type:, purposes: [purposes.first, other_type])
      expect(form).not_to be_valid
      expect(form.errors[:purposes]).to eq(["Select either any standard or 'other' as purposes"])
    end
  end
end
