require "rails_helper"

RSpec.describe Formatters::AsimFormatter do
  let(:current_user) { create(:user) }
  let(:formatter) { described_class.new(current_user) }

  let(:data) do
    {
      controller: "HomeController",
      action: "index",
      status: 200,
      level: "INFO",
      remote_ip: "192.168.1.1",
      user_agent: "Mozilla/5.0",
      owner: "MyApp",
      request_id: "abcd-1234",
      duration: 60,
    }
  end

  let(:formatted_log) { JSON.parse(formatter.call(data)) }

  describe "#call" do
    context "when formatting the event with user details" do
      it "includes trace headers in the formatted log" do
        trace_headers = formatted_log["AdditionalFields"]["TraceHeaders"]
        expect(trace_headers).not_to be_nil
        expect(trace_headers["X-Request-Id"]).to eq("abcd-1234")
      end

      it "includes the user ID in the formatted log" do
        expect(formatted_log["SrcUserId"]).to eq(current_user.id)
      end

      it "includes the event type in the formatted log" do
        expect(formatted_log["EventType"]).to eq("HomeController#index")
      end

      it "includes the event result in the formatted log" do
        expect(formatted_log["EventResult"]).to eq("Success")
      end
    end
  end
end
