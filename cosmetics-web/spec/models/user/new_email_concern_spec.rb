require "rails_helper"

RSpec.describe User, type: :model do
  describe "change email" do
    let(:old_email) { "old@example.com" }
    let(:user) { create(:submit_user, email: old_email) }
    let(:expected_token) { "foobar" }
    let(:new_email) { "new@example.com" }
    let(:new_email_expiration_expiration) { Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR }

    before do
      freeze_time
      allow(SecureRandom).to receive(:uuid).and_return(expected_token)

      user.new_email = new_email
      user.save
    end

    after do
      travel_back
    end

    describe "#new_email=" do
      context "when successful" do
        it "saves email" do
          expect(user.reload.new_email).to eq(new_email)
        end

        it "generate_new_email_token" do
          expect(user.reload.new_email_confirmation_token).to eq(expected_token)
        end

        it "sets token validity" do
          expect(user.reload.new_email_confirmation_token_expires_at).to eq(new_email_expiration_expiration)
        end
      end

      context "with validation errors" do
        shared_examples "invalid email" do
          specify do
            expect(user).not_to be_valid
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

    describe "#new_email!(token)" do
      context "when token is valid" do
        before do
          described_class.new_email!(expected_token)
        end

        it "changes email successfully" do
          expect(user.reload.email).to eq(new_email)
        end

        # rubocop:disable RSpec/MultipleExpectations
        it "clears all new_email fields" do
          expect(user.reload.new_email).to eq(nil)
          expect(user.reload.new_email_confirmation_token).to eq(nil)
          expect(user.reload.new_email_confirmation_token_expires_at).to eq(nil)
        end
        # rubocop:enable RSpec/MultipleExpectations
      end

      context "when token is invalid" do
        it "does not change email" do
          described_class.new_email!("token") rescue nil
          expect(user.reload.email).to eq(old_email)
        end

        it "raises ArgumentError" do
          expect { described_class.new_email!("token") }.to raise_error(ArgumentError)
        end
      end

      context "when token is expired" do
        before do
          travel_to(Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR + 1)
        end

        it "does not change email" do
          described_class.new_email!(expected_token) rescue nil
          expect(user.reload.email).to eq(old_email)
        end

        it "raises ArgumentError" do
          expect { described_class.new_email!(expected_token) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
