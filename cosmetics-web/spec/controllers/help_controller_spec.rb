require 'rails_helper'

RSpec.describe HelpController, type: :controller do
  describe "When not signed in" do
    describe "GET #terms_and_conditions" do
      it "returns success status" do
        get :terms_and_conditions
        expect(response).to have_http_status(:success)
      end

      it "renders the terms and conditions template" do
        get :terms_and_conditions
        expect(response).to render_template("help/terms_and_conditions")
      end
    end

    describe "GET #privacy_notice" do
      it "returns success status" do
        get :privacy_notice
        expect(response).to have_http_status(:success)
      end

      it "renders the privacy notice template" do
        get :privacy_notice
        expect(response).to render_template("help/privacy_notice")
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

    describe "GET #terms_and_conditions" do
      it "returns success status" do
        get :terms_and_conditions
        expect(response).to have_http_status(:success)
      end

      it "renders the terms and conditions template" do
        get :terms_and_conditions
        expect(response).to render_template("help/terms_and_conditions")
      end
    end

    describe "GET #privacy_notice" do
      it "returns success status" do
        get :privacy_notice
        expect(response).to have_http_status(:success)
      end

      it "renders the privacy notice template" do
        get :privacy_notice
        expect(response).to render_template("help/privacy_notice")
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    before do
      sign_in_as_member_of_responsible_person(create(:responsible_person))
    end

    after do
      sign_out
    end

    describe "GET #terms_and_conditions" do
      it "returns success status" do
        get :terms_and_conditions
        expect(response).to have_http_status(:success)
      end

      it "renders the terms and conditions template" do
        get :terms_and_conditions
        expect(response).to render_template("help/terms_and_conditions")
      end
    end

    describe "GET #privacy_notice" do
      it "returns success status" do
        get :privacy_notice
        expect(response).to have_http_status(:success)
      end

      it "renders the privacy notice template" do
        get :privacy_notice
        expect(response).to render_template("help/privacy_notice")
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

    describe "GET #terms_and_conditions" do
      it "returns success status" do
        get :terms_and_conditions
        expect(response).to have_http_status(:success)
      end

      it "renders the terms and conditions template" do
        get :terms_and_conditions
        expect(response).to render_template("help/terms_and_conditions")
      end
    end

    describe "GET #privacy_notice" do
      it "returns success status" do
        get :privacy_notice
        expect(response).to have_http_status(:success)
      end

      it "renders the privacy notice template" do
        get :privacy_notice
        expect(response).to render_template("help/privacy_notice")
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

    describe "GET #terms_and_conditions" do
      it "returns success status" do
        get :terms_and_conditions
        expect(response).to have_http_status(:success)
      end

      it "renders the terms and conditions template" do
        get :terms_and_conditions
        expect(response).to render_template("help/terms_and_conditions")
      end
    end

    describe "GET #privacy_notice" do
      it "returns success status" do
        get :privacy_notice
        expect(response).to have_http_status(:success)
      end

      it "renders the privacy notice template" do
        get :privacy_notice
        expect(response).to render_template("help/privacy_notice")
      end
    end
  end
end
