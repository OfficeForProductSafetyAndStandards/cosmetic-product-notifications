require "rails_helper"

RSpec.describe CookieForm do
  let(:session) { { accept_analytics_cookies: session_accept_analytics_cookies } }

  context "when initialised only with session attribute" do
    context "when accept_analytics_cookies is true" do
      let(:session_accept_analytics_cookies) { true }

      it "sets form properly" do
        form = described_class.new(session: session)
        expect(form.accept_analytics_cookies).to eq(true)
      end
    end

    context "when accept_analytics_cookies is false" do
      let(:session_accept_analytics_cookies) { false }

      it "sets form properly" do
        form = described_class.new(session: session)
        expect(form.accept_analytics_cookies).to eq(false)
      end
    end
  end

  context "when initialised with session and accept_analytics_cookies attribute" do
    let(:session_accept_analytics_cookies) { true }

    it "is prioritising attribute over session attribute" do
      form = described_class.new(session: session, accept_analytics_cookies: false)
      expect(form.accept_analytics_cookies).to eq(false)
    end

    it "is changing session when save called" do
      form = described_class.new(session: session, accept_analytics_cookies: false)
      form.save

      expect(session[:accept_analytics_cookies]).to eq(false)
    end
  end
end
