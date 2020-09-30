require "rails_helper"

RSpec.describe "Inviting a colleague", :with_stubbed_antivirus, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }
  let(:invited_user) { create(:submit_user) }

  before do
  end

  after do
    sign_out
  end

  scenario "sending an invitation" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit responsible_person_team_members_path(responsible_person)


    click_on "Invite a colleague"

    expect(page).to have_current_path(new_responsible_person_team_member_path(responsible_person))

    fill_in "Email address", with: "inviteduser@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path(responsible_person_team_members_path(responsible_person))
    expect(NotifyMailer).to have_received(:send_responsible_person_invite_email)
  end

  scenario "accepting an invitation" do
    configure_requests_for_submit_domain
    sign_in invited_user

    PendingResponsiblePersonUser.create(email_address: invited_user.email, responsible_person: responsible_person)

    visit join_responsible_person_team_members_path(responsible_person)

    expect(page).to have_current_path(responsible_person_path(responsible_person))
    expect(invited_user.responsible_persons).to include(responsible_person)
  end
end
