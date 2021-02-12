require "rails_helper"

RSpec.shared_examples "common user tests" do
  describe "validations" do
    it "requires email to be present" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("Email can not be blank")
    end

    it "requires name when user is not invited" do
      user.name = nil
      user.invite = false
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("Name can not be blank")
    end

    it "does not require name when user is invited" do
      user.name = nil
      user.invite = true
      expect(user).to be_valid
      expect(user.errors[:name]).to be_empty
    end

    it "does not enforce the presence of new_email" do
      user.new_email = nil
      expect(user).to be_valid
      expect(user.errors[:new_email]).to be_empty
    end

    it "validates the format of new_email" do
      user.new_email = "wrongformat"
      expect(user).not_to be_valid
      expect(user.errors[:new_email])
        .to include("Enter your email address in the correct format, like name@example.com")
    end

    it "does not require the secondary authentication methods when user didn't completete account security" do
      user.account_security_completed = false
      user.secondary_authentication_methods = nil
      expect(user).to be_valid
      expect(user.errors[:secondary_authentication_methods]).to be_empty
    end

    context "when user account security has been completed" do
      before { user.account_security_completed = true }

      it "requires a secondary authentication method" do
        user.secondary_authentication_methods = nil
        expect(user).not_to be_valid
        expect(user.errors[:secondary_authentication_methods])
          .to include("Select at least a secondary authentication method")
      end

      it "accepts sms as secondary authentication method" do
        user.account_security_completed = true
        user.secondary_authentication_methods = %w[sms]
        expect(user).to be_valid
        expect(user.errors[:secondary_authentication_methods]).to be_empty
      end

      it "accepts app as secondary authentication method" do
        user.account_security_completed = true
        user.secondary_authentication_methods = %w[app]
        expect(user).to be_valid
        expect(user.errors[:secondary_authentication_methods]).to be_empty
      end

      it "accepts both sms and app as secondary authentication methods" do
        user.account_security_completed = true
        user.secondary_authentication_methods = %w[app sms]
        expect(user).to be_valid
        expect(user.errors[:secondary_authentication_methods]).to be_empty
      end

      it "does not accept other secondary authenticatiom methods" do
        user.account_security_completed = true
        user.secondary_authentication_methods = %w[email]
        expect(user).not_to be_valid
        expect(user.errors[:secondary_authentication_methods])
          .to include("Invalid method. Secondary authentication methods accepted: 'sms','app' (or both)")
      end
    end
  end
end
