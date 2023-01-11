require "rails_helper"

RSpec.describe OneOff::NotificationBulkDeleter do
  subject(:bulk_deleter) { described_class.new(file) }

  let(:file) { "spec/fixtures/notification_bulk_deleter/notification_references.csv" }
  let(:existing_references) { %w[11039162 49508706 16335561 58914669 4970943] }

  before do
    existing_references.each { |ref| create(:notification, reference_number: ref) }
  end

  it "deletes the notifications" do
    expect {
      bulk_deleter.call
    }.to change(DeletedNotification, :count).from(0).to(5)
  end

  describe "service logging" do
    before do
      allow(Rails.logger).to receive(:info)
    end

    it "logs the amount of notification references requested to be deleted" do
      bulk_deleter.call
      expect(Rails.logger).to have_received(:info).with(/Attempted to delete 7 notifications/)
    end

    it "logs the amount of notification references to be deleted" do
      bulk_deleter.call
      expect(Rails.logger).to have_received(:info).with(/Deleting 5 notifications/)
    end

    it "logs the amount of given references that didn't match any notification" do
      bulk_deleter.call
      expect(Rails.logger).to have_received(:info)
        .with(/2 references did not match any notification in the service/)
    end

    it "logs the given references that didn't match any notification" do
      bulk_deleter.call
      expect(Rails.logger).to have_received(:info)
        .with(/References not found: \["11111111", "12345678"\]/)
    end

    it "logs the references for the deleted notifications" do
      bulk_deleter.call
      expect(Rails.logger).to have_received(:info)
        .with(/Deleted notifications: \["4970943", "11039162", "16335561", "49508706", "58914669"\]/)
    end
  end
end
