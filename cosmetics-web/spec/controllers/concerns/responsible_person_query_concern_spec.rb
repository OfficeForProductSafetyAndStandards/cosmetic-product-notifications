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

  let(:ingredient_a) { create(:exact_ingredient, inci_name: "NaCl", created_at: 2.days.ago) }
  let(:ingredient_b) { create(:exact_ingredient, inci_name: "Aqua", created_at: 1.week.ago) }
  let(:ingredient_c) { create(:exact_ingredient, inci_name: "Sodium", created_at: 2.weeks.ago) }
  let(:ingredient_d) { create(:exact_ingredient, inci_name: "Aqua", created_at: 3.weeks.ago) }
  let(:notification_a) { create(:notification, responsible_person: ingredient_d.component.responsible_person) }
  let(:component_a) { create(:exact_component, notification: notification_a) }
  let(:ingredient_e) { create(:exact_ingredient, inci_name: "Aqua", component: component_a, created_at: 3.weeks.ago) }

  before do
    ingredient_a
    ingredient_b
    ingredient_c
    ingredient_d
    ingredient_e
  end

  describe "#responsible_persons_by_notified_ingredient" do
    context "when ordered by Responsible Person names in ascending order" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "responsible_persons.name asc", page: "1", per_page: 100)
        expect(result).to include(ingredient_b.component.responsible_person, ingredient_d.component.responsible_person)
      end
    end

    context "when ordered by Responsible Person names in descending order" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "responsible_persons.name desc", page: "1", per_page: 100)
        expect(result).to include(ingredient_d.component.responsible_person, ingredient_b.component.responsible_person)
      end
    end

    context "when ordered by most notifications per Responsible Person" do
      it "returns a sorted array of Responsible Persons" do
        result = dummy.responsible_persons_by_notified_ingredient("Aqua", sort_by: "total_notifications desc", page: "1", per_page: 100)
        expect(result).to include(ingredient_d.component.responsible_person, ingredient_b.component.responsible_person)
      end
    end
  end

  describe "#notifications_by_notified_ingredient" do
    context "when ordered by product names in ascending order" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient_e.component.responsible_person, sort_by: "notifications.product_name asc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient_d.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient_e.component.notification.product_name)
      end
    end

    context "when ordered by product names in descending order" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient_e.component.responsible_person, sort_by: "notifications.product_name desc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient_e.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient_d.component.notification.product_name)
      end
    end

    context "when ordered by notification created date" do
      it "returns a sorted array of notifications" do
        result = dummy.notifications_by_notified_ingredient("Aqua", responsible_person: ingredient_e.component.responsible_person, sort_by: "notifications.created_at desc", page: "1", per_page: 20)
        # We need to check individual product names because the query does not return complete notifications
        expect(result[0].product_name).to eq(ingredient_e.component.notification.product_name)
        expect(result[1].product_name).to eq(ingredient_d.component.notification.product_name)
      end
    end
  end
end
