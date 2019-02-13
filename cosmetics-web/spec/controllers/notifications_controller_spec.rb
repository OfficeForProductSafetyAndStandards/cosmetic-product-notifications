require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:notification) { create(:notification) }
  let(:draft_notification) { create(:draft_notification) }

  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
    mock_antivirus
  end

  after do
    sign_out
    unmock_antivirus
  end

  describe "GET /confirmation" do
    it "assigns the correct notification" do
      notification = create(:notification)
      get(:confirmation, params: { id: notification.reference_number })
      expect(assigns(:notification)).to eq(notification)
    end

    it "marks the notification as complete" do
      attach_image_to_draft_with_metadata(safe: true)
      get(:confirmation, params: { id: draft_notification.reference_number })
      expect(draft_notification.reload.state).to eq('notification_complete')
    end
  end

  describe "GET /edit" do
    it "assigns the correct notification" do
      notification = create(:notification)
      get(:edit, params: { id: notification.reference_number })
      expect(assigns(:notification)).to eq(notification)
    end

    it "adds error if failed attempt to submit when images are pending anti virus check" do
      attach_image_to_draft_with_metadata({})
      get(:edit, params: { id: draft_notification.reference_number, submit_failed: true })
      expect(assigns(:notification).errors[:image_uploads]).to include("waiting for files to pass anti virus check. Refresh to update")
    end

    it "adds error if failed attempt to submit when images have failed anti virus check" do
      draft_notification.image_uploads.build
      draft_notification.save
      get(:edit, params: { id: draft_notification.reference_number, submit_failed: true })
      expect(assigns(:notification).errors[:image_uploads]).to include("failed anti virus check")
    end
  end

  describe "GET /new" do
    it "creates new notification object" do
      get :new
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "redirects to the notification build controller" do
      get :new
      expect(response).to redirect_to(new_notification_build_path(assigns(:notification).reference_number))
    end
  end

private

  def attach_image_to_draft_with_metadata(metadata)
    draft_notification.image_uploads.build

    image_upload = draft_notification.image_uploads.first
    image_upload.file.attach(fixture_file_upload("testImage.png", "image/png"))
    image_upload.save

    blob = image_upload.file.blob
    blob.metadata = metadata
    blob.save
  end
end
