require "rails_helper"

RSpec.describe SubmitNotifyMailer, :with_stubbed_mailer do
  let(:user) { create(:submit_user) }

  describe "#send_account_confirmation_email" do
    context "when user has a name" do
      it "sends email with the user's name" do
        described_class.send_account_confirmation_email(user).deliver_now

        email = delivered_emails.last
        expect(email.personalization[:name]).to eq(user.name)
      end
    end

    context "when user has no name" do
      before do
        user.update_column(:name, nil)
      end

      it "sends email with empty string as name" do
        expect {
          described_class.send_account_confirmation_email(user).deliver_now
        }.not_to raise_error

        email = delivered_emails.last
        expect(email.personalization[:name]).to eq("")
      end
    end

    context "when user has blank name" do
      before do
        user.update_column(:name, "")
      end

      it "sends email with empty string as name" do
        expect {
          described_class.send_account_confirmation_email(user).deliver_now
        }.not_to raise_error

        email = delivered_emails.last
        expect(email.personalization[:name]).to eq("")
      end
    end
  end
end
