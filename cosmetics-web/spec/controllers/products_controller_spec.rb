require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  before do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
  end

  after do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
  end

  # This should return the minimal set of attributes required to create a valid
  # Product. As you add validations to Product, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        uploaded_file: fixture_file_upload("testImage.png", "image/png")
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProductsController. Be sure to keep this updated too.
  let(:valid_session) { {} }


  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Product" do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it "redirects to the created product" do
        post :create, params: { product: valid_attributes }
        expect(response).to redirect_to(Product.last)
      end
    end
  end
end
