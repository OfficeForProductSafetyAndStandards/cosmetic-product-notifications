require "rails_helper"

RSpec.describe NotificationFileProcessorJob do
  let!(:notification_file_basic) { create(:notification_file, uploaded_file: create_file_blob) }

  after do
    sign_out
    remove_uploaded_files
    close_file
  end

  describe "#perform" do
    it "creates a notification and removes a notification file" do
      expect {
        described_class.new.perform(notification_file_basic.id)
      }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    end

    it "creates a notification populated with relevant name" do
      described_class.new.perform(notification_file_basic.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    context "when the file contains a post-Brexit date" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFilePostBrexit.zip")) }

      before do
        described_class.new.perform(notification_file.id)
      end

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("post_brexit_date")
      end
    end
  end
end
