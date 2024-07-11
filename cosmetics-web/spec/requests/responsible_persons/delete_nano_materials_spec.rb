require "rails_helper"

RSpec.describe "Delete Nano material page", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:path) { responsible_person_notification_draft_delete_nano_material_path(responsible_person, notification_a) }
  let(:user) { build(:submit_user, :with_sms_secondary_authentication) }

  let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:other_user) { build(:submit_user) }

  let(:notification_a) { create(:notification, responsible_person:) }
  let(:nano_material_a) { create(:nano_material, notification: notification_a) }
  let(:notification_b) { create(:notification, responsible_person: other_responsible_person) }
  let(:nano_material_b) { create(:nano_material, notification: notification_b) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  describe "success" do
    before do
      nano_material_a
    end

    it "destroys nano_material" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: [nano_material_a.id] } }
      }.to change(NanoMaterial, :count).from(1).to(0)
    end

    it "redirects properly" do
      delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: [nano_material_a.id] } }

      expect(response).to redirect_to(responsible_person_notification_draft_path(responsible_person, notification_a))
    end
  end

  context "when form is invalid" do
    before do
      nano_material_a
    end

    it "renders form again on nil params" do
      delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: nil } }

      expect(response).to render_template("show")
    end

    it "renders form again on empty params" do
      delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: [] } }

      expect(response).to render_template("show")
    end
  end

  # rubocop:disable RSpec/AnyInstance
  it "is using proper form class" do
    expect_any_instance_of(ResponsiblePersons::Notifications::DeleteNanoMaterialForm).to receive(:delete)

    delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: nil } }
  end
  # rubocop:enable RSpec/AnyInstance

  context "when user tries to access not his notification" do
    let(:path) { responsible_person_notification_draft_delete_nano_material_path(responsible_person, notification_b) }

    it "raises an exception on delete request" do
      expect {
        delete path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: [nano_material_a.id] } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "raises an exception on get request" do
      expect {
        get path, params: { responsible_persons_notifications_delete_nano_material_form: { nano_material_ids: [nano_material_a.id] } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
