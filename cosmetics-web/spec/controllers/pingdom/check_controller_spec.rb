require "rails_helper"
RSpec.describe Pingdom::CheckController, type: :controller do
  describe "GET #pingdom" do
    context "when the request is successful" do
      before do
        get :pingdom, format: :xml # Specify the format as XML
      end

      it "returns an HTTP 200 OK status" do
        expect(response).to have_http_status(:ok)
      end

      it "responds with XML content type" do
        expect(response.content_type).to eq("application/xml; charset=utf-8")
      end

      it "renders the correct XML structure" do
        expected_xml = "<pingdom_http_custom_check><status>OK</status></pingdom_http_custom_check>"
        expect(response.body.strip).to eq(expected_xml.strip)
      end
    end

    context "when the request fails (404 Not Found)" do
      before do
        get :pingdom, format: :html
      end

      it "returns a 404 status for any other format type" do
        expect(response).to redirect_to("/404")
      end
    end
  end
end
