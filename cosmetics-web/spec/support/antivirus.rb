RSpec.shared_context "with stubbed Antivirus API", shared_context: :metadata do
  before do
    antivirus_url = Rails.application.config.antivirus_url
    stubbed_response = JSON.generate(safe: true)
    stub_request(:any, /#{Regexp.quote(antivirus_url)}/).to_return(body: stubbed_response, status: 200)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed Antivirus API", with_stubbed_antivirus: true
end


RSpec.shared_context "with stubbed Antivirus API returning false", shared_context: :metadata do
  before do
    antivirus_url = Rails.application.config.antivirus_url
    stubbed_response = JSON.generate(safe: false)
    stub_request(:any, /#{Regexp.quote(antivirus_url)}/).to_return(body: stubbed_response, status: 200)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed Antivirus API returning false", with_stubbed_antivirus_returning_false: true
end
