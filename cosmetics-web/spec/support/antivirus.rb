RSpec.shared_context "with stubbed Antivirus API", shared_context: :metadata do
  before do
    stubbed_response = JSON.generate(safe: true)
    stub_request(:any, /#{Regexp.quote(ENV["ANTIVIRUS_URL"])}/).to_return(body: stubbed_response, status: 200)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with stubbed Antivirus API", with_stubbed_antivirus: true
end
