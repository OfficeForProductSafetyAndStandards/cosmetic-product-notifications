require "rails_helper"

RSpec.describe Registration::NewAccountForm do
  let(:full_name) { "Mr New Name" }
  let(:email) { "email@example.com" }

  let(:form) do
    described_class.new(email: email, full_name: full_name)
  end

  describe "name validations" do
    RSpec.shared_examples "invalid name" do |error_message|
      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "contains errors" do
        form.valid?
        expect(form.errors.full_messages_for(:full_name)).to eq [error_message]
      end
    end

    context "when a valid user name is introduced" do
      let(:full_name) { "John Doe" }

      it "is valid" do
        expect(form).to be_valid
      end

      it "does not contains errors" do
        form.valid?
        expect(form.errors.full_messages_for(:full_name)).to be_empty
      end
    end

    context "when name is not present" do
      let(:full_name) { "" }

      include_examples "invalid name", "Enter your full name"
    end

    context "when the name is too long" do
      let(:full_name) { "Hey John this is actionfraud and not an spam email so you should totally believe us and don't be suspicious" }

      include_examples "invalid name", "Full name must be 50 characters or fewer"
    end

    context "when name contains invalid strings" do
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

      invalid_names.each do |invalid_name|
        context "when name is '#{invalid_name}'" do
          let(:full_name) { invalid_name }

          include_examples "invalid name", "Enter a valid name"
        end
      end
    end
  end
end
