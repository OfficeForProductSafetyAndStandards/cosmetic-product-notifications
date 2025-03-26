RSpec.shared_context "with stubbed Antivirus API", shared_context: :metadata do
  let(:with_stubbed_antivirus_result) { true }

  before do
    antivirus_url = ENV["ANTIVIRUS_URL"] ? "#{ENV['ANTIVIRUS_URL'].chomp('/')}/v2/scan-chunked" : "http://localhost:3000/v2/scan-chunked"

    # For clamav-rest API, the opposite of "safe: true" is "malware: false"
    stubbed_response = with_stubbed_antivirus_result ? '{"malware": false, "reason": null, "time": 0.001}' : '{"malware": true, "reason": "Test-Virus-Found", "time": 0.001}'

    stub_request(:any, /#{Regexp.quote(antivirus_url)}/).to_return(body: stubbed_response, status: 200)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed Antivirus API", with_stubbed_antivirus: true
end

RSpec.shared_context "with stubbed Antivirus API returning false", shared_context: :metadata do
  before do
    antivirus_url = ENV["ANTIVIRUS_URL"] ? "#{ENV['ANTIVIRUS_URL'].chomp('/')}/v2/scan-chunked" : "http://localhost:3000/v2/scan-chunked"

    # For clamav-rest API, this would be "malware: true"
    stubbed_response = '{"malware": true, "reason": "Test-Virus-Found", "time": 0.001}'

    stub_request(:any, /#{Regexp.quote(antivirus_url)}/).to_return(body: stubbed_response, status: 200)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed Antivirus API returning false", with_stubbed_antivirus_returning_false: true
end
