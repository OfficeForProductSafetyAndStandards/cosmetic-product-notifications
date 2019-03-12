require "test_helper"

class Investigations::AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_user
    @investigation = investigations(:private)
    @investigation.source = sources(:investigation_private)
  end

  teardown do
    logout
  end

  test "prevents creation of alert on private investigation" do
    assert_raise(Pundit::NotAuthorizedError)  { get investigation_alert_url(@investigation, id: "compose") }
  end
end
