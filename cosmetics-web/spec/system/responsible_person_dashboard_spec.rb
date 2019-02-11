require 'rails_helper'

RSpec.describe "Responsible person dashboard", type: :system do
  let(:user_1) { create(:user) }
  let(:user_2) { create(:user) }
  let(:responsible_person_1) { create(:responsible_person) }
  let(:responsible_person_2) { create(:responsible_person, email_address: "responsible_person_2@example.com") }

  before do
    sign_in_as_member_of_responsible_person_as_user(responsible_person_1, user_1)
  end

  after do
    sign_out
  end

  it "only shows user the unfinished notifications belonging to their Responsible Person" do
    create(:draft_notification, responsible_person_id: responsible_person_1.id)
    create(:draft_notification, responsible_person_id: responsible_person_2.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Unfinished (1)"
  end

  it "only shows user the registered notifications belonging to their Responsible Person" do
    create(:registered_notification, responsible_person_id: responsible_person_1.id)
    create(:registered_notification, responsible_person_id: responsible_person_2.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Registered (1)"
  end

  it "does not allow user to access another Responsible Person's dashboard" do
    visit responsible_person_notifications_path(responsible_person_2)
    assert_text "Access denied"
  end

  it "doesn't count number of loading files from other users in Responsible Person" do
    responsible_person_1.add_user(user_2)
    create(:notification_file, responsible_person_id: responsible_person_1.id, user_id: user_1.id)
    create(:notification_file, responsible_person_id: responsible_person_1.id, user_id: user_2.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Checking 1 notification file"
  end

  it "doesn't count number of loading files from users outside of Responsible Person" do
    responsible_person_2.add_user(user_2)
    create(:notification_file, responsible_person_id: responsible_person_1.id, user_id: user_1.id)
    create(:notification_file, responsible_person_id: responsible_person_2.id, user_id: user_2.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Checking 1 notification file"
  end

  it "uses pagination to display unfinished notifications" do
    create_list(:draft_notification, 11, responsible_person_id: responsible_person_1.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Previous 1 2 Next"
  end

  it "uses pagination to display registered notifications" do
    create_list(:registered_notification, 11, responsible_person_id: responsible_person_1.id)
    visit responsible_person_notifications_path(responsible_person_1)
    assert_text "Previous 1 2 Next"
  end
end
