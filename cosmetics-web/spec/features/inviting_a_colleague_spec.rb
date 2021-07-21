require "rails_helper"

RSpec.describe "Inviting a team member", :with_stubbed_antivirus, :with_stubbed_notify, :with_stubbed_mailer, :with_2fa, :with_2fa_app, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, name: "Responsible Person") }
  let(:user) { create(:submit_user) }
  let(:invited_user) { create(:submit_user, name: "John Doeinvited", email: "inviteduser@example.com") }

  before do
    create(:responsible_person_user, user: user, responsible_person: responsible_person)

    configure_requests_for_submit_domain
  end

  scenario "sending an invitation to an existing user that does not belong to any team" do
    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1
    travel_to(Time.zone.now + wait_time.seconds) do
      click_on "Invite another team member"

      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
      complete_secondary_authentication_sms_with(user.direct_otp)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      # We use the wrong name when inviting the existing user
      fill_in "Full name", with: "John DiffName"
      fill_in "Email address", with: invited_user.email
      click_on "Send invitation"

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

      # Invitation gets listed with the correct name for the existing invited user
      expect(page).to have_css(
        "tr",
        text: "#{invited_user.name}: Awaiting confirmation #{invited_user.email} | Resend invitation to #{invited_user.name} #{user.name}",
      )

      # User receives an email with the invitation to the team
      invitation = PendingResponsiblePersonUser.last
      expect(delivered_emails.size).to eq 1
      email = delivered_emails.first
      expect(email).to have_attributes(
        recipient: invited_user.email,
        reference: "Invite user to join responsible person",
        template: SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation_for_existing_user],
        personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                           invite_sender: user.name,
                           responsible_person: responsible_person.name },
      )
    end
  end

  scenario "sending an invitation to an user that already belongs to the team" do
    create(:responsible_person_user, user: invited_user, responsible_person: responsible_person)

    sign_in(user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1
    travel_to(Time.zone.now + wait_time.seconds) do
      click_on "Invite another team member"

      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
      complete_secondary_authentication_sms_with(user.direct_otp)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Full name", with: invited_user.name
      fill_in "Email address", with: invited_user.email.upcase
      click_on "Send invitation"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css(".govuk-error-message", text: "This email address already belongs to member of this team")
      expect(delivered_emails.size).to eq 0
    end
  end

  scenario "sending an invitation to an user that had been already invited to the team" do
    create(:pending_responsible_person_user, email_address: invited_user.email, responsible_person: responsible_person)

    sign_in(user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1
    travel_to(Time.zone.now + wait_time.seconds) do
      click_on "Invite another team member"

      select_secondary_authentication_sms
      expect_to_be_on_secondary_authentication_sms_page
      expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
      complete_secondary_authentication_sms_with(user.direct_otp)

      expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

      fill_in "Full name", with: invited_user.name
      fill_in "Email address", with: invited_user.email.upcase
      click_on "Send invitation"

      expect(page).to have_css("h2#error-summary-title", text: "There is a problem")
      expect(page).to have_css(".govuk-error-message", text: "This person has already been invited to this team")
      expect(delivered_emails.size).to eq 0
    end
  end

  scenario "sending an invitation to an user that already belongs to a different team" do
    responsible_person2 = create(:responsible_person, :with_a_contact_person)
    create(:responsible_person_user, user: invited_user, responsible_person: responsible_person2)

    sign_in_as_member_of_responsible_person(responsible_person, user)
    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1

    travel_to(Time.zone.now.utc + wait_time.seconds)

    click_on "Invite another team member"

    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
    complete_secondary_authentication_sms_with(user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

    fill_in "Full name", with: invited_user.name
    fill_in "Email address", with: invited_user.email
    click_on "Send invitation"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

    # Invitation gets listed
    expect(page).to have_css(
      "tr",
      text: "#{invited_user.name}: Awaiting confirmation #{invited_user.email} | Resend invitation to #{invited_user.name} #{user.name}",
    )

    # User receives an email with the invitation to the team
    invitation = PendingResponsiblePersonUser.last
    expect(delivered_emails.size).to eq 1
    email = delivered_emails.first
    expect(email).to have_attributes(
      recipient: invited_user.email,
      reference: "Invite user to join responsible person",
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation_for_existing_user],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                         invite_sender: user.name,
                         responsible_person: responsible_person.name },
    )
  end

  scenario "re-sending an invitation" do
    sign_in_as_member_of_responsible_person(responsible_person, user)

    invitation = create(:pending_responsible_person_user, responsible_person: responsible_person, name: "John Doeinvited")

    team_path = "/responsible_persons/#{responsible_person.id}/team_members"
    visit team_path

    original_inviting_user_name = invitation.inviting_user.name
    expect(page).to have_css(
      "tr",
      text: "#{invitation.name}: Awaiting confirmation #{invitation.email_address} | Resend invitation to #{invitation.name} #{original_inviting_user_name}",
    )

    time_now = (Time.zone.at(Time.zone.now.to_i) + (PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR + 1))
    travel_to time_now

    click_on "Resend invitation"

    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
    complete_secondary_authentication_sms_with(user.direct_otp)

    # Extends the validity of the invitation
    expect(invitation.reload.invitation_token_expires_at).to eq(time_now + PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR)

    # Sends a new email
    email = delivered_emails.last
    expect(email).to have_attributes(
      recipient: invitation.email_address,
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                         invite_sender: user.name,
                         responsible_person: responsible_person.name },
    )

    # Shows the user who resent the invitation as the new inviting user
    expect(page).to have_current_path(team_path)
    expect(original_inviting_user_name).not_to eq user.name
    expect(page).to have_css(
      "tr",
      text: "#{invitation.name}: Awaiting confirmation #{invitation.email_address} | Resend invitation to #{invitation.name} #{user.name}",
    )
  end

  scenario "re-sending an invitation to a new user that accepted the original invitation but didn't complete their user account" do
    original_inviting_user = create(:submit_user, :with_sms_secondary_authentication)
    team = create(:responsible_person, :with_a_contact_person)
    create(:responsible_person_user, user: invited_user, responsible_person: team)

    # User sends the original invitation to the team
    sign_in_as_member_of_responsible_person(responsible_person, original_inviting_user)
    team_path = "/responsible_persons/#{responsible_person.id}/team_members"
    visit team_path
    click_on "Invite another team member"

    expect(page).to have_current_path("#{team_path}/new")
    fill_in "Full name", with: "John New User"
    fill_in "Email address", with: "newusertoregister@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path(team_path)

    invitation = PendingResponsiblePersonUser.last

    expect(delivered_emails.size).to eq 1
    original_email = delivered_emails.first

    expect(original_email).to have_attributes(
      recipient: "newusertoregister@example.com",
      reference: "Invite user to join responsible person",
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                         invite_sender: original_inviting_user.name,
                         responsible_person: responsible_person.name },
    )

    # Invited user accepts the invitation
    sign_out
    visit original_email.personalization[:invitation_url]

    expect(page).to have_css("h1", text: "Setup your account")

    # Invited user signs out without completing the registration
    sign_out

    # Team member can resend the invitation for the user that didn't complete its registration
    sign_in(user)

    visit "/responsible_persons/#{responsible_person.id}/team_members"

    # Still shows the invitation as pending
    expect(page).to have_css(
      "tr",
      text: "#{invitation.name}: Awaiting confirmation #{invitation.email_address} | Resend invitation to #{invitation.name} #{original_inviting_user.name}",
    )

    time_now = (Time.zone.at(Time.zone.now.to_i) + (PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR + 1))
    travel_to time_now

    click_on "Resend invitation"
    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
    complete_secondary_authentication_sms_with(user.direct_otp)

    # Extends the validity of the invitation
    expect(invitation.reload.invitation_token_expires_at).to eq(time_now + PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR)

    # Sends a new email
    expect(delivered_emails.size).to eq 2
    new_email = delivered_emails.last

    expect(new_email).to have_attributes(
      recipient: "newusertoregister@example.com",
      reference: "Invite user to join responsible person",
      template: SubmitNotifyMailer::TEMPLATES[:responsible_person_invitation_for_existing_user],
      personalization: { invitation_url: "http://#{ENV['SUBMIT_HOST']}/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}",
                         invite_sender: user.name,
                         responsible_person: responsible_person.name },
    )

    # Shows the user who resent the invitation as the new inviting user
    expect(page).to have_current_path(team_path)
    expect(original_inviting_user.name).not_to eq user.name
    expect(page).to have_css(
      "tr",
      text: "#{invitation.name}: Awaiting confirmation #{invitation.email_address} | Resend invitation to #{invitation.name} #{user.name}",
    )
  end

  scenario "accepting an invitation for a new user when not signed in" do
    pending = create(:pending_responsible_person_user, responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Setup your account")

    # User name is pre-filled with name provided in the invitation
    expect(page).to have_field("Full name", with: pending.name)

    # User can change the name
    fill_in "Full name", with: "Joe Doe"
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: pending.email_address)
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    expect(invited_user.responsible_persons).to include(responsible_person)
    # Updated user name from account security page
    expect(invited_user.name).to eq("Joe Doe")
  end

  scenario "accepting an invitation by an new user who belongs to another team" do
    responsible_person2 = create(:responsible_person, :with_a_contact_person)
    create(:responsible_person_user, user: invited_user, responsible_person: responsible_person2)

    pending = create(:pending_responsible_person_user,
                     email_address: invited_user.email,
                     responsible_person: responsible_person)
    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    sign_in(invited_user)
    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")
  end

  scenario "accepting an expired invitation for an existing user" do
    sign_in invited_user

    invitation = create(:pending_responsible_person_user,
                        email_address: invited_user.email,
                        responsible_person: responsible_person)

    join_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{invitation.invitation_token}"

    wait_time = PendingResponsiblePersonUser::INVITATION_TOKEN_VALID_FOR + 1
    travel_to(Time.zone.now + wait_time.seconds) do
      visit join_path
      expect(page).to have_current_path(join_path)
      expect(page).to have_css("h1", text: "This invitation has expired")
      expect(invited_user.responsible_persons).not_to include(responsible_person)
    end
  end

  scenario "accepting an invitation for an existing user" do
    sign_in invited_user

    pending = create(:pending_responsible_person_user,
                     email_address: invited_user.email.upcase,
                     responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when signed in as different user" do
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = create(:pending_responsible_person_user,
                     email_address: invited_user.email.upcase,
                     responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_css("h1", text: "You are already signed in")
    expect(page).to have_css("button", text: "Accept team invitation as John Doe")

    click_button "Accept team invitation as John Doe"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for a new user when signed in as different user" do
    # User invites a new member to the team
    sign_in_as_member_of_responsible_person(responsible_person, user)

    visit "/responsible_persons/#{responsible_person.id}/team_members"

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1
    travel_to(Time.zone.now + wait_time.seconds)

    click_on "Invite another team member"

    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
    complete_secondary_authentication_sms_with(user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/new")

    fill_in "Full name", with: "John New User"
    fill_in "Email address", with: "newusertoregister@example.com"
    click_on "Send invitation"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members")

    # Invitation gets listed
    expect(page).to have_css(
      "tr",
      text: "John New User: Awaiting confirmation newusertoregister@example.com | Resend invitation to John New User #{user.name}",
    )

    expect(delivered_emails.size).to eq 1

    email = delivered_emails.last
    expect(email.recipient).to eq "newusertoregister@example.com"
    expect(email.personalization[:responsible_person]).to eq("Responsible Person")

    # Accepting the invitation when signed in as a different user
    different_user = create(:submit_user, name: "John Doedifferent")
    sign_out
    sign_in_as_member_of_responsible_person(responsible_person, different_user)

    wait_time = SecondaryAuthentication::Operations::TIMEOUTS[SecondaryAuthentication::Operations::INVITE_USER] + 1
    travel_to(Time.zone.now + wait_time.seconds)
    visit email.personalization[:invitation_url]
    expect(page).to have_css("h1", text: "You are already signed in")

    click_button "Create a new account"

    expect(page).to have_css("h1", text: "Setup your account")
    # User name is pre-filled with name provided in the invitation
    expect(page).to have_field("Full name", with: "John New User")

    # User can change the name
    fill_in "Full name", with: "Joe Doe"
    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    expect(invited_user.responsible_persons).to include(responsible_person)
    # Updated user name from account security page
    expect(invited_user.name).to eq("Joe Doe")
  end

  scenario "accepting an invitation for a new user for second time after originally accepting it without completing the user registration" do
    pending = create(:pending_responsible_person_user,
                     email_address: "newusertoregister@example.com",
                     responsible_person: responsible_person)

    # Invited user originally accepts the invitation
    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Setup your account")

    # Abandones the service without completing its registration :(
    sign_out

    # Later, decides to follow the invitation again
    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"

    # Invitation is still valid and allows them to register and be added to the team
    expect(page).to have_current_path("/account-security")
    expect(page).to have_css("h1", text: "Setup your account")

    # User name is pre-filled with name provided in the invitation
    expect(page).to have_field("Full name", with: pending.name)

    fill_in "Create your password", with: "userpassword", match: :prefer_exact
    check "Text message"
    fill_in "Mobile number", with: "07000000000"
    click_button "Continue"

    invited_user = SubmitUser.find_by!(email: "newusertoregister@example.com")
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/declaration", ignore_query: true)
    expect(page).to have_css("h1", text: "Responsible Person Declaration")
    click_button "I confirm"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(page).to have_css("h1", text: "Your cosmetic products")

    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when not signed in" do
    pending = create(:pending_responsible_person_user,
                     email_address: invited_user.email.upcase,
                     responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=#{pending.invitation_token}"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    select_secondary_authentication_sms
    expect_to_be_on_secondary_authentication_sms_page
    expect_user_to_have_received_sms_code(invited_user.reload.direct_otp, invited_user)
    complete_secondary_authentication_sms_with(invited_user.direct_otp)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "following an invitation link with a token that does not match any invitation" do
    join_path = "/responsible_persons/#{responsible_person.id}/team_members/join?invitation_token=8cfa59f3-6b61-44f9-871b-c471651f234b"
    visit join_path

    expect(page).to have_current_path("/")
    expect(page).to have_css("h1", text: "Submit cosmetic product notifications")
    expect(page).to have_link("Sign in")
  end
end
