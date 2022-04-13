require "rails_helper"

RSpec.describe "Delete Notifications page", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:path) { responsible_person_notification_draft_delete_item_path(responsible_person, notification1) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification1) { create(:notification, responsible_person: responsible_person) }
  let(:component1) { create(:component, notification: notification1) }
  let(:component1_2) { create(:component, notification: notification1) }
  let(:component1_3) { create(:component, notification: notification1) }

  let(:notification2) { create(:notification, responsible_person: other_responsible_person) }
  let(:component2) { create(:component, notification: notification2) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  describe "success" do
    before do
      component1
      component1_2
      component1_3
    end

    it "destroys component" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component1.id } }
      }.to change(Component, :count).from(3).to(2)
    end

    it "redirects properly" do
      delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component1.id } }

      expect(response).to redirect_to(responsible_person_notification_draft_path(responsible_person, notification1))
    end
  end

  it "renders form again" do
    delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: nil } }

    expect(response).to render_template("show")
  end

  # rubocop:disable RSpec/AnyInstance
  it "is using proper form class" do
    expect_any_instance_of(ResponsiblePersons::Notifications::DeleteComponentForm).to receive(:delete)

    delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: nil } }
  end
  # rubocop:enable RSpec/AnyInstance

  context "when user tries to access not his notification" do
    let(:path) { responsible_person_notification_draft_delete_item_path(responsible_person, notification2) }

    it "raises an exception on delete request" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component1.id } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "raises an exception on get request" do
      expect {
        get path, params: { responsible_persons_notifications_delete_component_form: { component_id: component1.id } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
