require "rails_helper"

RSpec.describe "Poison centre search" do
  let(:results) { keyword_search(keyword) }
  let(:notifications) { results.records }

  let(:responsible_person_a) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", postal_code: "N12 8AA") }
  let(:responsible_person_b) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", address_line_1: "Foo bar street", postal_code: "N12 9XY") }
  let(:responsible_person_c) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person", postal_code: "LA1 1LZ") }

  let(:notification_a) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person: responsible_person_a) }
  let(:notification_b) { create(:notification, :registered, :with_component, notification_complete_at: 2.days.ago, product_name: "Shower Bubbles", responsible_person: responsible_person_b) }
  let(:notification_c) { create(:notification, :registered, :with_component, notification_complete_at: 3.days.ago, product_name: "Bath Bubbles", category: :face_care_products_other_than_face_mask, responsible_person: responsible_person_c) }

  before do
    notification_a
    notification_b
    notification_c

    Notification.import_to_opensearch(force: true)
  end

  describe "Search by post code" do
    context "when searching by full code" do
      let(:keyword) { "N12 8AA" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification_a]
      end
    end

    context "when searching by part code" do
      let(:keyword) { "N12" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification_a, notification_b]
      end
    end

    context "when searching by different code" do
      let(:keyword) { "LA1" }

      it "finds proper notifications" do
        expect(notifications.to_a).to eq [notification_c]
      end
    end
  end
end

def keyword_search(keyword)
  query = OpenSearchQuery::Notification.new(keyword:,
                                            category: nil,
                                            from_date: nil,
                                            to_date: nil,
                                            status: nil,
                                            sort_by: nil,
                                            match_similar: nil,
                                            search_fields: nil,
                                            responsible_person_id: nil)
  Notification.full_search(query)
end
