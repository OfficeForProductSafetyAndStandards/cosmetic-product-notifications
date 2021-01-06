require "rails_helper"

RSpec.describe ResponsiblePersons::Wizard::TriggerQuestionsController, :with_stubbed_antivirus, type: :controller do
  let(:user) { build(:submit_user) }
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:component) { create(:component, notification: notification) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #show" do
    context "when the notification is already submitted" do
      subject(:request) { get(:show, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id, id: "select_ph_range" }) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end
  end
end
