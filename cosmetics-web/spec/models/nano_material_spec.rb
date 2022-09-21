require "rails_helper"

RSpec.describe NanoMaterial, type: :model do
  subject(:nano_material) { build(:nano_material) }

  describe "validations" do
    describe "inci_name presence" do
      before do
        nano_material.inci_name = ""
      end

      it "accepts empty name without validation context" do
        expect(nano_material).to be_valid
      end

      it "does not accept an empty name with validation context" do
        expect(nano_material).not_to be_valid(:add_nanomaterial_name)
        expect(nano_material.errors[:inci_name]).to eq ["Enter a name"]
      end
    end

    describe "name uniqueness per notification" do
      let(:existing_name) { "Nanomaterial" }
      let(:new_name) { existing_name }

      let(:existing_nano_material) { create(:nano_material, inci_name: existing_name) }
      let(:new_nano_material) { build(:nano_material, notification: existing_nano_material.notification) }

      before do
        existing_nano_material
      end

      context "when validating with name context" do
        let(:unique_error) { "Enter a name which has not already been used in this notification" }

        it "does not cause error on the already saved value against itself" do
          expect(existing_nano_material).to be_valid(:add_nanomaterial_name)
        end

        it "accepts same name as existing one for a different notification" do
          create(:nano_material, inci_name: "FooBar")
          new_nano_material.inci_name = "FooBar"
          expect(new_nano_material).to be_valid
        end

        it " does not accept same name as existing one" do
          new_nano_material.inci_name = existing_name
          expect(new_nano_material).not_to be_valid(:add_nanomaterial_name)
          expect(new_nano_material.errors[:inci_name]).to eq [unique_error]
        end

        it "does not accept a name that differs only by whitespaces" do
          new_nano_material.inci_name = "#{existing_name} "
          expect(new_nano_material).not_to be_valid(:add_nanomaterial_name)
          expect(new_nano_material.errors[:inci_name]).to eq [unique_error]
        end

        it "does not accept a name that differs only by case" do
          new_nano_material.inci_name = existing_name.upcase
          expect(new_nano_material).not_to be_valid(:add_nanomaterial_name)
          expect(new_nano_material.errors[:inci_name]).to eq [unique_error]
        end
      end

      context "when validating without name context" do
        it "accepts same name as existing one" do
          new_nano_material.inci_name = existing_name
          expect(new_nano_material).to be_valid
        end

        it "accepts a name that differs only by whitespaces" do
          new_nano_material.inci_name = "#{existing_name} "
          expect(new_nano_material).to be_valid
        end

        it "accepts a name that differs only by case" do
          new_nano_material.inci_name = existing_name.upcase
          expect(new_nano_material).to be_valid
        end
      end
    end

    describe "purposes" do
      context "when validating with select purposes context" do
        it "acepts multiple purposes" do
          nano_material.purposes = %w[preservative uv_filter]
          expect(nano_material).to be_valid(:select_purposes)
        end

        it "does not accept a not allowed purpose" do
          nano_material.purposes = %w[invalid_purpose]
          expect(nano_material).not_to be_valid(:select_purposes)
          expect(nano_material.errors[:purposes]).to include("invalid_purpose is not a valid purpose")
        end

        it "does not accept an empty purposes" do
          nano_material.purposes = []
          expect(nano_material).not_to be_valid(:select_purposes)
          expect(nano_material.errors[:purposes]).to include("Choose an option")
        end
      end

      context "when validating without select purposes context" do
        it "does not accept a not allowed purpose" do
          nano_material.purposes = %w[invalid_purpose]
          expect(nano_material).not_to be_valid(:select_purposes)
          expect(nano_material.errors[:purposes]).to include("invalid_purpose is not a valid purpose")
        end

        it "accepts an empty purposes" do
          nano_material.purposes = []
          expect(nano_material).to be_valid
        end
      end
    end
  end

  describe "#non_standard?" do
    it "is true when purposes includes 'other'" do
      nano_material.purposes = %w[colorant other]
      expect(nano_material).to be_non_standard
    end

    it "is false when purposes do not include 'other'" do
      nano_material.purposes = %w[colorant preservative uv_filter]
      expect(nano_material).not_to be_non_standard
    end
  end

  describe "#standard?" do
    it "is true when purposes does not include 'other'" do
      nano_material.purposes = %w[colorant]
      expect(nano_material).to be_standard
    end

    it "is false when purposes includes 'other'" do
      nano_material.purposes = %w[other]
      expect(nano_material).not_to be_standard
    end
  end

  describe "#display_name" do
    let(:name_number_attrs) do
      {
        iupac_name: "IUPAC",
        inci_name: "INCI",
        inn_name: "INN",
        xan_name: "XAN",
        cas_number: "CAS-123",
        ec_number: "EC-123",
        einecs_number: "EINECS-123",
        elincs_number: "ELINCS-123",
      }
    end

    it "concatenates all the name and number attributes with a comma between them" do
      nano_material.attributes = name_number_attrs
      expect(nano_material.display_name).to eq "IUPAC, INCI, INN, XAN, CAS-123, EC-123, EINECS-123, ELINCS-123"
    end

    it "does not include attributes with nil values" do
      nano_material.attributes = name_number_attrs.merge(iupac_name: nil, xan_name: nil, einecs_number: "")
      expect(nano_material.display_name).to eq "INCI, INN, CAS-123, EC-123, ELINCS-123"
    end

    it "is empty when none of the name and number attributes are present" do
      nano_material.attributes = name_number_attrs.transform_values { |_v| "" }
      expect(nano_material.display_name).to eq ""
    end
  end

  describe "#multi_purpose?" do
    it "is false when there are no purposes" do
      nano_material.purposes = []
      expect(nano_material).not_to be_multi_purpose
    end

    it "is false when there is only one purpose" do
      nano_material.purposes = %w[colorant]
      expect(nano_material).not_to be_multi_purpose
    end

    it "is true when there are multiple purposes" do
      nano_material.purposes = %w[colorant preservative]
      expect(nano_material).to be_multi_purpose
    end
  end

  describe "#blocked?" do
    it "is not blocked by default" do
      expect(nano_material).not_to be_blocked
    end

    it "is blocked when the usage confirmation is negative" do
      nano_material.confirm_usage = "no"
      expect(nano_material).to be_blocked
    end

    it "is blocked when the restrictions confirmation is negative" do
      nano_material.confirm_restrictions = "no"
      expect(nano_material).to be_blocked
    end

    it "is blocked when the toxicology notification confirmation is negative" do
      nano_material.confirm_toxicology_notified = "no"
      expect(nano_material).to be_blocked
    end

    it "is blocked when the toxicology notification confirmation is dubius" do
      nano_material.confirm_toxicology_notified = "not sure"
      expect(nano_material).to be_blocked
    end
  end

  describe "#completed?" do
    before do
      nano_material.attributes =
        { inci_name: "INCI", confirm_usage: "yes", confirm_restrictions: "yes", confirm_toxicology_notified: "yes" }
    end

    context "with standard nanomaterial purposes" do
      before do
        nano_material.purposes = %w[colorant]
      end

      it "is completed when the standard purposes requirements are met" do
        expect(nano_material).to be_completed
      end

      it "is not completed when missing an inci_name" do
        nano_material.inci_name = ""
        expect(nano_material).not_to be_completed
      end

      it "is not completed when usage confirmation is missing" do
        nano_material.confirm_usage = ""
        expect(nano_material).not_to be_completed
      end

      it "is not completed when usage confirmation is negative" do
        nano_material.confirm_usage = "no"
        expect(nano_material).not_to be_completed
      end

      it "is not completed when restrictions confirmation is missing" do
        nano_material.confirm_restrictions = ""
        expect(nano_material).not_to be_completed
      end

      it "is completed when toxicology notification confirmation is missing" do
        nano_material.confirm_toxicology_notified = ""
        expect(nano_material).to be_completed
      end

      it "is completed when toxicology notification confirmation is positive" do
        nano_material.confirm_toxicology_notified = "yes"
        expect(nano_material).to be_completed
      end

      it "is not completed when toxicology notification confirmation is negative" do
        nano_material.confirm_toxicology_notified = "no"
        expect(nano_material).not_to be_completed
      end

      it "is not completed when toxicology notification confirmation is dubious" do
        nano_material.confirm_toxicology_notified = "not sure"
        expect(nano_material).not_to be_completed
      end
    end

    context "when the non-standard purposes requirements are met" do
      before do
        nano_material.purposes = %w[other]
      end

      it "is completed when toxicology notification confirmation is positive" do
        nano_material.confirm_toxicology_notified = "yes"
        expect(nano_material).to be_completed
      end

      it "is not completed when toxicology notification confirmation is negative" do
        nano_material.confirm_toxicology_notified = "no"
        expect(nano_material).not_to be_completed
      end

      it "is not completed when toxicology notification confirmation is dubious" do
        nano_material.confirm_toxicology_notified = "not sure"
        expect(nano_material).not_to be_completed
      end

      it "is not completed when toxicology notification confirmation is missing" do
        nano_material.confirm_toxicology_notified = ""
        expect(nano_material).not_to be_completed
      end

      it "is completed when missing an inci_name" do
        nano_material.inci_name = ""
        expect(nano_material).to be_completed
      end

      it "is completed when usage confirmation is missing" do
        nano_material.confirm_usage = ""
        expect(nano_material).to be_completed
      end

      it "is not completed when usage confirmation is negative" do
        nano_material.confirm_usage = "no"
        expect(nano_material).not_to be_completed
      end

      it "is completed when restrictions confirmation is missing" do
        nano_material.confirm_restrictions = ""
        expect(nano_material).to be_completed
      end
    end
  end

  describe "#toxicology_required?" do
    it "is not required for a nanomaterial with standard purposes" do
      nano_material.purposes = %w[colorant]
      expect(nano_material).not_to be_toxicology_required
    end

    context "with a non-standard purposes nanomaterial" do
      before do
        nano_material.purposes = %w[other]
      end

      it "is not required when the toxicology notification confirmation is positive" do
        nano_material.confirm_toxicology_notified = "yes"
        expect(nano_material).not_to be_toxicology_required
      end

      it "is not required when the toxicology notification confirmation is not stated" do
        nano_material.confirm_toxicology_notified = ""
        expect(nano_material).not_to be_toxicology_required
      end

      it "is required when the toxicology notification confirmation is dubius" do
        nano_material.confirm_toxicology_notified = "not sure"
        expect(nano_material).to be_toxicology_required
      end

      it "is required when the toxicology notification confirmation is negative" do
        nano_material.confirm_toxicology_notified = "no"
        expect(nano_material).to be_toxicology_required
      end
    end
  end

  describe "#conforms_to_restrictions?" do
    before do
      nano_material.attributes =
        { confirm_restrictions: "yes", confirm_usage: "yes", confirm_toxicology_notified: "yes" }
    end

    context "with a nanomaterial with standard purposes" do
      before do
        nano_material.purposes = %w[colorant]
      end

      it "conforms to restrictions when restrictions confirmation, usage confirmation and toxicology notification confirmation are positive" do
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the toxicology notification confirmation is negative" do
        nano_material.confirm_toxicology_notified = "no"
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the toxicology notification confirmation is dubious" do
        nano_material.confirm_toxicology_notified = "not sure"
        expect(nano_material).to be_conforms_to_restrictions
      end

      it " does not conform to restrictions when the toxicology notification confirmation is unset" do
        nano_material.confirm_toxicology_notified = ""
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the restrictions confirmation is unset" do
        nano_material.confirm_restrictions = ""
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the usage confirmation is unset" do
        nano_material.confirm_usage = ""
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the restrictions confirmation is negative" do
        nano_material.confirm_restrictions = "no"
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the usage confirmation is negative" do
        nano_material.confirm_usage = "no"
        expect(nano_material).not_to be_conforms_to_restrictions
      end
    end

    context "with a nanomaterial with non-standard purposes" do
      before do
        nano_material.purposes = %w[other]
      end

      it "conforms to restrictions when restrictions confirmation, usage confirmation and toxicology notification confirmation are positive" do
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the toxicology notification confirmation is unset" do
        nano_material.confirm_toxicology_notified = ""
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the toxicology notification confirmation is negative" do
        nano_material.confirm_toxicology_notified = "no"
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the toxicology notification confirmation is dubius" do
        nano_material.confirm_toxicology_notified = "not sure"
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the restrictions confirmation is unset" do
        nano_material.confirm_restrictions = ""
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "conforms to restrictions when the usage confirmation is unset" do
        nano_material.confirm_usage = ""
        expect(nano_material).to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the restrictions confirmation is negative" do
        nano_material.confirm_restrictions = "no"
        expect(nano_material).not_to be_conforms_to_restrictions
      end

      it "does not conform to restrictions when the usage confirmation is negative" do
        nano_material.confirm_usage = "no"
        expect(nano_material).not_to be_conforms_to_restrictions
      end
    end
  end
end
