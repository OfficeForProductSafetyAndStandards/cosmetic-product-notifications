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

  describe "#mobile_number_verified?" do
    context "with secondary authentication enabled" do
      before do
        allow(Rails.application.config).to receive(:secondary_authentication_enabled).and_return(true)
      end

      it "returns true for users with the mobile number verified" do
        user.mobile_number_verified = true
        expect(user.mobile_number_verified?).to eq true
      end

      it "returns false for users without the mobile number verified" do
        user.mobile_number_verified = false
        expect(user.mobile_number_verified?).to eq false
      end
    end

    context "with secondary_authentication disabled" do
      before do
        allow(Rails.application.config).to receive(:secondary_authentication_enabled).and_return(false)
      end

      it "returns true for users with the mobile number verified" do
        user.mobile_number_verified = true
        expect(user.mobile_number_verified?).to eq true
      end

      it "returns true for users without the mobile number verified" do
        user.mobile_number_verified = false
        expect(user.mobile_number_verified?).to eq true
      end
    end
  end

  describe "#mobile_number_change_allowed?" do
    context "with secondary authentication enabled" do
      before do
        allow(Rails.application.config).to receive(:secondary_authentication_enabled).and_return(true)
      end

      it "users with verified mobile number are not allowed to change their mobile number" do
        user.mobile_number_verified = true
        expect(user.mobile_number_change_allowed?).to eq false
      end

      it "users without verified mobile number are allowed to change their mobile number" do
        user.mobile_number_verified = false
        expect(user.mobile_number_change_allowed?).to eq true
      end
    end

    context "with secondary_authentication disabled" do
      before do
        allow(Rails.application.config).to receive(:secondary_authentication_enabled).and_return(false)
      end

      it "users with verified mobile number are not allowed to change their mobile number" do
        user.mobile_number_verified = true
        expect(user.mobile_number_change_allowed?).to eq false
      end

      it "users without verified mobile number are not allowed to change their mobile number" do
        user.mobile_number_verified = false
        expect(user.mobile_number_change_allowed?).to eq false
      end
    end
  end

  describe "#has_completed_registration?" do
    before do
      user.assign_attributes(encrypted_password: "encrypted_password_hash",
                             name: "John Doe",
                             mobile_number: "07123456789",
                             mobile_number_verified: true)
    end

    it "user has completed registration registration when password, name, mibile number and mobile number verification are set" do
      expect(user.has_completed_registration?).to eq true
    end

    it "user has not completed registration when missing encrypted password" do
      user.encrypted_password = nil
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when blank encrypted password" do
      user.encrypted_password = ""
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when missing name" do
      user.name = nil
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when blank name" do
      user.name = ""
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when missing mobile number" do
      user.mobile_number = nil
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when blank mobile number" do
      user.mobile_number = ""
      expect(user.has_completed_registration?).to eq false
    end

    it "user has not completed registration when mobile number is not verified" do
      user.mobile_number_verified = false
      expect(user.has_completed_registration?).to eq false
    end
  end
end
