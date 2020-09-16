require "rails_helper"

RSpec.describe "Inviting a colleague", :with_stubbed_antivirus, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }
  let(:invited_user) { create(:submit_user, name: "John Doeinvited", email: "inviteduser@example.com") }

  scenario "sending an invitation" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit responsible_person_team_members_path(responsible_person)

    click_on "Invite a colleague"

    expect(page).to have_current_path(new_responsible_person_team_member_path(responsible_person))

    fill_in "Email address", with: invited_user.email
    click_on "Send invitation"

    expect(page).to have_current_path(responsible_person_team_members_path(responsible_person))

    invitation = PendingResponsiblePersonUser.last

    expect(delivered_emails.size).to eq 1
    email = delivered_emails.first

    expect(email).to have_attributes(
      recipient: invited_user.email,
      reference: "Invite user to join responsible person",
      template: NotifyMailer::TEMPLATES[:responsible_person_invitation],
      personalization: { invitation_url: "http://submit/responsible_persons/#{responsible_person.id}/team_members/#{invitation.id}/join",
                         inviting_user_name: user.name,
                         responsible_person_name: responsible_person.name },
    )
  end

  scenario "accepting an invitation as an existing user" do
    configure_requests_for_submit_domain
    sign_in invited_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit join_responsible_person_team_member_path(responsible_person, pending)

    expect(page).to have_current_path(responsible_person_path(responsible_person))
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when signed in as different user" do
    configure_requests_for_submit_domain
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit join_responsible_person_team_member_path(responsible_person, pending)
    expect(page).to have_css("h1", text: "You are already signed in")
    expect(page).to have_css("button", text: "Accept team invitation as John Doe")

    click_button "Accept team invitation as John Doe"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    expect(page).to have_current_path(responsible_person_path(responsible_person))
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for a new user when signed in as different user" do
    configure_requests_for_submit_domain
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = PendingResponsiblePersonUser.create(email_address: "newusertoregister@example.com",
                                                  responsible_person: responsible_person)

    visit join_responsible_person_team_member_path(responsible_person, pending)
    expect(page).to have_css("h1", text: "You are already signed in")
    expect(page).to have_css("button", text: "Create a new account")

    click_button "Create a new account"

    expect(page).to have_current_path(registration_new_submit_user_path)
    expect(page).to have_css("h1", text: "Create an account")
  end

  scenario "accepting an invitation for a new user when not signed in" do
    configure_requests_for_submit_domain

    pending = PendingResponsiblePersonUser.create(email_address: "newusertoregister@example.com",
                                                  responsible_person: responsible_person)

    visit join_responsible_person_team_member_path(responsible_person, pending)

    expect(page).to have_current_path(registration_new_submit_user_path)
    expect(page).to have_css("h1", text: "Create an account")
  end

  scenario "accepting an invitation for an existent user when not signed in" do
    configure_requests_for_submit_domain

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit join_responsible_person_team_member_path(responsible_person, pending)
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    expect(page).to have_current_path(responsible_person_path(responsible_person))
    expect(invited_user.responsible_persons).to include(responsible_person)
  end
end
