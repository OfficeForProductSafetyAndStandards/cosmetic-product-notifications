require 'rails_helper'

RSpec.describe ResponsiblePerson, type: :model do
  let(:responsible_person) { build(:responsible_person) }

  describe "create record" do
    it "succeeds when all required attributes are specified" do
      expect(responsible_person.save).to be true
    end

    it "fails if an account_type is not specified" do
      responsible_person.account_type = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:account_type]).to include("can't be blank")
    end

    it "fails if a name is not specified" do
      responsible_person.name = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:name]).to include("can't be blank")
    end

    it "fails if an email address is not specified" do
      responsible_person.email_address = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("can't be blank")
    end

    it "fails if a phone number is not specified" do
      responsible_person.phone_number = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:phone_number]).to include("can't be blank")
    end

    it "fails if a street address is not specified" do
      responsible_person.address_line_1 = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:address_line_1]).to include("can't be blank")
    end

    it "fails if a city is not specified" do
      responsible_person.city = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:city]).to include("can't be blank")
    end

    it "fails if a postal code is not specified" do
      responsible_person.postal_code = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:postal_code]).to include("can't be blank")
    end

    it "fails if the email address is not unique" do
      create(:responsible_person, email_address: "duplicate@example.com")
      responsible_person.email_address = "duplicate@example.com"

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("has already been taken")
    end

    it "fails if the email address format is invalid" do
      responsible_person.email_address = "invalid_format"

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("is invalid")
    end

    it "succeeds if a Companies House number is not specified for individual account type" do
      responsible_person.account_type = :individual
      responsible_person.companies_house_number = nil

      expect(responsible_person.save).to be true
    end

    it "fails if a Companies House number is not specified for business account type" do
      responsible_person.account_type = :business
      responsible_person.companies_house_number = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:companies_house_number]).to include("can't be blank")
    end

    it "fails if the Companies House number is not unique for business account type" do
      create(:business_responsible_person, companies_house_number: "12345678")
      responsible_person = build(:business_responsible_person, companies_house_number: "12345678")

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:companies_house_number]).to include("has already been taken")
    end
  end
end
