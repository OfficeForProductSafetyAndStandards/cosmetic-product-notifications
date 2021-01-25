require "rails_helper"

# rubocop:disable Style/RescueModifier
RSpec.describe NotificationDeleteService do
  let(:responsible_person) { create(:responsible_person) }
  let(:submit_user) { create(:submit_user) }
  let(:notification) { create(:registered_notification, cpnp_reference: "123412344") }
  let(:current_user) { submit_user }
  let(:other_user) { submit_user }
  let(:service) { described_class.new(notification, current_user) }

  before do
    freeze_time
    notification
    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person)
  end

  it "deletes the notification" do
    expect {
      service.call
    }.to change(Notification, :count).by(-1)
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
      submit_user: submit_user,
      notification_product_name: notification.product_name,
      responsible_person: notification.responsible_person,
      notification_created_at: notification.created_at,
      notification_updated_at: notification.updated_at,
      cpnp_reference: notification.cpnp_reference,
    )
  end

  context "when submit user is not provided" do
    let(:current_user) { nil }

    it "is not saved" do
      service.call

      log = NotificationDeleteLog.first

      expect(log).to have_attributes(
        submit_user: nil,
        notification_product_name: notification.product_name,
        responsible_person: notification.responsible_person,
        notification_created_at: notification.created_at,
        notification_updated_at: notification.updated_at,
        cpnp_reference: notification.cpnp_reference,
      )
    end
  end

  context "when 30 days passed" do
    before do
      travel_to 31.days.from_now
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
# rubocop:enable Style/RescueModifier
