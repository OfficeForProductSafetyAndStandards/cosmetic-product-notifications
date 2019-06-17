require 'rails_helper'

RSpec.describe NonStandardNanomaterial, type: :model do
  let(:non_standard_nanomaterial) { build(:non_standard_nanomaterial) }

  it "fails if IUPAC name is not specified" do
    non_standard_nanomaterial.iupac_name = nil

    expect(non_standard_nanomaterial.save(context: :add_iupac_name)).to be false
    expect(non_standard_nanomaterial.errors[:iupac_name]).to include("IUPAC name can not be blank")
  end

  it "succeeds if IUPAC name is specified" do
    expect(non_standard_nanomaterial.save).to be true
  end
end
