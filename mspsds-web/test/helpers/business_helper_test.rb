require "test_helper"
require "rspec/mocks/standalone"

class BusinessHelperTest < ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods
  include BusinessesHelper

  setup do
    Business.import force: true, refresh: true
  end

  teardown do
  end


end
