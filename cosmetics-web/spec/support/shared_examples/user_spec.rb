require "rails_helper"

RSpec.shared_examples "common user tests" do
  describe "validations" do
    context "when password is too common" do
      it "does not validate user" do
        user.password = "password"
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("Choose a password that is harder to guess")
      end
    end

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

    describe "name database validations" do
      let(:user) { build(super().class.name.underscore) } # In case original 'user' is a 'build_stubbed' object that cannot be saved

      RSpec.shared_examples "name format validations" do
        it "does not accept a website as a part of the name" do
          user.name = "Emma www.example.com"
          expect(user.save).to be_falsey
          expect(user.errors[:name]).to include("Enter a valid name")
        end

        it "does not accept a line break as a part of the name" do
          user.name = "Emma\nWilliams"
          expect(user.save).to be_falsey
          expect(user.errors[:name]).to include("Enter a valid name")
        end

        it "does not accept a names over 50 characters" do
          user.name = "This is a very long name that should not be accepted and should fail validation attempts"
          expect(user.save).to be_falsey
          expect(user.errors[:name]).to include("Name is too long (maximum is 50 characters)")
        end
      end

      context "when setting the name for first time" do
        include_examples "name format validations"
      end

      describe "when changing the name" do
        before do
          user.name = "Emma McCay"
          user.save
        end

        include_examples "name format validations"
      end
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
        .to include("Enter the email address in the correct format, like name@example.com")
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

  describe "mobile number change callback" do
    let(:user_factory) { user.class.to_s.underscore.to_sym }

    context "when the mobile number changes" do
      let(:new_user) { create(user_factory, :with_sms_secondary_authentication) }

      before do
        new_user.mobile_number = "07123456789"
      end

      it "sets the mobile number as not verified" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :mobile_number_verified).from(true).to(false)
      end

      it "keeps sms as secondary authentication method" do
        new_user.save
        expect(new_user.reload.secondary_authentication_methods).to eq %w[sms]
      end
    end

    context "when the mobile number does not change" do
      let(:new_user) { create(user_factory, :with_sms_secondary_authentication) }

      it "keeps the mobile number as verified" do
        expect {
          new_user.save
          new_user.reload
        }.not_to change(new_user, :mobile_number_verified).from(true)
      end

      it "keeps sms as secondary authentication method" do
        new_user.save
        expect(new_user.reload.secondary_authentication_methods).to eq %w[sms]
      end
    end

    context "when the mobile number is set from prior null value" do
      let(:new_user) { create(user_factory, :with_app_secondary_authentication) }

      before do
        new_user.mobile_number = "07123456789"
      end

      it "keeps the mobile number as not verified" do
        expect {
          new_user.save
          new_user.reload
        }.not_to change(new_user, :mobile_number_verified).from(false)
      end

      it "includes sms as secondary authentication method" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :secondary_authentication_methods).from(%w[app]).to(%w[app sms])
      end

      context "when the verification is also changed set" do
        before do
          new_user.mobile_number_verified = true
        end

        it "keeps the verification change as given" do
          expect {
            new_user.save
            new_user.reload
          }.not_to change(new_user, :mobile_number_verified).from(true)
        end
      end
    end

    context "when the mobile number is removed" do
      let(:new_user) { create(user_factory, :with_all_secondary_authentication_methods) }

      before do
        new_user.mobile_number = nil
      end

      it "sets the mobile number as not verified" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :mobile_number_verified).from(true).to(false)
      end

      it "removes sms as secondary authentication method" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :secondary_authentication_methods).from(%w[app sms]).to(%w[app])
      end
    end
  end

  describe "totp secret key change callback" do
    let(:user_factory) { user.class.to_s.underscore.to_sym }

    context "when the totp secret key changes" do
      let(:new_user) { create(user_factory, :with_app_secondary_authentication) }

      before do
        new_user.totp_secret_key = ROTP::Base32.random
      end

      it "keeps app as secondary authentication method" do
        new_user.save
        expect(new_user.reload.secondary_authentication_methods).to eq %w[app]
      end
    end

    context "when the totp secret key does not change" do
      let(:new_user) { create(user_factory, :with_app_secondary_authentication) }

      it "keeps sms as secondary authentication method" do
        new_user.name = "John Doe Murray"
        new_user.save
        expect(new_user.reload.secondary_authentication_methods).to eq %w[app]
      end
    end

    context "when the totp secret key is set from prior null value" do
      let(:new_user) { create(user_factory, :with_sms_secondary_authentication) }

      before do
        new_user.totp_secret_key = ROTP::Base32.random
      end

      it "includes app as secondary authentication method" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :secondary_authentication_methods).from(%w[sms]).to(%w[app sms])
      end
    end

    context "when the totp secret key is removed" do
      let(:new_user) { create(user_factory, :with_all_secondary_authentication_methods) }

      before do
        new_user.totp_secret_key = nil
      end

      it "removes app as secondary authentication method" do
        expect {
          new_user.save
          new_user.reload
        }.to change(new_user, :secondary_authentication_methods).from(%w[app sms]).to(%w[sms])
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
      user.assign_attributes(account_security_completed: false,
                             mobile_number: nil,
                             mobile_number_verified: false,
                             encrypted_totp_secret_key: nil,
                             last_totp_at: nil)
    end

    it "registration is not completed when account security has not been completed" do
      user.account_security_completed = false
      expect(user.has_completed_registration?).to eq false
    end

    context "when account security has been completed" do
      before { user.account_security_completed = true }

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

      it "user has completed registration when having a mobile number that is verified" do
        user.mobile_number = "07123456789"
        user.mobile_number_verified = false
        expect(user.has_completed_registration?).to eq true
      end

      it "user has completed registration when having set the app secondary authentication" do
        user.encrypted_totp_secret_key = "foobarencrypted"
        user.last_totp_at = 1_123_456_789
        expect(user.has_completed_registration?).to eq true
      end
    end
  end
end
