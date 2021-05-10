require "rails_helper"

RSpec.describe NotificationsDecorator do
  before { travel_to(Time.zone.local(2021, 2, 20, 13)) }

  let(:date) { Time.zone.local(2020, 9, 22, 13) }

  let(:notification1) { create(:notification, :with_component, product_name: "Product 1", reference_number: 111) }
  let(:notification2) { create(:notification, :with_component, :via_zip_file, product_name: "Product 2", reference_number: 222) }
  let(:notification3) { create(:notification, :with_components, :via_zip_file, product_name: "Product 3", reference_number: 333, cpnp_notification_date: date, industry_reference: "foo bar") }

  let(:notifications) { [notification1, notification2, notification3] }

  let(:expected_csv) do
    <<~CSV
      Product name,UK cosmetic product number,Notification date,EU Reference number,EU Notification date,Internal reference,Number of components,Component 1 root category,Component 1 sub category,Component 1 sub sub category,Component 2 root category,Component 2 sub category,Component 2 sub sub category
      Product 1,UKCP-00000111,2021-02-20 13:00:00 +0000,,,,1,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
      Product 2,UKCP-00000222,2021-02-20 13:00:00 +0000,123456789,,,1,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
      Product 3,UKCP-00000333,2021-02-20 13:00:00 +0000,123456789,2020-09-22 13:00:00 +0100,foo bar,2,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
    CSV
  end

  describe "#to_csv" do
    it "returns proper string" do
      csv = described_class.new(notifications).to_csv

      expect(csv).to eq expected_csv
    end
  end
end
