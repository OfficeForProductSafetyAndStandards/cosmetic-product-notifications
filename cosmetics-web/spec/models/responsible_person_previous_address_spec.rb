require "rails_helper"

RSpec.describe ResponsiblePersonPreviousAddress, type: :model do
  subject(:previous_address) { build_stubbed(:responsible_person_previous_address) }

  describe "validations" do
    it "fails if a street address is not specified" do
      previous_address.line_1 = nil

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:line_1]).to include("Line 1 can not be blank")
    end

    it "fails if a city is not specified" do
      previous_address.city = nil

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:city]).to include("City can not be blank")
    end

    it "fails if a postal code is not specified" do
      previous_address.postal_code = nil

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:postal_code]).to include("Postal code can not be blank")
    end

    it "fails if postal code does not belong to UK" do
      previous_address.postal_code = "JJJJJ"

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:postal_code]).to include("Enter a UK postcode")
    end

    it "fails if the start date is not specified" do
      previous_address.start_date = nil

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:start_date]).to include("Start date can not be blank")
    end

    it "fails if the end date is not specified" do
      previous_address.end_date = nil

      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:end_date]).to include("End date can not be blank")
    end

    it "acepts the second line and county not being specified" do
      previous_address.line_2 = nil
      previous_address.county = nil

      expect(previous_address.valid?).to be true
    end
  end
end
