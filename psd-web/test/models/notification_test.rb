require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    mock_out_keycloak_and_notify
    @investigation = Investigation.create(description: "new investigation for notification test")
    @user_one = User.find_by(last_name: "User_one")
    @user_two = User.find_by(last_name: "User_two")
    @user_three = User.find_by(last_name: "User_three")
  end

  teardown do
    reset_keycloak_and_notify_mocks
  end

  test "should notify current assignee when the assignee is a person and there is any change" do
    @investigation.update(assignee: @user_two)
    mock_investigation_updated(who_will_be_notified: [@user_two.email])
    make_generic_change
    assert_equal @number_of_notifications, 1
  end

  test "should not notify current assignee when the assignee makes the change" do
    @investigation.update(assignee: @user_one.teams[0])
    mock_investigation_updated(who_will_be_notified: [])
    make_generic_change
    assert_equal @number_of_notifications, 0
  end

  test "should not notify anyone when the assignee is a team and there is any change done by team users" do
    @investigation.update(assignee: @user_one.teams[0])
    mock_investigation_updated(who_will_be_notified: [])
    make_generic_change
    assert_equal @number_of_notifications, 0
  end

  test "should notify all team members when the assignee is a team and there is any change done by outsiders" do
    @investigation.update(assignee: @user_three.teams[0])
    mock_investigation_updated(who_will_be_notified: [@user_three.email])
    make_generic_change
    assert_equal @number_of_notifications, 1
  end

  test "should notify creator and assignee when case is closed or reopened by someone else" do
    @investigation.update(assignee: @user_three)
    sign_in_as User.find_by(last_name: "User_four")
    mock_investigation_updated(who_will_be_notified: [@user_one, @user_three].map(&:email))
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal 2, @number_of_notifications
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal 4, @number_of_notifications
  end

  test "should not notify creator when case is closed or reopened by the creator" do
    @investigation.update(assignee: @user_three)
    mock_investigation_updated(who_will_be_notified: [@user_three.email])
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 1
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 2
  end

  test "should notify previous assignee if case is assigned to someone else by someone else" do
    @investigation.update(assignee: @user_one.teams[0])
    @investigation.update(assignee: @user_three)
    mock_investigation_updated(who_will_be_notified: [@user_three, @user_one].map(&:email))
    @investigation.update(assignee: @user_one)
    assert_equal @number_of_notifications, 2
  end

  test "should not notify previous assignee if case is assigned to someone else by them" do
    @investigation.update(assignee: @user_one)
    mock_investigation_updated(who_will_be_notified: [@user_three.email])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify previous assignee team if case is assigned to someone by someone outside" do
    @investigation.update(assignee: @user_one)
    @investigation.update(assignee: @user_three.teams[0])
    mock_investigation_updated(who_will_be_notified: [@user_three, @user_one].map(&:email))
    @investigation.update(assignee: @user_one)
    assert_equal @number_of_notifications, 2
  end

  test "should not notify previous assignee team if case is assigned to someone by someone inside" do
    @investigation.update(assignee: @user_three)
    @investigation.update(assignee: @user_one.teams[0])
    mock_investigation_updated(who_will_be_notified: [@user_three.email])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify a person who gets assigned a case" do
    mock_investigation_updated(who_will_be_notified: [@user_three.email])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify everyone in team that gets assigned a case" do
    mock_investigation_updated(who_will_be_notified: @user_one.teams[0].users.map(&:email))
    @investigation.update(assignee: @user_one.teams[0])
    assert_equal @number_of_notifications, 2
  end

  test "previous assignee is computed correctly" do
    @investigation.update(assignee: @user_one)
    @investigation.update(assignee: @user_two)
    mock_investigation_updated(who_will_be_notified: [@user_three, @user_two].map(&:email))
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 2
  end

  test "notifies current user when investigation created" do
    mock_investigation_created(who_will_be_notified: [@user_one])
    @investigation_two = investigations :two
    Investigation.create(@investigation_two.attributes.merge(id: 123))
    assert_equal @number_of_notifications, 1
  end

  test "Team is notified correctly" do
    team_with_email = Team.find_by(name: "Team 4")
    @investigation.update(assignee: team_with_email)
    mock_investigation_updated(who_will_be_notified: [team_with_email.team_recipient_email])
    make_generic_change
    assert_equal @number_of_notifications, 1
  end

  def mock_investigation_updated(who_will_be_notified: [])
    notify_mailer_return_value = ""
    @number_of_notifications = 0
    allow(notify_mailer_return_value).to receive(:deliver_later)
    allow(NotifyMailer).to receive(:investigation_updated) do |_id, _user_name, email, _text|
      @number_of_notifications += 1
      assert_includes who_will_be_notified, email
      notify_mailer_return_value
    end
  end

  def mock_investigation_created(who_will_be_notified: [])
    notify_mailer_return_value = ""
    @number_of_notifications = 0
    allow(notify_mailer_return_value).to receive(:deliver_later)
    allow(NotifyMailer).to receive(:investigation_created) do |_id, user_name, _user_email, _investigation_title, _investigation_type|
      @number_of_notifications += 1
      assert_includes who_will_be_notified.map(&:full_name), user_name
      notify_mailer_return_value
    end
  end

  def make_generic_change
    # Should not be changing the assignee, since it's a special case
    @investigation.add_business(Business.create(trading_name: 'Test Company'), "Test relationship")
  end
end
