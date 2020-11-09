require "rails_helper"

RSpec.describe "Creating an account when having pending responsible person invitations", :with_2fa, :with_stubbed_notify, :with_stubbed_mailer, type: :feature do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person2) { create(:responsible_person, :with_a_contact_person) }
  let(:invited_user_email) { "invited_user@example.com" }
  let(:user) { User.find_by(email: invited_user_email) }
  let(:inviting_user) { create(:submit_user, name: "First John Doe") }
  let(:inviting_user2) { create(:submit_user, name: "Second John Doe") }
  let(:inviting_user3) { create(:submit_user, name: "Third John Doe") }

  before do
    configure_requests_for_submit_domain
    travel_to Time.zone.local(2020, 11, 24)
  end

  after do
    travel_back
  end

  scenario "user is invited to multiple responsible persons" do
    create(:pending_responsible_person_user,
           :expired,
           email_address: invited_user_email,
           responsible_person: responsible_person,
           inviting_user: inviting_user,
           created_at: 3.days.ago)
    create(:pending_responsible_person_user,
           email_address: invited_user_email,
           inviting_user: inviting_user,
           responsible_person: responsible_person2)

    user_creates_an_account_with_invitation_email

    # User sees RP invites list showing when user is invited
    expect(page).to have_css("h1", text: "Who do you want to submit cosmetic product notifications for?")
    expect(page).to have_text(responsible_person.name)
    # Shows invitation date for active invitations
    expect(page).to have_text("Check your email inbox for your invite, sent 24 November 2020.")
    # Expired invitations show the name of the user who sent the invitation
    expect(page).to have_text(responsible_person2.name)
    expect(page).to have_text("Your invite has expired and needs to be resent. You were invited by #{inviting_user.name}.")
    # Invitations are displayed in order of most recent to oldest invite
    expect(page.body.index(responsible_person2.name)).to be < page.body.index(responsible_person.name)
    # User gets the option to create a new responsible person
    expect(page).to have_link("create a new Responsible Person", href: "/responsible_persons/account/select_type")
  end

  scenario "user is invited by multiple users to the same responsible person but all invitations have expired" do
    create(:pending_responsible_person_user,
           :expired,
           email_address: invited_user_email,
           inviting_user: inviting_user,
           responsible_person: responsible_person,
           created_at: 5.days.ago)
    create(:pending_responsible_person_user,
           :expired,
           email_address: invited_user_email,
           responsible_person: responsible_person,
           inviting_user: inviting_user2,
           created_at: 4.days.ago)
    create(:pending_responsible_person_user,
           :expired,
           email_address: invited_user_email,
           responsible_person: responsible_person,
           inviting_user: inviting_user3,
           created_at: 3.days.ago)

    user_creates_an_account_with_invitation_email
    # User sees RP invites list
    expect(page).to have_css("h1", text: "Who do you want to submit cosmetic product notifications for?")
    # Displays the invitations to the RP as a single line with all the inviting users
    expect(page).to have_text(responsible_person.name).once
    expect(page).to have_text(
      "Your invite has expired and needs to be resent. You were invited by #{inviting_user3.name}, #{inviting_user2.name} and #{inviting_user.name}.",
    )
    # User gets the option to create a new responsible person
    expect(page).to have_link("create a new Responsible Person", href: "/responsible_persons/account/select_type")
  end

  scenario "user is invited by multiple users to the same responsible person" do
    create(:pending_responsible_person_user,
           :expired,
           email_address: invited_user_email,
           inviting_user: inviting_user,
           responsible_person: responsible_person,
           created_at: 3.days.ago)
    create(:pending_responsible_person_user,
           email_address: invited_user_email,
           responsible_person: responsible_person,
           inviting_user: inviting_user2,
           created_at: 2.days.ago)
    create(:pending_responsible_person_user,
           email_address: invited_user_email,
           responsible_person: responsible_person,
           inviting_user: inviting_user3)

    user_creates_an_account_with_invitation_email
    # User sees RP invites list
    expect(page).to have_css("h1", text: "Who do you want to submit cosmetic product notifications for?")
    # Displays the invitations to the RP as a single line with the last non expired invitation date
    expect(page).to have_text(responsible_person.name).once
    expect(page).to have_text("Check your email inbox for your invite, sent 24 November 2020.")
    # User gets the option to create a new responsible person
    expect(page).to have_link("create a new Responsible Person", href: "/responsible_persons/account/select_type")
  end

  def user_creates_an_account_with_invitation_email
    visit "/"
    click_on "Create an account"
    expect(page).to have_current_path("/create-an-account")

    fill_in "Full name", with: "Joe Doe"
    fill_in "Email address", with: invited_user_email
    click_button "Continue"

    expect(page).to have_css("h1", text: "Check your email")
    expect(page).to have_css(".govuk-body", text: "A message with a confirmation link has been sent to your email address.")

    email = delivered_emails.last
    expect(email.recipient).to eq invited_user_email
    expect(email.personalization[:name]).to eq("Joe Doe")

    verify_url = email.personalization[:verify_email_url]
    visit verify_url

    fill_in "Mobile number", with: "07000000000"
    fill_in "Password", with: "userpassword", match: :prefer_exact
    click_button "Continue"

    expect_to_be_on_secondary_authentication_page
    expect_user_to_have_received_sms_code(otp_code)
    complete_secondary_authentication_with(otp_code)

    expect_to_be_on_declaration_page
    click_button "I confirm"
  end
end
