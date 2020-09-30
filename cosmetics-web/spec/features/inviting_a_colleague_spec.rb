require "rails_helper"

RSpec.describe "Inviting a colleague", :with_stubbed_antivirus, :with_stubbed_notify, :with_stubbed_mailer, :with_2fa, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }
  let(:invited_user) { create(:submit_user, name: "John Doeinvited", email: "inviteduser@example.com") }

  scenario "sending an invitation to an existing user that does not belong to any team" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::INVITE_USER] + 1
    travel_to(Time.now.utc + wait_time.seconds) do
      click_on "Invite a colleague"

      complete_secondary_authentication_for(user)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Email address", with: invited_user.email
      click_on "Send invitation"

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

      invitation = PendingResponsiblePersonUser.last

      expect(delivered_emails.size).to eq 1
      email = delivered_emails.first

      expect(email).to have_attributes(
        recipient: invited_user.email,
        reference: "Invite user to join responsible person",
        template: NotifyMailer::TEMPLATES[:responsible_person_invitation],
        personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                          invite_sender: user.name,
                          responsible_person: responsible_person.name },
      )
    end
  end

  scenario "sending an invitation to an user that already belongs to the team" do
    create(:responsible_person_user, user: invited_user, responsible_person: responsible_person)

    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::INVITE_USER] + 1
    travel_to(Time.now.utc + wait_time.seconds) do
      click_on "Invite a colleague"

      complete_secondary_authentication_for(user)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Email address", with: invited_user.email
      click_on "Send invitation"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css(".govuk-error-message", text: "This email address already belongs to member of this team")
      expect(delivered_emails.size).to eq 0
    end
  end

  scenario "sending an invitation to an user that already belongs to a different team" do
    team = create(:responsible_person, :with_a_contact_person)
    create(:responsible_person_user, user: invited_user, responsible_person: team)

    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::INVITE_USER] + 1
    travel_to(Time.now.utc + wait_time.seconds) do
      click_on "Invite a colleague"

      complete_secondary_authentication_for(user)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Email address", with: invited_user.email
      click_on "Send invitation"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css(".govuk-error-message", text: "You can not invite this email address to join your team")
      expect(delivered_emails.size).to eq 0
    end
  end

  scenario "sending an invitation to an user with an expired previous invitation" do
    create(:pending_responsible_person_user,
           email_address: invited_user.email,
           responsible_person: responsible_person)

    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR + 1
    travel_to(Time.now.utc + wait_time.seconds) do
      click_on "Invite a colleague"

      complete_secondary_authentication_for(user)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Email address", with: invited_user.email
      click_on "Send invitation"

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

      expect(delivered_emails.size).to eq 1
      email = delivered_emails.first
      new_token = PendingResponsiblePersonUser.last.invitation_token

      expect(email).to have_attributes(
        recipient: invited_user.email,
        reference: "Invite user to join responsible person",
        template: NotifyMailer::TEMPLATES[:responsible_person_invitation],
        personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{new_token}",
                          invite_sender: user.name,
                          responsible_person: responsible_person.name },
      )
    end
  end


  scenario "re-sending an invitation to a new user that accepted the original invitation but didn't complete their user account" do
    configure_requests_for_submit_domain

    team = create(:responsible_person, :with_a_contact_person)
    create(:responsible_person_user, user: invited_user, responsible_person: team)

    # User sends the original invitation to the team
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"
    click_on "Invite a colleague"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")
    fill_in "Email address", with: "newusertoregister@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

    invitation = PendingResponsiblePersonUser.last

    expect(delivered_emails.size).to eq 1
    original_email = delivered_emails.first

    expect(original_email).to have_attributes(
      recipient: "newusertoregister@example.com",
      reference: "Invite user to join responsible person",
      template: NotifyMailer::TEMPLATES[:responsible_person_invitation],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                        invite_sender: user.name,
                        responsible_person: responsible_person.name },
    )

    # Invited user accepts the invitation
    sign_out
    visit original_email.personalization[:invitation_url]

    expect(page).to have_css("h1", text: "Create an account")

    # Invited user signs out without completing the registration
    sign_out

    # Original team member can re-invite the user that didn't complete its registration
    sign_in(user)

    visit "/responsible_persons/#{responsible_person.id}/team_members"
    click_on "Invite a colleague"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")
    fill_in "Email address", with: "newusertoregister@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")
    expect(page).not_to have_css("h2#error-summary-title", text: "There is a problem")
    expect(page).not_to have_css(".govuk-error-message", text: "This email address already belongs to member of this team")
    expect(delivered_emails.size).to eq 2
    second_email = delivered_emails.last
    invitation = PendingResponsiblePersonUser.last

    expect(second_email).to have_attributes(
      recipient: "newusertoregister@example.com",
      reference: "Invite user to join responsible person",
      template: NotifyMailer::TEMPLATES[:responsible_person_invitation],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                        invite_sender: user.name,
                        responsible_person: responsible_person.name },
    )
  end

  scenario "accepting an expired invitation for an existing user" do
    configure_requests_for_submit_domain
    sign_in invited_user

    invitation = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                     responsible_person: responsible_person)

    join_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}"

    wait_time = PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR + 1
    travel_to(Time.now.utc + wait_time.seconds) do
      visit join_path
      expect(page).to have_current_path(join_path)
      expect(page).to have_css("h1", text: "This invitation has expired")
      expect(invited_user.responsible_persons).not_to include(responsible_person)
    end
  end

  scenario "following an invitation link with a token that does not match any invitation" do
    configure_requests_for_submit_domain
    join_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=8cfa59f3-6b61-44f9-871b-c471651f234b"
    visit join_path

    expect(page).to have_current_path("/")
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
    expect(page).to have_link("Sign in")
  end

  scenario "accepting an invitation for an existing user" do
    configure_requests_for_submit_domain
    sign_in invited_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when signed in as different user" do
    configure_requests_for_submit_domain
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_css("h1", text: "You are already signed in")
    expect(page).to have_css("button", text: "Accept team invitation as John Doe")

    click_button "Accept team invitation as John Doe"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for a new user when signed in as different user" do
    configure_requests_for_submit_domain

    # User invites a new member to the team
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::TIMEOUTS[SecondaryAuthentication::INVITE_USER] + 1
    travel_to(Time.now.utc + wait_time.seconds)

    click_on "Invite a colleague"

    complete_secondary_authentication_for(user)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

    fill_in "Email address", with: "newusertoregister@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

    expect(delivered_emails.size).to eq 1

    email = delivered_emails.last
    expect(email.recipient).to eq "newusertoregister@example.com"
    expect(email.personalization[:responsible_person]).to eq("Responsible Person")

    # Accepting the invitation when signed in as a different user
    different_user = create(:submit_user, name: "John Doedifferent")
    sign_out
    sign_in_as_member_of_responsible_person(responsible_person, different_user)
    visit email.personalization[:invitation_url]

    expect(page).to have_css("h1", text: "You are already signed in")

    click_button "Create a new account"

    expect(page).to have_css("h1", text: "Create an account")

    fill_in "Full Name", with: "John Doe"
    fill_in "Mobile Number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for a new user when not signed in" do
    configure_requests_for_submit_domain

    pending = PendingResponsiblePersonUser.create(email_address: "newusertoregister@example.com",
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Create an account")

    fill_in "Full Name", with: "Joe Doe"
    fill_in "Mobile Number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for a new user for second time after originally accepting it without completing the user registration" do
    configure_requests_for_submit_domain

    pending = PendingResponsiblePersonUser.create(email_address: "newusertoregister@example.com",
                                                  responsible_person: responsible_person)

    # Invited user originally accepts the invitation
    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Create an account")

    # Abandones the service without completing its registration :(
    sign_out

    # Later, decides to follow the invitation again
    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"

    # Invitation is still valid and allows them to register and be added to the team
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Create an account")

    fill_in "Full Name", with: "Joe Doe"
    fill_in "Mobile Number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when not signed in" do
    configure_requests_for_submit_domain

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end
end

def complete_secondary_authentication_for(user)
  expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
  expect_to_be_on_secondary_authentication_page
  complete_secondary_authentication_with(user.direct_otp)
end
