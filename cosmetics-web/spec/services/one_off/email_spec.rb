require "rails_helper"

RSpec.describe OneOff::Email do
  let(:email) { "foo.bar.baz@gmail.com" }

  it "extracts all names" do
    ne = described_class.new("foo.bar.baz@example.com")
    expect(ne.name).to eq "Foo Bar Baz"
  end

  it "extracts email" do
    ne = described_class.new("foo.bar.baz@example.com")
    expect(ne.email).to eq "foo.bar.baz@example.com"
  end

  it "extracts one name" do
    ne = described_class.new("foobarbaz@example.com")
    expect(ne.name).to eq "Foobarbaz"
  end

  it "extracts one nothing if email has no @" do
    ne = described_class.new("foobarbazexample.com")
    expect(ne.name).to eq nil
    expect(ne.email).to eq nil
  end
end
