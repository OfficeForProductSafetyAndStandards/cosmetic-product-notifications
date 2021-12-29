require "rails_helper"

RSpec.describe NotificationsDecorator do # rubocop:todo RSpec/MultipleMemoizedHelpers
  let(:date) { Time.zone.local(2020, 9, 22, 13) }
  let(:expected_csv) do
    <<~CSV
      Product name,UK cosmetic product number,Notification date,EU Reference number,EU Notification date,Internal reference,Number of items,Item 1 Level 1 category,Item 1 Level 2 category,Item 1 Level 3 category,Item 2 Level 1 category,Item 2 Level 2 category,Item 2 Level 3 category
      Product 1,UKCP-00000111,2021-02-20 13:00:00 +0000,,,,1,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
      Product 2,UKCP-00000222,2021-02-20 13:00:00 +0000,,,,1,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
      Product 3,UKCP-00000333,2021-02-20 13:00:00 +0000,,,foo bar,2,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products
    CSV
  end

  let(:responsible_person) { create(:responsible_person) }
  let(:notification1) { create(:notification, :registered, :with_component, responsible_person: responsible_person, product_name: "Product 1", reference_number: 111) }
  let(:notification2) { create(:notification, :registered, :with_component, responsible_person: responsible_person, product_name: "Product 2", reference_number: 222) }
  let(:notification3) { create(:notification, :registered, :with_components, responsible_person: responsible_person, product_name: "Product 3", reference_number: 333, industry_reference: "foo bar") }

  let(:notifications) { [notification1, notification2, notification3] }

  before do
    travel_to(Time.zone.local(2021, 2, 20, 13))
    notifications.each(&:cache_notification_for_csv!)
  end

  describe "#to_csv" do # rubocop:todo RSpec/MultipleMemoizedHelpers
    it "returns proper string" do
      csv = described_class.new(notifications).to_csv

      expect(csv).to eq expected_csv
    end
  end
end
