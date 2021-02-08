require "rails_helper"


RSpec.describe OneOff::NameExtractor do
  let(:email) { "foo.bar.baz@gmail.com" }

  it "extracts all names" do
    ne = OneOff::NameExtractor.new("foo.bar.baz@example.com")
    expect(ne.name).to eq "Foo Bar Baz"
  end

  it "extracts email" do
    ne = OneOff::NameExtractor.new("foo.bar.baz@example.com")
    expect(ne.email).to eq "foo.bar.baz@example.com"
  end

  it "extracts one name" do
    ne = OneOff::NameExtractor.new("foobarbaz@example.com")
    expect(ne.name).to eq "Foobarbaz"
  end

  it "extracts one nothing if email has no @" do
    ne = OneOff::NameExtractor.new("foobarbazexample.com")
    expect(ne.name).to eq nil
    expect(ne.email).to eq nil
  end
end
