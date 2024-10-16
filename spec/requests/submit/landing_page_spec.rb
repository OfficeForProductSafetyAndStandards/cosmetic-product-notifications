require "rails_helper"

RSpec.describe "Landing page", :with_2fa, type: :request do
  context "when not signed in" do
    before do
      configure_requests_for_submit_domain
    end

    it "loads the landing page offering to sign in or create an account" do
      get submit_root_path
      expect(response).to render_template(:index)
      expect(response.body).to include("Sign in").and include("Create an account")
    end
  end

  context "when signed in" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { create(:submit_user, has_accepted_declaration: true) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    after do
      sign_out(:submit_user)
    end

    context "when the user belongs to a single responsible person" do
      it "loads the landing page with a link to the user notifications" do
        get submit_root_path
        expect(response).to render_template(:index)
        expect(response.body).to include("cosmetic products page")
      end
    end

    context "when the user belongs to multiple responsible persons" do
      let(:second_responsible_person) { create(:responsible_person, :with_a_contact_person) }

      before do
        second_responsible_person.add_user(user)
      end

      it "redirects the user to the responsible person selection page" do
        get submit_root_path
        expect(response).to redirect_to(select_responsible_persons_path)
      end
    end
  end
end
