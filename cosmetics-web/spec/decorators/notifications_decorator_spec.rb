require "rails_helper"

RSpec.describe NotificationsDecorator do
  before { travel_to(Time.zone.local(2021, 2, 20, 13)) }

  let(:date) { Time.zone.local(2020, 9, 22, 13) }

  let(:notification1) { create(:notification, product_name: "Product 1", reference_number: 111) }
  let(:notification2) { create(:notification, :via_zip_file, product_name: "Product 2", reference_number: 222) }
  let(:notification3) { create(:notification, :via_zip_file, product_name: "Product 3", reference_number: 333, cpnp_notification_date: date) }

  let(:notifications) { [notification1, notification2, notification3] }

  let(:expected_csv) do
    <<~CSV
      Product name,Reference number,Notification date,EU Reference number,EU Notification date
      Product 1,111,2021-02-20 13:00:00 +0000,,
      Product 2,222,2021-02-20 13:00:00 +0000,123456789,
      Product 3,333,2021-02-20 13:00:00 +0000,123456789,2020-09-22 13:00:00 +0100
    CSV
  end

  describe "#to_csv" do
    it "returns proper string" do
      csv = described_class.new(notifications).to_csv
      expect(csv).to eq expected_csv
    end
  end
end
