require "rails_helper"

RSpec.describe "Root path", :with_stubbed_antivirus, type: :request do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person_with_no_contact_person) { create(:responsible_person) }
  let(:user) { create(:user) }
  let(:user_who_hasnt_accepted_declaration) { create(:user, first_login: true) }

  after do
    sign_out
  end

  context "when requested from the submit sub-domain" do
    before do
      configure_requests_for_submit_domain
    end

    context "when not signed in" do
      before do
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("landing_page/submit_landing_page")
      end
    end

    context "when signed in as a user not associated with a responsible person" do
      before do
        sign_in as_user: user
        get "/"
      end

      it "redirects to a page prompting user to create or join a company" do
        expect(response).to redirect_to("/responsible_persons/account/overview")
      end
    end

    context "when signed in as a user who hasn’t accepted declaration yet" do
      before do
        sign_in as_user: user_who_hasnt_accepted_declaration
        get "/"
      end

      it "redirects to the declaration page" do
        expect(response).to redirect_to("/declaration")
      end
    end

    context "when signed in as a user associated with a Responsible Person account that doesn’t have a contact person" do
      before do
        responsible_person_with_no_contact_person.add_user(user)
        sign_in as_user: user
        get "/"
      end

      it "redirects to a page prompting user to add a contact person" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person_with_no_contact_person.id}/contact_persons/new")
      end
    end

    context "when signed in as a user associated with a Responsible Person account" do
      before do
        responsible_person.add_user(user)
        sign_in as_user: user
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("landing_page/submit_landing_page")
      end
    end
  end

  context "when requested from the search sub-domain" do
    before do
      configure_requests_for_search_domain
    end

    context "when not signed in" do
      before do
        get "/"
      end

      it "renders the homepage" do
        expect(response).to render_template("landing_page/search_landing_page")
      end
    end

    context "when signed in as a user associated with a Responsible Person account" do
      before do
        responsible_person.add_user(user)
        sign_in as_user: user
        get "/"
      end

      it "redirects to invalid account page" do
        expect(response).to redirect_to("/invalid-account")
      end
    end

    context "when signed in as a poison centre user" do
      before do
        sign_in as_user: user, with_roles: [:poison_centre_user]
        get "/"
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end

    context "when signed in as a market surveilance authority user" do
      before do
        sign_in as_user: user, with_roles: [:msa_user]
        get "/"
      end

      it "redirects to the notifications page" do
        expect(response).to redirect_to("/notifications")
      end
    end
  end

  context "when requested from localhost" do
    before { host! "localhost" }

    it "renders the submit homepage" do
      get "/"
      expect(response).to render_template("landing_page/submit_landing_page")
    end
  end
end
