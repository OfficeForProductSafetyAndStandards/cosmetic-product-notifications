require "rails_helper"

RSpec.describe ComponentHelper, type: :helper do
  describe "#ph_value_error_message" do
    subject(:error) { helper.ph_value_error_message(ph_scope, component, "minimum_ph") }

    let(:ph_scope) { "lower_than_3" }
    let(:component) { build(:component, ph: ph_scope) }

    context "when there is an error on the minimum_ph" do
      it "reassigns the error message" do
        component.errors.add :minimum_ph, %w[Oops]
        expect(error[:text]).to eq("Oops")
      end
    end

    context "when there is no error" do
      it { expect(error).to be_nil }
    end
  end
end
