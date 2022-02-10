require "rails_helper"

RSpec.describe "Delete formulation file", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification1) { create(:notification, responsible_person: responsible_person) }
  let(:component1) { create(:component, :with_formulation_file, notification: notification1) }

  let(:notification2) { create(:notification, responsible_person: other_responsible_person) }
  let(:component2) { create(:component, :with_formulation_file, notification: notification2) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  before do
    component1
    component2
  end

  describe "success" do
    it "works" do
      expect {
        delete responsible_person_notification_draft_delete_formulation_file_path(responsible_person, notification1, component_id: component1.id)
      }.to change { component1.reload.formulation_file.present? }.from(true).to(false)
    end
  end

  describe "failure" do
    it "fails to delete a file" do
      expect {
        delete responsible_person_notification_draft_delete_formulation_file_path(responsible_person, notification1, component_id: component2.id)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
