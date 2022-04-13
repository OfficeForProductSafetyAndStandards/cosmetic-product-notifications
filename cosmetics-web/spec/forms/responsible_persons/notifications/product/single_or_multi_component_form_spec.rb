require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::Product::SingleOrMultiComponentForm do
  subject(:form) do
    described_class.new(single_or_multi_component: single_or_multi_component, components_count: components_count)
  end

  let(:single_or_multi_component) { "multiple" }
  let(:components_count) { "3" }

  describe "#single_component?" do
    context "when single_or_multi_component is 'single'" do
      let(:single_or_multi_component) { "single" }

      it { expect(form.single_component?).to be true }
    end

    context "when single_or_multi_component is 'multiple'" do
      let(:single_or_multi_component) { "multiple" }

      it { expect(form.single_component?).to be false }
    end

    context "when single_or_multi_component is empty" do
      let(:single_or_multi_component) { "" }

      it { expect(form.single_component?).to be false }
    end

    context "when single_or_multi_component is neither 'yes' nor 'no'" do
      let(:single_or_multi_component) { "maybe" }

      it { expect(form.single_component?).to be false }
    end
  end

  describe "#multi_component?" do
    context "when single_or_multi_component is 'multiple'" do
      let(:single_or_multi_component) { "multiple" }

      it { expect(form.multi_component?).to be true }
    end

    context "when single_or_multi_component is 'single'" do
      let(:single_or_multi_component) { "single" }

      it { expect(form.multi_component?).to be false }
    end

    context "when single_or_multi_component is empty" do
      let(:single_or_multi_component) { "" }

      it { expect(form.multi_component?).to be false }
    end

    context "when single_or_multi_component is neither 'yes' nor 'no'" do
      let(:single_or_multi_component) { "maybe" }

      it { expect(form.multi_component?).to be false }
    end
  end

  describe "#valid?" do
    ["", "maybe"].each do |invalid_single_or_multi_component_answer|
      context "when the single or multi components answer is #{invalid_single_or_multi_component_answer}" do
        let(:single_or_multi_component) { invalid_single_or_multi_component_answer }

        before { form.validate }

        it "is not valid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the single or multi components attribute" do
          expect(form.errors.full_messages_for(:single_or_multi_component)).to eq(["Select yes if the product is a multi-item kit, no if its single item"])
        end

        context "when the components count is also invalid" do
          let(:components_count) { "twelve" }

          it "does not add an error message for the components count attribute" do
            expect(form.errors.full_messages_for(:components_count)).to be_empty
          end
        end
      end
    end

    context "when the single or multi component answer is 'multiple'" do
      let(:single_or_multi_component) { "multiple" }

      before { form.validate }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not adds an error message for single or multi components" do
        expect(form.errors.full_messages_for(:single_or_multi_component)).to be_empty
      end

      context "when the components count is empty" do
        let(:components_count) { "" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the components count attribute" do
          expect(form.errors.full_messages_for(:components_count)).to eq(["Enter a number for how how many items it contains"])
        end
      end

      context "when the components count contains a non numeric value" do
        let(:components_count) { "twelve" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the components count attribute" do
          expect(form.errors.full_messages_for(:components_count)).to eq(["Enter a number for how how many items it contains"])
        end
      end

      context "when the components count value is too low" do
        let(:components_count) { "1" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the components count attribute" do
          expect(form.errors.full_messages_for(:components_count)).to eq(["There is a minimum of 2 items"])
        end
      end

      context "when the components count value is too high" do
        let(:components_count) { "11" }

        it "is invalid" do
          expect(form).to be_invalid
        end

        it "adds an error message for the components count attribute" do
          expect(form.errors.full_messages_for(:components_count)).to eq(["Maximum items count is 10. More can be added later"])
        end
      end
    end

    context "when the single or multi component answer is 'single'" do
      let(:single_or_multi_component) { "single" }

      before { form.validate }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not adds an error message for single or multi components" do
        expect(form.errors.full_messages_for(:single_or_multi_component)).to be_empty
      end

      context "when the components count is invalid" do
        let(:components_count) { "twelve" }

        it "is still valid" do
          expect(form).to be_valid
        end

        it "does not add an error message for the components count attribute" do
          expect(form.errors.full_messages_for(:components_count)).to be_empty
        end
      end
    end
  end
end
