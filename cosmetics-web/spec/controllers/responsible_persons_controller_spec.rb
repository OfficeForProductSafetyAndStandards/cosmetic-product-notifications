require "rails_helper"

RSpec.describe ResponsiblePersonsController, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  before do
    configure_requests_for_submit_domain
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
    reset_domain_request_mocking
  end

  describe "GET #show" do
    it "assigns @responsible_person" do
      get :show, params: { id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the show template" do
      get :show, params: { id: responsible_person.id }
      expect(response).to render_template("responsible_persons/show")
    end
  end

  describe "GET #products_page_redirect" do
    it "redirects to responsible person path" do
      get :products_page_redirect, params: { id: responsible_person.id }
      expect(response).to redirect_to(responsible_person_notifications_url(responsible_person))
    end
  end
end
