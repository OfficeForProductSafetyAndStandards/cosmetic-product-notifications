require "rails_helper"

RSpec.describe EmailValidator do
  subject(:validator) { validator_class.new(email) }

  let(:error_msg) { "Enter your email address in the correct format, like name@example.com" }

  let(:validator_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :email

      validates :email, email: { message: ERROR_MSG }

      def initialize(email)
        @email = email
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

  valid_emails = [
    "user@example.com",
    "user+extra@example.com",
    "user@example.co.uk",
  ]

  invalid_emails = [
    nil,
    1234,
    "",
    "notanemail",
    "user@ example.com",
    "user@example .com",
    "useratexample.com",
    "user@example.com,",
    "user@example..com",
    "user@example",
  ]

  valid_emails.each do |email|
    context "with valid email (#{email})" do
      let(:email) { email }

      it "is valid" do
        expect(validator).to be_valid
      end

      it "does not populate an error message" do
        expect(validator.errors.messages[:email]).to be_empty
      end
    end
  end

  invalid_emails.each do |email|
    context "with invalid email (#{email})" do
      let(:email) { email }

      it "is not valid" do
        expect(validator).not_to be_valid
      end

      it "populates an error message" do
        expect(validator.errors.messages[:email]).to eq [error_msg]
      end
    end
  end
end
