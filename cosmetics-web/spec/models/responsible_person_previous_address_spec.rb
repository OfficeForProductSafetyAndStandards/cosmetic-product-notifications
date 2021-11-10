require "rails_helper"

RSpec.describe ResponsiblePersonPreviousAddress, type: :model do
  describe "validations" do
    subject(:previous_address) { build_stubbed(:responsible_person_previous_address) }

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

    it "acepts the second line and county not being specified" do
      previous_address.line_2 = nil
      previous_address.county = nil

      expect(previous_address.valid?).to be true
    end

    it "fails if the end date is earlier than start date" do
      previous_address.start_date = Time.zone.local(2021, 7, 1)
      previous_address.end_date = Time.zone.local(2020, 5, 1)
      expect(previous_address.valid?).to be false
      expect(previous_address.errors[:end_date]).to include("End date must be after start date")
    end
  end

  describe "end date set on callback" do
    let(:current_time) { Time.zone.local(2021, 9, 3) }

    before { travel_to current_time }

    after { travel_back }

    it "autopopulates the end date to the current time when not provided" do
      previous_address = build_stubbed(:responsible_person_previous_address, end_date: nil)
      previous_address.validate
      expect(previous_address.end_date).to eq(Time.zone.now)
    end

    it "keeps the given end date when provided" do
      given_date = Time.zone.local(2021, 8, 1)
      previous_address = build_stubbed(:responsible_person_previous_address, end_date: given_date)
      previous_address.validate
      expect(previous_address.end_date).to eq(given_date)
    end
  end

  describe "start date set on callback" do
    let(:responsible_person) { create(:responsible_person, created_at: Time.zone.local(2021, 7, 1)) }

    context "when there where other previous addresses associated with the responsible person" do
      before do
        create(:responsible_person_previous_address,
               responsible_person: responsible_person,
               start_date: Time.zone.local(2021, 7, 1),
               end_date: Time.zone.local(2021, 8, 1))
        create(:responsible_person_previous_address,
               responsible_person: responsible_person,
               start_date: Time.zone.local(2021, 8, 1),
               end_date: Time.zone.local(2021, 9, 1))
      end

      it "populates the start date with the last previous address end date" do
        previous_address = build_stubbed(:responsible_person_previous_address,
                                         responsible_person: responsible_person,
                                         start_date: nil)
        previous_address.validate
        expect(previous_address.start_date).to eq(Time.zone.local(2021, 9, 1))
      end
    end

    context "when there aren't previous addresses associated with the responsible person" do
      it "populates the start date with the Responsible Person creation date" do
        previous_address = build_stubbed(:responsible_person_previous_address,
                                         responsible_person: responsible_person,
                                         start_date: nil)
        previous_address.validate
        expect(previous_address.start_date).to eq(responsible_person.created_at)
      end
    end
  end

  describe "#to_s" do
    # rubocop:disable RSpec/ExampleLength
    it "returns the address in a human readable format" do
      previous_address = build_stubbed(:responsible_person_previous_address,
                                       line_1: "Office name",
                                       line_2: "123 Street",
                                       city: "London",
                                       county: "Greater London",
                                       postal_code: "SW1A 1AA")
      expect(previous_address.to_s).to eq("Office name, 123 Street, London, Greater London, SW1A 1AA")
    end

    it "does not include empty fields" do
      previous_address = build_stubbed(:responsible_person_previous_address,
                                       line_1: "Office name",
                                       line_2: nil,
                                       city: "London",
                                       county: nil,
                                       postal_code: "SW1A 1AA")
      expect(previous_address.to_s).to eq("Office name, London, SW1A 1AA")
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
