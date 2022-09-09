require "rails_helper"

# rubocop:disable Style/RescueModifier
RSpec.describe NotificationDeleteService do
  let(:responsible_person) { create(:responsible_person) }
  let(:submit_user) { create(:submit_user) }
  let(:current_user) { submit_user }
  let(:service) { described_class.new(notification, current_user) }

  let(:notification_attributes) { @notification_attributes } # rubocop:disable RSpec/InstanceVariable

  before do
    freeze_time
    notification
    # Attributes needs to be cached after time freezing and notification creation,
    # but before removing the notification, so instance variable has a use here.
    @notification_attributes = OpenStruct.new(notification.attributes.merge(responsible_person: notification.responsible_person))
    create(:responsible_person_user, user: submit_user, responsible_person:)
  end

  context "when the notification is completed" do
    let(:notification) { create(:registered_notification, cpnp_reference: "123412344") }

    it "deletes the notification" do
      expect {
        service.call
      }.to change(Notification.deleted, :count).by(1)
    end

    it "creates log" do
      expect {
        service.call
      }.to change(NotificationDeleteLog, :count).by(1)
    end

    it "creates log entry with correct data" do
      service.call

      log = NotificationDeleteLog.first

      expect(log).to have_attributes(
        submit_user:,
        notification_product_name: notification_attributes.product_name,
        responsible_person: notification_attributes.responsible_person,
        notification_created_at: notification_attributes.created_at,
        notification_updated_at: notification_attributes.updated_at,
        cpnp_reference: notification_attributes.cpnp_reference,
        reference_number: notification_attributes.reference_number,
      )
    end

    context "when submit user is not provided" do
      let(:current_user) { nil }

      it "is not saved" do
        service.call

        log = NotificationDeleteLog.first

        expect(log).to have_attributes(
          submit_user: nil,
          notification_product_name: notification_attributes.product_name,
          responsible_person: notification_attributes.responsible_person,
          notification_created_at: notification_attributes.created_at,
          notification_updated_at: notification_attributes.updated_at,
          cpnp_reference: notification_attributes.cpnp_reference,
          reference_number: notification_attributes.reference_number,
        )
      end
    end

    context "when 7 days passed" do
      before do
        travel_to 8.days.from_now
      end

      it "doesn't delete the notification" do
        expect {
          service.call rescue nil
        }.to change(Notification, :count).by(0)
      end

      it "doesn't create log" do
        expect {
          service.call rescue nil
        }.to change(NotificationDeleteLog, :count).by(0)
      end

      it "raises proper exception" do
        expect {
          service.call
        }.to raise_error(Notification::DeletionPeriodExpired)
      end
    end
  end

  context "when the notification is a draft" do
    let(:notification) { create(:draft_notification, cpnp_reference: "123412344") }

    it "deletes the notification" do
      expect {
        service.call
      }.to change(Notification.deleted, :count).by(1)
    end

    it "does not create a log" do
      expect {
        service.call
      }.not_to change(NotificationDeleteLog, :count)
    end
  end
end
# rubocop:enable Style/RescueModifier
