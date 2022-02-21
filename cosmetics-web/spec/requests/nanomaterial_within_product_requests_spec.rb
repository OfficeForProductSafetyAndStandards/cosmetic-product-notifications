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
    let(:notification) do
      create(:notification, responsible_person: responsible_person)
    end

    let(:nano_material) { create(:nano_material, notification: notification) }
    let(:nano_element) { create(:nano_element, nano_material: nano_material) }

    before do
      put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/nanomaterials/#{nano_element.id}/build/confirm_usage", params: { nano_element: { confirm_usage: "yes" } }
    end

    it "redirects to the Category question page" do
      expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/nanomaterials/#{nano_element.id}/build/after_standard_nanomaterial_routing")
    end
  end
end
