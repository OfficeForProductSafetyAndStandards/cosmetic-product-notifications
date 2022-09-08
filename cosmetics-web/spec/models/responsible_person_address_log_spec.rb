require "rails_helper"

RSpec.describe ResponsiblePersonAddressLog, type: :model do
  describe "validations" do
    subject(:address_log) { build_stubbed(:responsible_person_address_log) }

    it "fails if a street address is not specified" do
      address_log.line_1 = nil

      expect(address_log.valid?).to be false
      expect(address_log.errors[:line_1]).to include("Line 1 can not be blank")
    end

    it "fails if a city is not specified" do
      address_log.city = nil

      expect(address_log.valid?).to be false
      expect(address_log.errors[:city]).to include("City can not be blank")
    end

    it "fails if a postal code is not specified" do
      address_log.postal_code = nil

      expect(address_log.valid?).to be false
      expect(address_log.errors[:postal_code]).to include("Postal code can not be blank")
    end

    it "fails if postal code does not belong to UK" do
      address_log.postal_code = "JJJJJ"

      expect(address_log.valid?).to be false
      expect(address_log.errors[:postal_code]).to include("Enter a UK postcode")
    end

    it "acepts the second line and county not being specified" do
      address_log.line_2 = nil
      address_log.county = nil

      expect(address_log.valid?).to be true
    end

    it "fails if the end date is earlier than start date" do
      address_log.start_date = Time.zone.local(2021, 7, 1)
      address_log.end_date = Time.zone.local(2020, 5, 1)
      expect(address_log.valid?).to be false
      expect(address_log.errors[:end_date]).to include("End date must be after start date")
    end
  end

  describe "end date set on callback" do
    let(:current_time) { Time.zone.local(2021, 9, 3) }

    before { travel_to current_time }

    after { travel_back }

    it "autopopulates the end date to the current time when not provided" do
      address_log = build_stubbed(:responsible_person_address_log, end_date: nil)
      address_log.validate
      expect(address_log.end_date).to eq(Time.zone.now)
    end

    it "keeps the given end date when provided" do
      given_date = Time.zone.local(2021, 8, 1)
      address_log = build_stubbed(:responsible_person_address_log, end_date: given_date)
      address_log.validate
      expect(address_log.end_date).to eq(given_date)
    end
  end

  describe "start date set on callback" do
    let(:responsible_person) { create(:responsible_person, created_at: Time.zone.local(2021, 7, 1)) }

    context "when there where other previous addresses associated with the responsible person" do
      before do
        create(:responsible_person_address_log,
               responsible_person:,
               start_date: Time.zone.local(2021, 7, 1),
               end_date: Time.zone.local(2021, 8, 1))
        create(:responsible_person_address_log,
               responsible_person:,
               start_date: Time.zone.local(2021, 8, 1),
               end_date: Time.zone.local(2021, 9, 1))
      end

      it "populates the start date with the last previous address end date" do
        address_log = build_stubbed(:responsible_person_address_log,
                                    responsible_person:,
                                    start_date: nil)
        address_log.validate
        expect(address_log.start_date).to eq(Time.zone.local(2021, 9, 1))
      end
    end

    context "when there aren't previous addresses associated with the responsible person" do
      it "populates the start date with the Responsible Person creation date" do
        address_log = build_stubbed(:responsible_person_address_log,
                                    responsible_person:,
                                    start_date: nil)
        address_log.validate
        expect(address_log.start_date).to eq(responsible_person.created_at)
      end
    end
  end

  describe "#to_s" do
    # rubocop:disable RSpec/ExampleLength
    it "returns the address in a human readable format" do
      address_log = build_stubbed(:responsible_person_address_log,
                                  line_1: "Office name",
                                  line_2: "123 Street",
                                  city: "London",
                                  county: "Greater London",
                                  postal_code: "SW1A 1AA")
      expect(address_log.to_s).to eq("Office name, 123 Street, London, Greater London, SW1A 1AA")
    end

    it "does not include empty fields" do
      address_log = build_stubbed(:responsible_person_address_log,
                                  line_1: "Office name",
                                  line_2: nil,
                                  city: "London",
                                  county: nil,
                                  postal_code: "SW1A 1AA")
      expect(address_log.to_s).to eq("Office name, London, SW1A 1AA")
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
