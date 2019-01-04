require 'rails_helper'

RSpec.describe HelloworldController, type: :controller do
  describe "GET #index" do
    it "redirects the user if they are not logged in" do
      get :index
      expect(response.status).to eq(302)
    end
  end
end
