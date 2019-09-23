require 'rails_helper'

RSpec.describe PubliclyAccessibleController, type: :controller do
  controller(PubliclyAccessibleController) do
    def index
      render body: nil
    end
  end

  describe "When not signed in" do
    describe "GET #index" do
      it "returns success status" do
        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "When signed in for the first time" do
    let(:first_time_user) { build(:user, first_login: true) }

    before do
      sign_in(as_user: first_time_user)
    end

    after do
      sign_out
    end

    describe "GET #index" do
      it "returns success status" do
        get :index

        expect(response).to have_http_status(:success)
      end
    end

    describe "When signed in as a Responsible Person user" do
      before do
        sign_in_as_member_of_responsible_person(create(:responsible_person))
      end

      after do
        sign_out
      end

      describe "GET #index" do
        it "returns success status" do
          get :index

          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "When signed in as a Poison Centre user" do
      before do
        sign_in_as_poison_centre_user
      end

      after do
        sign_out
      end

      describe "GET #index" do
        it "returns success status" do
          get :index

          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "When signed in as a MSA user" do
      before do
        sign_in_as_msa_user
      end

      after do
        sign_out
      end

      describe "GET #index" do
        it "returns success status" do
          get :index

          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
