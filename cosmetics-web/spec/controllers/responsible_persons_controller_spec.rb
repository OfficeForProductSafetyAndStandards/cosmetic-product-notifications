require 'rails_helper'

RSpec.describe ResponsiblePersonsController, type: :controller do
  before do
    authenticate_user
  end

  after do
    sign_out_user
  end

  describe "GET #show" do
    it "assigns @responsible_person" do
      responsible_person = ResponsiblePerson.create
      get :show, params: { id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the show template" do
      responsible_person = ResponsiblePerson.create
      get :show, params: { id: responsible_person.id }
      expect(response).to render_template('responsible_persons/show')
    end
  end
end
