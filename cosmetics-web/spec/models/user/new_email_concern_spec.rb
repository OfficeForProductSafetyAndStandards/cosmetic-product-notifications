require "rails_helper"

RSpec.describe User, type: :model do
  describe "change email" do
    let(:old_email) { "old@example.com" }
    let(:expected_token) { "foobar" }
    let(:new_email) { "new@example.com" }
    let(:new_email_expiration) { Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR }

    before do
      freeze_time
    end

    after do
      travel_back
    end

    describe "#new_email_pending_confirmation!" do
      let(:user) { create(:submit_user, email: old_email) }
      let(:mailer) { double }

      before do
        allow(SecureRandom).to receive(:uuid).and_return(expected_token)
        allow(NotifyMailer).to receive(:new_email_verification_email).and_return(mailer)
        allow(mailer).to receive(:deliver_later)
      end

      context "when successful" do
        it "saves email" do
          expect {
            user.new_email_pending_confirmation!(new_email)
            user.reload
          }.to change(user, :new_email).from(nil).to(new_email)
        end

        it "sets a token for confirming the new email" do
          expect {
            user.new_email_pending_confirmation!(new_email)
            user.reload
          }.to change(user, :new_email_confirmation_token).from(nil).to(expected_token)
        end

        it "sets token validity" do
          expect {
            user.new_email_pending_confirmation!(new_email)
            user.reload
          }.to change(user, :new_email_confirmation_token_expires_at).from(nil).to(new_email_expiration)
        end

        it "sends a confirmation email" do
          user.new_email_pending_confirmation!(new_email)
          expect(mailer).to have_received(:deliver_later)
        end
      end

      context "with validation errors" do
        shared_examples "invalid email" do
          specify do
            expect {
              user.new_email_pending_confirmation!(new_email)
            }.to raise_error(ActiveRecord::RecordInvalid)
          end
        end

        context "when email is empty" do
          let(:new_email) { "" }

          include_examples "invalid email"
        end

        context "when email is missing domain" do
          let(:new_email) { "foo@bar" }

          include_examples "invalid email"
        end

        context "when email is incorrect" do
          let(:new_email) { "foo.bar.com" }

          include_examples "invalid email"
        end
      end
    end

    describe ".confirm_new_email!(token)" do
      shared_examples "invalid token" do
        it "does not change email" do
          begin
            described_class.confirm_new_email!(token)
          rescue StandardError
            nil
          end
          expect(user.reload.email).to eq(old_email)
        end

        it "raises ArgumentError" do
          expect { described_class.confirm_new_email!(token) }.to raise_error(ArgumentError)
        end
      end

      let(:user) do
        create(:submit_user,
               email: old_email,
               new_email: new_email,
               new_email_confirmation_token: expected_token,
               new_email_confirmation_token_expires_at: new_email_expiration)
      end
      let(:mailer) { double }

      before do
        allow(NotifyMailer).to receive(:update_email_address_notification_email).and_return(mailer)
        allow(mailer).to receive(:deliver_later)
      end

      context "when token is valid" do
        let(:token) { expected_token }

        it "changes email successfully" do
          expect {
            described_class.confirm_new_email!(token)
            user.reload
          }.to change(user, :email).from(old_email).to(new_email)
        end

        it "clears all new_email fields" do
          expect {
            described_class.confirm_new_email!(token)
            user.reload
          }.to change(user, :new_email).from(new_email).to(nil)
           .and change(user, :new_email_confirmation_token).from(expected_token).to(nil)
           .and change(user, :new_email_confirmation_token_expires_at).from(new_email_expiration).to(nil)
        end
      end

      context "when token is invalid" do
        let(:token) { "wrong-token" }

        include_examples "invalid token"
      end

      context "when token is expired" do
        let(:token) { expected_token }

        before do
          travel_to(Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR + 1)
        end

        include_examples "invalid token"
      end
    end
  end
end
