require 'rails_helper'

RSpec.describe "Invite a user to join a responsible person", type: :system do
  let(:responsible_person) { create(:responsible_person) }
  let(:user) { create(:user) }

  before do
    stub_notify_mailer
  end

  after do
    sign_out
  end

  it "allows user to send an invite to join a responsible person" do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit responsible_person_team_members_path(responsible_person)

    click_on "Invite a colleague"

    fill_in "Email address", with: "inviteduser@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path(responsible_person_team_members_path(responsible_person))
    expect(NotifyMailer).to have_received(:send_responsible_person_invite_email)
  end

  it "allows user to accept responsible person invitation" do
    sign_in
    pending_responsible_person_user = PendingResponsiblePersonUser.create(email_address: user.email, responsible_person: responsible_person)
    pending_responsible_person_user.update responsible_person: responsible_person

    visit join_responsible_person_team_members_path(responsible_person)

    expect(page).to have_current_path(responsible_person_path(responsible_person))
    expect(responsible_person.reload.responsible_person_users.size).to eq(1)
  end
end
