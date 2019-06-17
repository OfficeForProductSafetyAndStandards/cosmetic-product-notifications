require 'rails_helper'

RSpec.describe NonStandardNanomaterialBuildController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:non_standard_nanomaterial) { create(:non_standard_nanomaterial, responsible_person: responsible_person) }

  let(:params) {
    {
      responsible_person_id: responsible_person.id,
      non_standard_nanomaterial_id: non_standard_nanomaterial.id
    }
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params: params)
      expect(response).to redirect_to(responsible_person_non_standard_nanomaterial_build_path(responsible_person, non_standard_nanomaterial, :add_iupac_name))
    end

    it "does not allow the user to create a non standard nanomaterial for a Responsible Person they not belong to" do
      expect {
        get(:new, params: other_responsible_person_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #show" do
    it "assigns the correct non standard nanomaterial" do
      get(:show, params: params.merge(id: :add_iupac_name))
      expect(assigns(:non_standard_nanomaterial)).to eq(non_standard_nanomaterial)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :add_iupac_name))
      expect(response).to render_template(:add_iupac_name)
    end

    it "does not allow the user to view a non standard nanomaterial for a Responsible Person they not belong to" do
      expect {
        get(:show, params: other_responsible_person_params.merge(id: :add_iupac_name))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "redirects to check your answer page on finish" do
      get(:show, params: params.merge(id: :wicked_finish))
      expect(response).to redirect_to(edit_responsible_person_non_standard_nanomaterial_path(responsible_person, non_standard_nanomaterial))
    end
  end

  describe "POST #update" do
    it "assigns the correct non standard nanomaterial" do
      post(:update, params: params.merge(id: :add_iupac_name, non_standard_nanomaterial: { iupac_name: "4-ethyl" }))
      expect(assigns(:non_standard_nanomaterial)).to eq(non_standard_nanomaterial)
    end

    it "does not allow the user to update a non standard nanomaterial that has already been submitted" do
      expect {
        get(:update, params: other_responsible_person_params.merge(id: :add_iupac_name))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "updates non standard nanomaterial parameters if present" do
      post(:update, params: params.merge(id: :add_iupac_name, non_standard_nanomaterial: { iupac_name: "10-ethyl" }))
      expect(non_standard_nanomaterial.reload.iupac_name).to eq("10-ethyl")
    end
  end

private

  def other_responsible_person_params
    other_responsible_person = create(:responsible_person)
    other_non_standard_nanomaterial = create(:non_standard_nanomaterial, responsible_person: other_responsible_person)

    {
        responsible_person_id: other_responsible_person.id,
        non_standard_nanomaterial_id: other_non_standard_nanomaterial.id
    }
  end
end
