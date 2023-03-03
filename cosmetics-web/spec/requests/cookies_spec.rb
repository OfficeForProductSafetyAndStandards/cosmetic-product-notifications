require "rails_helper"

describe "user declarations", type: :request do
  before do
    cookies["essential"] = "cosmetics"
    cookies["_ga_NSLSMEMX9S"] = "foo"
    cookies["_gid"] = "bar"
    cookies["_gat_gtag_UA_126364208_2"] = "baz"
    cookies["journey_uuid"] = "baz"

    cookies["accept_analytics_cookies"] = accept_analytics_cookies

    get "/help/terms-and-conditions"
  end

  context "when analytics cookies are allowed" do
    let(:accept_analytics_cookies) { true }

    it "has analytics cookies" do
      # response is not returning any cookies to delete
      # returned cookie is the one that stores cookie options
      expect(response.cookies.to_hash.size).to eq(1)
    end
  end

  context "when analytics cookies are not allowed" do
    let(:accept_analytics_cookies) { false }

    it "removes analytics" do
      cookies_to_delete = response.cookies.to_hash.select do |_, v|
        v.nil?
      end

      # response is returning 3 cookies that should be deleted
      expect(cookies_to_delete.to_hash.keys).to eq(%w[_ga_NSLSMEMX9S _gat_gtag_UA_126364208_2 _gid journey_uuid])
    end
  end
end
