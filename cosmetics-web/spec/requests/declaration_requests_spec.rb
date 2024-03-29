require "rails_helper"

RSpec.describe "User declarations", :with_stubbed_antivirus, type: :request do
  context "when signed in as a company user" do
    let(:responsible_person) { create(:responsible_person) }
    let(:user) { build(:submit_user, has_accepted_declaration: false) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    after do
      sign_out(:submit_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/business_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Submit homepage" do
        expect(response).to redirect_to(submit_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as an OPSS General user" do
    let(:user) { create(:opss_general_user, has_accepted_declaration: false) }

    before do
      sign_in_as_opss_general_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/msa_user_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as an OPSS Enforcement user" do
    let(:user) { create(:opss_enforcement_user, has_accepted_declaration: false) }

    before do
      sign_in_as_opss_enforcement_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/msa_user_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as an OPSS IMT user" do
    let(:user) { create(:opss_imt_user, has_accepted_declaration: false) }

    before do
      sign_in_as_opss_imt_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/msa_user_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as a Trading Standards user" do
    let(:user) { create(:trading_standards_user, has_accepted_declaration: false) }

    before do
      sign_in_as_trading_standards_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/msa_user_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as a poison centre user" do
    let(:user) { create(:poison_centre_user, has_accepted_declaration: false) }

    before do
      sign_in_as_poison_centre_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/poison_centre_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end

  context "when signed in as an OPSS Science user" do
    let(:user) { create(:opss_science_user, has_accepted_declaration: false) }

    before do
      sign_in_as_opss_science_user(user:)
    end

    after do
      sign_out(:search_user)
    end

    context "when viewing the declaration page" do
      before do
        get declaration_path
      end

      it "renders the page" do
        expect(response.status).to be(200)
        expect(response).to render_template("declaration/msa_user_declaration")
      end
    end

    context "when submitting the declaration page" do
      before do
        post accept_declaration_path
      end

      it "redirects to the Search homepage" do
        expect(response).to redirect_to(search_root_path)
      end

      it "updates the user attributes" do
        expect(user.has_accepted_declaration?).to be true
      end
    end
  end
end
