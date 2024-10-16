require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::Product::ContainsNanomaterialsForm do
  subject(:form) do
    described_class.new(contains_nanomaterials:, nanomaterials_count:)
  end

  let(:contains_nanomaterials) { "yes" }
  let(:nanomaterials_count) { "3" }

  describe "#contains_nanomaterials?" do
    context "when contains_nanomaterials is 'yes'" do
      let(:contains_nanomaterials) { "yes" }

      it { expect(form.contains_nanomaterials?).to be true }
    end

    context "when contains_nanomaterials is 'no'" do
      let(:contains_nanomaterials) { "no" }

      it { expect(form.contains_nanomaterials?).to be false }
    end

    context "when contains_nanomaterials is empty" do
      let(:contains_nanomaterials) { "" }

      it { expect(form.contains_nanomaterials?).to be false }
    end

    context "when contains_nanomaterials is neither 'yes' nor 'no'" do
      let(:contains_nanomaterials) { "maybe" }

      it { expect(form.contains_nanomaterials?).to be false }
    end
  end

  describe "#valid?" do
    ["", "maybe"].each do |invalid_contains_nanomaterials_answer|
      context "when the contains nanomaterials answer is #{invalid_contains_nanomaterials_answer}" do
        let(:contains_nanomaterials) { invalid_contains_nanomaterials_answer }

        before { form.validate }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the contains nanomaterials attribute" do
          expect(form.errors.full_messages_for(:contains_nanomaterials)).to eq(["Select yes if the product contains nanomaterials"])
        end

        context "when the nanomaterials count is also invalid" do
          let(:nanomaterials_count) { "twelve" }

          it "does not add an error message for the nanomaterials count attribute" do
            expect(form.errors.full_messages_for(:nanomaterials_count)).to be_empty
          end
        end
      end
    end

    context "when the contains nanomaticals answer is 'yes'" do
      let(:contains_nanomaterials) { "yes" }

      before { form.validate }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not adds an error message for contains nanomaterials" do
        expect(form.errors.full_messages_for(:contains_nanomaterials)).to be_empty
      end

      context "when the nanomaterials count is empty" do
        let(:nanomaterials_count) { "" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the nanomaterials count attribute" do
          expect(form.errors.full_messages_for(:nanomaterials_count)).to eq(["Enter a number for how many nanomaterials"])
        end
      end

      context "when the nanomaterials count contains a non numeric value" do
        let(:nanomaterials_count) { "twelve" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the nanomaterials count attribute" do
          expect(form.errors.full_messages_for(:nanomaterials_count)).to eq(["Enter a number for how many nanomaterials"])
        end
      end

      context "when the nanomaterials count value is too low" do
        let(:nanomaterials_count) { "0" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the nanomaterials count attribute" do
          expect(form.errors.full_messages_for(:nanomaterials_count)).to eq(["Enter a number for how many nanomaterials"])
        end
      end

      context "when the nanomaterials count value is too high" do
        let(:nanomaterials_count) { "11" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the nanomaterials count attribute" do
          expect(form.errors.full_messages_for(:nanomaterials_count)).to eq(["Maximum nanomaterials count is 10. More can be added later"])
        end
      end
    end

    context "when the contains nanomaticals answer is 'no'" do
      let(:contains_nanomaterials) { "no" }

      before { form.validate }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not adds an error message for contains nanomaterials" do
        expect(form.errors.full_messages_for(:contains_nanomaterials)).to be_empty
      end

      context "when the nanomaterials count is higher" do
        let(:nanomaterials_count) { "3" }

        it "returns 0 as count" do
          expect(form.nanomaterials_count).to eq 0
        end
      end

      context "when the nanomaterials count is invalid" do
        let(:nanomaterials_count) { "twelve" }

        it "is still valid" do
          expect(form).to be_valid
        end

        it "does not add an error message for the nanomaterials count attribute" do
          expect(form.errors.full_messages_for(:nanomaterials_count)).to be_empty
        end
      end
    end
  end
end
