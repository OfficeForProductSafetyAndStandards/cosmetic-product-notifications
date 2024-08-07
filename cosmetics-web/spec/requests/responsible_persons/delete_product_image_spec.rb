require "rails_helper"

RSpec.describe "Delete product image", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification_a) { create(:notification, :with_label_image, responsible_person:) }

  let(:notification_b) { create(:notification, :with_label_image, responsible_person: other_responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    notification_a
    notification_b
  end

  describe "success" do
    it "deletes the product image" do
      expect {
        delete responsible_person_notification_draft_delete_product_image_path(responsible_person, notification_a, image_id: notification_a.image_uploads.first.id)
      }.to change { notification_a.image_uploads.count }.from(1).to(0)
    end
  end

  describe "failure" do
    it "raises an authorisation error" do
      expect {
        delete responsible_person_notification_draft_delete_product_image_path(responsible_person, notification_a, image_id: notification_b.image_uploads.first.id)
      }.not_to(change { notification_a.image_uploads.count })
    end
  end
end
