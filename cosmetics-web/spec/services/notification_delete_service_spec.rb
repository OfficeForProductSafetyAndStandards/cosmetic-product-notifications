require "rails_helper"

# rubocop:disable Style/RescueModifier
RSpec.describe NotificationDeleteService do
  let(:responsible_person) { create(:responsible_person) }
  let(:submit_user) { create(:submit_user) }
  let(:notification) { create(:registered_notification, cpnp_reference: "123412344") }
  let(:current_user) { submit_user }
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

    expect(log.submit_user).to eq submit_user
    expect(log.notification_product_name).to eq notification.product_name
    expect(log.responsible_person).to eq notification.responsible_person
    expect(log.notification_created_at).to eq notification.created_at
    expect(log.notification_updated_at).to eq notification.updated_at
    expect(log.cpnp_reference).to eq notification.cpnp_reference
  end

  context "when submit user is not provided" do
    let(:current_user) { nil }

    it "is not saved" do
      service.call

      log = NotificationDeleteLog.first

      expect(log.submit_user).to eq nil
      expect(log.notification_product_name).to eq notification.product_name
      expect(log.responsible_person).to eq notification.responsible_person
      expect(log.notification_created_at).to eq notification.created_at
      expect(log.notification_updated_at).to eq notification.updated_at
      expect(log.cpnp_reference).to eq notification.cpnp_reference
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
