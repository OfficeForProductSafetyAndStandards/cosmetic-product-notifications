RSpec.configure do |config|
  config.before do
    Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
  end
end
