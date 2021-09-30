require "rails_helper"

RSpec.describe NameFormatValidator do
  subject(:validator) { validator_class.new(name) }

  let(:error_msg) { "Enter a valid name" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :name

      validates :name, name_format: { message: ERROR_MSG }

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
    "John Doe",
    "Felipe-Juan Froilan De Todos Los Santos",
    "Nuñez de Balbóa",
    "Ëllie Günter",
  ]

  invalid_names = [
    "John winmoney@example.org",
    "John welcome to www.spammyaddress.com",
    "John download a file from ftp:spamurl.co/resource",
    "Money is waiting at http://spam.com/dad33424sfksd",
    "<script>alert('hello')</script>",
    "<a href='spamurl'>",
    "Hello Jane, we have an offer for you",
    "Hello Sarah. There is an offer for you",
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
