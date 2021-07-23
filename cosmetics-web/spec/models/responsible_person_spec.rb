require "rails_helper"

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

    it "fails if postal code does not belong to UK" do
      responsible_person.postal_code = "JJJJJ"

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:postal_code]).to include("Enter a UK postcode")
    end

    it "strips postal code leading/trailing spaces before saving it" do
      responsible_person.postal_code = " EC1 2PE "

      expect(responsible_person.save).to be true
      expect(responsible_person.postal_code).to eq "EC1 2PE"
    end
  end

  describe "#has_user_with_email?" do
    let(:user) { build(:submit_user, email: "member@example.org") }
    let(:responsible_person_user) { build(:responsible_person_user, user: user) }

    before do
      responsible_person.responsible_person_users << responsible_person_user
    end

    it "is false when no email is given" do
      expect(responsible_person.has_user_with_email?(nil)).to eq false
    end

    it "is false when there an empty email is given" do
      expect(responsible_person.has_user_with_email?("")).to eq false
    end

    it "is false when given email is not a string" do
      expect(responsible_person.has_user_with_email?(123)).to eq false
    end

    it "is false when given an email not matching any responsible person user" do
      expect(responsible_person.has_user_with_email?("not.member@example.org")).to eq false
    end

    it "is true when given an email matching a user of the responsible person" do
      expect(responsible_person.has_user_with_email?("member@example.org")).to eq true
    end

    it "is true when given an email matching a user of the responsible person with different capitalisation" do
      expect(responsible_person.has_user_with_email?("MeMbEr@EXAMPLE.org")).to eq true
    end
  end
end
