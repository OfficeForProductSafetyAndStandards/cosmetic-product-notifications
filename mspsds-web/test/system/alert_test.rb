require "application_system_test_case"

class AlertTest < ApplicationSystemTestCase
  setup do
    mock_out_keycloak_and_notify
    @investigation = investigations(:one)
    @alert = alerts :one
    go_to_new_activity_for_investigation @investigation
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "prepopulates email content with link to case" do
    fill_in_activity_selection
    click_on "Compose new alert"
    assert_includes(find_field(:alert_description).value, investigation_path(@investigation))
  end

  test "sends notify email" do
    stub_email_alert
    stub_email_preview @alert
    fill_in_activity_selection
    click_on "Compose new alert"

    fill_in_compose_alert @alert

    assert_text "Preview your alert"
    assert_text @alert.summary
    assert_text @alert.description

    expected_number_of_emails_sent = User.all.length

    click_on "Send to #{expected_number_of_emails_sent} people"

    assert_equal(expected_number_of_emails_sent, @number_of_emails_sent)
    assert_text @investigation.title
    assert_text "Email alert sent to #{expected_number_of_emails_sent} users"
  end

  test "requires a restricted case be derestricted before raising an alert" do
    @private_investigation = investigations :private
    @alert = alerts :on_private_investigation
    stub_email_preview @alert

    go_to_new_activity_for_investigation @private_investigation
    fill_in_activity_selection

    assert_selector "h1", text: "You cannot send an alert about a restricted case"

    click_on "Change case visibility"
    assert_selector "h1", text: "Legal privilege"
  end

  def go_to_new_activity_for_investigation investigation
    visit investigation_path(investigation)

    first(:link, "Add activity").click
  end

  def fill_in_activity_selection
    choose "activity_type_alert", visible: false
    click_on "Continue"
  end

  def fill_in_compose_alert alert
    fill_in :alert_summary, with: alert.summary
    fill_in :alert_description, with: alert.description
    click_on "Preview alert"
  end

  def stub_email_alert
    allow(SendAlertJob).to receive(:perform_later) do |recipients, _user_name, _user_email|
      @number_of_emails_sent = recipients.length
    end
  end

  def stub_email_preview alert
    stubbed_notifications_client = double("NotificationsClient")
    stubbed_template = double("TemplatePreview", html: "<p>#{alert.description}</p>")
    allow(Notifications::Client).to receive(:new) { stubbed_notifications_client }
    allow(stubbed_notifications_client).to receive(:generate_template_preview) { stubbed_template }
  end
end
