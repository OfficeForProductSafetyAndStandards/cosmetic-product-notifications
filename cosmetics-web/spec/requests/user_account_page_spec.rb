require "rails_helper"

RSpec.describe "User account page", type: :request do
  include RSpecHtmlMatchers

  RSpec.shared_examples "can change name and security" do
    it "allows user to change their name" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Full name", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: user.name, with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Change name")
      end
    end

    it "allows user to change their password" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Email address", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: "********", with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Change password")
      end
    end

    it "allows user to change their account 2FA SMS" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Text message", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: user.mobile_number, with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Change text message")
      end
    end

    it "allows user to change their account 2FA App" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Authenticator app", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: "Authenticator app is set", with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Change authenticator app")
      end
    end
  end

  RSpec.shared_examples "can't change email" do
    it "does not allow user to change their email" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Email address", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: user.email, with: { class: "govuk-summary-list__value" })
        without_tag("dd.govuk-summary-list__actions a", text: "Change email address")
      end
    end
  end

  RSpec.shared_examples "can't download nanomaterials" do
    # rubocop:disable RSpec/MultipleExpectations
    it "does not allow user to download a list of cosmetic products containing nanomaterials" do
      expect(response.body).not_to have_tag("h2", text: "Downloadable data")
      expect(response.body).not_to have_tag("dt", text: "All notified cosmetic products containing nanomaterials", with: { class: "govuk-summary-list__key" })
      expect(response.body).not_to have_tag("dd", text: "Download as a CSV (spreadsheet) file", with: { class: "govuk-summary-list__value" })
      expect(response.body).not_to have_tag("dd.govuk-summary-list__actions a", text: "Download products with nanomaterials")
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context "with a Submit/business user" do
    let(:rp) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { create(:submit_user) }

    before do
      sign_in_as_member_of_responsible_person(rp, user)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't download nanomaterials"

    it "allows user to change their email" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "Email address", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: user.email, with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Change email address")
      end
    end
  end

  context "with a Search poison centre user" do
    let(:user) { create(:poison_centre_user) }

    before do
      sign_in_as_poison_centre_user(user: user)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end

  context "with a Search market surveilance authority user" do
    let(:user) { create(:msa_user) }

    before do
      sign_in_as_msa_user(user: user)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end

  context "with a Search OPSS science user" do
    let(:user) { create(:opss_science_user) }

    before do
      sign_in_as_opss_science_user(user: user)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"

    it "allows user to download a list of cosmetic products containing nanomaterials" do
      expect(response.body).to have_tag("h2", text: "Downloadable data")
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: "All notified cosmetic products containing nanomaterials", with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: "Download as a CSV (spreadsheet) file", with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: "Download products with nanomaterials")
      end
    end
  end
end
