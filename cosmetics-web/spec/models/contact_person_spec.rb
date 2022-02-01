require "rails_helper"

RSpec.describe ContactPerson, type: :model do
  let(:contact_person) { build(:contact_person) }

  it "fails if a name is not specified" do
    contact_person.name = nil

    expect(contact_person.save).to be false
    expect(contact_person.errors[:name]).to include("Name can not be blank")
  end

  it "fails if a phone number is not specified" do
    contact_person.phone_number = nil

    expect(contact_person.save).to be false
    expect(contact_person.errors[:phone_number]).to include("Telephone number can not be blank")
  end

  it "fails if an email address is not specified" do
    contact_person.email_address = nil
    expect(contact_person.save).to be false
    expect(contact_person.errors[:email_address]).to include("Enter an email address")
  end

  it "fails if the email address format is invalid" do
    contact_person.email_address = "invalid_format"

    expect(contact_person.save).to be false
    expect(contact_person.errors[:email_address]).to include("Enter the email address in the correct format, like name@example.com")
  end

  describe "name database validations" do
    RSpec.shared_examples " contact person name format validations" do
      it "does not accept a website as a part of the name" do
        contact_person.name = "Emma www.example.com"
        expect(contact_person.save).to be_falsey
        expect(contact_person.errors[:name]).to include("Enter a valid name")
      end

      it "does not accept a line break as a part of the name" do
        contact_person.name = "Emma\nWilliams"
        expect(contact_person.save).to be_falsey
        expect(contact_person.errors[:name]).to include("Enter a valid name")
      end

      it "does not accept a names over 50 characters" do
        contact_person.name = "This is a very long name that should not be accepted and should fail validation attempts"
        expect(contact_person.save).to be_falsey
        expect(contact_person.errors[:name]).to include("Name is too long (maximum is 50 characters)")
      end
    end

    context "when setting the name for first time" do
      include_examples " contact person name format validations"
    end

    describe "when changing the name" do
      before do
        contact_person.name = "Emma McCay"
        contact_person.save
      end

      include_examples " contact person name format validations"
    end
  end
end
