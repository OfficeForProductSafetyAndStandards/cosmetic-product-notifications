require "rails_helper"

RSpec.describe ResponsiblePersons::SelectionForm do
  subject(:form) do
    described_class.new(selection: selected_rp,
                        previous: previous_rp,
                        available: available_rps)
  end

  let(:selected_rp) { build_stubbed(:responsible_person) }
  let(:previous_rp) { build_stubbed(:responsible_person) }
  let(:available_rps) { build_stubbed_list(:responsible_person, 2) }

  describe "#valid?" do
    before { form.validate }

    context "when all the data is present" do
      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end

    context "when missing the responsible person selection" do
      let(:selected_rp) { nil }

      context "when there are available responsible persons" do
        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message requesting the selection or addition of a RP" do
          expect(form.errors.full_messages_for(:selection)).to eq(["Select a Responsible Person or add a new Responsible Person"])
        end
      end

      context "when there are not available responsible persons" do
        let(:available_rps) { [] }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message requesting the addition of a RP" do
          expect(form.errors.full_messages_for(:selection)).to eq(["Select add a new Responsible Person"])
        end
      end

      context "when the only available responsible person is the previously selected one" do
        let(:available_rps) { [previous_rp] }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "populates an error message requesting the addition of a RP" do
          expect(form.errors.full_messages_for(:selection)).to eq(["Select add a new Responsible Person"])
        end
      end
    end

    context "when missing the previous responsible person" do
      let(:previous_rp) { nil }

      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end

    context "when missing the available responsible persons" do
      let(:available_rps) { [] }

      it "is valid" do
        expect(form).to be_valid
      end

      it "has no error messages" do
        expect(form.errors).to be_empty
      end
    end
  end

  describe "#radio_items" do
    context "when there are no available responsible persons" do
      let(:available_rps) { [] }

      it "only returns the add a new responsible person radio item" do
        expect(form.radio_items).to eq([{ text: "Add a new Responsible Person", value: "new" }])
      end
    end

    context "when there is only a single available responsible person" do
      let(:available_rps) { [build_stubbed(:responsible_person)] }

      context "when is set as the previous responsible person" do
        let(:previous_rp) { available_rps.first }

        it "only returns the add a new responsible person radio item" do
          expect(form.radio_items).to eq([{ text: "Add a new Responsible Person", value: "new" }])
        end
      end

      context "when is not set as the previous responsible person" do
        let(:previous_rp) { nil }

        it "returns the available responsible person and the add new rp option" do
          rp = available_rps.first
          expect(form.radio_items).to eq([
            { text: rp.name, value: rp.id },
            { divider: "or" },
            { text: "Add a new Responsible Person", value: "new" },
          ])
        end
      end
    end

    context "when there are 2 available responsible persons" do
      let(:available_rps) do
        [build_stubbed(:responsible_person, name: "Responsible Person B"),
         build_stubbed(:responsible_person, name: "Responsible Person A")]
      end

      context "when one of them is set as the previous responsible person" do
        let(:previous_rp) { available_rps.first }

        it "excludes the previous rp from the returned radio items and includes the add new rp option" do
          expect(form.radio_items).to eq([
            { text: "Responsible Person A", value: available_rps.last.id },
            { divider: "or" },
            { text: "Add a new Responsible Person", value: "new" },
          ])
        end
      end

      context "when none of them is set as the previous responsible person" do
        let(:previous_rp) { nil }

        it "returns the available responsible persons in alphabetical order and the add new rp option" do
          expect(form.radio_items).to eq([
            { text: "Responsible Person A", value: available_rps.last.id },
            { text: "Responsible Person B", value: available_rps.first.id },
            { divider: "or" },
            { text: "Add a new Responsible Person", value: "new" },
          ])
        end
      end
    end
  end
end
