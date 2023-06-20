require "rails_helper"

RSpec.describe "Root path", :with_stubbed_antivirus, type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person_with_no_contact_person) { create(:responsible_person) }

  context "when requested from the submit subdomain" do
    let(:user) { create(:submit_user) }

    before do
      configure_requests_for_submit_domain
    end

    after do
      sign_out(:submit_user)
    end

    context "when not signed in" do
      before do
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("submit/landing_page/index")
      end

      it "renders the correct header link" do
        get submit_root_path
        expect(response).to render_template(partial: "submit/_header_link")
      end
    end

    context "when signed in as a user not associated with a Responsible Person" do
      before do
        sign_in user
        get "/"
      end

      it "redirects to a page prompting the user to create or join a Responsible Person" do
        expect(response).to redirect_to("/responsible_persons/account/overview")
      end
    end

    context "when signed in as a user who hasn’t accepted the declaration yet" do
      let(:user_who_hasnt_accepted_declaration) { create(:submit_user, has_accepted_declaration: false) }

      before do
        sign_in user_who_hasnt_accepted_declaration
        get "/"
      end

      it "redirects to the declaration page" do
        expect(response).to redirect_to("/declaration")
      end
    end

    context "when signed in as a user associated with a Responsible Person account that doesn’t have a contact person" do
      before do
        responsible_person_with_no_contact_person.add_user(user)
        sign_in user
        get "/"
      end

      it "redirects to a page prompting user to add a contact person" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person_with_no_contact_person.id}/contact_persons/new")
      end
    end

    context "when signed in as a user associated with a Responsible Person account" do
      before do
        responsible_person.add_user(user)
        sign_in user
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("submit/landing_page/index")
      end
    end
  end

  context "when requested from the search subdomain" do
    before do
      configure_requests_for_search_domain
    end

    context "when not signed in" do
      before do
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("search/landing_page/index")
      end

      it "renders the correct header link" do
        get search_root_path
        expect(response).to render_template(partial: "search/_header_link")
      end
    end

    context "when signed in as a user associated with a Responsible Person account" do
      let(:user) { create(:submit_user) }

      before do
        responsible_person.add_user(user)
        sign_in user
        get "/"
      end

      after do
        sign_out(:submit_user)
      end

      it "redirects to the invalid account page" do
        expect(response).to redirect_to("/invalid-account")
      end
    end

    context "when signed in as a poison centre user" do
      let(:user) { create(:poison_centre_user) }

      before do
        sign_in_as_poison_centre_user(user:)
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as an OPSS General user" do
      let(:user) { create(:opss_general_user) }

      before do
        sign_in_as_opss_general_user(user:)
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as an OPSS Enforcement user" do
      let(:user) { create(:opss_enforcement_user) }

      before do
        sign_in_as_opss_enforcement_user(user:)
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as an OPSS Science user" do
      let(:user) { create(:opss_science_user) }

      before do
        sign_in_as_opss_science_user(user:)
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as a Trading Standards user" do
      let(:user) { create(:trading_standards_user) }

      before do
        sign_in_as_trading_standards_user(user:)
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as a support user" do
      let(:user) { create(:support_user) }

      before do
        sign_in user
        get "/"
      end

      after do
        sign_out(:support_user)
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end
  end

  context "when requested from the support subdomain" do
    let(:user) { create(:support_user) }

    before do
      configure_requests_for_support_domain
    end

    after do
      sign_out(:support_user)
    end

    context "when not signed in" do
      before do
        get "/"
      end

      it "redirects to the sign in page" do
        expect(response).to redirect_to("/sign-in")
      end
    end

    context "when signed in as a user associated with a Responsible Person account" do
      let(:user) { create(:submit_user) }

      before do
        responsible_person.add_user(user)
        sign_in user
        get "/"
      end

      after do
        sign_out(:submit_user)
      end

      it "redirects to the sign in page" do
        expect(response).to redirect_to("/sign-in")
      end
    end

    context "when signed in as a search user" do
      let(:user) { create(:search_user) }

      before do
        sign_in user
        get "/"
      end

      after do
        sign_out(:search_user)
      end

      it "redirects to the sign in page" do
        expect(response).to redirect_to("/sign-in")
      end
    end

    context "when signed in as a support user" do
      before do
        sign_in user
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("support_portal/dashboard/index")
      end
    end
  end

  context "when requested from localhost" do
    before { host! "localhost" }

    it "raises an error" do
      expect { get("/") }.to raise_error(RuntimeError)
    end
  end
end
