require "rails_helper"

RSpec.describe DateHelper, type: :helper do
  describe "#display_full_month_date" do
    it "returns a Date string" do
      date = Date.new(2022, 2, 1)
      expect(helper.display_full_month_date(date)).to eq("1 February 2022")
    end

    it "returns nil when passed nil" do
      date = nil
      expect(helper.display_full_month_date(date)).to be_nil
    end
  end

  describe "#display_date" do
    it "returns a Date string" do
      date = Date.new(2022, 2, 1)
      expect(helper.display_date(date)).to eq("01/02/2022")
    end

    it "returns nil when passed nil" do
      date = nil
      expect(helper.display_date(date)).to be_nil
    end
  end

  describe "#display_date_time" do
    it "returns a Date string" do
      date = Date.new(2022, 2, 1)
      expect(helper.display_date_time(date)).to eq("01/02/2022 00:00")
    end

    it "converts the input to a Date if a String and returns a Date string" do
      date = "2022-02-01 13:12:01"
      expect(helper.display_date_time(date)).to eq("01/02/2022 13:12")
    end

    it "returns nil when passed nil" do
      date = nil
      expect(helper.display_date_time(date)).to be_nil
    end
  end
end
