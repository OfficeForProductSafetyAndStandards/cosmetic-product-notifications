require 'rails_helper'

RSpec.describe HelloworldController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_redirect
    end
  end
end
