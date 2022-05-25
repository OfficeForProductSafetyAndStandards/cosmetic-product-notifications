require "rails_helper"

# rubocop:disable Rspec/AnyInstance
describe "user declarations", type: :request do
  before do
    cookies["essential"] = "cosmetics"
    cookies["_ga_NSLSMEMX9S"] = "foo"
    cookies["_gid"] = "bar"
    cookies["_gat_gtag_UA_126364208_2"] = "baz"

    allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { accept_analytics_cookies: accept_analytics_cookies } }

    get "/help/terms-and-conditions"
  end

  context "when analytics cookies are allowed" do
    let(:accept_analytics_cookies) { true }

    it "has analytics cookies" do
      # response is not returning any cookies to delete
      expect(response.cookies.to_hash.size).to eq(0)
    end
  end

  context "when analytics cookies are not allowed" do
    let(:accept_analytics_cookies) { false }

    it "removes analytics" do
      # response is returning 3 cookies that should be deleted
      expect(response.cookies.to_hash.keys).to eq(%w[_ga_NSLSMEMX9S _gat_gtag_UA_126364208_2 _gid])
      expect(response.cookies.to_hash.values.uniq).to eq([nil])
    end
  end
end
# rubocop:enable Rspec/AnyInstance
