require 'rails_helper'

RSpec.describe ResponsiblePersons::AddNotificationWizardController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #show" do
    it "sets the responsible person from the path parameters" do
      get(:show, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu" })
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end
  end

  describe "PUT #update" do
    it "redirects to the correct step for the given answer" do
      put(:update, params: { responsible_person_id: responsible_person.id,
      id: "have_products_been_notified_in_eu", answer: "yes" })
      expect(response).to redirect_to(responsible_person_add_notification_path(responsible_person, "do_you_have_files_from_eu_notification"))
    end

    it "sets the responsible person from the path parameters" do
      put(:update, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu", answer: "yes" })
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end
  end

  describe "GET #new" do
    it "redirects users to the correct first step" do
      get(:new, params: { responsible_person_id: responsible_person.id })
      expect(response).to redirect_to(responsible_person_add_notification_path(responsible_person, "have_products_been_notified_in_eu"))
    end
  end
end
