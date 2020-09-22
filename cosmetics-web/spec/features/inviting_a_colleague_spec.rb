require "rails_helper"

RSpec.describe "Inviting a colleague", :with_stubbed_antivirus, :with_stubbed_notify, :with_stubbed_mailer, :with_2fa, type: :feature do
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

  scenario "accepting an invitation for an existing user" do
    configure_requests_for_submit_domain
    sign_in invited_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/join"
    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end

  scenario "accepting an invitation for an existent user when signed in as different user" do
    configure_requests_for_submit_domain
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = PendingResponsiblePersonUser.create(email_address: invited_user.email,
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/join"
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
    different_user = create(:submit_user, name: "John Doedifferent")

    sign_in different_user

    pending = PendingResponsiblePersonUser.create(email_address: "newusertoregister@example.com",
                                                  responsible_person: responsible_person)

    visit "/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/join"
    expect(page).to have_css("h1", text: "You are already signed in")
    expect(page).to have_css("button", text: "Create a new account")

    click_button "Create a new account"

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/new-account")
    expect(page).to have_css("h1", text: "Create an account")

    fill_in "Full Name", with: "Joe Doe"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "newusertoregister@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

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

    visit "/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/join"
    expect(page).to have_current_path(
      new_account_responsible_person_team_member_path(responsible_person, pending),
    )
    expect(page).to have_css("h1", text: "Create an account")

    fill_in "Full Name", with: "Joe Doe"
    click_button "Continue"

    expect_to_be_on_check_your_email_page

    email = delivered_emails.last
    expect(email.recipient).to eq "newusertoregister@example.com"
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

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

    visit "/responsible_persons/#{responsible_person.id}/team_members/#{pending.id}/join"
    expect(page).to have_css("h1", text: "Sign in")

    fill_in "Email address", with: invited_user.email
    fill_in "Password", with: invited_user.password
    click_button "Continue"

    complete_secondary_authentication_for(invited_user)

    expect(page).to have_current_path("/responsible_persons/#{responsible_person.id}/notifications")
    expect(invited_user.responsible_persons).to include(responsible_person)
  end
end

def expect_to_be_on_check_your_email_page
  expect(page).to have_css("h1", text: "Check your email")
  expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")
end

def complete_secondary_authentication_for(user)
  expect_user_to_have_received_sms_code(user.reload.direct_otp, user)
  expect_to_be_on_secondary_authentication_page
  complete_secondary_authentication_with(user.direct_otp)
end
