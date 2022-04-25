require "rails_helper"

RSpec.describe "Edit Responsible Person Details", type: :request do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }

  before do
    configure_requests_for_submit_domain

    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "POST /accept" do
    let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }
    let(:params) { { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number } }
    let(:accept_path) { accept_responsible_person_notification_draft_path(responsible_person, draft_notification) }

    it "assigns the correct notification" do
      post accept_path, params: params
      expect(assigns(:notification)).to eq(draft_notification)
    end

    it "marks the notification as complete" do
      attach_image_to_draft_with_metadata(safe: true)
      post accept_path, params: params
      expect(draft_notification.reload.state).to eq("notification_complete")
    end

    it "populates the completion timestamp" do
      attach_image_to_draft_with_metadata(safe: true)
      post accept_path, params: params
      expect(draft_notification.reload.notification_complete_at).not_to be_nil
    end
  end

private

  def attach_image_to_draft_with_metadata(metadata)
    draft_notification.image_uploads.build

    image_upload = draft_notification.image_uploads.first
    image_upload.file.attach(fixture_file_upload("/testImage.png", "image/png"))
    image_upload.save

    blob = image_upload.file.blob
    blob.metadata = metadata
    blob.save
  end
end
