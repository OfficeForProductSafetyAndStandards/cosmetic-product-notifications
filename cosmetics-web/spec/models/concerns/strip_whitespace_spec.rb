require "rails_helper"
require_relative "../../../app/models/responsible_person.rb"

RSpec.describe StripWhitespace, type: :model do
  context "when included in an ApplicationRecord class" do
    subject(:instance) do
      create(:responsible_person, name: "Test RP", postal_code: "EC1 2JP", city: "London")
    end

    context "with a list of attributes to strip" do
      before { stub_const("ResponsiblePerson::STRIP_WHITESPACE", %i[name postal_code]) }

      it "only strips the spaces from the listed attributes" do
        instance.name = " Test RP "
        instance.postal_code = " EC1 2JP "
        instance.city = " London "
        instance.validate
        expect(instance).to have_attributes(name: "Test RP", postal_code: "EC1 2JP", city: " London ")
      end
    end

    context "without a list of attributes to strip" do
      it "strips the spaces from all the attributes that have changed" do
        instance.name = " Test RP "
        instance.postal_code = " EC1 2JP "
        instance.city = " London "
        instance.validate
        expect(instance).to have_attributes(name: "Test RP", postal_code: "EC1 2JP", city: "London")
      end
    end
  end

  context "when included in an ActiveModel class" do
    subject(:instance) do
      testing_class.new(name: " John ", postal_code: " EC1 2JP ", city: " London ")
    end

    let(:testing_class) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        include StripWhitespace

        attribute :name
        attribute :postal_code
        attribute :city
      end
    end

    before do
      stub_const("TestingClass", testing_class)
    end

    context "with a list of attributes to strip" do
      before do
        stub_const("TestingClass::STRIP_WHITESPACE", %i[name postal_code])
      end

      it "only strips the spaces from the listed attributes" do
        instance.validate
        expect(instance).to have_attributes(name: "John", postal_code: "EC1 2JP", city: " London ")
      end
    end

    context "without a list of attributes to strip" do
      it "strips the spaces from all the attributes" do
        instance.validate
        expect(instance).to have_attributes(name: "John", postal_code: "EC1 2JP", city: "London")
      end
    end
  end
end
