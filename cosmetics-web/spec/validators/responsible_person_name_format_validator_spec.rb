require "rails_helper"

RSpec.describe ResponsiblePersonNameFormatValidator do
  subject(:validator) { validator_class.new(name) }

  let(:error_msg) { "Enter a valid name" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :name

      validates :name, responsible_person_name_format: { message: ERROR_MSG }

      def initialize(name)
        @name = name
      end

      def self.name
        "ValidatorClass"
      end
    end
  end

  before do
    stub_const("ERROR_MSG", error_msg)
    validator.validate
  end

  valid_names = [
    "Nice Soaps LTD.",
    "www.examplesoaps.org",
    "Nice Soaps",
    "Süper so@ps",
  ]

  invalid_names = [
    "Money is waiting at http://spam.com/dad33424sfksd",
    "<script>alert('hello')</script>",
    "<a href='spamurl'>",
    "Welcome Jane\nYou can join us at",
  ]

  valid_names.each do |name|
    context "with valid name (#{name})" do
      let(:name) { name }

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:name]).to be_empty
      end
    end
  end

  invalid_names.each do |name|
    context "with invalid name (#{name})" do
      let(:name) { name }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:name]).to eq [error_msg]
      end
    end
  end
end
