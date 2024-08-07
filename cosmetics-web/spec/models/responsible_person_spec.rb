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
      expect(responsible_person.errors.messages[:account_type]).to include("Account type cannot be blank")
    end

    it "fails if a name is not specified" do
      responsible_person.name = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:name]).to include("Name cannot be blank")
    end

    it "fails if a street address is not specified" do
      responsible_person.address_line_1 = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:address_line_1]).to include("Enter a building and street")
    end

    it "fails if a city is not specified" do
      responsible_person.city = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:city]).to include("Enter a town or city")
    end

    it "fails if a postal code is not specified" do
      responsible_person.postal_code = nil

      expect(responsible_person.save).to be false
      expect(responsible_person.errors[:postal_code]).to include("Enter a postcode")
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

  describe "name database validations" do
    RSpec.shared_examples "responsible person name validations" do
      it "fails when name includes http" do
        responsible_person.name = "Soaps http://www.example.com"
        expect(responsible_person.save).to be_falsey
        expect(responsible_person.errors[:name]).to include("Enter a valid name")
      end

      it "fails when name includes a line break" do
        responsible_person.name = "Great\nSoaps"
        expect(responsible_person.save).to be_falsey
        expect(responsible_person.errors[:name]).to include("Enter a valid name")
      end

      it "fails when name includes '<' or '>'" do
        responsible_person.name = "Great <a> Soaps"
        expect(responsible_person.save).to be_falsey
        expect(responsible_person.errors[:name]).to include("Enter a valid name")
      end

      it "fails when name is longer than 250 characters" do
        responsible_person.name = "a" * 251
        expect(responsible_person.save).to be_falsey
        expect(responsible_person.errors[:name]).to include("Name must be 250 characters or fewer")
      end
    end

    context "when setting the name for first time" do
      include_examples "responsible person name validations"
    end

    describe "when changing the name" do
      before do
        responsible_person.name = "Example Soaps"
        responsible_person.save
      end

      include_examples "responsible person name validations"
    end
  end

  describe "#has_user_with_email?" do
    let(:user) { build(:submit_user, email: "member@example.org") }
    let(:responsible_person_user) { build(:responsible_person_user, user:) }

    before do
      responsible_person.responsible_person_users << responsible_person_user
    end

    it "is false when no email is given" do
      expect(responsible_person.has_user_with_email?(nil)).to be false
    end

    it "is false when there an empty email is given" do
      expect(responsible_person.has_user_with_email?("")).to be false
    end

    it "is false when given email is not a string" do
      expect(responsible_person.has_user_with_email?(123)).to be false
    end

    it "is false when given an email not matching any responsible person user" do
      expect(responsible_person.has_user_with_email?("not.member@example.org")).to be false
    end

    it "is true when given an email matching a user of the responsible person" do
      expect(responsible_person.has_user_with_email?("member@example.org")).to be true
    end

    it "is true when given an email matching a user of the responsible person with different capitalisation" do
      expect(responsible_person.has_user_with_email?("MeMbEr@EXAMPLE.org")).to be true
    end
  end

  describe "#address_lines" do
    it "returns the available address files in an especific order" do
      responsible_person.assign_attributes(
        address_line_1: "123 Example Street", address_line_2: "Example Town", city: "Example City", county: "Example County", postal_code: "EX1 1EX",
      )
      expect(responsible_person.address_lines)
        .to eq(["123 Example Street", "Example Town", "Example City", "Example County", "EX1 1EX"])
    end

    it "only returns the available fields" do
      responsible_person.assign_attributes(
        address_line_1: "123 Example Street", address_line_2: "", city: "Example City", county: "", postal_code: "EX1 1EX",
      )
      expect(responsible_person.address_lines).to eq(["123 Example Street", "Example City", "EX1 1EX"])
    end
  end
end
