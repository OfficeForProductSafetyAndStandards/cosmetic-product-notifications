RSpec.configure do |config|
  config.before do
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
    # Enable two-factor authentication by default for tests
    # Individual tests can disable it as needed
    Flipper.enable(:two_factor_authentication)
  end
end
