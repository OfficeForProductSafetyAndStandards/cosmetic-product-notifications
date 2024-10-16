require "rails_helper"

RSpec.describe "Help pages", type: :request do
  include RSpecHtmlMatchers

  describe "'Terms and conditions'" do
    before do
      get "/help/terms-and-conditions"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\ATerms and conditions/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: "Terms and conditions")
    end
  end

  describe "'Privacy policy'" do
    before do
      get "/help/privacy-notice"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\APrivacy policy/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: "Privacy policy")
    end
  end

  describe "'Cookies policy'" do
    before do
      get "/help/cookies"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\ACookies policy/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: "Cookies policy")
    end
  end

  describe "'Accessibility Statement'" do
    before do
      get "/help/accessibility-statement"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\AAccessibility Statement/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: "Accessibility statement for Submit cosmetic product notifications")
    end
  end

  describe "'How to create an ingredient CSV file'" do
    before do
      get "/help/csv?csv_file_type=#{csv_file_type}"
    end

    %w[exact exact-with-multiple-shades range].each do |csv_file_type|
      context "when csv_file_type is set to #{csv_file_type}" do
        let(:csv_file_type) { csv_file_type }

        it "is successful" do
          expect(response.code).to eql("200")
        end

        it "has a page title" do
          expect(response.body).to have_tag("title", text: /\AHow to create an ingredient CSV file/)
        end

        it "has a page heading" do
          expect(response.body).to have_tag("h1", text: "How to create an ingredient CSV file")
        end
      end
    end

    context "when csv_file_type is not set" do
      let(:csv_file_type) { nil }

      it "redirects to the 404 error page" do
        expect(response).to redirect_to("/404")
      end
    end
  end
end
