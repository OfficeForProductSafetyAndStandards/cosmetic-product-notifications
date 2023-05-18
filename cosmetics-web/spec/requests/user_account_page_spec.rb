require "rails_helper"

RSpec.describe "User account page", type: :request do
  include RSpecHtmlMatchers

  RSpec.shared_examples "can change name and security" do
    it "allows user to change their name" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("Full name"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces(user.name), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Change name"))
      end
    end

    it "allows user to change their password" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("Email address"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces('\*\*\*\*\*\*\*\*'), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Change password"))
      end
    end

    it "allows user to change their account 2FA SMS" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("Text message"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces(user.mobile_number), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", optional_spaces("Change text message"))
      end
    end

    it "allows user to change their account 2FA App" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("Authenticator app"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces("Authenticator app is set"), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Change authenticator app"))
      end
    end
  end

  RSpec.shared_examples "can't change email" do
    it "does not allow user to change their email" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("Email address"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces(user.email), with: { class: "govuk-summary-list__value" })
        without_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Change email address"))
      end
    end
  end

  RSpec.shared_examples "can't download nanomaterials" do
    it "does not show the downloadable data section" do
      expect(response.body).not_to have_tag("div#opss_science_downloads")
    end
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
        with_tag("dt", text: optional_spaces("Email address"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces(user.email), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Change email address"))
      end
    end
  end

  context "with a Search poison centre user" do
    let(:user) { create(:poison_centre_user) }

    before do
      sign_in_as_poison_centre_user(user:)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end

  context "with a Search OPSS General user" do
    let(:user) { create(:opss_general_user) }

    before do
      sign_in_as_opss_general_user(user:)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end

  context "with a Search OPSS Enforcement user" do
    let(:user) { create(:opss_enforcement_user) }

    before do
      sign_in_as_opss_enforcement_user(user:)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end

  context "with a Search OPSS Science user" do
    let(:user) { create(:opss_science_user) }

    before do
      sign_in_as_opss_science_user(user:)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"

    it "includes the downloadable data section" do
      expect(response.body).to have_tag("div#opss_science_downloads")
    end

    it "allows user to download a list of cosmetic products containing nanomaterials" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("All notified cosmetic products containing nanomaterials"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces('Download as a CSV \(spreadsheet\) file'), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Download products with nanomaterials"))
      end
    end

    it "allows user to download a list of notified nanomaterials" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("All notified nanomaterials"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces('Download as a CSV \(spreadsheet\) file'), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Download notified nanomaterials"))
      end
    end

    it "allows user to download all nanomaterial notifications pdfs" do
      expect(response.body).to have_tag("div", with: { class: "govuk-summary-list__row" }) do
        with_tag("dt", text: optional_spaces("All notified nanomaterials as PDFs"), with: { class: "govuk-summary-list__key" })
        with_tag("dd", text: optional_spaces('Download as a ZIP file \(containing PDFs\)'), with: { class: "govuk-summary-list__value" })
        with_tag("dd.govuk-summary-list__actions a", text: optional_spaces("Download notified nanomaterials as PDFs"))
      end
    end
  end

  context "with a Search Trading Standards user" do
    let(:user) { create(:trading_standards_user) }

    before do
      sign_in_as_trading_standards_user(user:)
      get "/my_account"
    end

    include_examples "can change name and security"
    include_examples "can't change email"
    include_examples "can't download nanomaterials"
  end
end
