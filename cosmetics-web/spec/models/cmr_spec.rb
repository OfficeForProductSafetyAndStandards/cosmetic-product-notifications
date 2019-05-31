require 'rails_helper'

RSpec.describe Cmr, type: :model do
  let(:cmr) { build(:cmr) }

  it "fails if a name is not specified" do
    cmr.name = nil

    expect(cmr.save).to be false
    expect(cmr.errors[:name]).to include("Name can not be blank")
  end

  it "fails if ec number doesn't contain 7 digits" do
    cmr.ec_number = "123"

    expect(cmr.save).to be false
    expect(cmr.errors[:ec_number]).to include("EC number must contain 7 digits")
  end

  it "fails if cas number doesn't contain 5-10 digits" do
    cmr.cas_number = "123"

    expect(cmr.save).to be false
    expect(cmr.errors[:cas_number]).to include("CAS number must contain between 5 to 10 digits")
  end

  it "fails if ec number is specified in a wrong format" do
    cmr.ec_number = "abcdef"

    expect(cmr.save).to be false
    expect(cmr.errors[:ec_number]).to include("EC number is invalid")
  end

  it "fails if cas number is specified in a wrong format" do
    cmr.cas_number = "abcdef"

    expect(cmr.save).to be false
    expect(cmr.errors[:cas_number]).to include("CAS number is invalid")
  end

  it "succeeds if ec number is blank" do
    cmr.ec_number = nil

    expect(cmr.save).to be true
  end

  it "succeeds if cas number is blank" do
    cmr.cas_number = nil

    expect(cmr.save).to be true
  end

  it "remove hyphens from cas number before saving" do
    cmr.cas_number = "1234-56-7"

    expect(cmr.save).to be true
    expect(cmr.cas_number).to eq "1234567"
  end

  it "remove hyphens from ec number before saving" do
    cmr.ec_number = "123-456-7"

    expect(cmr.save).to be true
    expect(cmr.ec_number).to eq "1234567"
  end
end
