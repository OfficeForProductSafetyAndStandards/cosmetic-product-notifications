# frozen_string_literal: true

RSpec.shared_context "with stubbed notify" do
  let(:notify_stub) do
    instance_double(
      Notifications::Client,
      send_sms: instance_double(Notifications::Client::ResponseNotification),
    )
  end

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_stub)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed notify", :with_stubbed_notify
end
