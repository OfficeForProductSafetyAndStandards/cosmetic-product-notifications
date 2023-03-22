require "rails_helper"

describe ComponentBuildHelper, type: :helper do
  describe "#next_step_if_ph_required" do
    subject { helper.next_step_if_ph_required(component) }

    context "when the PH step is required?" do
      let(:component) { build(:component) }

      it { is_expected.to eq(:select_ph_option) }
    end

    context "when the PH step is *not* required?" do
      let(:component) { build(:component, :ph_not_required) }

      it { is_expected.to eq(:completed) }
    end
  end
end
