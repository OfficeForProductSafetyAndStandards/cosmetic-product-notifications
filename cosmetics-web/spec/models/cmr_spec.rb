require 'rails_helper'

RSpec.describe Cmr, type: :model do
  let(:cmr) { create(:cmr) }

  describe "display cas number" do
    it "returns cas number formatted as XX-XX-X when cas number has 5 digits" do
      cmr.update_attribute(:cas_number, "12345")
      expect(cmr.display_name).to eq "Test CMR, 12-34-5, 123-456-7"
    end

    it "returns cas number formatted as XXXXX-XX-X when cas number has 8 digits" do
      cmr.update_attribute(:cas_number, "12345678")
      expect(cmr.display_name).to eq "Test CMR, 12345-67-8, 123-456-7"
    end

    it "returns cas number formatted as XXXXXXX-XX-X when cas number has 10 digits" do
      cmr.update_attribute(:cas_number, "1234567890")
      expect(cmr.display_name).to eq "Test CMR, 1234567-89-0, 123-456-7"
    end
  end

  describe "display ec number" do
    it "returns ec number formatted as XXX-XXX-X" do
      expect(cmr.display_name).to eq "Test CMR, 1234-56-7, 123-456-7"
    end
  end

  describe "display name" do
    it "returns non-empty cmr name, formatted cas and ec number separated by comma" do
      cmr.update_attribute(:ec_number, "")
      expect(cmr.display_name).to eq "Test CMR, 1234-56-7"
    end
  end
end
