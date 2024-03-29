require "rails_helper"

RSpec.describe NanoMaterialPurposes, type: :model do
  describe ".all" do
    it "returns all the purposes" do
      expect(described_class.all.map(&:name)).to eq(%w[colorant preservative uv_filter other])
    end
  end

  describe ".standard" do
    it "returns all the standard purposes" do
      expect(described_class.standard.map(&:name)).to eq(%w[colorant preservative uv_filter])
    end
  end

  describe ".find" do
    it "returns the purpose with the given name" do
      expect(described_class.find("colorant")).to have_attributes(
        class: NanoMaterialPurposes::Purpose,
        name: "colorant",
      )
    end

    it "returns nil if the purpose name does not exist" do
      expect(described_class.find("foo")).to be_nil
    end
  end

  %i[colorant preservative uv_filter other].each do |purpose|
    describe ".#{purpose}" do
      it "returns '#{purpose}' purpose" do
        expect(described_class.public_send(purpose)).to have_attributes(
          class: NanoMaterialPurposes::Purpose,
          name: purpose.to_s,
        )
      end
    end
  end
end
