require "rails_helper"

RSpec.describe "Delete Notifications page", :with_stubbed_antivirus, :with_stubbed_notify, type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:draft_notification) { create(:draft_notification, responsible_person:) }
  let(:notification) { create(:registered_notification, responsible_person:) }

  context "when deleting notification user notification" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    context "when deletion is confirmed" do
      it "creates log record with current user" do
        expect(NotificationDeleteLog.count).to eq 0

        get delete_responsible_person_delete_notification_path(responsible_person, notification)

        expect(NotificationDeleteLog.first.submit_user).to eq user
      end

      it "removes record" do
        draft_notification
        expect {
          get delete_responsible_person_delete_notification_path(responsible_person, notification)
        }.to change(Notification.deleted, :count).from(0).to(1)
      end
    end

    context "when 2FA time passed", :with_2fa do
      before do
        get delete_responsible_person_delete_notification_url(responsible_person, draft_notification)
        post secondary_authentication_sms_url,
             params: {
               secondary_authentication_form: {
                 otp_code: user.reload.direct_otp,
                 user_id: user.id,
               },
             }

        travel_to 16.minutes.from_now
      end

      it "does not remove record" do
        expect {
          get delete_responsible_person_delete_notification_url(responsible_person, draft_notification)
        }.not_to change(Notification, :count)
      end

      it "redirects to 2FA" do
        draft_notification
        get delete_responsible_person_delete_notification_path(responsible_person, draft_notification)
        expect(response).to redirect_to("/two-factor/sms")
      end

      it "redirects info page to 2FA" do
        get delete_responsible_person_delete_notification_path(responsible_person, draft_notification)

        expect(response.status).to be(302)
      end
    end
  end

  context "when deleting notification that belongs to other user" do
    before do
      sign_in_as_member_of_responsible_person(other_responsible_person, user)
    end

    it "does not succeed" do
      expect {
        get delete_responsible_person_delete_notification_path(other_responsible_person, draft_notification)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
