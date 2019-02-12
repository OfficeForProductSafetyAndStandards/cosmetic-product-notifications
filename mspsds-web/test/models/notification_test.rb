require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    sign_in_as_user
    @investigation = Investigation.create(description: "new investigation for notification test")
    @user_one = User.find_by(last_name: "User_one")
    @user_two = User.find_by(last_name: "User_two")
    @user_three = User.find_by(last_name: "User_three")
  end

  teardown do
    logout
  end

  test "should notify current assignee when the assignee is a person and there is any change" do
    @investigation.update(assignee: @user_one)
    prepare_notify_check(who_will_be_notified: [@user_one])
    make_generic_change
    assert_equal @number_of_notifications, 1
  end

  test "should not notify anyone when the assignee is a team and there is any change done by team users" do
    @investigation.update(assignee: @user_one.teams[0])
    prepare_notify_check(who_will_be_notified: [])
    make_generic_change
    assert_equal @number_of_notifications, 0
  end

  test "should notify all team members when the assignee is a team and there is any change done by outsiders" do
    @investigation.update(assignee: @user_three.teams[0])
    prepare_notify_check(who_will_be_notified: [@user_three])
    make_generic_change
    assert_equal @number_of_notifications, 1
  end

  test "should notify creator and assignee when case is closed or reopened by someone else" do
    @investigation.update(assignee: @user_three)
    logout
    sign_in_as_admin
    prepare_notify_check(who_will_be_notified: [@user_one, @user_three])
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 1
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 2
  end

  test "should not notify creator when case is closed or reopened by the creator" do
    @investigation.update(assignee: @user_three)
    prepare_notify_check(who_will_be_notified: [@user_three])
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 1
    @investigation.update(is_closed: !@investigation.is_closed)
    assert_equal @number_of_notifications, 2
  end

  test "should notify previous assignee if case is assigned to someone else by someone else" do
    @investigation.update(assignee: @user_one.teams[0])
    @investigation.update(assignee: @user_three)
    prepare_notify_check(who_will_be_notified: [@user_three, @user_one])
    @investigation.update(assignee: @user_one)
    assert_equal @number_of_notifications, 2
  end

  test "should not notify previous assignee if case is assigned to someone else by them" do
    @investigation.update(assignee: @user_one)
    prepare_notify_check(who_will_be_notified: [@user_three])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify previous assignee team if case is assigned to someone by someone outside" do
    @investigation.update(assignee: @user_one)
    @investigation.update(assignee: @user_three.teams[0])
    prepare_notify_check(who_will_be_notified: [@user_three, @user_one])
    @investigation.update(assignee: @user_one)
    assert_equal @number_of_notifications, 2
  end

  test "should not notify previous assignee team if case is assigned to someone by someone inside" do
    @investigation.update(assignee: @user_three)
    @investigation.update(assignee: @user_one.teams[0])
    prepare_notify_check(who_will_be_notified: [@user_three])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify a person who gets assigned a case" do
    prepare_notify_check(who_will_be_notified: [@user_three])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 1
  end

  test "should notify everyone in team that gets assigned a case" do
    prepare_notify_check(who_will_be_notified: @user_one.teams[0].users)
    @investigation.update(assignee: @user_one.teams[0])
    assert_equal @number_of_notifications, 2
  end

  test "previous assignee is computed correctly" do
    @investigation.update(assignee: @user_one)
    @investigation.update(assignee: @user_two)
    prepare_notify_check(who_will_be_notified: [@user_three, @user_two])
    @investigation.update(assignee: @user_three)
    assert_equal @number_of_notifications, 2
  end

  def prepare_notify_check(who_will_be_notified: [])
    result = ""
    @number_of_notifications = 0
    allow(result).to receive(:deliver_later)
    allow(NotifyMailer).to receive(:updated_investigation) do |_id, user_name, _user_email, _text|
      @number_of_notifications += 1
      assert_includes who_will_be_notified.map(&:full_name), user_name
      result
    end
  end

  def make_generic_change
    # Should not be changing the assignee, since it's a special case
    @investigation.add_business(Business.create(trading_name: 'Test Company'), "Test relationship")
  end
end
