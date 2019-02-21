require 'rails_helper'

RSpec.describe ReadDataAnalyzer, type: :analyzer do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob) }
  let(:analyzer) { ReadDataAnalyzer.new(notification_file.uploaded_file) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
    remove_uploaded_files
  end

  describe "#accept" do
    it "rejects a null blob" do
      expect(ReadDataAnalyzer.accept?(nil)).equal?(false)
    end

    it "accepts a zip blob" do
      expect(ReadDataAnalyzer.accept?(notification_file.uploaded_file)).equal?(true)
    end
  end

  describe "#metadata" do
    it "creates a notification and removes a notification file" do
      notification_file
      expect {
        analyzer.metadata
      }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    end

    it "creates a notification populated with relevant name" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    it "creates a notification populated with relevant cpnp reference" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_reference).equal?("1000094")
    end

    it "creates a notification populated with relevant shades" do
      analyzer.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).equal?("")
    end

    it "creates a notification populated with relevant imported info" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_is_imported).equal?(false)
      expect(notification.cpnp_imported_country).equal?("")
    end

    it "creates a notification populated with relevant number of components" do
      notification_file
      expect {
        analyzer.metadata
      }.to change(Component, :count).by(1)
    end

    it "creates a notification populated with relevant notification type" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.notification_type).equal?(1)
    end

    it "creates a notification populated with relevant sub-sub-category" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.sub_sub_category).equal?(262)
    end

    it "creates a notification populated with relevant number of trigger questions and trigger elements" do
      notification_file
      expect {
        analyzer.metadata
      }.to change(TriggerQuestion, :count).by(7).and change(TriggerQuestionElement, :count).by(7)
    end

    it "creates a notification populated with relevant fram formulation" do
      analyzer.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.frame_formulation).equal?(263)
    end
  end
end
