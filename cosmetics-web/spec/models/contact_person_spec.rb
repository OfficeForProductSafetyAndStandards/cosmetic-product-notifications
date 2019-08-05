require 'rails_helper'

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
    expect(contact_person.errors[:phone_number]).to include("Phone number can not be blank")
  end

  it "fails if an email address is not specified" do
    contact_person.email_address = nil
    expect(contact_person.save).to be false
    expect(contact_person.errors[:email_address]).to include("Email address can not be blank")
  end

  it "fails if the email address format is invalid" do
    contact_person.email_address = "invalid_format"

    expect(contact_person.save).to be false
    expect(contact_person.errors[:email_address]).to include("Email address is invalid")
  end

  it "email is verified if the email address is same as current user email" do
    User.current = build(:user)

    contact_person.email_verified = false
    contact_person.email_address = User.current.email

    expect(contact_person.save).to be true
    expect(contact_person.email_verified).to be true
  end

  it "email verified resets to false if the email address changes" do
    contact_person.save
    contact_person.email_verified = true
    contact_person.email_address = "new_email@test.com"

    expect(contact_person.save).to be true
    expect(contact_person.email_verified).to be false
  end
end
