require 'rails_helper'

RSpec.describe ResponsiblePerson, type: :model do
  let(:responsible_person) { build(:responsible_person) }

  describe "create record" do
    it "succeeds when all required attributes are specified" do
      expect(responsible_person.save).to be true
    end

    it "fails if an account type is not specified" do
      responsible_person.account_type = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors.messages[:account_type]).to include("Account type can not be blank")
    end

    it "fails if a name is not specified" do
      responsible_person.name = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:name]).to include("Name can not be blank")
    end

    it "fails if a street address is not specified" do
      responsible_person.address_line_1 = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:address_line_1]).to include("Building and street can not be blank")
    end

    it "fails if a city is not specified" do
      responsible_person.city = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:city]).to include("Town or city can not be blank")
    end

    it "fails if a postal code is not specified" do
      responsible_person.postal_code = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:postal_code]).to include("Postcode can not be blank")
    end

    it "fails if a phone number is not specified" do
      responsible_person.phone_number = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:phone_number]).to include("Phone number can not be blank")
    end

    it "fails if an email address is not specified" do
      responsible_person.email_address = nil
      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("Email address can not be blank")
    end

    it "fails if the email address is not unique" do
      create(:responsible_person, email_address: "duplicate@example.com")
      responsible_person.email_address = "duplicate@example.com"

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("Email address has already been taken")
    end

    it "fails if the email address format is invalid" do
      responsible_person.email_address = "invalid_format"

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:email_address]).to include("Email address is invalid")
    end
  end
end
