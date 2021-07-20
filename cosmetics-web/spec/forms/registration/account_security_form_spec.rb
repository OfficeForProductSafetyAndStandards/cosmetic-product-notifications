require "rails_helper"

RSpec.describe Registration::AccountSecurityForm do
  let(:full_name) { "Mr New Name" }
  let(:password) { "foobarbaz" }
  let(:mobile_number) { "07000 000 000" }
  let(:user) { build_stubbed(:submit_user) }
  let(:secret_key) { "QSE5PUJFT4ZGTBRPGOOOW3QJWWVZNUP7" }

  let(:form) do
    described_class.new(password: password,
                        app_authentication: "1",
                        sms_authentication: "1",
                        app_authentication_code: "123456",
                        mobile_number: mobile_number,
                        full_name: full_name,
                        user: user,
                        secret_key: secret_key)
  end

  before do
    allow(ROTP::TOTP).to receive(:new)
      .and_return(instance_double(ROTP::TOTP, verify: 1_474_590_700))
  end

  # rubocop:disable RSpec/ExampleLength
  describe "#update!" do
    let(:user) do
      create(:submit_user, :confirmed_not_verified, :invited, name: nil)
    end

    shared_examples "security attributes set" do
      it "sets the user security attributes" do
        expect {
          form.update!
          user.reload
        }.to change(user, :name).to(full_name)
         .and change(user, :encrypted_password)
         .and change(user, :account_security_completed).from(false).to(true)
      end
    end

    shared_examples "confirmation token removal" do
      it "removes the user confirmation token info" do
        expect {
          form.update!
          user.reload
        }.to change(user, :confirmation_token).to(nil)
         .and change(user, :confirmation_sent_at).to(nil)
      end
    end

    context "when the form attributes are valid" do
      context "when both sms and app authentication are selected" do
        include_examples "security attributes set"
        include_examples "confirmation token removal"

        it "sets user secondary authentication attributes for both app and sms" do
          expect {
            form.update!
            user.reload
          }.to change(user, :mobile_number).from(nil).to(mobile_number)
           .and change(user, :totp_secret_key).from(nil)
           .and change(user, :last_totp_at).from(nil)
           .and change(user, :secondary_authentication_methods).from(nil).to(%w[app sms])
        end
      end

      context "when only the app authentication is selected" do
        before do
          form.assign_attributes(app_authentication: "1", sms_authentication: "0")
        end

        include_examples "security attributes set"
        include_examples "confirmation token removal"

        it "sets user app secondary authentication attributes but not the sms ones" do
          expect {
            form.update!
            user.reload
          }.to change(user, :totp_secret_key).from(nil)
           .and change(user, :last_totp_at).from(nil)
           .and change(user, :secondary_authentication_methods).from(nil).to(%w[app])
           .and not_change(user, :mobile_number).from(nil)
        end
      end

      context "when only the sms authentication is selected" do
        before do
          form.assign_attributes(app_authentication: "0", sms_authentication: "1")
        end

        include_examples "security attributes set"
        include_examples "confirmation token removal"

        it "sets user sms secondary authentication attributes but not app ones" do
          expect {
            form.update!
            user.reload
          }.to change(user, :mobile_number).from(nil).to(mobile_number)
           .and change(user, :secondary_authentication_methods).from(nil).to(%w[sms])
           .and not_change(user, :totp_secret_key).from(nil)
           .and not_change(user, :last_totp_at).from(nil)
        end
      end
    end

    context "when the form attributes are not valid" do
      before { form.password = "" }

      it "returns false" do
        expect(form.update!).to eq false
      end

      it "does not change any user attribute" do
        expect {
          form.update!
          user.reload
        }.to not_change(user, :name)
         .and not_change(user, :encrypted_password)
         .and not_change(user, :account_security_completed).from(false)
         .and not_change(user, :confirmation_token)
         .and not_change(user, :totp_secret_key).from(nil)
         .and not_change(user, :last_totp_at).from(nil)
         .and not_change(user, :mobile_number).from(nil)
         .and not_change(user, :secondary_authentication_methods).from(nil)
         .and(not_change { user.confirmation_sent_at.to_s })
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe "#secret_key" do
    it "returns secret key if is already set" do
      expect(form.secret_key).to eq secret_key
    end

    it "generates a new secret key when wasn't already set" do
      form.secret_key = nil
      expect(form.secret_key).not_to eq secret_key
      expect(form.secret_key.size).to eq 32
    end
  end

  describe "#decorated_secret_key" do
    it "introduces a space between every 4 characters of the form secret key" do
      form.secret_key = "QSE5PUJFT4ZGTBRPGOOOW3QJWWVZNUP7"
      expect(form.decorated_secret_key).to eq "QSE5 PUJF T4ZG TBRP GOOO W3QJ WWVZ NUP7"
    end
  end

  describe "#app_authentication_code" do
    before { form.app_authentication_code = "123456" }

    it "discards the app authentication code when the app authentication is not selected" do
      form.app_authentication = "0"
      expect(form.app_authentication_code).to be_nil
    end

    it "keeps the app authentication code when the app authentication is selected" do
      form.app_authentication = "1"
      expect(form.app_authentication_code).to eq "123456"
    end
  end

  describe "#mobile_number" do
    before { form.mobile_number = "07123456789" }

    it "discards the mobile number when the sms authentication is not selected" do
      form.sms_authentication = "0"
      expect(form.mobile_number).to be_nil
    end

    it "keeps the mobile number when the sms authentication is selected" do
      form.sms_authentication = "1"
      expect(form.mobile_number).to eq "07123456789"
    end
  end

  describe "validations" do
    context "when the password is too short" do
      let(:password) { "foobar" }

      it "is invalid" do
        expect(form).not_to be_valid
      end

      it "contains errors" do
        form.valid?
        expect(form.errors.full_messages_for(:password)).to eq ["Password must be at least 8 characters"]
      end
    end

    describe "name validations" do
      let(:form) do
        described_class.new(password: password,
                            mobile_number: mobile_number,
                            user: user,
                            full_name: full_name,
                            app_authentication: "0",
                            sms_authentication: "1")
      end

      context "when the user name is not introduced" do
        let(:full_name) { nil }

        it "is invalid" do
          expect(form).not_to be_valid
        end

        it "contains errors" do
          form.valid?
          expect(form.errors.full_messages_for(:full_name)).to eq ["Enter your full name"]
        end
      end

      context "when the user name is introduced" do
        let(:full_name) { "John Doe" }

        it "is valid" do
          expect(form).to be_valid
        end

        it "does not contains errors" do
          form.valid?
          expect(form.errors.full_messages_for(:full_name)).to be_empty
        end
      end
    end

    describe "app authentication methods validations" do
      it "is valid when sms is selected" do
        form.sms_authentication = "1"
        form.app_authentication = "0"
        expect(form).to be_valid
        expect(form.errors.full_messages_for(:secondary_authentication_methods)).to be_empty
      end

      it "is valid when app is selected" do
        form.sms_authentication = "0"
        form.app_authentication = "1"
        expect(form).to be_valid
        expect(form.errors.full_messages_for(:secondary_authentication_methods)).to be_empty
      end

      it "is valid when app and sms are both selected" do
        form.sms_authentication = "1"
        form.app_authentication = "1"
        expect(form).to be_valid
        expect(form.errors.full_messages_for(:secondary_authentication_methods)).to be_empty
      end

      it "is invalid when neither app or sms are selected" do
        form.sms_authentication = "0"
        form.app_authentication = "0"
        expect(form).not_to be_valid
        expect(form.errors.full_messages_for(:secondary_authentication_methods))
          .to eq(["Select how to get an access code"])
      end
    end

    describe "mobile number validations" do
      context "when the sms authentication is selected" do
        before { form.sms_authentication = "1" }

        shared_examples "mobile number" do
          it "is invalid" do
            expect(form).not_to be_valid
          end

          it "contains errors" do
            form.valid?
            expect(form.errors.full_messages_for(:mobile_number)).to include(message)
          end
        end

        context "when the mobile number is empty" do
          include_examples "mobile number" do
            let(:mobile_number) { "" }
            let(:message) { "Enter a mobile number, like 07700 900 982 or +44 7700 900 982" }
          end
        end

        context "when mobile number has letters" do
          include_examples "mobile number" do
            let(:mobile_number) { "070000assd" }
            let(:message) { "Enter a mobile number, like 07700 900 982 or +44 7700 900 982" }
          end
        end

        context "when mobile number has not enough characters" do
          include_examples "mobile number" do
            let(:mobile_number) { "0700710120" }
            let(:message) { "Enter a mobile number, like 07700 900 982 or +44 7700 900 982" }
          end
        end
      end

      context "when the sms authentication is not selected" do
        before { form.sms_authentication = "0" }

        it "does not require mobile number" do
          form.mobile_number = ""
          expect(form).to be_valid
          expect(form.errors.full_messages_for(:mobile_number)).to be_empty
        end

        it "does not validate the mobile number format" do
          form.mobile_number = "not a mobile number"
          expect(form).to be_valid
          expect(form.errors.full_messages_for(:mobile_number)).to be_empty
        end
      end
    end

    describe "app authentication code validations" do
      context "when the app authentication is selected" do
        before { form.app_authentication = "1" }

        it "fails validation when the app authentication code is not present" do
          form.app_authentication_code = ""
          expect(form).not_to be_valid
          expect(form.errors.full_messages_for(:app_authentication_code))
            .to eq ["Enter an access code"]
        end

        it "fails validation when the app authentication code is wrong" do
          allow(ROTP::TOTP).to receive(:new).and_return(instance_double(ROTP::TOTP, verify: nil))
          form.app_authentication_code = "000000"

          expect(form).not_to be_valid
          expect(form.errors.full_messages_for(:app_authentication_code))
            .to eq ["Enter a correct code"]
        end

        it "passes validation when the app authentication code is correct" do
          allow(ROTP::TOTP).to receive(:new).and_return(instance_double(ROTP::TOTP, verify: "1474590700"))
          form.app_authentication_code = "123456"

          expect(form).to be_valid
          expect(form.errors.full_messages_for(:app_authentication_code)).to be_empty
        end
      end

      context "when the app authentication is not selected" do
        before { form.app_authentication = "0" }

        it "does not require the app authentication code" do
          form.app_authentication_code = ""
          expect(form).to be_valid
          expect(form.errors.full_messages_for(:app_authentication_code)).to be_empty
        end
      end
    end
  end
end
