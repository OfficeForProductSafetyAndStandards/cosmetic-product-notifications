require "rails_helper"

RSpec.describe "Nanomaterial usage within product notifications", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "PUT #confirm_usage" do
    context "when the notification was via ZIP file upload, pre-Brexit, and formulation included" do
      let(:notification) {
        create(:notification,
               :via_zip_file, :pre_brexit,
               responsible_person: responsible_person)
      }

      let(:component) { create(:component, :with_range_formulas, notification: notification) }
      let(:nano_material) { create(:nano_material, component: component) }
      let(:nano_element) { create(:nano_element, nano_material: nano_material) }

      before do
        put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/nanomaterials/#{nano_element.id}/build/confirm_usage", params: { nano_element: { confirm_usage: "yes" } }
      end

      it "redirects to the Check your answers page" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit")
      end
    end

    context "when the notification was via ZIP file upload, pre-Brexit, using exact, and formulation missing" do
      let(:notification) {
        create(:notification,
               :via_zip_file, :pre_brexit,
               responsible_person: responsible_person)
      }

      let(:component) { create(:component, :using_exact, notification: notification) }
      let(:nano_material) { create(:nano_material, component: component) }
      let(:nano_element) { create(:nano_element, nano_material: nano_material) }

      before do
        put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/nanomaterials/#{nano_element.id}/build/confirm_usage", params: { nano_element: { confirm_usage: "yes" } }
      end

      it "redirects to the Upload formulation page" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/formulation/new")
      end
    end

    context "when the notification was manual" do
      let(:notification) {
        create(:notification, :manual, :pre_brexit,
               responsible_person: responsible_person)
      }

      let(:component) { create(:component, notification: notification) }
      let(:nano_material) { create(:nano_material, component: component) }
      let(:nano_element) { create(:nano_element, nano_material: nano_material) }

      before do
        put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/nanomaterials/#{nano_element.id}/build/confirm_usage", params: { nano_element: { confirm_usage: "yes" } }
      end

      it "redirects to the Category question page" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/build/select_category")
      end
    end

    context "when there is another nanomaterial to confirm usage for" do
      let(:notification) {
        create(:notification, :via_zip_file, :pre_brexit,
               responsible_person: responsible_person)
      }

      let(:component) { create(:component, notification: notification) }
      let(:nano_material) { create(:nano_material, component: component) }

      let!(:first_nano_element) { create(:nano_element, nano_material: nano_material) }
      let!(:second_nano_element) { create(:nano_element, nano_material: nano_material) }

      before do
        put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/nanomaterials/#{first_nano_element.id}/build/confirm_usage", params: { nano_element: { confirm_usage: "yes" } }
      end

      it "redirects to ‘What is the purpose’ question for the second nano material" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/nanomaterials/#{second_nano_element.id}/build/new")
      end
    end
  end
end
