require "rails_helper"

describe ActiveModel::Type::StrictFloat do
  class DummyForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :float_attribute, :strict_float
  end

  it "casts string representation of float properly" do
    form = DummyForm.new(float_attribute: "3.14")
    expect(form.float_attribute).to eq(3.14)
  end

  it "does not cast non-strict string representation of float properly" do
    form = DummyForm.new(float_attribute: "3.14-30")
    expect(form.float_attribute).to eq(nil)
  end
end
