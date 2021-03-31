# frozen_string_literal: true

RSpec.shared_context "with secondary authentication app" do
  let(:authentication_app_stub) do
    instance_double(ROTP::TOTP, verify: nil, provisioning_uri: Faker::Internet.url)
  end
  let(:correct_app_code) { "123456" }

  before do
    allow(authentication_app_stub).to receive(:verify)
                                  .with(correct_app_code, anything)
                                  .and_return(Time.zone.now.to_i)
    allow(ROTP::TOTP).to receive(:new).and_return(authentication_app_stub)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with secondary authentication app", :with_2fa_app
end
