require "rails_helper"

RSpec.describe NanomaterialHelper, type: :helper do
  before do
    stub_const("NanoMaterialPurpose", Class.new)

    purposes_class = Class.new do
      def self.find(_purpose)
        nil
      end
    end
    stub_const("NanoMaterialPurposes", purposes_class)

    allow(NanoMaterialPurposes).to receive(:find) do |purpose|
      case purpose
      when "uv_filter"
        instance_double(NanoMaterialPurpose, annex_number: "VI")
      when "preservative"
        instance_double(NanoMaterialPurpose, annex_number: "V")
      when "colorant"
        instance_double(NanoMaterialPurpose, annex_number: "IV")
      end
    end

    allow(helper).to receive(:pluralize) do |count, word|
      count == 1 ? word : "#{word}s"
    end

    allow(helper).to receive(:to_sentence) do |array, _options|
      if array.size == 1
        array.first
      elsif array.size == 2
        "#{array.first} and #{array.last}"
      else
        last = array.pop
        "#{array.join(', ')} and #{last}"
      end
    end
  end

  describe "#ec_regulation_annex_details_for_nanomaterial_purposes" do
    subject { helper.ec_regulation_annex_details_for_nanomaterial_purposes(purposes) }

    context "when no purposes are provided" do
      [nil, []].each do |empty_value|
        context "with #{empty_value.inspect}" do
          let(:purposes) { empty_value }

          it { is_expected.to eq("No annexes") }
        end
      end
    end

    context "when only invalid purposes are provided" do
      let(:purposes) { %w[unknown_purpose another_unknown] }

      it { is_expected.to eq("No annexes") }
    end

    context "when a single valid purpose is provided" do
      let(:purposes) { %w[uv_filter] }

      it { is_expected.to eq("Annex VI") }
    end

    context "when two valid purposes are provided" do
      let(:purposes) { %w[uv_filter preservative] }

      it { is_expected.to eq("Annexes VI and V") }
    end

    context "when three valid purposes are provided" do
      let(:purposes) { %w[uv_filter preservative colorant] }

      it { is_expected.to eq("Annexes VI, V and IV") }
    end

    context "when a mix of valid and invalid purposes are provided" do
      let(:purposes) { %w[uv_filter unknown_purpose preservative] }

      it { is_expected.to eq("Annexes VI and V") }
    end
  end
end
