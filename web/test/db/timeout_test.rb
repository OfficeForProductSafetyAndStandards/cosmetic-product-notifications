require "test_helper"

class TimeoutTest < ActiveSupport::TestCase
  test "long queries timeout" do
    assert_raises do
      ActiveRecord::Base.connection.execute("SELECT pg_sleep(20);")
    end
  end
end
