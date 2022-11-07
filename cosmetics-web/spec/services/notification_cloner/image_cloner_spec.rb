require "rails_helper"
require "sidekiq/testing"

RSpec.describe NotificationCloner::ImageCloner, :with_stubbed_antivirus do
  let(:notification) { create(:registered_notification, :with_label_image) }

  let(:component1) { create(:ranges_component, :completed, :with_range_ingredients, notification:) }

  before do
    component1
  end

  describe "Notification cloning" do
    let(:new_notification) { NotificationCloner::Base.clone(notification) }

    it "schedules job to clone images" do
      notification
      with_test_queue_adapter do
        expect {
          new_notification
        }.to have_enqueued_job(CopyImageUploadsJob)
      end
    end

    it "create copy of images" do
      expect {
        new_notification
      }.to change(ImageUpload, :count).by(1)
    end
  end

  def with_test_queue_adapter
    ActiveJob::Base.queue_adapter = :test
    yield
    ActiveJob::Base.queue_adapter = :inline
  end
end
