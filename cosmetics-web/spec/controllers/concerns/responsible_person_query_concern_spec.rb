require "rails_helper"

RSpec.describe ResponsiblePersonQueryConcern, type: :controller do
  let(:dummy_class) do
    Class.new(ApplicationController) do
      include ResponsiblePersonQueryConcern

      def self.name
        "DummyClass"
      end
    end
  end

  let(:dummy) { dummy_class.new }

  let(:ingredient1) { create(:exact_ingredient, inci_name: "NaCl", created_at: 2.days.ago) }
  let(:ingredient2) { create(:exact_ingredient, inci_name: "Aqua", created_at: 1.week.ago) }
  let(:ingredient3) { create(:exact_ingredient, inci_name: "Sodium", created_at: 2.weeks.ago) }
  let(:ingredient4) { create(:exact_ingredient, inci_name: "Aqua", created_at: 3.weeks.ago) }
  let(:notification5) { create(:notification, responsible_person: ingredient4.component.responsible_person) }
  let(:component5) { create(:exact_component, notification: notification5) }
  let(:ingredient5) { create(:exact_ingredient, inci_name: "Aqua", component: component5, created_at: 3.weeks.ago) }

  before do
    ingredient1
    ingredient2
    ingredient3
    ingredient4
    ingredient5
  end

  describe "#responsible_persons_by_notified_ingredient" do
    context "when ordered by Responsible Person names in ascending order" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "responsible_persons.name asc", page: "1", per_page: 100)
        expect(result).to eq([ingredient2.component.responsible_person, ingredient4.component.responsible_person])
      end
    end

    context "when ordered by Responsible Person names in descending order" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "responsible_persons.name desc", page: "1", per_page: 100)
        expect(result).to eq([ingredient4.component.responsible_person, ingredient2.component.responsible_person])
      end
    end

    context "when ordered by most notifications per Responsible Person" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "total_notifications desc", page: "1", per_page: 100)
        expect(result).to eq([ingredient4.component.responsible_person, ingredient2.component.responsible_person])
      end
    end
  end

  describe "#notifications_by_notified_ingredient" do
    context "when ordered by product names in ascending order" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient5.component.responsible_person, sort_by: "notifications.product_name asc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient4.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient5.component.notification.product_name)
      end
    end

    context "when ordered by product names in descending order" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient5.component.responsible_person, sort_by: "notifications.product_name desc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient5.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient4.component.notification.product_name)
      end
    end

    context "when ordered by notification created date" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient5.component.responsible_person, sort_by: "notifications.created_at desc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient5.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient4.component.notification.product_name)
      end
    end
  end
end
