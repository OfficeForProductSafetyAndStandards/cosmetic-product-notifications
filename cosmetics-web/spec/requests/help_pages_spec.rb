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
      expect(response.body).to have_tag("h1", text: /\ATerms and conditions/)
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
      expect(response.body).to have_tag("h1", text: /\APrivacy policy/)
    end
  end
end
