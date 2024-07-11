require "rails_helper"

RSpec.describe "Delete Notifications page", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:path) { responsible_person_notification_draft_delete_item_path(responsible_person, notification_a) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification_a) { create(:notification, responsible_person:) }
  let(:component_a) { create(:component, notification: notification_a) }
  let(:component_b) { create(:component, notification: notification_a) }
  let(:component_c) { create(:component, notification: notification_a) }

  let(:notification_b) { create(:notification, responsible_person: other_responsible_person) }
  let(:component_d) { create(:component, notification: notification_b) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  describe "success" do
    before do
      component_a
      component_b
      component_c
    end

    it "destroys component" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component_a.id } }
      }.to change(Component, :count).from(3).to(2)
    end

    it "redirects properly" do
      delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component_a.id } }

      expect(response).to redirect_to(responsible_person_notification_draft_path(responsible_person, notification_a))
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
    let(:path) { responsible_person_notification_draft_delete_item_path(responsible_person, notification_b) }

    it "raises an exception on delete request" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_component_form: { component_id: component_a.id } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "raises an exception on get request" do
      expect {
        get path, params: { responsible_persons_notifications_delete_component_form: { component_id: component_a.id } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
