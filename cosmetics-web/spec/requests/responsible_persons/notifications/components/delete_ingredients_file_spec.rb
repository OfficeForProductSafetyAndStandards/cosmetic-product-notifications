require "rails_helper"

RSpec.describe "Removing ingredients file", type: :request do
  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:notification) { create(:notification, responsible_person:) }
  let(:component) { create(:component, :with_ingredients_file, notification:) }
  let(:ingredient) { create(:exact_ingredient, component:) }

  before do
    ingredient

    configure_requests_for_submit_domain

    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  it "deletes all ingredients withing component" do
    expect {
      delete responsible_person_notification_component_delete_ingredients_file_path(responsible_person, notification, component)
    }.to change { component.ingredients.count }.from(1).to(0)
  end

  it "deletes ingredients file" do
    delete responsible_person_notification_component_delete_ingredients_file_path(responsible_person, notification, component)

    expect(component.reload.ingredients_file.filename).to be_nil
  end

  it "redirects to proper step" do
    delete responsible_person_notification_component_delete_ingredients_file_path(responsible_person, notification, component)

    expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :upload_ingredients_file))
  end

  context "when trying to access with data without authorisation" do
    context "when accessing component from different notification" do
      let(:other_notification) { create(:notification, responsible_person:) }
      let(:other_component) { create(:component, :with_ingredients_file, notification: other_notification) }
      let(:other_ingredient) { create(:exact_ingredient, component: other_component) }

      before do
        other_ingredient
      end

      it "is not changing ingredients count" do
        expect {
          delete responsible_person_notification_component_delete_ingredients_file_path(responsible_person, notification, other_component)
        }.not_to(change { component.ingredients.count })
      end
    end

    context "when accessing component from different responsible person" do
      let(:other_responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
      let(:other_notification) { create(:notification, responsible_person: other_responsible_person) }
      let(:other_component) { create(:component, :with_ingredients_file, notification: other_notification) }
      let(:other_ingredient) { create(:exact_ingredient, component: other_component) }

      it "is unsuccessful" do
        expect {
          delete responsible_person_notification_component_delete_ingredients_file_path(responsible_person, notification, other_component)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
