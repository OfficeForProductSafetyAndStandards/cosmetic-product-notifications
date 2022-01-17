require "rails_helper"

RSpec.describe "Delete product image", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification1) { create(:notification, :with_label_image, responsible_person: responsible_person) }

  let(:notification2) { create(:notification, :with_label_image, responsible_person: other_responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  before do
    notification1
    notification2
  end

  describe "success" do
    it "works" do
      expect {
        delete responsible_person_notification_draft_delete_product_image_path(responsible_person, notification1, image_id: notification1.image_uploads.first.id)
      }.to change { notification1.image_uploads.count }.from(1).to(0)
    end
  end

  describe "failure" do
    it "raises authorisation error" do
      expect {
        delete responsible_person_notification_draft_delete_product_image_path(responsible_person, notification1, image_id: notification2.image_uploads.first.id)
      }.not_to change { notification1.image_uploads.count }
    end
  end
end
