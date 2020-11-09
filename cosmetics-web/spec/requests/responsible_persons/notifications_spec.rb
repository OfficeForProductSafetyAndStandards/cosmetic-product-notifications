require "rails_helper"

RSpec.describe "Notifications page", :with_stubbed_antivirus, :with_stubbed_notify, type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { build(:submit_user) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

  context "when deleting notification user incomplete notification" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    it "redirects" do
      delete responsible_person_notification_path(responsible_person, draft_notification)

      expect(response.status).to eq 302
    end

    it "removes record" do
      draft_notification
      expect {
        delete responsible_person_notification_path(responsible_person, draft_notification)
      }.to change(Notification, :count).from(1).to(0)
    end
  end

  context "when deleting notification that is complete" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    it "does not succeed" do
      expect {
        delete responsible_person_notification_path(responsible_person, notification)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when deleting notification that belongs to other user" do
    before do
      sign_in_as_member_of_responsible_person(other_responsible_person, user)
    end

    it "does not succeed" do
      expect {
        delete responsible_person_notification_path(other_responsible_person, draft_notification)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
