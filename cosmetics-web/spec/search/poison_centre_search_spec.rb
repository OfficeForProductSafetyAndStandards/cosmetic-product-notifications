require "rails_helper"

RSpec.describe "Poison centre search" do
  let(:results) { keyword_search(keyword) }
  let(:notifications) { results.records }

  let(:responsible_person1) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", postal_code: "N12 8AA") }
  let(:responsible_person2) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", address_line_1: "Foo bar street", postal_code: "N12 9XY") }
  let(:responsible_person3) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", postal_code: "LA1 1LZ") }

  let(:notification1) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person: responsible_person1) }
  let(:notification2) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles", responsible_person: responsible_person2) }
  let(:notification3) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask, responsible_person: responsible_person3) }

  before do
    notification1
    notification2
    notification3

    Notification.opensearch.import force: true
  end

  describe "Search by post code" do
    context "when searching by full code" do
      let(:keyword) { "N12 8AA" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification1, notification2]
      end
    end

    context "when searching by part code" do
      let(:keyword) { "N12" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification1, notification2]
      end
    end

    context "when searching by different code" do
      let(:keyword) { "LA1" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification3]
      end
    end
  end
end

def keyword_search(keyword)
  query = OpensearchQuery.new(keyword: keyword, category: nil, from_date: nil, to_date: nil, sort_by: nil)
  Notification.full_search(query)
end
