require 'rails_helper'

RSpec.describe ResponsiblePersons::NonStandardNanomaterialsController, type: :controller do
  let(:user) { build(:user) }
  let(:responsible_person) { create(:responsible_person) }
  let(:non_standard_nanomaterial) { create(:non_standard_nanomaterial, responsible_person: responsible_person) }
  let(:params) {
    {
        responsible_person_id: responsible_person.id,
        id: non_standard_nanomaterial.id
    }
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns the correct Responsible Person" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template("responsible_persons/non_standard_nanomaterials/index")
    end

    it "does not allow the user to access another Responsible Person's dashboard" do
      other_responsible_person = create(:responsible_person)
      expect { get :index, params: { responsible_person_id: other_responsible_person.id } }
          .to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #new" do
    it "creates a new non standard nanomaterial" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:non_standard_nanomaterial)).to be_kind_of(NonStandardNanomaterial)
    end

    it "associates the new non standard nanomaterial with current Responsible Person" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:non_standard_nanomaterial).responsible_person).to eq(responsible_person)
    end

    it "redirects to the non standard nanomaterial build controller" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to redirect_to(new_responsible_person_non_standard_nanomaterial_build_path(assigns(:responsible_person), assigns(:non_standard_nanomaterial)))
    end

    it "does not allow the user to create a new non standard nanomaterial for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      expect {
        get :new, params: { responsible_person_id: other_responsible_person.id }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #edit" do
    it "assigns the correct non standard nanomaterial" do
      get :edit, params: params
      expect(assigns(:non_standard_nanomaterial)).to eq(non_standard_nanomaterial)
    end

    it "renders the edit template" do
      get :edit, params: params
      expect(response).to render_template("responsible_persons/non_standard_nanomaterials/edit")
    end

    it "does not allow the user to edit non standard nanomaterial for a Responsible Person they not belong to" do
      expect {
        get :edit, params: other_responsible_person_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "POST #confirm" do
    it "renders the confirm template" do
      post :confirm, params: params
      expect(response).to render_template("responsible_persons/non_standard_nanomaterials/confirm")
    end

    it "does not allow the user to confirm non standard nanomaterial for a Responsible Person they not belong to" do
      expect {
        post :confirm, params: other_responsible_person_params
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

private

  def other_responsible_person_params
    other_responsible_person = create(:responsible_person)
    other_non_standard_nanomaterial = create(:non_standard_nanomaterial, responsible_person: other_responsible_person)

    {
        responsible_person_id: other_responsible_person.id,
        id: other_non_standard_nanomaterial.id
    }
  end
end
