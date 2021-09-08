require "rails_helper"

RSpec.describe CommonPasswordValidator do
  subject(:validator) do
    Class.new {
      include ActiveModel::Validations
      attr_accessor :password

      validates :password,
                common_password: {
                  message: "Choose a less frequently used password"
                }

      def self.name
        "User"
      end
    }.new
  end

  # To avoid tests depending on the actual file content.
  before do
    allow(File).to receive(:foreach).and_yield("password").and_yield("testpassword")
  end

  context "with passwords listed in the common passwords file" do
    before do
      validator.password = "testpassword"
      validator.validate
    end

    it "is not valid" do
      expect(validator).not_to be_valid
    end

    it "populates an error message" do
      expect(validator.errors.messages[:password])
        .to eq ["Choose a less frequently used password"]
    end
  end

  context "with passwords not listed in the common passwords file" do
    before do
      validator.password = "notCommonPassword123"
      validator.validate
    end

    it "is valid" do
      expect(validator).to be_valid
    end

    it "does not populate an error message" do
      expect(validator.errors.messages[:password]).to be_empty
    end
  end
end
