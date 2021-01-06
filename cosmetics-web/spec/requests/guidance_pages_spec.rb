require "rails_helper"

RSpec.describe "Guidance pages", type: :request do
  include RSpecHtmlMatchers

  describe "'How to notify nanomaterials'" do
    before do
      get "/guidance/how-to-notify-nanomaterials"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\AHow to notify products containing nanomaterials/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: /\AHow to notify products containing nanomaterials/)
    end
  end

  describe "'How to prepare images for notification'" do
    before do
      get "/guidance/how-to-prepare-images-for-notification"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page title" do
      expect(response.body).to have_tag("title", text: /\AHow to prepare images for notification/)
    end

    it "has a page heading" do
      expect(response.body).to have_tag("h1", text: /\AHow to prepare images for notification/)
    end
  end
end
